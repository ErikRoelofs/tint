lastId = 0
function newId()
  lastId = lastId + 1
  return lastId
end  

function love.load(arg)
  
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    io.stdout:setvbuf("no") 
  
    require('string')
  
    elements = {
      {
        id = newId(),
        etype = "text",
        value = "some title",
      },
      {
        id = newId(),
        etype = "text",
        value = "some text",
      }
    }
    
    renderer = {
      basex = 100,
      basey = 75,

      renderElements = function(self, elements)
        for k, v in ipairs(elements) do
          love.graphics.printf(v.value, self.basex, self.basey + 25*k, love.graphics.getWidth())
        end  
      end,
      renderButton = function(self, buttonKey, element)
        for k, v in ipairs(elements) do
          if element.id == v.id then
            drawButton(self.basex - 40, self.basey + 25*k, buttonKey)
          end
        end          
      end,
      renderTextHighlight = function(self, element)
        for k, v in ipairs(elements) do
          if element.id == v.id then
            drawTextHighlight(self.basex - 40, self.basey + 25*k)
          end
        end          
      end
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
        renderer:renderButton(k, v.element)
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
        local element = newItem()
        inputHandler:setCommand(editTextMode(self.handler, element))
      end
    end,
    render = function(self)
      renderer:renderTextHighlight(self.element)
    end
  }
end

function love.update(dt)

end

function love.draw()
  renderer:renderElements(elements)
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
    id = newId(),
    etype = "text",
    value = "newline",
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

