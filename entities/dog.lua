Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local dog = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function dog:init(world, x, y)
  self.isDog = true
  self.player = world.player
  self.mouse = world.mouse
  self.spriteSheet = love.graphics.newImage('/assets/entities/dog.png')
  self.scaleFactor = 1.8
  Entity.init(self, world, x, y, 40*self.scaleFactor, 40 *self.scaleFactor)
  self.count = 0
  -- Add our unique player values
  self.xVelocity = 0 -- current velocity on x, y axes
  self.yVelocity = 0
  self.acc = 80 -- the acceleration of our player
  self.maxSpeed = 600 -- the top speed
  self.friction = 20 -- slow our player down - we could toggle this situationally to create icy or slick platforms
  self.gravity = 100 -- we will accelerate towards the bottom

    -- These are values applying specifically to jumping
  self.isJumping = false -- are we in the process of jumping?
  self.isGrounded = false -- are we on the ground?
  self.hasReachedMax = false  -- is this as high as we can go?
  self.jumpAcc = 500 -- how fast do we accelerate towards the top
  self.jumpMaxSpeed = 11 -- our speed limit while jumping

  self.world:add(self, self:getRect())

  self.grid = anim8.newGrid(40, 40, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

  self.animations = {}
  self.animations.right = anim8.newAnimation(self.grid('1-6', 1), 0.1)
  self.animations.left = anim8.newAnimation(self.grid('1-6', 2), 0.1)
  self.animations.attackLeft = anim8.newAnimation(self.grid('1-5', 3), 0.1)
  self.animations.attackRight = anim8.newAnimation(self.grid('1-5', 4), 0.1)
  self.anim = self.animations.left
  self.soundDogAttack = love.audio.newSource('/assets/sound/dog/soundDogAttack.wav', 'static')
  --attack
  self.attackLeft = 20
  self.goingRight = true
end

function dog:jump(dt)
  if -self.yVelocity < self.jumpMaxSpeed and not self.hasReachedMax then
    self.yVelocity = self.yVelocity - self.jumpAcc * dt * 2
  elseif math.abs(self.yVelocity) > self.jumpMaxSpeed then
    self.hasReachedMax = true
  end

  self.isGrounded = false -- we are no longer in contact with the ground

  self.x, self.y, c, l = self.world:move(self, self.x + self.xVelocity, self.y + self.yVelocity)
end

function dog:canAttack()
  return self.attackLeft > 0
end


function dog:resetAttackLeft()
  self.attackLeft = 20
end

function dog:decrementAttackLeft()
  self.attackLeft = self.attackLeft - 1
end

function dog:moveLeft(dt)
  self.xVelocity = self.xVelocity - self.acc *dt
  self.anim = self.animations.left
  self.goingRight = false
  self.isMoving = true
end

function dog:moveRight(dt)
  self.xVelocity = self.xVelocity + self.acc *dt
  self.anim = self.animations.right
  self.goingRight = true
  self.isMoving = true
end

function dog:attack(entity)
  if self:canAttack() then
    if entity.isZombie then
      self.soundDogAttack:play()
      entity.life = entity.life - 3
      entity.isAttacked = true
    end


    if self.goingRight then
      self.anim = self.animations.attackRight
    else
      self.anim = self.animations.attackLeft
    end

    self:decrementAttackLeft()
  end
end


function dog:needsToJump(other)
  if other['properties'] ~= nil then
    if other.properties['jumpable'] ~= nil and love.mouse.isDown(1) then
      return true
    end
  end
  
  return false
end 

function dog:collisionFilter(other)
  local x, y, w, h = self.world:getRect(other)
  local playerBottom = self.y + self.h
  local otherBottom = y + h
  
  if other.isPlayer then
    return 'touch'
  elseif other.isFlower then
    return nil
  elseif other.isZombie then
    return 'touch'
  elseif other.isMonkeyBoss then
    return nil
  elseif other.isPuku or other.isPukuGrown then
    return 'touch'
  end

  if other.isPukuCounter then
    return nil
  end
  return 'slide'
end

function dog:update(dt)
  local prevX, prevY = self.x, self.y

  self.isMoving = false

  -- Apply Friction
  self.xVelocity = self.xVelocity * (1 - math.min(dt * self.friction, 1))
  self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))

  -- Apply gravity
  self.yVelocity = self.yVelocity + self.gravity * dt

	if love.mouse.isDown(1) and not self.mouse:onModeMove() and self.xVelocity > -self.maxSpeed then
    if self.mouse.x <= prevX then
      self:moveLeft(dt)
    else
      self:moveRight(dt)
    end 
	end

  -- these store the location the player will arrive at should
  local goalX = self.x + self.xVelocity
  local goalY = self.y + self.yVelocity

  -- Move the player while testing for collisions
  self.x, self.y, collisions, len = self.world:move(self, goalX, goalY, self.collisionFilter)

  -- Loop through those collisions to see if anything important is happening
  for i, coll in ipairs(collisions) do

    if self:needsToJump(coll.other) then
      self:jump(dt)
    end
    

    if love.mouse.isDown(1) and coll.other.isZombie then
        self:attack(coll.other)
      elseif not love.mouse.isDown(1) then
        self:resetAttackLeft()
    end
  end

  if not self.isMoving then
    self.anim:gotoFrame(1)
  end
  self.anim:update(dt)
  self.hasReachedMax = false
end

function dog:draw()
  self.anim:draw(self.spriteSheet, self.x, self.y, nil, self.scaleFactor)
end

return dog
