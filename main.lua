function love.load(arg)
  
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    io.stdout:setvbuf("no") 
  
    require('string')
  
    elements = {
      {
        etype = "text",
        value = "some title",
        x = 100,
        y = 100
      },
      {
        etype = "text",
        value = "some text",
        x = 100,
        y = 125
      }
    }
          
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
        drawButton(v.element.x - 40, v.element.y, k)
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
        element = newItem()
        inputHandler:setCommand(editTextMode(self.handler, element))
      end
    end,
    render = function(self)
      drawTextHighlight(self.element.x - 40, self.element.y)
    end
  }
end

function love.update(dt)

end

function love.draw()
  for k, v in ipairs(elements) do
    love.graphics.printf(v.value, v.x, v.y, love.graphics.getWidth())
  end  
  inputHandler:render()
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
  element.value = element.value .. text  
end

function backspace(element)
  element.value = string.sub( element.value, 1, string.len( element.value ) - 1)
end

function newItem()
  local key = #elements + 1
  elements[key] = {
    etype = "text",
    value = "newline",
    x = 100,
    y = 75 + 25*key
  }
  return elements[key]
end

function drawButton(x,y,key)
  love.graphics.setColor(255,255,255)
  love.graphics.rectangle("fill", x, y, 20, 20)
  love.graphics.setColor(255,0,0)
  love.graphics.print(key,  x+5, y+5)
  love.graphics.setColor(255,255,255)
end

function drawTextHighlight(x,y)
  love.graphics.print(">>", x, y)
end