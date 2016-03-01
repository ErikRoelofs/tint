return function (base, options)
  
  --[[
  
    - horizontal container
      - arg1
      - arg2
      - arg3
  ]]--
  
  local container = lc:build("linear", {direction = "h", width="wrap", height="wrap"})
  
  baseOptions = {width="wrap", height="wrap", backgroundColor = {50,100,50,255}, textColor={255,255,255,255}, text = ".", margin = lc.margin(5)}
  local buttonMerged = lc.mergeOptions(baseOptions, options.buttonOptions or {})

  container:addChild( lc:build( "button", buttonMerged ))
  
  container:addChild(lc:build("node_arg", {}))
  container:addChild(lc:build("node_arg", {}))
  
  container.setCommandKey = function(self, k)
    if k == nil then
      k = "."
    end
    container:getChild(1).text = k
  end
  
  container.argsList = {
    container:getChild(2),
    container:getChild(3)
  }
  
  container.getArgsList = function(self)
    return self.argsList
  end

  
  return container
  
end