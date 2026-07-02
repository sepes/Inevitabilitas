local game = {}
local squares = {}
local eyetable = {}
local next_act = false
local SQUARE_SIZE = 20
local SCREEN_W = 320
local SCREEN_H = 200
local CENTER_Y = SCREEN_H / 2
local CENTER_X = SCREEN_W / 2
local SPAWN_TIMER = 0
local SPAWN_INTERVAL = 2
local SPEED = 20
local FRAME_W = 16
local FRAME_H = 16
local ratclimpsheet
local ratcquads = {}
local ratfallsheet
local ratfquads = {}
local rathit
local mobsheet
local mobquads = {}
local mobframe = 1
local mobtimer = 0
local eyesheet
local eyequads = {}
local eyeframe = 1
local eyetimer = 0
local eyeshot
local altar
local altarsheet
local altarquads = {}
local altarframe = 1
local altartimer = 0
local altarshot
local ALTAR_W = 23
local ALTAR_H = 31
local FRAME_SPEED = 0.5
local FRAME_COUNT_C = 2
local FRAME_COUNT_F = 2
local FRAME_COUNT_MOB = 2
local FRAME_COUNT_EYE = 2
local FRAME_COUNT_ALTAR = 3
local mouseX = 0
local mouseY = 0

local function spawnSquare()
  local x = math.random(0, SCREEN_W - SQUARE_SIZE)
  table.insert(squares, {
    x = x,
    y = SCREEN_H - SQUARE_SIZE,
    dropping = false,
    frame = 1,
    frameTimer = 0,
  })
end

local function spawnEye()
  altar.kills = altar.kills + 1
  rathit:play()
  local px = math.random(5,SCREEN_W - 5)
  local py = math.random(5,87)
  table.insert(eyetable, {x = px, y = py})
    if #eyetable < 40 then
      SPAWN_INTERVAL = 2 - #eyetable * 0.025
      if SPAWN_INTERVAL < 0.4 then
        SPAWN_INTERVAL = 0.4
      end
    end
  if #eyetable > 100 then
    for i = #eyetable, 100 do
    table.remove(#eyetable, 0)
    end 
  end
end

function game.load()
  math.randomseed(os.time())
  gbg = love.graphics.newImage("assets/gbg.png")
  local music_act_one = love.audio.newSource("assets/one_them.wav")
  music_act_one:setLooping(true)
  music_act_one:play()

  rathit = love.audio.newSource("assets/rathit.wav")
  eyeshot = love.audio.newSource("assets/eyeshot.wav")
  altarshot = love.audio.newSource("assets/altarshot.wav")

  ratclimpsheet = love.graphics.newImage("assets/rat_c.png")
  for i = 0, 1 do
    ratcquads[i+1] = love.graphics.newQuad(i * FRAME_W, 0, FRAME_W, FRAME_H)
  end

  ratfallsheet = love.graphics.newImage("assets/rat_f.png")
  for i = 0, 1 do
    ratfquads[i+1] = love.graphics.newQuad(i * FRAME_W, 0, FRAME_W, FRAME_H)
  end

  mobsheet = love.graphics.newImage("assets/mob.png")
  for i = 0, 1 do
    mobquads[i+1] = love.graphics.newQuad(i * SCREEN_W, 0, SCREEN_W, 20)
  end

  eyesheet = love.graphics.newImage("assets/eye.png")
  for i = 0, 1 do
    eyequads[i+1] = love.graphics.newQuad(i * FRAME_W, 0, FRAME_W, FRAME_H)
  end

  altarsheet = love.graphics.newImage("assets/altar.png")
  for i = 0, 16 do
    altarquads[i+1] = love.graphics.newQuad(i * ALTAR_W, 0, ALTAR_W, ALTAR_H)
  end
  altar = {
    activated = false,
    kills = 0
  }

end

function game.update(dt)
  SPAWN_TIMER = SPAWN_TIMER + dt
  if SPAWN_TIMER >= SPAWN_INTERVAL then
    SPAWN_TIMER = 0
    spawnSquare()
  end

  if altarframe == 14 then
    altar.activated = false
  end

  if altar.kills > 150 then
    next_act = true
  end

  for i = #squares, 1, -1 do
    local s = squares[i]

    -- move
    if s.dropping then
      s.y = s.y + SPEED * dt
      if s.y > SCREEN_H then
        table.remove(squares, i)
      end
    else
      if s.y > CENTER_Y then
        s.y = s.y - SPEED * dt
      end
      if s.y <= CENTER_Y then
        altar.activated = true
        if altarframe == 12 then
          altarshot:play()
        end
        if altarframe == 13 then
          s.dropping = true
          s.frame = 1
          s.frameTimer = 0
          spawnEye()
        end
      end
      if s.x + SQUARE_SIZE/2 < CENTER_X then
        s.x = s.x + (CENTER_X - s.x) * 0.25 * dt
      end
      if s.x + SQUARE_SIZE/2 > CENTER_X then
        s.x = s.x - (CENTER_X - s.x) * -0.25 * dt
      end
    end

    -- Animate per square
    if squares[i] then
      s.frameTimer = s.frameTimer + dt
      if s.frameTimer >= FRAME_SPEED then
        s.frameTimer = s.frameTimer - FRAME_SPEED
        local count = s.dropping and FRAME_COUNT_F or FRAME_COUNT_C
        s.frame = s.frame % count + 1
      end
    end
  end
  -- Animate BG Mob
  mobtimer = mobtimer + dt
  if mobtimer >= FRAME_SPEED then
    mobtimer = mobtimer - FRAME_SPEED
    mobframe = mobframe % FRAME_COUNT_MOB + 1
  end
  
  -- Animate Altar
  altartimer = altartimer + dt
  if altartimer >= FRAME_SPEED then
    altartimer = altartimer - FRAME_SPEED
    if altar.activated then
      FRAME_COUNT_ALTAR = 17
    else
      if altarframe < 3 then
      FRAME_COUNT_ALTAR = 3
      end
    end
     
    altarframe = altarframe % FRAME_COUNT_ALTAR + 1
  end

  -- Animate Cursor
  if eyeframe == 1 then
    eyetimer = eyetimer + dt
  end 
  if eyetimer >= FRAME_SPEED then
    eyetimer = 0
    eyeframe = 2
  end

end

function game.mousepressed(x, y, button)
  if button == 0 then
    for i = #squares, 1, -1 do
      local s = squares[i]
      if x >= s.x and x <= s.x + SQUARE_SIZE and
         y >= s.y and y <= s.y + SQUARE_SIZE then
        s.dropping = true
        s.frame = 1
        s.frameTimer = 0
        spawnEye()
        break
      end
    end
    eyeshot:play()
    eyeframe = 1

  end
end

function game.draw()
  love.graphics.setColor(146, 32, 23)
    for _, p in ipairs(eyetable) do
      love.graphics.rectangle("fill", p.x, p.y, 1, 1)
    end
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(gbg, 0, 0)
  love.graphics.draw(altarsheet, altarquads[altarframe], 155, 86)

  for _, s in ipairs(squares) do
    if s.dropping then
      love.graphics.draw(ratfallsheet, ratfquads[s.frame], s.x, s.y)
      if s.y <= CENTER_Y + 10 and altarframe == 13 then
        love.graphics.draw(eyesheet, eyequads[1], s.x, CENTER_Y - 10)
      end
    else
      love.graphics.draw(ratclimpsheet, ratcquads[s.frame], s.x, s.y)
    end
  end

  love.graphics.draw(mobsheet, mobquads[mobframe], 0, SCREEN_H - 20 )
  if next_act then
  love.graphics.print("Next act (Enter)", 5, 5)
  end
  -- cursor
  local mx, my = love.mouse.getPosition()
  love.graphics.draw(eyesheet, eyequads[eyeframe], mx - 8, my - 8)
end

return game