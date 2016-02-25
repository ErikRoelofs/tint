return function(base, options)
  if not options.border then
    options.border = { color = { 100, 100, 100, 255 }, thickness = 3 }
  end
  options.padding = lc.padding(5)
  return lc:build("text", options )
end