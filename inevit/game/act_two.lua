local game = {}
local music_act_two

function game.load()
  music_act_two = love.audio.newSource("assets/two_them.wav")
  music_act_two:setLooping(true)
  music_act_two:play()

  -- gbg = love.graphics.newImage("assets/gbg2.png")

end

function game.update()
end

function game.draw()
  love graphics.setColor(74, 67, 60)
      love.graphics.circle("fill", 50, 100, 100)
    love.graphics.setColor(146, 32, 23)
    love.graphics.rectangle("fill", 20, 20, 50, 50)
end

return game