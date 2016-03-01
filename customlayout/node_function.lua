return function (base, options)
  
  --[[
  
    - vertical container
      - horizontal container
        - command button
        - edittext (return type)
        - text (function keyword)
        - edittext (function title)
        - args
    - horizontal container
      - body
  ]]--
  
  local container = lc:build("linear", {direction = "v", width="wrap", height="wrap"})
  local headerContainer = lc:build("linear", {direction = "h", width="wrap", height="wrap"})
  local returnType = lc:build("edittext", { width = "wrap", height = "wrap", margin = lc.margin(5), textOptions = { text = "<returntype>" }, buttonOptions = {text = "."} } )
  local functionTitle = lc:build("edittext", { width = "wrap", height = "wrap", margin = lc.margin(5), textOptions = { text = "<title>" }, buttonOptions = {text = "."} } )
  local functionKeyword = lc:build("text", { width = "wrap", height = "wrap", margin = lc.margin(5), text = "FUNCTION" } )
  --local functionArgs = lc:build("text",{ width = "wrap", height = "wrap", margin = lc.margin(5), text = "ARGS" } )
  local functionArgs = lc:build("node_args",{} )
  local button = lc:build("button", { width = "wrap", height = "wrap", margin = lc.margin(5), text = "." } )
  
  headerContainer:addChild(button)
  headerContainer:addChild(returnType)
  headerContainer:addChild(functionKeyword)
  headerContainer:addChild(functionTitle)
  headerContainer:addChild(functionArgs)
  
  local bodyContainer = lc:build("linear", {direction = "h", width="wrap", height="wrap", backgroundColor={30,30,30,255}})
  
  local body = lc:build("text",{ width = "wrap", height = "wrap", margin = lc.margin(5), text = "FUNCTION BODY" } )
  
  bodyContainer:addChild(body)
  
  container:addChild(headerContainer)
  container:addChild(bodyContainer)
  
  container.setCommandKey = function(self, k)
    if k == nil then
      k = "."
    end
    container:getChild(1):getChild(1).text = k
  end

  container.id = newId()
  container.etype = "function"

  container.getReturnType = function(self)
    return self:getChild(1):getChild(2)
  end
  
  container.getTitle = function(self)
    return self:getChild(1):getChild(4)
  end

  container.getArgs = function(self)
    return self:getChild(1):getChild(5)
  end

  return container
  
end