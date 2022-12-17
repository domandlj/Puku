Gamestate = require 'libs.hump.gamestate'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'
local pukuGrown = require 'entities.pukuGrown'

local puku = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function puku:init(world, x, y)
  self.isPuku = true
  self.player = world.player
  self.spriteSheet = love.graphics.newImage('/assets/entities/pukuOne.png')
  self.soundPukuGrabbed = love.audio.newSource('/assets/sound/puku/soundPukuGrabbed.wav', 'static') 
  Entity.init(self, world, x, y, 32, 32)
  self.world:add(self, self:getRect())
  self.mouse = world.mouse
  self.yVelocity = 0
  self.friction = 20
  self.gravity = 80
  self.isGrounded = false
  self.hasGrown = false
  self.id = math.random(1, 999999)
  self.grid = anim8.newGrid(self.w, self.h, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.animations = {}
  self.animations.pukuOne = anim8.newAnimation(self.grid('1-6', 1), 0.2)
  self.animations.pukuSelected = anim8.newAnimation(self.grid('1-6', 2), 0.2)
  self.anim = self.animations.pukuOne
end

function range(a, i, b) 
  return a <= i and i <= b
end

function puku:mouseIsTouching()
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

function puku:collisionFilter(other)
    if other.isPuku then
      return 'touch'
    end
    return 'touch'
end

function puku:update(dt)
  self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))
  
  self.yVelocity = self.yVelocity + self.gravity * dt


  if self:mouseIsTouching() then
    self.anim = self.animations.pukuSelected
  else
    self.anim = self.animations.pukuOne
  end

  local goalX = self.x 
  local goalY = self.y + self.yVelocity
  
  self.x, self.y, cols, len = self.world:move(self, goalX, goalY, self.collisionFilter)
  if (self:mouseIsTouching() or self.mouse:isGrabbing(self.id)) and self.mouse:onModeMove() then
    if love.mouse.isDown(1)  then
      self.player:lock()
      self.soundPukuGrabbed:play()
      self.x, self.y, c, l = self.world:move(self, self.mouse.x, self.mouse.y)
      self.mouse:setGrabbing(self.id)
      self.grabbing = true
    end
  end
  
  if self.grabbing and not love.mouse.isDown(1) then
    self.player:unlock()
    self.mouse:relaseGrabbing()
    self.soundPukuGrabbed:stop()
    self.grabbing = false
  end

  

  self.anim:update(dt)
end

function puku:draw()
  self.anim:draw(self.spriteSheet, self.x, self.y)
end

return puku
