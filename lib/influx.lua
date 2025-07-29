local component = require("component")
local internet = component.internet

local _M = {}

-- Configure your InfluxDB connection here
local INFLUX_HOST = "94.159.105.250"
local INFLUX_PORT = 8086
local INFLUX_DB   = "oc_metrics"
local WRITE_URL   = string.format("http://%s:%d/write?db=%s", INFLUX_HOST, INFLUX_PORT, INFLUX_DB)

-- Send a raw line-protocol payload to InfluxDB
function _M.sendLine(line)
  if not internet then
    error("InfluxDB: internet card not available")
  end
  local h = internet.request(WRITE_URL, line, { ["Content-Type"] = "text/plain" })
  -- Drain the response (avoid hanging)
  for _ in h do end
end

-- Format a measurement in Line Protocol, with optional timestamp
-- measurement: string, tags: table k=v, fields: table k=v, timestamp: nanoseconds optional number
function _M.format(measurement, tags, fields, timestamp)
  -- Build tags
  local tagParts = {}
  for k, v in pairs(tags or {}) do
    table.insert(tagParts, string.format('%s=%s', k, tostring(v)))
  end
  local tagStr = #tagParts > 0 and ',' .. table.concat(tagParts, ',') or ''

  -- Build fields
  local fieldParts = {}
  for k, v in pairs(fields or {}) do
    local val = v
    if type(v) == 'string' then
      val = '"' .. v:gsub('"','\\"') .. '"'
    elseif type(v) == 'boolean' then
      val = v and 'true' or 'false'
    elseif type(v) == 'number' and math.type and math.type(v) == 'integer' then
      val = tostring(v) .. 'i'
    else
      val = tostring(v)
    end
    table.insert(fieldParts, string.format('%s=%s', k, val))
  end
  local fieldStr = table.concat(fieldParts, ',')

  -- Compose final line
  local lp = measurement .. tagStr .. ' ' .. fieldStr
  if timestamp then
    lp = lp .. ' ' .. tostring(timestamp)
  end
  return lp
end

-- High-level API: send a measurement
function _M.send(measurement, tags, fields, timestamp)
  local line = _M.format(measurement, tags, fields, timestamp)
  _M.sendLine(line)
end

return _M
