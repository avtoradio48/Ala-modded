local component = require("component")
local MEController =
  component.isAvailable("me_controller")
  and component.me_controller
  or nil

local ae2 = {}

-- Returns table { busy, idle, total }
function ae2.getCPUStats()
  if not MEController then
    return { busy = 0, idle = 0, total = 0 }
  end

  local ok, processors = pcall(MEController.getCpus, MEController)
  if not ok or type(processors) ~= "table" then
    return { busy = 0, idle = 0, total = 0 }
  end

  local stats = { busy = 0, idle = 0 }
  for _, cpu in ipairs(processors) do
    if cpu.busy then
      stats.busy = stats.busy + 1
    else
      stats.idle = stats.idle + 1
    end
  end
  stats.total = #processors

  return stats
end

return ae2
