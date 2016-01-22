function love.load(arg)
  
    if arg[#arg] == "-debug" then require("mobdebug").start() end
  
    require('string')
  
    elements = {
      {
        etype = "text",
        name = "title",
        value = "some title",
        x = 100,
        y = 100
      },
      {
        etype = "text",
        name = "text",
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
      end
    }
    
    initialMode = simpleCommandMode(inputHandler)
    inputHandler:setCommand(initialMode)
    
end

function simpleCommandMode(inputHandler)
  local delegates = {
    c = editTextMode(inputHandler),
    t = editTitleMode(inputHandler)
  }
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
      
    end
  }
end

function editTextMode(inputHandler)
  return {
    handleText = function(self, text)
      append('text', text)
    end,
    handleSpecial = function(self, special)
      if special == "backspace" then
        backspace('text')
      end
    end
  }
end

function editTitleMode(inputHandler)
  return {
    handleText = function(self, text)
      append('title', text)
    end,
    handleSpecial = function(self, special)
      if special == "backspace" then
        backspace('title')
      end
    end
  }
end

function love.update(dt)

end

function love.draw()
  for k, v in ipairs(elements) do
    love.graphics.printf(v.value, v.x, v.y, love.graphics.getWidth())
  end  
end

function love.keypressed(key, unicode)
  if key == "escape" then
    inputHandler:abort()
  end
  if key == "backspace" then
    inputHandler:handleSpecial("backspace")
  end
end

function love.keyreleased(key)

end

function love.textinput(t)  
  inputHandler:handleText(t)
end

function currentItem()  
end

function append(element, text)
  element.value = element.value .. text  
end

function backspace(element)
  element.value = string.sub( element.value, 1, string.len( element.value ) - 1)
end

function newItem()
  return {
    title = 'Some title',
    text = 'Some text'
  }
end