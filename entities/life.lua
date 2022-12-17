Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local life = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function life:init(world, x, y)
  self.isLife = true
  self.player = world.player
  self.camera = world.camera
  self.relativeX = x
  self.relativeY = y
  self.spriteSizeX = 256
  self.spriteSizeY = 64
  self.scaleSprite = 1
  self.spriteSheet = love.graphics.newImage('/assets/entities/life.png')
  Entity.init(self, world,  x, y, self.spriteSizeX * self.scaleSprite, self.spriteSizeY * self.scaleSprite)
  self.world:add(self, self:getRect())

  self.grid = anim8.newGrid(self.spriteSizeX, self.spriteSizeY, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

  self.animations = {}
  self.animations.life = anim8.newAnimation(self.grid(1, '1-10'), 0.15)
  self.animations.isDyingHalf = anim8.newAnimation(self.grid(2, '1-3'), 0.15)
  self.animations.isDying = anim8.newAnimation(self.grid(3, '1-3'), 0.15)
  self.anim = self.animations.life

end

function life:checkLife()
  local life = self.player.life
  
  if life <= 10 then
    self.anim = self.animations.isDyingHalf
  elseif life <= 20 then
    self.anim = self.animations.isDying
  elseif life <= 30 then
    self.anim = self.animations.life
    self.anim:gotoFrame(3)
  elseif life <= 40 then
    self.anim = self.animations.life
    self.anim:gotoFrame(4)
  elseif life <= 50 then
    self.anim = self.animations.life
    self.anim:gotoFrame(5)
  elseif life <= 60 then 
    self.anim = self.animations.life
    self.anim:gotoFrame(6)
  elseif life <= 70 then
    self.anim = self.animations.life
    self.anim:gotoFrame(7)
  elseif life <= 80 then
    self.anim = self.animations.life
    self.anim:gotoFrame(8)
  elseif life <= 90 then 
    self.anim = self.animations.life
    self.anim:gotoFrame(9)
  else 
    self.anim = self.animations.life      
    self.anim:gotoFrame(10)
  end
end

function life:update(dt)
  self.x = self.relativeX + self.camera.x
  self.y = self.relativeY + self.camera.y
  
  self:checkLife()

  self.anim:update(dt)
end

function life:draw()
  self.anim:draw(self.spriteSheet, self.x, self.y, nil, self.scaleSprite)
end

return life
