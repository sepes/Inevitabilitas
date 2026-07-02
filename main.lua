local bg
local gameStarted = false
local game = nil
local blinktimer = 0
local blinkvisible = true
local theme

function love.load()
  bg = love.graphics.newImage("assets/bg.png")
  if love.audio then
  theme = love.audio.newSource("assets/theme.wav")
  theme:setLooping(true)
  theme:play()
  end
end

function love.update(dt)
    if gameStarted then
    game.update(dt)
  end
  blinktimer = blinktimer + 1
  if blinktimer >= 300 then
    blinktimer = 0
    blinkvisible = not blinkvisible
  end
end

function love.draw()
  if gameStarted then
    game.draw()
  else
  love.graphics.draw(bg, 0, 0)
    if blinkvisible then
    love.graphics.print("Press Enter to Start", 320/2-50, 200/2-10)
    end
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  if not gameStarted and key == "return" then
    theme:stop()
    game = require("act_one")
    game.load()
    gameStarted = true
    end
  if gameStarted and game.keypressed then
    game.keypressed(key)
  end
end

function love.mousepressed(x, y, button)
  if not gameStarted and button == 0 then
    theme:stop()
    game = require("act_one")
    game.load()
    gameStarted = true
    end
  if gameStarted and game.mousepressed then
    game.mousepressed(x, y, button)
  end
end
