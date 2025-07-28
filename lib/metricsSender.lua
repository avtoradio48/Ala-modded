local component = require("component")
local hasInternet = component.isAvailable("internet")
local internet = hasInternet and component.internet or nil

-- Конфигурация подключения к InfluxDB
local config = {
  host = "<INFLUX_HOST>",  -- адрес сервера InfluxDB
  port = 8086,               -- порт InfluxDB
  db   = "<DB_NAME>",      -- имя базы данных
  tags = {
    host = os.getenv("OC_HOSTNAME") or component.computer.address()
  }
}

local function encodeTags(tags)
  local parts = {}
  for k, v in pairs(tags) do
    table.insert(parts, k .. "=" .. tostring(v))
  end
  return table.concat(parts, ",")
end

-- Отправка одной метрики в InfluxDB (Line Protocol)
local function sendMetric(measurement, value, extraTags)
  -- measurement: имя метрики, например "players_online"
  -- value: число (или строка, если нужно)
  -- extraTags: таблица дополнительных тегов, например {module="players"}
  local tags = {}
  for k,v in pairs(config.tags) do tags[k] = v end
  if extraTags then for k,v in pairs(extraTags) do tags[k] = v end end
  local tagString = encodeTags(tags)
  local payload = string.format(
    "%s,%s value=%s", measurement, tagString, tostring(value)
  )

  local url = string.format(
    "http://%s:%d/write?db=%s",
    config.host, config.port, config.db
  )

  if not hasInternet then
    return false, "internet card not available"
  end

  local handle, err = internet.request(url, payload)
  if not handle then
    return false, err
  end
  handle:setTimeout(5)
  -- читаем весь ответ, если нужно логгировать
  local response = handle:readAll()
  -- finish() возвращает HTTP-код
  local code = handle:finish()
  handle:close()
  return code == 204, code, response
end

-- API модуля
return {
  send      = sendMetric,
  setConfig = function(cfg) for k,v in pairs(cfg) do config[k] = v end end,
  available = hasInternet
}
