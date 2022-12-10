i = {}
local utf8 = require("utf8")
local preback = false
local state = nil

local function otherkey()
  if love.keyboard.isDown("backspace") then
    if preback == false then
      local byteoffset = utf8.offset(text, -1)
      if byteoffset then
        text = string.sub(text, 1, byteoffset - 1)
      end
      preback = true
    elseif preback == true then
      function love.keyreleased(backspace)
        if backspace == "backspace" then
          preback = false
        end
      end
    end
  elseif love.keyboard.isDown("return") then
    local tmp = text
    text = ""
    return tmp
  end
end

function i:addr()
  function love.textinput(added)
    text = text .. added
  end
  state = "addr"
  return otherkey()
end

function i:port()
  function love.textinput(added)
    if tonumber(added) ~= nil and string.len(text) < 5 then
      text = text .. added
    end
  end
  state = "port"
  return otherkey()
end

function i:draw()
  love.graphics.setFont(font)
  love.graphics.setColor(0, 0, 0)
  love.graphics.print(state..": "..text, 100, 100)
end
