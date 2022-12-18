local socket = require("socket")
local udp = socket.udp()
udp:setsockname("127.0.0.1", 54321)
udp:settimeout()

local idcount = 0
local tmpcount = socket.gettime()*1000
local clientlist = {}
while true do
  data, addr, port = udp:receivefrom()
  if data == "joined" then
    math.randomseed(tmpcount)
    local r, g, b = math.random(0, 255), math.random(0, 255), math.random(0, 255)
    idcount = idcount + 1
    udp:sendto(string.format("%d %d %d %d", idcount, r, g, b), addr, port)
    for _, client in ipairs(clientlist) do
      udp:sendto(string.format("%d %d %d %d joined", client[3], client[4], client[5], client[6]), addr, port)
    end
    table.insert(clientlist, {addr, port, idcount, r, g, b})
    data = string.format("%d %d %d %d joined", idcount, r, g, b)
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
end
