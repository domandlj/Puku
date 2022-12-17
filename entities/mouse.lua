Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local mouse = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function mouse:init(world, x, y)
  self.camera = world.camera
  self.isMouse = true
  self.soundActive = true
  self.spriteSheet = love.graphics.newImage('/assets/entities/mouse.png')
  self.soundClick = love.audio.newSource('assets/sound/mouse/click.wav', 'static')

  self.scaleFactor = 1.8
  Entity.init(self, world, x, y, 20 * self.scaleFactor, 20 * self.scaleFactor)

    -- These are values applying specifically to jumping
  self.isJumping = false -- are we in the process of jumping?
  self.isGrounded = false -- are we on the ground?
  self.hasReachedMax = false  -- is this as high as we can go?
  self.jumpAcc = 500 -- how fast do we accelerate towards the top
  self.jumpMaxSpeed = 11 -- our speed limit while jumping

  self.world:add(self, self:getRect())

  self.grid = anim8.newGrid(20, 20, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

  self.animations = {}
  self.animations.mouse = anim8.newAnimation(self.grid('1-2', 1), 0.2) 
  self.anim = self.animations.mouse
  self.mode = 0 -- 0 is mode move, 1 is mode Dog
  self.grabbingId = 0
  self.locked = false
end

function mouse:lock()
  self.locked = true
end

function mouse:unlock()
  self.locked = false
end

function mouse:setGrabbing(id)
  self.grabbingId = id  
end

function mouse:isGrabbing(id)
  return self.grabbingId == id
end

function mouse:relaseGrabbing()
  self.grabbingId = 0
end

function mouse:setModeDog()
  self.mode = 1
end

function mouse:setModeMove()
  self.mode = 0
end

function mouse:onModeMove()
  return self.mode == 0
end

function mouse:update(dt)
  if not self.locked then
    self.x = love.mouse.getX() + self.camera.x
    self.y = love.mouse.getY() + self.camera.y
  end

  if love.mouse.isDown(1) then
    self.anim:gotoFrame(2)

    if self.soundActive then
      love.audio.play(self.soundClick)
    end
    self.soundActive = false
    
  else
    self.anim:gotoFrame(1)
    if not self.soundActive then
      love.audio.play(self.soundClick)
    end
    self.soundActive = true
  end
  
  self.anim:update(dt) 
end

function mouse:draw()
  self.anim:draw(self.spriteSheet, self.x, self.y, nil, self.scaleFactor)
end

return mouse
