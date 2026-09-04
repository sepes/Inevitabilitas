local bg
local gameStarted = false
local game = nil
local gameState = require("state")
local blinkTimer = 0
local blinkVisible = true
local debugMode = false
local theme
local transitionTimer = 300
local transitionValue = -200
local transitionState = 0 -- 0 = none, 1 = fadeIn, 2 = fadeOut
local FRAME_SPEED = 0.5

local function nextAct()
  gameStarted = true
  if gameState.activeAct == 1 then
    game = require("act_two")
  end
  if gameState.activeAct == 0 then
    game = require("act_one")
  end
    gameState.activeAct = gameState.activeAct + 1
    gameState.next_act = false
    game.load()
end

function love.load()
  bg = love.graphics.newImage("assets/bg.png")
  if love.audio then
  theme = love.audio.newSource("assets/theme.wav")
  theme:setLooping(true)
  theme:play()
  end
  gameState.next_act = true
end

function love.update(dt)
    if gameStarted then
    game.update(dt)
  end
  blinkTimer = blinkTimer + dt
  if blinkTimer >= FRAME_SPEED then
    blinkTimer = blinkTimer - FRAME_SPEED
    blinkVisible = not blinkVisible
  end
  if transitionState > 0 then
    transitionTimer = transitionTimer + dt
  end
  if transitionState == 1 and transitionTimer >= FRAME_SPEED then
    transitionTimer = transitionTimer - FRAME_SPEED
    transitionValue = transitionValue + 1
    if transitionValue >= 0 then
      transitionValue = 0
      transitionState = 2
      nextAct()
    end
  end
  if transitionState == 2 and transitionTimer >= FRAME_SPEED then
    transitionTimer = transitionTimer - FRAME_SPEED
    transitionValue = transitionValue - 1
    if transitionValue <= -200 then
      transitionValue = -200
      transitionState = 0
    end
  end

end

function love.draw()
  if gameStarted then
    game.draw()
  else
  love.graphics.draw(bg, 0, 0)
  end
  if blinkVisible then
    if gameState.activeAct == 0 then
      love.graphics.print("Press Enter to Start", 320/2-50, 200/2-10)
    end
    if gameState.activeAct == 1 and gameState.next_act then
      love.graphics.print("Next act (Enter)", 5, 5)
    end 
  end
  if transitionState > 0 then
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, transitionValue, 320, 200)
    love.graphics.setColor(255, 255, 255)
  end

  -- debug, f8 to show in game
  if debugMode then
    love.graphics.print("Memory: " .. math.floor(collectgarbage("count")) .. "kb", 240, 0)
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  if not gameStarted and key == "return" and gameState.next_act then
    transitionState = 1
    theme:stop()
  end
  if gameStarted and key == "return" and gameState.next_act then
    transitionState = 1
  end
  if gameStarted and game.keypressed then
    game.keypressed(key)
  end
  if key == "f8" then
    debugMode = not debugMode
  end
end

function love.mousepressed(x, y, button)
  if not gameStarted and button == 0 then
    transitionState = 1
    theme:stop()
    end
  if gameStarted and game.mousepressed then
    game.mousepressed(x, y, button)
  end
end