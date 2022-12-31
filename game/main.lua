require("player")
require("input")

function love.load()
  love.window.setMode(500, 500, {resizable=false, vsync=0})
  love.mouse.setVisible(true)
  socket = require("socket")
  udp = socket.udp()
  text = ""
  font = love.graphics.newFont(30)
  online = false
end

function love.update()
  if love.keyboard.isDown("escape") then
    if online == true then
      p:disconnect()
    end
    love.event.quit()
  end

  if online == true then
    p:update()
  elseif online == false then
    if ((addr ~= "") and addr) and ((port ~= "") and port) and ((name ~= "") and name) then
      online = true
      p:connect(addr, tonumber(port), name)
    elseif not addr or addr == "" then
      addr = i:addr()
    elseif addr and (not port or port == "") then
      port = i:port()
    elseif port and (not name or name == "") then
      name = i:name()
    end
  end
end

function love.draw()
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(1, 1, 1)
  if online == true then
    p:draw()
  elseif online == false then
    i:draw()
  end
end
