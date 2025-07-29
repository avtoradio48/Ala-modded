-- lib/ae2.lua
-- AE2 statistics library using MEController.getCpus()

local component = require("component")
local MEController = component.isAvailable("me_controller") and component.me_controller or nil

local ae2 = {}

-- Retrieve detailed MEController statistics
-- Returns table: { processors = { {id, busy, status}, ... }, stats = { idle, busy }, total = number }
function ae2.getMEControllerStats()
  if not MEController then
    return { processors = {}, stats = { idle = 0, busy = 0 }, total = 0 }
  end
  
  -- Attempt to get raw CPU list
  local ok, processors = pcall(function() return MEController.getCpus() end)
  if not ok or type(processors) ~= "table" then
    return { processors = {}, stats = { idle = 0, busy = 0 }, total = 0 }
  end

  local cpuStats = { idle = 0, busy = 0 }
  local processorsData = {}

  for i = 1, #processors do
    local entry = processors[i]
    local isWorking = entry.busy or false
    local status = isWorking and "В работе" or "Свободен"
    table.insert(processorsData, {
      id     = i,
      busy   = isWorking,
      status = status
    })
    if isWorking then
      cpuStats.busy = cpuStats.busy + 1
    else
      cpuStats.idle = cpuStats.idle + 1
    end
  end

  return {
    processors = processorsData,
    stats      = cpuStats,
    total      = #processors
  }
end

return ae2
