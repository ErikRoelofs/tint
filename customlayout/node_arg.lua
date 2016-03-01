return function (base, options)
  
  --[[
  
    - horizontal container
      - type
      - name
      - default
  ]]--
  
  local container = lc:build("linear", {direction = "h", width="wrap", height="wrap"})
  
  local argType = lc:build("edittext", { width = "wrap", height = "wrap", margin = lc.margin(5), textOptions = { text = "<argtype>" }, buttonOptions = {text = "."} } )
  local argName = lc:build("edittext", { width = "wrap", height = "wrap", margin = lc.margin(5), textOptions = { text = "argname" }, buttonOptions = {text = "."} } )
  --local argDefault = lc:build("edittext", { width = "wrap", height = "wrap", margin = lc.margin(5), textOptions = { text = "default" }, buttonOptions = {text = "."} } )
  
  container:addChild(argType)
  container:addChild(argName)
  --container:addChild(argDefault)
  
  container.getType = function(self)
    return self:getChild(1)
  end
  container.getName = function(self)
    return self:getChild(2)
  end
  --container.getDefault = function(self)
  --  return self:getChild(3)
  --end
  
  return container
  
end