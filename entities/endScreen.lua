Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local endScreen = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function endScreen:init(world, x, y)
  Entity.init(self, world, x, y, 512, 256)
  self.relativeX = x
  self.relativeY = y
  self.camera = world.camera
  self.spriteSheet = love.graphics.newImage('/assets/entities/menus/endScreen.png')
  self.grid = anim8.newGrid(512, 256, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.animations = {}
  self.animations.endScreen = anim8.newAnimation(self.grid(1, '1-12'), 0.2)
end

    
function endScreen:update(dt)
  self.x = self.camera.x + self.relativeX
  self.y = self.camera.y + self.relativeY
  
  self.animations.endScreen:update(dt)
end

function endScreen:draw()
  self.animations.endScreen:draw(self.spriteSheet, self.x, self.y)  
end

return endScreen
