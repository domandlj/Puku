Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'
local moonshine = require 'libs.moonshine'



local gameLevel1 = require 'gamestates.gameLevel1'

local mainMenu = {}

function mainMenu:init()
  spriteSheet = love.graphics.newImage('/assets/entities/menus/wasd.png')
  grid = anim8.newGrid(256, 256, spriteSheet:getWidth(), spriteSheet:getHeight())
  self.animations = {}
  self.animations.wasd = anim8.newAnimation(grid('1-5', 1), 0.1)
  self.animations.wasd:gotoFrame(1)
  
  self.animations.keySpace = anim8.newAnimation(grid('6-7', 1), 0.1)
  self.animations.keySpace:gotoFrame(6)
  
  self.animations.keyJ = anim8.newAnimation(grid('8-9', 1), 0.1)
  self.animations.keyJ:gotoFrame(8)


  -- moonshine(moonshine.effects.chromasep).chain(moonshine.effects.crt)

  self.effect = moonshine(moonshine.effects.crt)
 -- self.effect.chromasep.radius = 2
  self.background = love.graphics.newImage('/assets/backgrounds/introBackground.jpg')
  self.soundCoin = love.audio.newSource('/assets/sound/menus/soundCoin.wav', 'static')
end


function mainMenu:keypressed(key)
   if key == "space" then
    self.soundCoin:play()
   end
   
  if key == "w" then
   self.animations.wasd:gotoFrame(3)
   self.soundCoin:play()

  elseif key == "a" then
    self.animations.wasd:gotoFrame(5)
    self.soundCoin:play()

  elseif key == "d" then
    self.animations.wasd:gotoFrame(2) 
    self.soundCoin:play()

  elseif key == "s" then
    self.animations.wasd:gotoFrame(4)
    self.soundCoin:play()
  
  elseif key == "j" then
    self.animations.keyJ:gotoFrame(2)
    self.soundCoin:play()
  
  elseif key == "space" then
    self.animations.keySpace:gotoFrame(2)
    self.soundCoin:play()

  elseif key == "return" then
    Gamestate.switch(gameLevel1)
  end
end

function mainMenu:update(dt)
  if not love.keyboard.isDown("w", "a", "s", "d", "j","space") then
    self.animations.wasd:gotoFrame(1)
    self.animations.keySpace:gotoFrame(1) 
    self.animations.keyJ:gotoFrame(1)
  end

end

function mainMenu:draw()
 self.effect(function()
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.draw(self.background, 0,0)
  self.animations.wasd:draw(spriteSheet, 0, 200, nil, 2)
  self.animations.keySpace:draw(spriteSheet, 380, 400, nil, 2)
  self.animations.keyJ:draw(spriteSheet, 700, 200, nil, 2)

 end)

 love.graphics.print({
      {255, 255, 255}, "APRETÁ ", 
      {100, 0, 0}, "ENTER"
    }, 520, 180, nil, 2)
end 

return mainMenu
