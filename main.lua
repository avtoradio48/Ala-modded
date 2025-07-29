local component = require("component")
local event     = require("event")
local term      = require("term")
local os        = require("os")

local sgui     = require("sgui")
local ae2      = require("ae2")
local fluxnet  = require("flux")
local reactors = require("reactors")
local players  = require("players")
local influx   = require("influx")

local UPDATE_INTERVAL = 5 -- seconds between updates

-- Setup screen and GPU for 160×50 terminal
if component.gpu and component.screen then
  component.gpu.setResolution(160, 50)
  term.clear()
end

-- Initialize GUI panels
sgui.init()
sgui.createPanel("AE2 CPUs",     1,  1, 80, 10)
sgui.createPanel("Flux Network", 1, 12, 80, 10)
sgui.createPanel("Reactors",     81, 1, 80, 10)
sgui.createPanel("Players",      81, 12, 80, 10)

-- Main loop
while true do
  -- AE2 CPU stats
  local stats = ae2.getCPUStats()
  influx.send(
    "ae2_cpu",
    {},
    { busy = stats.busy, idle = stats.idle, total = stats.total }
  )
  sgui.drawPanel("AE2 CPUs", stats)

  -- Flux Network metrics
  local fluxData = fluxnet.getStatus()
  influx.send(
    "flux_network",
    {},
    { energy_current = fluxData.current, energy_max = fluxData.max }
  )
  sgui.drawPanel("Flux Network", fluxData)

  -- Reactor metrics
  local reactorList = reactors.getAll()
  for _, reactor in ipairs(reactorList) do
    influx.send(
      "reactor",
      { reactor = reactor.id },
      { temperature = reactor.temp, power_output = reactor.output }
    )
  end
  sgui.drawPanel("Reactors", reactorList)

  -- Player activity metrics
  local tracked = players.getTracked()
  for _, p in ipairs(tracked) do
    influx.send(
      "player_activity",
      { player = p.name },
      { online = p.online and 1 or 0 }
    )
  end
  sgui.drawPanel("Players", tracked)

  -- Wait before next update
  os.sleep(UPDATE_INTERVAL)
end
