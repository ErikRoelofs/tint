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
  
  container.setCommandKey = function(self, k)
    if k == nil then
      k = "."
    end
    container:getChild(1).text = k
  end
  
  container.argsList = {
    container:getChild(2)
  }
  
  container.getArgsList = function(self)
    return self.argsList
  end

  container.addOne = function(self)
    local child = lc:build("node_arg", {})
    container:addChild(child)
    table.insert(self.argsList, child)
  end
  
  container.removeOne = function(self, toRemove)
    local index
    for k, v in ipairs(self.argsList) do
      if toRemove == v then
        table.remove(self.argsList, k)        
        index = k
        break
      end
    end
    self:removeChild(index+1)
  end
  
  return container
  
end