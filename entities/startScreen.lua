Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local startScreen = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function startScreen:init(world, x, y)
  Entity.init(self, world, x, y, 512, 512)
  self.relativeX = x
  self.relativeY = y
  self.camera = world.camera
  self.mouse = world.mouse
  self.spriteSheet = love.graphics.newImage('/assets/entities/menus/startScreen.png')
  self.grid = anim8.newGrid(self.w, self.h, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.animations = {}
  self.animations.deadScreen = anim8.newAnimation(self.grid('1-4', 1), 0.2)
  self.animations.deadScreen:gotoFrame(1)
  self.option = 0
  self.isActive = false
  self.pressingOne = false
  self.pressingTwo = false
  self.world:add(self, 0,0, 1, 1) --dummy add to world, no collision with it
  self.start = false
  self.soundCoin = love.audio.newSource('/assets/sound/menus/soundCoin.wav', 'static')
end

function range(a, i, b) 
  return a <= i and i <= b
end

function startScreen:mouseIsTouching(x, y, w, h)
  local mouseX = self.mouse.x
  local mouseY = self.mouse.y
  local condX = range(x, mouseX, x + w)
  local condY = range(y, mouseY, y + h)

  return condX and condY
end


function startScreen:startActive()
  return self.start
end

function startScreen:buttonOneSelected()
  if self:mouseIsTouching(self.x + 90, self.y + 350, 140, 50) then
    return true
  else
    return false
  end
end

function startScreen:buttonTwoSelected()
  if self:mouseIsTouching(self.x + 260, self.y + 350, 140, 50) then
    return true
  else
    return false
  end
end

function startScreen:handleInput()
  if love.keyboard.isDown('d') or self:buttonTwoSelected() and self.option ~= 1 then
    self.option = 1
    self.animations.deadScreen:gotoFrame(3)
    self.soundCoin:play()
  end

  if love.keyboard.isDown('a') or self:buttonOneSelected() and self.option ~= 0 then
    self.option = 0
    self.animations.deadScreen:gotoFrame(1)
    self.soundCoin:play()
  end
  
  if love.mouse.isDown(1) then
    if self:buttonOneSelected() then 
      self.animations.deadScreen:gotoFrame(1)
      self.pressingOne = true
      self.start = true
    elseif self:buttonTwoSelected() then
      self.animations.deadScreen:gotoFrame(4)
      self.pressingTwo = true
      love.event.quit()
    end

  end

  if love.keyboard.isDown('space') then
    if self.option == 0 then
      self.animations.deadScreen:gotoFrame(2)
      self.start = true
    else
      self.animations.deadScreen:gotoFrame(4)
      love.event.quit()
    end
  end
end

function startScreen:update(dt)
  self.x = self.camera.x + self.relativeX
  self.y = self.camera.y + self.relativeY
  --self.pressingOne = false
  --self.pressingTwo = false
  self:handleInput()

end

function startScreen:draw()
   self.animations.deadScreen:draw(self.spriteSheet, self.x, self.y)    
end

return startScreen
