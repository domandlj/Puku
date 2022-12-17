Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local flower = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function flower:init(world, x, y)
  self.isFlower = true
  self.spriteSheet = love.graphics.newImage('/assets/entities/flower.png')
  self.scaleFactor = 1
  Entity.init(self, world, x, y, 64 * self.scaleFactor, 64 * self.scaleFactor)
  self.world:add(self, self:getRect())
  self.mouse = world.mouse
  self.grid = anim8.newGrid(64, 64, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.yVelocity = 0
  self.friction = 20
  self.gravity = 80
  self.isGrounded = false
  self.isFlower = true
  self.animations = {}
  self.animations.flower = anim8.newAnimation(self.grid('1-6', 1), 0.2)
  self.animations.crying = anim8.newAnimation(self.grid('1-6', 2), 0.2)
  self.soundCartoonScream = love.audio.newSource('/assets/sound/flower/soundCartoonScream.wav', 'static')
  self.anim = self.animations.flower
end

function range(a, i, b) 
  return a <= i and i <= b
end

function flower:mouseIsTouching()
  local x = self.x
  local y = self.y
  local w = self.w
  local h = self.h
  local mouseX = self.mouse.x
  local mouseY = self.mouse.y
  local condX = range(x, mouseX, x + w)
  local condY = range(y, mouseY, y + h)

  return condX and condY
end

function flower:collisionFilter(other)
  if other.isPlayer then 
    return nil
  else
    return 'touch'
  end
end

function flower:checkUnderAttack()
  if self.isAttacked then
    self.soundCartoonScream:play()
    self.anim = self.animations.crying
  end
end

function flower:update(dt)
  self.anim = self.animations.flower
  self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))
  
  if love.mouse.isDown(1) and self.mouse:onModeMove() then
    if self:mouseIsTouching() then
      self.soundCartoonScream:play()
      self.anim = self.animations.crying    
      self.x = self.mouse.x - 30
      self.y = self.mouse.y - 30
    end
  end
  
  self.yVelocity = self.yVelocity + self.gravity * dt
  local goalX = self.x 
  local goalY = self.y + self.yVelocity
  
  self.x, self.y, cols, len = self.world:move(self, goalX, goalY, self.collisionFilter)
  
  self:checkUnderAttack()
  self.isAttacked = false 
  self.anim:update(dt)
end

function flower:draw()
  self.anim:draw(self.spriteSheet, self.x, self.y, nil, self.scaleFactor)
end

return flower
