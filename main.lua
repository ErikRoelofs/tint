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
  
    lc = require "renderer/load"
    lc:register("edittext", require "customlayout/edittext")
    lc:register("button", require "customlayout/button")
  
    root = lc:build("root", {})
    root:addChild(lc:build("linear", { direction="v", width="fill", height="wrap", margin = lc.margin(100)} ) )
    require('string')
  
    elements = {}    
    newItem()
    newItem()
  
    root:layoutingPass()
    
    inputHandler = {
      setCommand = function(self, command)
        self.activeCommand = command        
      end,
      handleText = function(self, text)
        self.activeCommand:handleText(text)
      end,
      handleSpecial = function(self, special)      
        self.activeCommand:handleSpecial(special)
      end,      
      abort = function(self)
        self.activeCommand = simpleCommandMode(self)
      end,
      render = function(self)
        self.activeCommand:render()
      end
    }
    
    initialMode = simpleCommandMode(inputHandler)
    inputHandler:setCommand(initialMode)
    
end

function simpleCommandMode(inputHandler)
  local inputs = { 'q', 'w', 'e', 'r', 't' , 'y', 'u', 'i', 'o', 'p' }
  local delegates = {}
  for k, v in ipairs(elements) do
    delegates[inputs[k]] = editTextMode(inputHandler, v)
  end
  return commandMode(inputHandler, delegates)
end

function commandMode(inputHandler, delegates)
  return {
    handler = inputHandler,
    handleText = function(self, text)
      for k, v in pairs(delegates) do
        if text == k then
          inputHandler:setCommand(v)
        end
      end     
    end,
    handleSpecial = function(self, special)
      if special == "return" then
        element = newItem()
        inputHandler:setCommand(editTextMode(self.handler, element))
      end
    end,
    setButtons = function()
      
    end,
    render = function()
      for k, v in pairs(delegates) do        
        v.element.view:getChild(1).text = k
      end
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
        inputHandler:setCommand(editTextMode(self.handler, element))
      end
    end,
    render = function(self)
      self.element.view:getChild(1).text = ">"
    end
  }
end

function love.update(dt)

end

function love.draw()
  inputHandler:render()
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
  element.view:getChild(2).text = element.view:getChild(2).text .. text    
end

function backspace(element)
  element.view:getChild(2).text = string.sub( element.view:getChild(2).text, 1, string.len( element.view:getChild(2).text ) - 1)
end

function newItem(addAt)
  addAt = addAt or #elements + 1
  local item = {
    id = newId(),
    etype = "text",    
    view = lc:build("edittext", { width = "wrap", height = "wrap", margin = lc.margin(5), textOptions = { text = "newline" }, buttonOptions = {text = "."} } ),    
  }

  root:getChild(1):addChild(item.view)
  root:layoutingPass()
  table.insert(elements, addAt, item)
  return item
end

function findPosition(element)
  for k, v in ipairs(elements) do
    if v.id == element.id then
      return k
    end
  end
end