Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local pukuCounter = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function pukuCounter:init(world, x, y, counter)
  self.isPukuCounter = true
  self.counter = counter
  self.player = world.player
  self.camera = world.camera
  self.relativeX = x
  self.relativeY = y
  self.spriteSizeX = 32
  self.spriteSizeY = 96
  self.scaleSprite = 1
  self.spriteSheet = love.graphics.newImage('/assets/entities/pukuCounter.png')
  self.soundPuzzleSucces = love.audio.newSource('/assets/sound/puku/soundPuzzleSucces.mp3', 'static')
  Entity.init(self, world, x, y, self.spriteSizeX * self.scaleSprite, self.spriteSizeY * self.scaleSprite)
  self.world:add(self, self:getRect())

  self.grid = anim8.newGrid(self.spriteSizeX, self.spriteSizeY, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

  self.animations = {}
  self.animations.counter = anim8.newAnimation(self.grid('1-14', 1), 0.15)
  self.anim = self.animations.counter
  self.anim:gotoFrame(8)
end


function pukuCounter:checkCount()
  local count = self.counter.count
  
  if count == 0 then
    self.anim:gotoFrame(8)
  elseif count == 1 then
    self.anim:gotoFrame(9)
  elseif count == 2 then
    self.anim:gotoFrame(10)
  elseif count == 3 then
    self.anim:gotoFrame(11)
  elseif count == 4 then
    self.anim:gotoFrame(12)
  elseif count == 5 then 
    self.anim:gotoFrame(13)
  elseif count == 6 and not self.done then
    self.anim:gotoFrame(14)
    self.soundPuzzleSucces:play()
    self.done = true
  end
end

function pukuCounter:update(dt)
  self:checkCount()
  --self.anim:update(dt)
end

function pukuCounter:draw()
  self.anim:draw(self.spriteSheet, self.x, self.y, nil, self.scaleSprite)
end

return pukuCounter 
