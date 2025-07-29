local component = require("component")

local flux = {}

-- Retrieve Flux Network energy storage status
function flux.getStatus()
  local net = component.flux_network or component.fluxnet
  if not net then return { current = 0, max = 0 } end
  return {
    current = net.getEnergyStored(),
    max     = net.getEnergyCapacity()
  }
end

return flux
