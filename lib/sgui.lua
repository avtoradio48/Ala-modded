local component = require("component")
local term      = require("term")
local gpu = require("component").gpu

local sgui = {}
local panels = {}

-- Сбросить список панелей
function sgui.init()
  panels = {}
end

-- Создать панель с заголовком title в позиции x,y размерами w×h
function sgui.createPanel(title, x, y, w, h)
  panels[title] = { x = x, y = y, w = w, h = h, title = title }
end

-- Отрисовать содержимое panels[title] (если есть GPU)
function sgui.drawPanel(title, content)
  local p = panels[title]
  if not p or not gpu then return end

  -- Title bar
  gpu.setBackground(0x336699)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(p.x, p.y, p.w, 1, " ")
  gpu.set(p.x + 1, p.y, p.title)

  -- Body
  gpu.setBackground(0x000000)
  gpu.setForeground(0xCCCCCC)
  for i = 1, p.h - 1 do
    gpu.fill(p.x, p.y + i, p.w, 1, " ")
  end

  -- Вывод данных
  if type(content) == "table" then
    local row = 1
    if #content > 0 then
      for _, item in ipairs(content) do
        local line = ""
        for k, v in pairs(item) do
          line = line .. k .. ":" .. tostring(v) .. " "
        end
        gpu.set(p.x + 1, p.y + row, line)
        row = row + 1
        if row >= p.h then break end
      end
    else
      for k, v in pairs(content) do
        gpu.set(p.x + 1, p.y + row, k .. ":" .. tostring(v))
        row = row + 1
        if row >= p.h then break end
      end
    end
  end
end

return sgui
