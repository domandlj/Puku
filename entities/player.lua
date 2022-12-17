Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local player = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function player:init(world, x, y)
  self.isPlayer = true
  self.spriteSizeX = 30
  self.spriteSizeY = 50
  self.scaleSprite = 2.5
  self.spriteSheet = love.graphics.newImage('/assets/entities/jose.png')
  Entity.init(self, world, x, y, 
    self.spriteSizeX * self.scaleSprite, self.spriteSizeY * self.scaleSprite)

  -- Add our unique player values
  self.xVelocity = 0 -- current velocity on x, y axes
  self.yVelocity = 0
  self.acc = 100 -- the acceleration of our player
  self.maxSpeed = 300 -- the top speed
  self.friction = 20 -- slow our player down - we could toggle this situationally to create icy or slick platforms
  self.gravity = 80 -- we will accelerate towards the bottom

    -- These are values applying specifically to jumping
  self.isJumping = false -- are we in the process of jumping?
  self.isGrounded = false -- are we on the ground?
  self.hasReachedMax = false  -- is this as high as we can go?
  self.jumpAcc = 700 -- how fast do we accelerate towards the top
  self.jumpMaxSpeed = 11 -- our speed limit while jumping
  self.jumps = 100
  self.world:add(self, self:getRect())

  self.grid = anim8.newGrid(self.spriteSizeX, self.spriteSizeY, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.animations = {}
  self.animations.attacked = anim8.newAnimation(self.grid('1-2', 5), 0.2)
  self.animations.attack = anim8.newAnimation(self.grid('1-2', 4), 0.2)
  self.animations.idle = anim8.newAnimation(self.grid('1-1', 3), 0.2)
  self.animations.right = anim8.newAnimation(self.grid('1-8', 1), 0.2)
  self.animations.left = anim8.newAnimation(self.grid('1-8', 2), 0.2)
  self.animations.teleporting = anim8.newAnimation(self.grid('1-16', 6), 0.2)
  self.animations.hide = anim8.newAnimation(self.grid('8-8', 6), 0.2)
  self.anim = self.animations.left
  self.goingRight = true
  self.attackLeft = 20

  -- sounds
  self.soundJump = love.audio.newSource('/assets/sound/player/soundJump.wav', 'static')
  self.soundWalking = love.audio.newSource('assets/sound/player/soundWalking.wav', 'static')
  self.soundPlayerAttack = love.audio.newSource('/assets/sound/player/soundPlayerAttack.wav', 'static')
  self.soundPlayerAttack:setPitch(1.2)
  self.soundPipe = love.audio.newSource('/assets/sound/pipe/soundPipe.wav', 'static')
  

  self.locked = false
  self.teleporting = false
  self.wait = 0
end


function player:lock()
  self.locked = true
end

function player:unlock()
  self.locked = false 
end

function player:collisionFilter(other)
  local x, y, w, h = self.world:getRect(other)
  local playerBottom = self.y + self.h
  local otherBottom = y + h
  
  if other.isFlower then
    return nil 
  elseif other.isPukuCounter then
    return nil
  elseif other.isGlobe then
    return 'cross'
  elseif other.isZombie then
    return 'touch'
  elseif other.isMonkeyBoss then
     return 'touch'
  end

  if playerBottom <= y then -- bottom of player collides with top of platform.
    return 'slide'
  else
    return 'slide'
  end
  

end

function player:canAttack()
  return self.attackLeft > 0
end


function player:resetAttackLeft()
  self.attackLeft = 20
end

function player:isDying()
  if self.life < 20 then
    return true
  else
    return false
  end
end

function player:decrementAttackLeft() 
  self.attackLeft = self.attackLeft - 1 
end

function player:canMove()
  if not self:isDying() and not self.locked then
    return true
  else
    return false
  end
end

function player:hide()
  self.hidden = true
  self:lock()
  self.anim = self.animations.hide
end

 function player:attack(entity)
  if self:canAttack() and self:canMove() then
    if entity.isZombie then
      entity.life = entity.life - 0.7
      entity.isAttacked = true
    end

    if entity.isMonkeyBoss then
      entity.life = entity.life - 0.2
      entity.isAttacked = true
    end
    
    self.anim = self.animations.attack
  
    if self.goingRight then
      self.anim:gotoFrame(1)
    else
      self.anim:gotoFrame(2)
    end
  
    self:decrementAttackLeft()
    love.audio.play(self.soundPlayerAttack)
  end
end


function player:checkUnderAttack()
  if self.isAttacked then
    self.anim = self.animations.attacked
    self.anim:gotoFrame(1)  
  end 
end

function player:moveLeft(dt)
  if self:canMove() and self.xVelocity > -self.maxSpeed then
    self.goingRight = false
    self.xVelocity = self.xVelocity - self.acc * dt
    self.anim = self.animations.left
    self.isMoving = true
 
    if self.isGrounded then
      love.audio.play(self.soundWalking)
    end
  end
end

function player:moveRight(dt)
  if self:canMove() and self.xVelocity < self.maxSpeed then
    self.goingRight = true
    self.xVelocity = self.xVelocity + self.acc * dt
    self.anim = self.animations.right
    self.isMoving = true
  
    if self.isGrounded then
      love.audio.play(self.soundWalking)
    end
  end
end

function player:jump(dt) 
  if self:canMove() then
    if -self.yVelocity < self.jumpMaxSpeed and not self.hasReachedMax then
      self.yVelocity = self.yVelocity - self.jumpAcc * dt
      love.audio.play(self.soundJump)
    elseif math.abs(self.yVelocity) > self.jumpMaxSpeed then
      self.hasReachedMax = true
    end
    self.isJumping = true
    self.isGrounded = false -- we are no longer in contact with the ground
    self.jumps = self.jumps - 1
  end
end



function player:checkNormalForces(coll)
  if coll.normal.x ~= 0 then
    self.hasReachedMax = false
    self.isGrounded = false
  elseif coll.normal.y < 0 then
    self.hasReachedMax = false
    self.isGrounded = true
  end
end
    
function player:checkDying()
  if self.life < 20 then
    self.anim = self.animations.attacked
    self.anim:gotoFrame(2)
  end 
end

function player:checkIdle()
  if not self.isMoving then
    self.anim:gotoFrame(1)
  end 
end

function player:regenerateLife()
  if self.life > 0 and self.life < 100 then
    self.life = self.life + 0.02
  end
end


function player:cameraMove(dt)
   if love.keyboard.isDown("o") then
    if self.pressed == 0 then
      self.oldX = self.x
    end
    --self.render = false

    self.x = self.x + dt*500
    self.pressed = self.pressed + 1
  end 

  if not love.keyboard.isDown("o") and self.pressed > 0 then
    self.x = self.oldX
    self.pressed = 0
    --self.render = true
  end 
 

end

function player:teleport()
  self.soundPipe:play()
  self.teleporting = true
end

function player:teleportingAnimation(dt)
  if self.wait < 3.2 then
    self:lock()
    self.anim = self.animations.teleporting
    self.wait = self.wait + dt

  else
    self:unlock()
    self.anim = self.animations.idle
    self.teleporting = false
    self.wait = 0
  end

end


function player:canJump()
  return self.jumps > 0 
end

function player:needsToJump(other)
  if other['properties'] ~= nil then
    if other.properties['jumpable'] ~= nil and love.keyboard.isDown('a', 'd') then
      return true
    end
  end
  
  if other.isPuku and love.keyboard.isDown('a', 'd') then
    return true 
  end

  return false
end

function player:action(dt)
  local prevX, prevY = self.x, self.y
  
  self.isMoving = false

  -- Apply Friction
  self.xVelocity = self.xVelocity * (1 - math.min(dt * self.friction, 1))
  self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))

  -- Apply gravity
  self.yVelocity = self.yVelocity + self.gravity * dt
 
	if love.keyboard.isDown("left", "a") then
    self:moveLeft(dt)

	elseif love.keyboard.isDown("right", "d") then
	  self:moveRight(dt)
	end
  
  if not self.isMoving and not self.hidden then
    self.anim = self.animations.idle
  end
   

  -- The Jump code gets a lttle bit crazy.  Bare with me.
  if love.keyboard.isDown("up", "w") and self:canJump() then
    self:jump(dt)
  elseif not love.keyboard.isDown("up", "w") then
    self.jumps = (self.jumps + 1 ) % 100 
  end


  -- these store the location the player will arrive at should
  local goalX = self.x + self.xVelocity
  local goalY = self.y + self.yVelocity

  -- Move the player while testing for collisions
  if self:canMove() then
    self.x, self.y, collisions, len = self.world:move(self, goalX, goalY, self.collisionFilter)
  
    -- Loop through those collisions to see if anything important is happening
    for i, coll in ipairs(collisions) do
   

      if self:needsToJump(coll.other) then 
        self:jump(dt)
      end
      
      -- Check normal forces
      self:checkNormalForces(coll)
    
   
      if love.keyboard.isDown("j") then
        self:attack(coll.other)
      elseif not love.keyboard.isDown("j") then
        self:resetAttackLeft()
      end 

    end
  end
  self:checkIdle()
  self:checkDying()
  self:checkUnderAttack()
  self:regenerateLife()
  self.isAttacked = false
  

end

function player:update(dt)
  if not self.teleporting then
    self:action(dt) 
  else
    self:teleportingAnimation(dt)
  end
  self.anim:update(dt)
end

function player:draw()
  self.anim:draw(self.spriteSheet, self.x, self.y, nil, self.scaleSprite)
end

return player
