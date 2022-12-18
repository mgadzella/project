p = {}
local userlist = {}
local x, y =  0, 0
local playerstate = "capture"
local size = 100
local cancontinue = true
local grid = {}
local gridsize = 5
local griddone = 0
for index = 1, gridsize, 1 do
  grid[index] = {}
  for _ = 1, gridsize, 1 do
    table.insert(grid[index], 0)
  end
end

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

local function getcolor(userid)
  if userid < 0 then
    userid = -(userid)
  end
  local color = nil
  for _, user in ipairs(userlist) do
    if tonumber(user[1]) == userid then
      color = {user[4], user[5], user[6]}
    end
  end
  return color
end

local function findwinner()
  local list = {}
  for _, user in ipairs(userlist) do
    table.insert(list, {user[1], 0})
  end
  for _, row in ipairs(grid) do
    for _, column in ipairs(row) do
      if column ~= 0 then
        for index, user in ipairs(list) do
          if tonumber(user[1]) == column or tonumber(user[1]) == -(column) then
            list[index][2] = list[index][2] + 1
          end
        end
      end
    end
  end
  local highest = {0, -1}
  local tie = false
  for _, value in ipairs(list) do
    if value[2] > highest[2] then
      highest = value
    elseif value[2] == highest[2] then
      tie = true
    end
  end
  if tie == false then
    return tostring(highest[1])
  elseif tie == true then
    local ties = {}
    for _, value in ipairs(list) do
      if value[2] == highest[2] then
        table.insert(ties, value[1])
      end
    end
    return table.concat(ties, ", ")
  end
end

function p:connect(addr, port)
  udp:setpeername(addr, port)
  udp:send("joined")
  local tmpdata = udp:receive()
  if not tmpdata then
    print("something went wrong between server and client")
    udp:close()
    love.event.quit()
  end
  local data, _ = split(tmpdata)
  myid = tonumber(data[1])
  mycolor = {tonumber(data[2]), tonumber(data[3]), tonumber(data[4])}
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
        table.insert(userlist, {userdata[1], "default", "default", userdata[2], userdata[3], userdata[4]})
        udp:send(string.format("%d %d %d pos", myid, x, y))
        for rowindex, row in ipairs(grid) do
          for columnindex, column in ipairs(row) do
            if column == myid then
              udp:send(string.format("%d %d %d cap", myid, rowindex-1, columnindex-1))
            elseif column == -(myid) then
              udp:send(string.format("%d %d %d def", myid, rowindex-1, columnindex-1))
            end
          end
        end
      elseif action == "left" then
        for index, user in ipairs(userlist) do
          if user[1] == userdata[1] then
            table.remove(userlist, index)
            break
          end
        end
        for rowindex, row in ipairs(grid) do
          for columnindex, column in ipairs(row) do
            if column == tonumber(userdata[1]) or column == -(tonumber(userdata[1])) then
              grid[rowindex][columnindex] = 0
            end
          end
        end
      elseif action == "pos" then
        for index, user in ipairs(userlist) do
          if user[1] == userdata[1] then
            userlist[index][2] = userdata[2]
            userlist[index][3] = userdata[3]
            break
          end
        end
      elseif action == "cap" then
        row = tonumber(userdata[2]) + 1
        column = tonumber(userdata[3]) + 1
        if tonumber(userdata[1]) == myid then
          grid[row][column] = myid
        else
          grid[row][column] = tonumber(userdata[1])
        end
      elseif action == "def" then
        row = tonumber(userdata[2]) + 1
        column = tonumber(userdata[3]) + 1
        if tonumber(userdata[1]) == myid then
          grid[row][column] = -(myid)
        else
          grid[row][column] = -(tonumber(userdata[1]))
        end
      end
    end
  end

  if cancontinue == true then
    if love.keyboard.isDown("w") then
      if y >= 1 then
        if grid[x+1][y] == myid then
          y = y - 1
          udp:send(string.format("%d %d %d pos", myid, x, y))
        end
      end
      cancontinue = false
      key = "w"
    elseif love.keyboard.isDown("a") then
      if x >= 1 then
        if grid[x][y+1] == myid then
          x = x - 1
          udp:send(string.format("%d %d %d pos", myid, x, y))
        end
      end
      cancontinue = false
      key = "a"
    elseif love.keyboard.isDown("s") then
      if y+2 <= gridsize then
        if grid[x+1][y+2] == myid then
          y = y + 1
          udp:send(string.format("%d %d %d pos", myid, x, y))
        end
      end
      cancontinue = false
      key = "s"
    elseif love.keyboard.isDown("d") then
      if x+2 <= gridsize then
        if grid[x+2][y+1] == myid then
          x = x + 1
          udp:send(string.format("%d %d %d pos", myid, x, y))
        end
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
        if y >= 1 then
          if grid[x+1][y] >= 0 then
            udp:send(string.format("%d %d %d cap", myid, x, y-1))
          end
        end
        cancontinue = false
        key = "up"
      elseif love.keyboard.isDown("left") then
        if x >= 1 then
          if grid[x][y+1] >= 0 then
            udp:send(string.format("%d %d %d cap", myid, x-1, y))
          end
        end
        cancontinue = false
        key = "left"
      elseif love.keyboard.isDown("down") then
        if y+2 <= gridsize then
          if grid[x+1][y+2] >= 0 then
            udp:send(string.format("%d %d %d cap", myid, x, y+1))
          end
        end
        cancontinue = false
        key = "down"
      elseif love.keyboard.isDown("right") then
        if x+2 <= gridsize then
          if grid[x+2][y+1] >= 0 then
            udp:send(string.format("%d %d %d cap", myid, x+1, y))
          end
        end
        cancontinue = false
        key = "right"
      end
    elseif playerstate == "defend" then
      if love.keyboard.isDown("up") then
        if y >= 1 then
          if grid[x+1][y] == myid then
            udp:send(string.format("%d %d %d def", myid, x, y-1))
          end
        end
        cancontinue = false
        key = "up"
      elseif love.keyboard.isDown("left") then
        if x >= 1 then
          if grid[x][y+1] == myid then
            udp:send(string.format("%d %d %d def", myid, x-1, y))
          end
        end
        cancontinue = false
        key = "left"
      elseif love.keyboard.isDown("down") then
        if y+2 <= gridsize then
          if grid[x+1][y+2] == myid then
            udp:send(string.format("%d %d %d def", myid, x, y+1))
          end
        end
        cancontinue = false
        key = "down"
      elseif love.keyboard.isDown("right") then
        if x+2 <= gridsize then
          if grid[x+2][y+1] == myid then
            udp:send(string.format("%d %d %d def", myid,x+1, y))
          end
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
        if tonumber(user[1]) == myid then
          love.graphics.setColor(mycolor[1]/255, mycolor[2]/255, mycolor[3]/255)
        else
          love.graphics.setColor(user[4]/255, user[5]/255, user[6]/255)
        end
        love.graphics.rectangle("fill", user[2]*size, user[3]*size, size, size)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(user[1], user[2]*size, user[3]*size+30, size, "center")
      end
    end
    for rowindex, row in ipairs(grid) do
      for column in ipairs(row) do
        square = tonumber(row[column])
        if square ~= 0 then
          griddone = griddone + 1
          if square == myid then
            love.graphics.setColor(mycolor[1]/255, mycolor[2]/255, mycolor[3]/255, 0.25)
          elseif square > 0 then
            local usercolor = getcolor(row[column])
            if usercolor then
              love.graphics.setColor(usercolor[1]/255, usercolor[2]/255, usercolor[3]/255, 0.25)
            end
          elseif square == -(myid) then
            love.graphics.setColor(mycolor[1]/255, mycolor[2]/255, mycolor[3]/255, 0.5)
          elseif square < 0 then
            local usercolor = getcolor(row[column])
            if usercolor then
              love.graphics.setColor(usercolor[1]/255, usercolor[2]/255, usercolor[3]/255, 0.5)
            end
          end
          love.graphics.rectangle("fill", (rowindex-1)*size, (column-1)*size, size, size)
        end
      end
    end
    if griddone == (gridsize ^ 2) then
      print("winner(s): "..findwinner())
      love.event.quit()
      for rowindex, row in ipairs(grid) do
        for columnindex, column in ipairs(row) do
          if column ~= 0 then
            grid[rowindex][columnindex] = 0
          end
        end
      end
      udp:send("done")
    end
    griddone = 0
  end
end
