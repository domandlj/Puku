Gamestate = require 'libs.hump.gamestate'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local pukuGrown = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function pukuGrown:init(world, x, y, mouse)
  self.isPukuGrown = true
  self.spriteSheet = love.graphics.newImage('/assets/entities/pukuOneGrown.png')
  Entity.init(self, world, x, y, 32, 320)
  self.world:add(self, self:getRect())
  self.mouse = world.mouse
  self.yVelocity = 0
  self.friction = 20
  self.gravity = 80
  self.isGrounded = false
  self.soundPukuGrowing = love.audio.newSource('/assets/sound/puku/soundPukuGrowing.mp3', 'static')
  self.soundPukuGrabbed = love.audio.newSource('/assets/sound/puku/soundPukuGrabbed.wav', 'static')
  self.grid = anim8.newGrid(self.w, self.h, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.animations = {}
  self.animations.pukuOne = anim8.newAnimation(self.grid('1-6', 1), 0.2)
  self.animations.pukuSelected = anim8.newAnimation(self.grid('1-6', 2), 0.2)
  self.introDurationFrame = 0.3
  self.animations.pukuIntro = anim8.newAnimation(self.grid('1-6', 3),self.introDurationFrame , 'pauseAtEnd')
  self.anim = self.animations.pukuIntro
  self.soundPukuGrowing:play()
  self.dtotal = 0
end

function range(a, i, b) 
  return a <= i and i <= b
end

function pukuGrown:mouseIsTouching()
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

function pukuGrown:collisionFilter(other)
    if other.isPuku then
      return nil
    end
    return 'touch'
end


function pukuGrown:update(dt)
  self.dtotal = self.dtotal + dt
  
 
  self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))
  
  self.yVelocity = self.yVelocity + self.gravity * dt


  if self:mouseIsTouching() then
    self.anim = self.animations.pukuSelected
  elseif not self:mouseIsTouching() and self.dtotal >= self.introDurationFrame * 6 then
    self.anim = self.animations.pukuOne
  end
  
  local goalX = self.x 
  local goalY = self.y + self.yVelocity
  
  self.x, self.y, cols, len = self.world:move(self, goalX, goalY, self.collisionFilter)
  
  if self:mouseIsTouching() and self.mouse:onModeMove() then
    if love.mouse.isDown(1) then
      self.soundPukuGrabbed:play()
      self.x, self.y, c, l = self.world:move(self, self.mouse.x - 6, self.mouse.y - 16)
    end
  end
  
  if not love.mouse.isDown(1) then
    self.soundPukuGrabbed:stop()
  end

  self.anim:update(dt)
end

function pukuGrown:draw()
  self.anim:draw(self.spriteSheet, self.x, self.y)
end

return pukuGrown
