p = {}
local userlist = {}
local x, y =  0, 0
local playerstate = "capture"
local size = 100
local cancontinue = true
local grid = {}
for index = 1, 5, 1 do
  grid[index] = {}
  for _ = 1, 5, 1 do
    table.insert(grid[index], 0)
  end
end
grid[x+1][y+1] = 1

local function split(str)
  local strs = {}
  local action = nil
  for substr in string.gmatch(str, "(%g+)") do
    if substr == "joined" or substr == "left" or substr == "pos" or substr == "cap" or substr == "def" then
      action = substr
    end
    table.insert(strs, substr)
  end
  return strs, action
end

-- TODO: noticable delay when global multiplayer

function p:connect(addr, port)
  udp:setpeername(addr, port)
  udp:send("joined")
  myid = udp:receive()
  if not myid then
    print("something went wrong between server and client")
    udp:close()
    love.event.quit()
  end
  udp:settimeout(0)
end

function p:disconnect()
  udp:send("left")
  udp:close()
end

function p:update()

  local data = udp:receive()
  if data then
    local userdata, action = split(data)
    if userdata then
      if action == "joined" then
        table.insert(userlist, {userdata[1], "default", "default"})
        udp:send(string.format("%d %s %s pos", myid, x, y))
        for rowindex, row in ipairs(grid) do
          for columnindex, column in ipairs(row) do
            if column == 1 then
              udp:send(string.format("%d %s %s cap", myid, rowindex-1, columnindex-1))
            elseif column == -1 then
              udp:send(string.format("%d %s %s def", myid, rowindex-1, columnindex-1))
            end
          end
        end
      elseif action == "left" then
        for index, user in ipairs(userlist) do
          if user[1] == userdata[1] then
            userlist[index] = nil
            break
          end
        end
      elseif action == "pos" then
        for index, user in ipairs(userlist) do
          if user[1] == userdata[1] then
            userlist[index][2] = nil
            userlist[index][3] = nil
            table.insert(userlist[index], 2, userdata[2])
            table.insert(userlist[index], 3, userdata[3])
            break
          end
        end
      elseif action == "cap" then
        row = tonumber(userdata[2]) + 1
        column = tonumber(userdata[3]) + 1
        if userdata[1] == myid then
          grid[row][column] = 1
        else
          grid[row][column] = 2
        end
      elseif action == "def" then
        row = tonumber(userdata[2]) + 1
        column = tonumber(userdata[3]) + 1
        if userdata[1] == myid then
          grid[row][column] = -1
        else
          grid[row][column] = -2
        end
      end
    end
  end

  if cancontinue == true then
    if love.keyboard.isDown("w") then
      if grid[x+1][y] == 1 then
        y = y - 1
        udp:send(string.format("%d %s %s pos", myid, x, y))
      end
      cancontinue = false
      key = "w"
    elseif love.keyboard.isDown("a") then
      if grid[x][y+1] == 1 then
        x = x - 1
        udp:send(string.format("%d %s %s pos", myid, x, y))
      end
      cancontinue = false
      key = "a"
    elseif love.keyboard.isDown("s") then
      if grid[x+1][y+2] == 1 then
        y = y + 1
        udp:send(string.format("%d %s %s pos", myid, x, y))
      end
      cancontinue = false
      key = "s"
    elseif love.keyboard.isDown("d") then
      if grid[x+2][y+1] == 1 then
        x = x + 1
        udp:send(string.format("%d %s %s pos", myid, x, y))
      end
      cancontinue = false
      key = "d"
    end
    if love.keyboard.isDown("space") then
      if playerstate == "capture" then
        playerstate = "defend"
      elseif playerstate == "defend" then
        playerstate = "capture"
      end
      cancontinue = false
      key = "space"
    end

    if playerstate == "capture" then
      if love.keyboard.isDown("up") then
        if grid[x+1][y] >= 0 then
          udp:send(string.format("%d %s %s cap", myid, x, y-1))
        end
        cancontinue = false
        key = "up"
      elseif love.keyboard.isDown("left") then
        if grid[x][y+1] >= 0 then
          udp:send(string.format("%d %s %s cap", myid, x-1, y))
        end
        cancontinue = false
        key = "left"
      elseif love.keyboard.isDown("down") then
        if grid[x+1][y+2] >= 0 then
          udp:send(string.format("%d %s %s cap", myid, x, y+1))
        end
        cancontinue = false
        key = "down"
      elseif love.keyboard.isDown("right") then
        if grid[x+2][y+1] >= 0 then
          udp:send(string.format("%d %s %s cap", myid, x+1, y))
        end
        cancontinue = false
        key = "right"
      end
    elseif playerstate == "defend" then
      if love.keyboard.isDown("up") then
        if grid[x+1][y] == 1 then
          udp:send(string.format("%d %s %s def", myid, x, y-1))
        end
        cancontinue = false
        key = "up"
      elseif love.keyboard.isDown("left") then
        if grid[x][y+1] == 1 then
          udp:send(string.format("%d %s %s def", myid, x-1, y))
        end
        cancontinue = false
        key = "left"
      elseif love.keyboard.isDown("down") then
        if grid[x+1][y+2] == 1 then
          udp:send(string.format("%d %s %s def", myid, x, y+1))
        end
        cancontinue = false
        key = "down"
      elseif love.keyboard.isDown("right") then
        if grid[x+2][y+1] == 1 then
          udp:send(string.format("%d %s %s def", myid,x+1, y))
        end
        cancontinue = false
        key = "right"
      end
    end
  elseif cancontinue == false then
    function love.keyreleased(keyrel)
      if keyrel == key then
        cancontinue = true
      end
    end
  end
end

function p:draw()
  if userlist then
    for _, user in ipairs(userlist) do
      if not (user[2] == "default" and user[3] == "default") then
        if user[1] == myid then
          love.graphics.setColor(0, 1, 0)
        else
          love.graphics.setColor(1, 0, 0)
        end
        love.graphics.rectangle("fill", user[2]*size, user[3]*size, size, size)
      end
    end
    for rowindex, row in ipairs(grid) do
      for column in ipairs(row) do
        if row[column] ~= 0 then
          if row[column] == 1 then
            love.graphics.setColor(0, 1, 0, 0.25)
          elseif row[column] == 2 then
            love.graphics.setColor(1, 0, 0, 0.25)
          elseif row[column] == -1 then
            love.graphics.setColor(0, 1, 1, 0.5)
          elseif row[column] == -2 then
            love.graphics.setColor(1, 0, 1, 0.5)
          end
          love.graphics.rectangle("fill", (rowindex-1)*size, (column-1)*size, size, size)
        end
      end
    end
  end
end
