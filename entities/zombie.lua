Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local zombie = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function zombie:init(world, x, y, limitA, limitB, waitToSpawn)
  self.isZombie = true
  self.player = world.player
  self.limitA = limitA
  self.limitB = limitB
  self.waitToSpawn = waitToSpawn
  self.spriteSizeX = 75
  self.spriteSizeY = 128
  self.scaleSprite = 1
  self.spriteSheet = love.graphics.newImage('/assets/entities/zombie1.png')
  Entity.init(self, world, x, y, self.spriteSizeX * self.scaleSprite, self.spriteSizeY * self.scaleSprite)

  -- Add our unique player values
  self.xVelocity = 0 -- current velocity on x, y axes
  self.yVelocity = 0
  self.acc = 30 -- the acceleration of our player
  self.maxSpeed = 50 -- the top speed
  self.friction = 20 -- slow our player down - we could toggle this situationally to create icy or slick platforms
  self.gravity = 80 -- we will accelerate towards the bottom

    -- These are values applying specifically to jumping
  self.isJumping = false -- are we in the process of jumping?
  self.isGrounded = false -- are we on the ground?
  self.hasReachedMax = false  -- is this as high as we can go?
  self.jumpAcc = 700 -- how fast do we accelerate towards the top
  self.jumpMaxSpeed = 20 -- our speed limit while jumping

  self.world:add(self, self:getRect())

  self.grid = anim8.newGrid(self.spriteSizeX, self.spriteSizeY, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

  self.animations = {}
  self.animations.right = anim8.newAnimation(self.grid('1-6', 1), 0.15)
  self.animations.left = anim8.newAnimation(self.grid('1-6', 2), 0.15)
  self.animations.attacked = anim8.newAnimation(self.grid('1-2', 3), 0.15)
  self.animations.spawn = anim8.newAnimation(self.grid('1-10', 4), 0.20, 'pauseAtEnd')
  self.anim = self.animations.spawn
  
  self.goingRight = true

  --spawning
  self.spawnFrame = 1
  self.spawnCounter = 0
  --sounds
  self.soundZombieAttack = love.audio.newSource('/assets/sound/zombie/soundZombieAttack.mp3', 'static')
end

function zombie:collisionFilter(other)
  local x, y, w, h = self.world:getRect(other)
  local playerBottom = self.y + self.h
  local otherBottom = y + h
  
  if other['properties'] ~= nil then
      if other.properties['jumpable'] ~= nil then
        return 'touch'
      end
  end

  if other.isPukuCounter then
    return nil
  end
  


  if other.isFlower then
      return 'touch' 
  end
  
  if other.isDog then 
    return 'touch'
  end
 
  if other.isZombie then
    return 'touch'
  elseif other.isPlayer then
    return 'touch'
  else
    return 'slide'
  end
  

end

function zombie:checkMovingDirection(dt)
   -- If out of bounds position go otherwise 
  if self.goingRight and self.x >= self.limitB then
    self.goingRight = false
    self.x = self.limitB
  end

  if not self.goingRight and self.x <= self.limitA then
    self.goingRight = true
    self.x = self.limitA
  end   
end

function zombie:moveLeft(dt)
  self.xVelocity = self.xVelocity - self.acc * dt
  self.anim = self.animations.left
  self.isMoving = true
  self.goingRight = false
end

function zombie:moveRight(dt)
  self.xVelocity = self.xVelocity + self.acc * dt
  self.anim = self.animations.right
  self.isMoving = true
  self.goingRight = true
end

function zombie:followPlayer()
  
  local distance = self.x - self.player.x
  local toTheRight = distance <= 0

  if math.abs(distance) < 100 then
    if toTheRight then
      self.goingRight = true
    else
      self.goingRight = false
    end
  end

end

function zombie:jump(dt)
  if -self.yVelocity < self.jumpMaxSpeed and not self.hasReachedMax then
    self.yVelocity = self.yVelocity - self.jumpAcc * dt * 2
  elseif math.abs(self.yVelocity) > self.jumpMaxSpeed then
    self.hasReachedMax = true
  end
  
  self.isGrounded = false -- we are no longer in contact with the ground

  self.x, self.y, c, l = self.world:move(self, self.x + self.xVelocity, self.y + self.yVelocity)
end

function zombie:checkUnderAttack()
  if self.isAttacked then
    self.anim = self.animations.attacked
    if self.goingRight then
      self.anim:gotoFrame(1)
    else
      self.anim:gotoFrame(2)
    end 
  end 
end

function zombie:attack(entity)
  if entity.isPlayer then
    entity.life = entity.life - 0.8
    entity.isAttacked = true
    love.audio.play(self.soundZombieAttack)
  end

  if entity.isFlower then
    entity.life = entity.life - 0.8
    entity.isAttacked = true
    love.audio.play(self.soundZombieAttack)
  end

end


function zombie:spawn(dt)
  
  local actualX, actualY, cols, len = self.world:move(self, self.x, self.y, self.collisionFilter)
   
  self.anim:update(dt)
  self.spawnFrame = self.spawnFrame + dt*3
end

function zombie:action(dt)

  local prevX, prevY = self.x, self.y
  
  self.isMoving = false

  -- Apply Friction
  self.xVelocity = self.xVelocity * (1 - math.min(dt * self.friction, 1))
  self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))

  -- Apply gravity
  self.yVelocity = self.yVelocity + self.gravity * dt
 
 
  self:checkMovingDirection(dt)
  -- If in bounds poisition continue walking left or right 
	if not self.goingRight and self.xVelocity > -self.maxSpeed then
    self:moveLeft(dt) 
	elseif self.goingRight and self.xVelocity < self.maxSpeed then
	  self:moveRight(dt)
  end

  if not self.isMoving then
    if self.goingRight then
      self.anim = self.animations.right
    else
      self.anim = self.animations.left
    end
  end

  -- these store the location the player will arrive at should
  local goalX = self.x + self.xVelocity
  local goalY = self.y + self.yVelocity 


    -- Move the player while testing for collisions
  self.x, self.y, collisions, len = self.world:move(self, goalX, goalY, self.collisionFilter)
  
  -- Loop through those collisions to see if anything important is happening
  for i, coll in ipairs(collisions) do

     
    if coll.other['properties'] ~= nil then
      if coll.other.properties['jumpable'] ~= nil then
        self:jump(dt)
      end
    end

    

    if (coll.other.isPlayer or coll.other.isFlower) and not self.isAttacked then
      self:attack(coll.other)
    end
   
  end

  if not self.isMoving then
    self.anim:gotoFrame(1)
  end
  
  self:followPlayer()
  
  self:checkUnderAttack()
  
  self.anim:update(dt)
  
  self.isAttacked = false
end

function zombie:update(dt)
  if self.spawnFrame >= 10 then
    self:action(dt)
  elseif self.spawnCounter < self.waitToSpawn then
    self.spawnCounter = self.spawnCounter + 3*dt
  else
    self:spawn(dt)
  end
end

function zombie:draw()

  self.anim:draw(self.spriteSheet, self.x, self.y, nil, self.scaleSprite)
end

return zombie
