Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local globe = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function globe:init(world, x, y)
  self.isGlobe = true
  self.player = world.player 
  self.spriteSheet = love.graphics.newImage('/assets/entities/globe.png')
  self.scaleFactor = 1
  Entity.init(self, world, x, y, 256 * self.scaleFactor, 256 * self.scaleFactor)
  self.world:add(self, self:getRect())
  self.mouse = mouse
  self.grid = anim8.newGrid(256, 256, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.yVelocity = 0
  self.friction = 20
  self.gravity = 80
  self.isGrounded = false
  self.animations = {}
  self.animations.globe = anim8.newAnimation(self.grid('1-2', 1), 0.2)
  self.soundGoingUp = love.audio.newSource('/assets/sound/globe/soundGoingUp.mp3', 'static')
  
  self.travelActive = false
  self.anim = self.animations.globe
  self.anim:gotoFrame(1)
  
  self.isAway = false
end


function globe:collisionFilter(other)
  if other.isPlayer then
    return 'cross'
  end

  return 'slide'
end

function globe:collisionIgnore(other)
  return nil
end

function globe:travel(dt)
  self.soundGoingUp:play()
  self.y = self.y - 80*dt
  self.world:update(self, self.x, self.y) 
end



function globe:update(dt)

  if not self.travelActive then
    self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))
  
  
    self.yVelocity = self.yVelocity + self.gravity * dt
    local goalX = self.x 
    local goalY = self.y + self.yVelocity
  
    self.x, self.y, cols, len = self.world:move(self, goalX, goalY, self.collisionFilter)

    for i, coll in ipairs(cols) do
      if coll.other.isPlayer and love.keyboard.isDown("j") then
        self.player:hide()
        self.anim:gotoFrame(2)
        self.travelActive = true
      end
    end
  end

  if self.travelActive then
    self:travel(dt)
  end
  
  if self.y < 200 then
    self.isAway = true
  end
end

function globe:draw()
  self.anim:draw(self.spriteSheet, self.x, self.y, nil, self.scaleFactor)
end

return globe
