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
    if (tonumber(added) or added == ".") and string.len(text) < 15 then
      text = text .. added
    end
  end
  state = "address"
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

function i:name()
  function love.textinput(added)
    if string.len(text) < 12 and added ~= " " then
      text = text .. added
    end
  end
  state = "username"
  return otherkey()
end

function i:draw()
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf(state..": "..text, 0, 200, 500, "center")
end
