return function (base, options)
  local baseOptions = {direction = "h", width = options.width, height = options.height}
  local containerOptions = lc.mergeOptions(baseOptions, options)
  local container = lc:build("linear", containerOptions)  
  
  baseOptions = {width="wrap", height="wrap", backgroundColor = {50,100,50,255}, textColor={255,255,255,255}}
  local textMerged = lc.mergeOptions(baseOptions, options.textOptions or {})
  
  baseOptions = {width="wrap", height="wrap", backgroundColor = {50,100,50,255}, textColor={255,255,255,255}}
  local buttonMerged = lc.mergeOptions(baseOptions, options.buttonOptions or {})
  
  container:addChild( lc:build( "button", buttonMerged ))
  container:addChild( lc:build( "text", textMerged ))
  container.setCommandKey = function(self, k)
    if k == nil then
      k = "."
    end
    container:getChild(1).text = k
  end
  
  container.id = newId()
  container.etype = "text"
  
  container.append = function (self, text)
    self:getChild(2).text = self:getChild(2).text .. text    
  end

  container.backspace = function (self)
    self:getChild(2).text = string.sub( self:getChild(2).text, 1, string.len( self:getChild(2).text ) - 1)
  end

  container.clear = function(self)
    self:getChild(2).text = ''
  end
  
  return container
end