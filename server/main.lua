function love.load()
  love.window.setMode(500, 500, {resizable=false, vsync=0})
  love.mouse.setVisible(true)
  local socket = require("socket")
  udp = socket.udp()
  udp:setsockname("127.0.0.1", 54321)
  udp:settimeout(0)
  idcount = 0
  tmpcount = socket.gettime()*1000
  clientlist = {}
  font = love.graphics.newFont(30)
  lastdata = "Started server"
end

function love.update()
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end
  data, addr, port = udp:receivefrom()
  if data then
    if string.sub(data, string.len(data)-5, string.len(data)) == "joined" then
      local username = string.sub(data, 1, string.len(data)-7)
      math.randomseed(tmpcount)
      local r, g, b = math.random(0, 255), math.random(0, 255), math.random(0, 255)
      local x, y = math.random(0, 4), math.random(0, 4)
      idcount = idcount + 1
      udp:sendto(string.format("%d %d %d %d %d %d", idcount, r, g, b, x, y), addr, port)
      for _, client in ipairs(clientlist) do
        udp:sendto(string.format("%d %d %d %d %s joined", client[3], client[4], client[5], client[6], client[7]), addr, port)
      end
      table.insert(clientlist, {addr, port, idcount, r, g, b, username})
      data = string.format("%d %d %d %d %s joined", idcount, r, g, b, username)
      tmpcount = tmpcount - 1
    elseif data == "left" then
      for index, client in ipairs(clientlist) do
        if client[1] == addr and client[2] == port then
          toremove = index
          break
        end
      end
      if toremove then
        data = string.format("%d left", clientlist[toremove][3])
        table.remove(clientlist, toremove)
      end
    end
    for _, client in ipairs(clientlist) do
      udp:sendto(string.format("%s", data), client[1], client[2])
    end
    lastdata = data
  end
end

function love.draw()
  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(lastdata, 0, 200, 500, "center")
  love.graphics.printf("Connect to 127.0.0.1:54321", 0, 250, 500, "center")
end
