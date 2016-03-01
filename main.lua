--[[
  clear text command
  add/delete args
  vartype instead of edittext
  variable output rendering
]]

lastId = 0
function newId()
  lastId = lastId + 1
  return lastId
end  

function workspace()
  return root.linear:getChild(1):getChild(1)
end

function commandPane()
  return root.linear:getChild(1):getChild(2)
end

function love.load(arg)
  
    if arg[#arg] == "-debug" then debug = true else debug = false end
    if debug then require("mobdebug").start() end
    io.stdout:setvbuf("no") 
    
    font = love.graphics.newFont()
  
    lc = require "load"
    lc:register("edittext", require "customlayout/edittext")
    lc:register("commandbutton", require "customlayout/commandbutton")
    lc:register("button", require "customlayout/button")
    lc:register("node_function", require "customlayout/node_function")
    lc:register("node_args", require "customlayout/node_args")
    lc:register("node_arg", require "customlayout/node_arg")
    
    local mainContainer = lc:build("linear", { direction="h", width="fill", height="fill", margin = lc.margin(0)} )
  
    root = lc:build("root", {})
    root:addChild(mainContainer)    
    mainContainer:addChild(lc:build("linear", { direction="v", width="fill", height="fill", margin = lc.margin(20), weight = 3} ) )
    mainContainer:addChild(lc:build("linear", { direction="v", width="fill", height="fill", margin = lc.margin(20)} ) )
    
    root:layoutingPass()
    
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
  for k, v in ipairs(workspace().children) do
    local mode = nil
    if v.etype == "text" then
      mode = editTextMode(inputHandler, v, true)
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
      for k, v in pairs(self.delegates) do
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

function editTextMode(inputHandler, linkedElement, allowNewlines)  
  return {
    handler = inputHandler,
    element = linkedElement,
    allowNewlines = allowNewlines,
    handleText = function(self, text)
      self.element:append(text)
    end,
    handleSpecial = function(self, special)
      if special == "backspace" then
        self.element:backspace()
      end
      if special == "return" and self.allowNewlines then
        local addAfter = findPosition(self.element) + 1
        local element = newItem(addAfter)
        inputHandler:replaceCommand(editTextMode(self.handler, element))
      end
      if special == "f1" then
        self.element:clear()
      end
    end,
    set = function(self)
      
    end,
    unset = function(self)
      
    end,
    pause = function(self)
      self.element:setCommandKey(nil)
      commandPane():removeChild(1)
    end,
    unpause = function(self)
      self.element:setCommandKey(">")
      commandPane():addChild(lc:build("commandbutton", {width="wrap", height="wrap", textOptions = {text = 'clear'}, buttonOptions = {text = 'f1'}}))
      root:layoutingPass()
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
      elseif text == "e" then
        self.handler:addCommand(argsMode(self.handler, self.element:getArgs()))
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
      self.element:getArgs():setCommandKey(nil)
    end,
    unpause = function(self)
      self.element:setCommandKey(">")      
      self.element:getReturnType():setCommandKey("q")
      self.element:getTitle():setCommandKey("w")      
      self.element:getArgs():setCommandKey("e")
    end
  }
end

function argsMode(inputHandler, linkedElement)
  return {
    handler = inputHandler,
    element = linkedElement,
    handleText = function(self, text)
      self.handler:addCommand( editTextMode( self.handler, self.delegates[text] ) )
    end,
    handleSpecial = function(self, special)
    end,
    set = function(self)
    end,
    unset = function(self)
    end,
    pause = function(self)
      for k, v in ipairs(self.element:getArgsList()) do
        v:getType():setCommandKey(nil)
        v:getName():setCommandKey(nil)
      end
    end,
    unpause = function(self)      
      self:setupDelegates()
    end,
    delegates = {},  
    setupDelegates = function(self)
      self.currentKey = 0
      for k, v in ipairs(self.element:getArgsList()) do
        local key = self:nextKey()
        v:getType():setCommandKey(key)
        self.delegates[key] = v:getType()
        
        local key = self:nextKey()
        v:getName():setCommandKey(key)
        self.delegates[key] = v:getName()
      end
    end,
    keys = { 'q', 'w', 'e', 'r', 't' , 'y', 'u', 'i', 'o', 'p' },
    currentKey = 0,
    nextKey = function(self)
      self.currentKey = self.currentKey + 1
      return self.keys[self.currentKey]
    end
  }
end


function love.update(dt)

end

function love.draw()
  root:layoutingPass()
  root:render()  
  if debug then
    love.graphics.setColor(255,255,255,255)
    love.graphics.print(keyname, 0,0)
  end
end

keyname = ''
function love.keypressed(key, unicode)
  if key == "escape" then
    inputHandler:abort()
  end
  inputHandler:handleSpecial(key)
  keyname = key
end

function love.keyreleased(key)

end

function love.textinput(t)  
  inputHandler:handleText(t)
end

function newItem(addAt)
  addAt = addAt or #(workspace().children) + 1
  local view = lc:build("edittext", { width = "wrap", height = "wrap", margin = lc.margin(5), textOptions = { text = "newline" }, buttonOptions = {text = "."} } )
  workspace():addChild(view, addAt)  
  return view
end

function newFunctionItem(addAt)
  addAt = addAt or #(workspace().children) + 1
  
  local view = lc:build("node_function", { width = "wrap", height = "wrap", margin = lc.margin(5), textOptions = { text = "this is a function" }, buttonOptions = {text = "."} } )
  workspace():addChild(view, addAt)
  return view
end

function findPosition(element)
  for k, v in ipairs( workspace().children ) do
    if v == element then
      return k
    end
  end    
end