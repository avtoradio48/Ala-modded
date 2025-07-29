local component = require("component")
local event     = require("event")
local term      = require("term")
local os        = require("os")

-- External libraries
local sgui     = require("sgui")
local ae2      = require("ae2")
local fluxnet  = require("flux")
local reactors = require("reactors")
local players  = require("players")
local influx   = require("influx")

-- Configuration
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
  -- AE2 CPU metrics
  local cpus = ae2.getCPUs()
  for _, cpu in ipairs(cpus) do
    influx.send(
      "ae2_cpu",
      { cpu = cpu.name },
      { busy = cpu.busy, total = cpu.total, stored = cpu.stored }
    )
  end
  sgui.drawPanel("AE2 CPUs", cpus)

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
  for _, r in ipairs(reactorList) do
    influx.send(
      "reactor",
      { reactor = r.id },
      { temperature = r.temp, power_output = r.output }
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
