local component = require("component")

local ae2 = {}

-- Retrieve AE2 CPU statistics
function ae2.getCPUs()
  local cpus = {}
  local me = component.me_controller or component.me_interface or component.me
  if not me then return cpus end
  local count = me.getCPUCount()
  for i = 0, count - 1 do
    local info = me.getCPUInfo(i)
    table.insert(cpus, {
      name   = info.name or ("cpu" .. i),
      busy   = info.busy,
      total  = info.total,
      stored = info.stored
    })
  end
  return cpus
end

return ae2
