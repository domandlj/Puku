Gamestate = require 'libs.hump.gamestate'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local mouseControl = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function mouseControl:init(world, x, y)
  self.relativeX = x
  self.relativeY = y
  self.isMouseControl = true
  self.spriteSheet = love.graphics.newImage('/assets/entities/mouseControl.png')
  self.soundSwitch = love.audio.newSource('/assets/sound/mouseControl/soundSwitch.wav', 'static') 
  self.soundBark = love.audio.newSource('/assets/sound/dog/soundBark.mp3', 'static')
  Entity.init(self, world, x, y, 100, 200)
  self.world:add(self, self:getRect())
  self.mouse = world.mouse
  self.camera = world.camera
  self.grid = anim8.newGrid(self.w, self.h, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.animations = {}
  self.animations.buttons = anim8.newAnimation(self.grid('1-2', 1), 0.2)
  self.anim = self.animations.buttons
  self.anim:gotoFrame(1)
end

function range(a, i, b) 
  return a <= i and i <= b
end

function mouseControl:mouseIsTouching(x2, y2, w2, h2)
  local x = self.x + x2
  local y = self.y + y2
  local w = w2 
  local h = h2 
  local mouseX = self.mouse.x 
  local mouseY = self.mouse.y  
  local condX = range(x, mouseX, x + w)
  local condY = range(y, mouseY, y + h)

  return condX and condY
end

function mouseControl:collisionFilter(other)
    if other.isPuku then
      return nil
    end
    return 'touch'
end

function mouseControl:mouseIsTouchingMove() 
  return self:mouseIsTouching(0, 30, 60, 60)
end

function mouseControl:mouseIsTouchingDog() 
  return self:mouseIsTouching(0, 110, 60, 60)
end

function mouseControl:update(dt)
  self.x = self.camera.x + self.relativeX
  self.y = self.camera.y + self.relativeY
  
  if self:mouseIsTouchingMove() then
    if love.mouse.isDown(1) then
      self.soundSwitch:play()
      self.anim:gotoFrame(1)
      self.mouse:setModeMove()
    end
  end

  if self:mouseIsTouchingDog() then
    if love.mouse.isDown(1) then
      self.soundSwitch:play()
      self.soundBark:play()
      self.anim:gotoFrame(2)
      self.mouse:setModeDog()
    end
  end
    

  --self.anim:update(dt)
end

function mouseControl:draw()
  self.anim:draw(self.spriteSheet, self.x, self.y)
end

return mouseControl
