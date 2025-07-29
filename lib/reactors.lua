local component = require("component")
local reactors = {}

-- Retrieve all Big Reactors stats
function reactors.getAll()
  local list = {}
  for addr in component.list("br_reactor") do
    local proxy = component.proxy(addr)
    table.insert(list, {
      id      = addr,
      temp    = proxy.getHotFluidTemperature(),
      output  = proxy.getEnergyProducedLastTick()
    })
  end
  return list
end

return reactors
