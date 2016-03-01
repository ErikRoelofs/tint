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
        self.currentCommand:unpause()
      end,
      replaceCommand = function(self, command)
        self.currentCommand:pause()
        self.currentCommand:unset()        
        self.currentCommand = command        
        self.currentCommand:set()
        self.currentCommand:unpause()
      end,
      endCommand = function(self)
        self.currentCommand:pause()
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
    
    initialMode = commandMode(inputHandler, determineDelegates())
    inputHandler:addCommand(initialMode)
    
end

function determineDelegates()
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
  return delegates
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
        inputHandler:replaceCommand(editTextMode(self.handler, element))
      end
    end,
    set = function(self)
    end,
    unset = function(self)
    end,
    pause = function(self)
      for k, v in pairs(self.delegates) do        
        v.element:setCommandKey(nil)
      end      
    end,
    unpause = function(self)
      self.delegates = determineDelegates()
      for k, v in pairs(self.delegates) do
        v.element:setCommandKey(k)
      end      
    end
  }
end

function editTextMode(inputHandler, linkedElement)  
  return {
    handler = inputHandler,
    element = linkedElement,
    handleText = function(self, text)
      self.element:append(text)
    end,
    handleSpecial = function(self, special)
      if special == "backspace" then
        self.element:backspace()
      end
      if special == "return" then
        local addAfter = findPosition(self.element) + 1
        local element = newItem(addAfter)
        inputHandler:replaceCommand(editTextMode(self.handler, element))
      end
    end,
    set = function(self)
      
    end,
    unset = function(self)
      
    end,
    pause = function(self)
      self.element:setCommandKey(nil)
    end,
    unpause = function(self)
      self.element:setCommandKey(">")
    end
  }
end

function functionEditMode(inputHandler, linkedElement)
  return {
    handler = inputHandler,
    element = linkedElement,
    handleText = function(self, text)
      if text == "q" then        
        self.handler:addCommand(editTextMode(self.handler, self.element:getReturnType()))
      elseif text == "w" then        
        self.handler:addCommand(editTextMode(self.handler, self.element:getTitle()))
      end      
      -- logic
    end,
    handleSpecial = function(self, special)
      -- logic
    end,
    set = function(self)
    end,
    unset = function(self)
    end,
    pause = function(self)
      self.element:setCommandKey(nil)
      self.element:getReturnType():setCommandKey(nil)
      self.element:getTitle():setCommandKey(nil)      
    end,
    unpause = function(self)
      self.element:setCommandKey(">")      
      self.element:getReturnType():setCommandKey("q")
      self.element:getTitle():setCommandKey("w")      
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