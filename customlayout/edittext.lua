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
  return container
end