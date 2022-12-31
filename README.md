# CS50x Project
[Video Demo](https://youtu.be/lXLusEWjBbQ)
#### The Process:
When looking through the list of examples for this project, "a game using Lua with LÖVE" had caught my eye. I knew that Roblox used Lua as a scripting language for creators, but I haven't heard of LÖVE. After some browsing, it appeared to me that it was both beginner friendly and highly functional, which sold the deal for me.

The goal for my game would be to make something fun but very simple, almost like a prototype. I wasn't interested in making art or music/effects, I wanted to focus on functionality. So, I started coding after some time I ended up with a get-to-the-goal-quickly game. It was not as fun as I would've hoped.

After brainstorming some more, putting more thought in the "fun" this time, I ended up with the concept of capturing and defending territory. I liked this idea because I wouldn't have to completely restart from scratch, so I got to work. Nearly days after, a problem came up. What's the goal? Sure, I could create A.I's but I wasn't convinced I could finish before the deadline. The other option would be to make the game multiplayer, which I ended up settling for.

Finally, after a long time, I have successfully done what I achieved to do. It's not a complicated game, and it's, as I mentioned, more like a prototype. In fact, I'm more proud of the fact that I got the multiplayer working (which took the majority of my time implementing) than the rest of the game combined, but nonetheless, I'm happy with the result.

#### The files:
In the `~/game` folder:
- `conf.lua` handles the monitor name and forces the newest version of LÖVE.
- `input.lua` handles the text input of the user during the connection phase of the game. Each kind of input has it's own unique function (ex. *"addr"* =  `addr()`). This is to handle things like numbers, character limits, and invalid characters.
- `main.lua` handles when to display the other `draw()` functions. In simple terms, it gets the user input if offline and runs the game if online.
- `player.lua` handles both the connection between the server and client (which is itself) and the main part of the game, including the grid of what is empty and who own's what, each player's unique data using a table, and other small but important things like boundaries.

In the `~/server` folder:
- `conf.lua` handles the monitor name and forces the newest version of LÖVE.
- `main.lua` handles the data between each of the connected clients. For maximum efficiency, it doesn't do any calculations other than give a user_id, color, or spawn position, it just sends what is requested (ex. *"bill joined"* would send *"user_id spawn_color spawn_pos"* to all connected clients).
