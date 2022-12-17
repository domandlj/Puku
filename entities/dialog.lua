Gamestate = require 'libs.hump.gamestate'
anim8 = require 'libs.anim8.anim8'

local Class = require 'libs.hump.class'
local Entity = require 'entities.Entity'

local dialog = Class{
  __includes = Entity -- Player class inherits our Entity class
}

function dialog:init(world, x, y, sounds, texts)
  Entity.init(self, world, x, y, 600, 100)
  self.player = world.player
  self.relativeX = x
  self.relativeY = y
  self.world:add(self, self:getRect())
  self.camera = world.camera
  self.spriteSheet = love.graphics.newImage('/assets/entities/menus/dialog.png')
  self.grid = anim8.newGrid(self.w, self.h, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
  self.animations = {}
  self.animations.dialog = anim8.newAnimation(self.grid(1, '1-6'), 0.2)
   
  self.soundCoin = love.audio.newSource('/assets/sound/menus/soundCoin.wav', 'static')
  self.soundJo = love.audio.newSource('/assets/sound/dialogs/soundJo.wav', 'static')
  self.soundPacha = love.audio.newSource('/assets/sound/dialogs/soundPacha.wav', 'static')
 
  self.sounds = sounds  
  self.texts = texts

  self.dialogN = 1
  self.pressed = false
  self.player:lock()

   self[self.sounds[self.dialogN]]:play()


end


function dialog:isDone()
  if self.dialogN == #self.texts + 1  then

    self.player:unlock()
  end
  return self.dialogN == #self.texts + 1
end

function dialog:update(dt)
  self.x = self.camera.x + self.relativeX
  self.y = self.camera.y + self.relativeY
  self.animations.dialog:update(dt)
  
   
  if love.keyboard.isDown("space") and not self.pressed then
    self.dialogN = self.dialogN + 1
    if self.dialogN <= #self.texts  then    
      self.soundCoin:play()
      self[self.sounds[self.dialogN -1]]:stop()
      self[self.sounds[self.dialogN]]:play()
      self.pressed = true
    end

  elseif not love.keyboard.isDown("space") and self.pressed then
    self.pressed = false
  end
end



function dialog:draw()
  local default = love.graphics.newFont(24)
  love.graphics.setFont(default) 
  local x = self.x
  local y = self.y
  
  self.animations.dialog:draw(self.spriteSheet, self.x, self.y) 
  --love.graphics.rectangle("fill", x, y, self.w, self.h)   
  love.graphics.print(self.texts[self.dialogN], x+50, y +20)

end
return dialog
