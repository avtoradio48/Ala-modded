local component = require("component")
local me = component.isAvailable("me_controller") and component.me_controller or nil

local ae2 = {}

-- Retrieve AE2 CPU statistics from the MEController
function ae2.getCPUs()
  local cpus = {}
  if not me then
    return cpus
  end

  -- Check available methods
  local hasCount = type(me.getCPUCount) == "function"
  local hasInfo  = type(me.getCPUInfo)  == "function"
  if not hasInfo then
    return cpus
  end

  if hasCount then
    -- Use getCPUCount if available
    local ok, count = pcall(me.getCPUCount, me)
    if ok and type(count) == "number" then
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
    end
  else
    -- Fallback: iterate until getCPUInfo fails
    local i = 0
    while true do
      local ok2, info = pcall(me.getCPUInfo, me, i)
      if not ok2 or type(info) ~= "table" then break end
      table.insert(cpus, {
        name   = info.name   or ("cpu" .. i),
        busy   = info.busy   or 0,
        total  = info.total  or 0,
        stored = info.stored or 0,
      })
      i = i + 1
    end
  end

  return cpus
end

return ae2
