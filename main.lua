lastId = 0
function newId()
  lastId = lastId + 1
  return lastId
end  

function love.load(arg)
  
    if arg[#arg] == "-debug" then debug = true else debug = false end
    if debug then require("mobdebug").start() end
    io.stdout:setvbuf("no") 
    
    font = love.graphics.newFont()
  
    lc = require "load"
    lc:register("edittext", require "customlayout/edittext")
    lc:register("button", require "customlayout/button")
    lc:register("node_function", require "customlayout/node_function")
    
  
    root = lc:build("root", {})
    root:addChild(lc:build("linear", { direction="v", width="fill", height="wrap", margin = lc.margin(100)} ) )
    require('string')
          
    newItem()
    newFunctionItem()
    newItem()
    newFunctionItem()
    newItem()
  
    
    inputHandler = {
      pausedCommands = {},
      currentCommand = { set = function() end, pause = function() end, unpause = function() end, unset = function() end},
      addCommand = function(self, command)
        self.currentCommand:pause()
        table.insert(self.pausedCommands, self.currentCommand)
        self.currentCommand = command        
        self.currentCommand:set()
      end,
      endCommand = function(self)
        self.currentCommand:unset()
        self.currentCommand = self.pausedCommands[#self.pausedCommands]
        self.currentCommand:unpause()
        table.remove(self.pausedCommands)
      end,
      handleText = function(self, text)
        self.currentCommand:handleText(text)
      end,
      handleSpecial = function(self, special)      
        self.currentCommand:handleSpecial(special)
      end,      
      abort = function(self)
        if #self.pausedCommands > 1 then
          self:endCommand()
        end
      end,      
    }
    
    initialMode = simpleCommandMode(inputHandler)
    inputHandler:addCommand(initialMode)
    
end

function simpleCommandMode(inputHandler)
  local inputs = { 'q', 'w', 'e', 'r', 't' , 'y', 'u', 'i', 'o', 'p' }
  local delegates = {}
  for k, v in ipairs(root.linear:getChild(1).children) do
    local mode = nil
    if v.etype == "text" then
      mode = editTextMode(inputHandler, v)
    elseif v.etype == "function" then
      mode = functionEditMode(inputHandler, v)    
    end
    delegates[inputs[k]] = mode
  end
  return commandMode(inputHandler, delegates)
end

function commandMode(inputHandler, delegates)
  return {
    delegates = delegates,
    handler = inputHandler,
    handleText = function(self, text)
      for k, v in pairs(delegates) do
        if text == k then
          inputHandler:addCommand(v)
        end
      end     
    end,
    handleSpecial = function(self, special)
      if special == "return" then
        element = newItem()
        inputHandler:addCommand(editTextMode(self.handler, element))
      end
    end,
    set = function(self)
      for k, v in pairs(self.delegates) do
        v.element:setCommandKey(k)
      end
    end,
    unset = function(self)
      for k, v in pairs(self.delegates) do        
        v.element:setCommandKey(nil)
      end
    end,
    pause = function(self)
      
    end,
    unpause = function(self)
      
    end
  }
end

function editTextMode(inputHandler, linkedElement)  
  return {
    handler = inputHandler,
    element = linkedElement,
    handleText = function(self, text)
      append(linkedElement, text)
    end,
    handleSpecial = function(self, special)
      if special == "backspace" then
        backspace(linkedElement)
      end
      if special == "return" then
        local addAfter = findPosition(self.element) + 1
        local element = newItem(addAfter)
        inputHandler:addCommand(editTextMode(self.handler, element))
      end
    end,
    set = function(self)
      self.element:getChild(1).text = ">"
    end,
    unset = function(self)
      self.element:getChild(1).text = "."
    end,
    pause = function(self)
      
    end,
    unpause = function(self)
      
    end
  }
end

function functionEditMode(inputHandler, linkedElement)
  return {
    handler = inputHandler,
    element = linkedElement,
    handleText = function(self, text)
      if text == "q" then        
        self.handler:addCommand(editTextMode(self.handler, self.element:getChild(1):getChild(2)))
      elseif text == "w" then        
        self.handler:addCommand(editTextMode(self.handler, self.element:getChild(1):getChild(4)))
      end
      --assert(false, "not implemented")
      -- logic
    end,
    handleSpecial = function(self, special)
      -- logic
    end,
    set = function(self)
      self.element:setCommandKey(">")      
      self.element:getChild(1):getChild(2):setCommandKey("q")
      self.element:getChild(1):getChild(4):setCommandKey("w")
    end,
    unset = function(self)
      self.element:setCommandKey(nil)
      self.element:getChild(1):getChild(2):setCommandKey(nil)
      self.element:getChild(1):getChild(4):setCommandKey(nil)
    end,
    pause = function(self)
      
    end,
    unpause = function(self)
      
    end
  }
end

function love.update(dt)

end

function love.draw()
  root:layoutingPass()
  root:render()  
end

function love.keypressed(key, unicode)
  if key == "escape" then
    inputHandler:abort()
  end
  if key == "backspace" then
    inputHandler:handleSpecial("backspace")
  end
  if key == "return" then
    inputHandler:handleSpecial("return")
  end
end

function love.keyreleased(key)

end

function love.textinput(t)  
  inputHandler:handleText(t)
end

function append(element, text)
  element:getChild(2).text = element:getChild(2).text .. text    
end

function backspace(element)
  element:getChild(2).text = string.sub( element:getChild(2).text, 1, string.len( element:getChild(2).text ) - 1)
end

function newItem(addAt)
  addAt = addAt or #root.linear:getChild(1).children + 1
  local view = lc:build("edittext", { width = "wrap", height = "wrap", margin = lc.margin(5), textOptions = { text = "newline" }, buttonOptions = {text = "."} } )
  root:getChild(1):addChild(view, addAt)  
  return view
end

function newFunctionItem(addAt)
  addAt = addAt or #root.linear:getChild(1).children + 1
  
  local view = lc:build("node_function", { width = "wrap", height = "wrap", margin = lc.margin(5), textOptions = { text = "this is a function" }, buttonOptions = {text = "."} } )
  root:getChild(1):addChild(view, addAt)
  return view
end

function findPosition(element)
  for k, v in ipairs( root:getChild(1).children ) do
    if v == element then
      return k
    end
  end    
end