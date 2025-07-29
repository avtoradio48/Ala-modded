local component = require("component")
local term      = require("term")
local gpu       = component.gpu

local sgui = {}
local panels = {}

-- Initialize or reset GUI panels
function sgui.init()
  panels = {}
end

-- Create a panel with a title at (x, y) of size w x h
function sgui.createPanel(title, x, y, w, h)
  panels[title] = { x = x, y = y, w = w, h = h, title = title }
end

-- Draw the panel background, border, title and content
function sgui.drawPanel(title, content)
  local p = panels[title]
  if not p or not gpu then return end
  -- Draw title bar
  gpu.setBackground(0x336699)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(p.x, p.y, p.w, 1, " ")
  gpu.set(p.x + 1, p.y, p.title)

  -- Clear panel area
  gpu.setBackground(0x000000)
  gpu.setForeground(0xCCCCCC)
  for i = 1, p.h - 1 do
    gpu.fill(p.x, p.y + i, p.w, 1, " ")
  end

  -- Render content depending on data structure
  if type(content) == "table" then
    local row = 1
    if #content > 0 then
      -- List of items
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
      -- Single key-value mapping
      for k, v in pairs(content) do
        local line = k .. ":" .. tostring(v)
        gpu.set(p.x + 1, p.y + row, line)
        row = row + 1
        if row >= p.h then break end
      end
    end
  end
end

return sgui
