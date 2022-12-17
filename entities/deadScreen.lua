Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local deadScreen = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function deadScreen:init(world, x, y)
  Entity.init(self, world, x, y, 512, 256)
  self.relativeX = x
  self.relativeY = y
  self.camera = world.camera
  self.mouse = world.mouse
  self.player = world.player
  self.spriteSheet = love.graphics.newImage('/assets/entities/menus/deadScreen.png')
  self.grid = anim8.newGrid(512, 256, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.animations = {}
  self.animations.deadScreen = anim8.newAnimation(self.grid(1, '1-4'), 0.2)
  self.animations.deadScreen:gotoFrame(2)
  self.option = 0
  self.isActive = false
  self.pressingOne = false
  self.pressingTwo = false

  self.respawn = false
  self.soundCoin = love.audio.newSource('/assets/sound/menus/soundCoin.wav', 'static')
end

function range(a, i, b) 
  return a <= i and i <= b
end

function deadScreen:mouseIsTouching(x, y, w, h)
  local mouseX = self.mouse.x
  local mouseY = self.mouse.y
  local condX = range(x, mouseX, x + w)
  local condY = range(y, mouseY, y + h)

  return condX and condY
end


function deadScreen:respawnActive()
  return self.respawn
end

function deadScreen:buttonOneSelected()
  if self:mouseIsTouching(self.x + 90, self.y + 150, 140, 50) then
    return true
  else
    return false
  end
end

function deadScreen:buttonTwoSelected()
  if self:mouseIsTouching(self.x + 260, self.y + 150, 140, 50) then
    return true
  else
    return false
  end
end

function deadScreen:handleInput()
  if love.keyboard.isDown('d') or self:buttonTwoSelected() and self.option ~= 1 then
    self.option = 1
    self.animations.deadScreen:gotoFrame(3)
    self.soundCoin:play()
  end

  if love.keyboard.isDown('a') or self:buttonOneSelected() and self.option ~= 0 then
    self.option = 0
    self.animations.deadScreen:gotoFrame(2)
    self.soundCoin:play()
  end
  
  if love.mouse.isDown(1) then
    if self:buttonOneSelected() then 
      self.animations.deadScreen:gotoFrame(1)
      self.pressingOne = true
      self.respawn = true
    elseif self:buttonTwoSelected() then
      self.animations.deadScreen:gotoFrame(4)
      self.pressingTwo = true
      love.event.quit()
    end

  end

  if love.keyboard.isDown('space') then
    if self.option == 0 then
      self.animations.deadScreen:gotoFrame(1)
      self.respawn = true
    else
      self.animations.deadScreen:gotoFrame(4)
      love.event.quit()
    end
  end
end

function deadScreen:update(dt)
  self.x = self.camera.x + self.relativeX
  self.y = self.camera.y + self.relativeY
  self.pressingOne = false
  self.pressingTwo = false

  if self.player:isAlive() then
    self.isActive = false
    self.respawn = false
  else
    self.isActive = true
  end

  if self.isActive then
    self:handleInput()
  end



end

function deadScreen:draw()
  local default = love.graphics.newFont(32)
  love.graphics.setFont(default)

  if self.isActive then
    local x = self.x
    local y = self.y
    self.animations.deadScreen:draw(self.spriteSheet, x, y)
    
    love.graphics.print({{255,255,255}, "¿Revivir?"}, x + 180, y + 80)

    if not self.pressingOne then
      love.graphics.print({{0,0,0}, "Sí"}, x + 130, y + 155)
    else
      love.graphics.print({{0,0,0}, "Sí"}, x + 135, y + 160)
    end
    
    if not self.pressingTwo then
      love.graphics.print({{0,0,0}, "No"}, x + 300, y + 155)
    else
      love.graphics.print({{0,0,0}, "No"}, x + 305, y + 160)
    end
  end

end
return deadScreen
