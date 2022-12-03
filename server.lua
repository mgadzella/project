local socket = require("socket")
local udp = socket.udp()
udp:setsockname("127.0.0.1", 54321)
udp:settimeout()

local idcount = 0
local clientlist = {}
while true do
  data, addr, port = udp:receivefrom()
  if data == "joined" then
    idcount = idcount + 1
    udp:sendto(string.format("%d", idcount), addr, port)
    for _, client in ipairs(clientlist) do
      udp:sendto(string.format("%d joined", client[3]), addr, port)
    end
    table.insert(clientlist, {addr, port, idcount})
    data = string.format("%d joined", idcount)
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
