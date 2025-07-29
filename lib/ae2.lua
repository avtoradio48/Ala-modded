local component = require("component")
local me = component.me_controller

local ae2 = {}

-- Retrieve AE2 CPU statistics from the me_controller
function ae2.getCPUs()
  local cpus = {}
  if not me then
    return cpus
  end

  -- Ensure methods exist
  if type(me.getCPUCount) ~= "function" or type(me.getCPUInfo) ~= "function" then
    return cpus
  end

  -- Attempt to get CPU count
  local ok, count = pcall(me.getCPUCount, me)
  if not ok or type(count) ~= "number" then
    return cpus
  end

  -- Collect info for each CPU
  for i = 0, count - 1 do
    local ok2, info = pcall(me.getCPUInfo, me, i)
    if ok2 and type(info) == "table" then
      table.insert(cpus, {
        name   = info.name   or ("cpu" .. i),
        busy   = info.busy   or 0,
        total  = info.total  or 0,
        stored = info.stored or 0,
      })
    end
  end

  return cpus
end

return ae2
