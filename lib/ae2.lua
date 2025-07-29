local component = require("component")
local MEController = component.isAvailable("me_controller") and component.me_controller or nil

local ae2 = {}

--- Получить статистику занятости CPU
-- @return table { busy = number, idle = number, total = number }
function ae2.getCPUStats()
  if not MEController then
    return { busy = 0, idle = 0, total = 0 }
  end

  -- Безопасно получить список CPU
  local ok, cpus = pcall(MEController.getCpus, MEController)
  if not ok or type(cpus) ~= "table" then
    return { busy = 0, idle = 0, total = 0 }
  end

  local stats = { busy = 0, idle = 0 }
  for _, cpu in ipairs(cpus) do
    if cpu.busy then
      stats.busy = stats.busy + 1
    else
      stats.idle = stats.idle + 1
    end
  end
  stats.total = #cpus

  return stats
end

return ae2
