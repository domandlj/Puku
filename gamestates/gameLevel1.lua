-- Import our libraries.
local Gamestate = require 'libs.hump.gamestate'
local Class = require 'libs.hump.class'
local moonshine = require 'libs.moonshine'

-- Grab our base class
local LevelBase = require 'gamestates.LevelBase'

-- Import the Entities we will build.
local Player = require 'entities.player'
local dog = require 'entities.dog'
local camera = require 'libs.camera'
local mouse = require 'entities.mouse'
local flower = require 'entities.flower'
local zombie = require 'entities.zombie'
local life = require 'entities.life'
local deadScreen = require 'entities.deadScreen' 
local dialog = require 'entities.dialog'
local puku = require 'entities.puku'
local pukuGrown = require 'entities.pukuGrown'
local pukuCounter = require 'entities.pukuCounter'
local monkeyBoss = require 'entities.monkeyBoss'
local mouseControl = require 'entities.mouseControl'
local globe = require 'entities.globe'
local endScreen = require 'entities.endScreen'
local startScreen = require 'entities.startScreen'

-- Import dialogs
local dialogLevel1 = require 'dialogs.dialogLevel1'
local dialogOne = dialogLevel1.dialogOne 
local dialogTwo = dialogLevel1.dialogTwo
local dialogCreepyScene = dialogLevel1.dialogCreepyScene
local dialogKilledZombies = dialogLevel1.dialogKilledZombies
local dialogMonkeyBoss = dialogLevel1.dialogMonkeyBoss
local dialogPreEnd = dialogLevel1.dialogPreEnd
local dialogEnd = dialogLevel1.dialogEnd

-- Set checkPoints
local checkPoints = {
  {
    x = 818,
    y = 451,
    creepySceneStarted = false,
  },
  {
    x = 14850,
    y = 451,
    creepySceneStarted = true,
  },
 {
    x = 14850,
    y = 451,
    creepySceneStarted = true,
  },
 {
    x = 14850,
    y = 451,
    creepySceneStarted = true,
  },
  {
    x = 14850,
    y = 451,
    creepySceneStarted = true,
  },
 {
    x = 14850,
    y = 451,
    creepySceneStarted = true,
  },
 {
    x = 14850,
    y = 451,
    creepySceneStarted = true,
  }
}





function createFalseTable(len)
  result = {}
  for i = 1, len do
    result[i] = false
  end
  return result
end


local gameLevel1 = Class{
  __includes = LevelBase
}

function gameLevel1:init()
  self.background = love.graphics.newImage("/assets/backgrounds/background.png")
  self.backgroundNight = love.graphics.newImage("/assets/backgrounds/backgroundNight.png")
  LevelBase.init(self, '/assets/levels/level_1.lua')
   
  -- shaders 
  self.effect = moonshine(moonshine.effects.crt)
  self.creepyEffect = moonshine(moonshine.effects.crt)
     .chain(moonshine.effects.desaturate)
     .chain(moonshine.effects.filmgrain)
   
  
  self.creepyEffect.desaturate.tint = {102, 59, 42}
  self.creepyEffect.desaturate.strength = 0.8
  self.creepyEffect.filmgrain.size = 3
  self.backgroundX = -1280
   
  -- camera scenes
  self.cameraPos = 0
  self.cameraSceneLeft = false
  self.cameraSceneRight = false
  self.cameraDirection = 0 -- (-1, 0, 1) = (left, neutral, right) 
   
  -- Scenes
  self.initialDialogEnded = false
  self.sndDialogEnded = false
  self.killedZombiesDialogEnded = false
  self.monkeyBossDialogEnded = false

  -- creepy scence
  self.creepySceneStarted = false
  self.sepiaShader = false
  self.hordeCreated = createFalseTable(5)

  -- sounds
  self.sheIsARainbow = love.audio.newSource("/assets/sound/background/sheIsARainbow.mp3","stream")
  self.sheIsARainbow:setLooping(true) 
  self.creepySong = love.audio.newSource("/assets/sound/background/creepySong.mp3","stream")
  self.creepySong:setLooping(true)
  self.soundGenesis = love.audio.newSource("/assets/sound/background/soundGenesis.mp3", "stream")
  self.soundGenesis:setLooping(true) 
  self.evilLaugh = love.audio.newSource("/assets/sound/background/evilLaugh.wav", "static")
  self.soundLDA = love.audio.newSource("/assets/sound/background/soundLDA.mp3", "stream")
  self.soundLDA:setLooping(true)
  self.soundPuzzleSucces = love.audio.newSource('/assets/sound/puku/soundPuzzleSucces.mp3', 'static')
  
   -- game stats
  self.killedZombies = 0
  self.killedAllZombies = false

   -- Memory card
  self.checkPoint = 0 

  self.active = false

  -- Pukus
  self.pukuBase = 2332
  self.pukusPuzzleSolved = false
  self.pukuCounter = {}
  self.pukuCounter.count = 0
  
  -- teleport
  self.wait = 0
  
  -- Boss
  self.gameWinned = false

  --camera shake
  self.t, self.shakeDuration, self.shakeMagnitude = 0, -1, 0

end


function gameLevel1:startShake(duration, magnitude)
    self.t, self.shakeDuration, self.shakeMagnitude = 0, duration or 1, magnitude or 5
end

function gameLevel1:createPukus()
  self.pukus = {}
  for i = 1, 16 do
    self.pukus[i] = puku(self.world,  150 + (i-1)*130, 300)
    LevelBase.Entities:add(self.pukus[i]) 
  end
end

function gameLevel1:loadCheckPoint()
    local checkPoint = {}
    checkPoint = checkPoints[self.checkPoint]
    player.life = 100
    player.x = checkPoint.x
    player.y = checkPoint.y
    self.world:update(player, checkPoint.x, checkPoint.y)
    self.creepySceneStarted = checkPoint.creepySceneStarted
end

function gameLevel1:limitPlayer()
  local limitPukus = 2690
  local limitStart = 0 
  local limitEnd = 22400 
  local limitGlobe = 21516.173
  local limitZombiesKilled = 15908.4938

  if player.x <= limitStart then
    player.x, player.y, c, l = self.world:move(player, limitStart, player.y)
  end

  if player.x >= limitEnd then
    player.x, player.y, c, l = self.world:move(player, limitEnd, player.y)
  end


  if not self.pukusPuzzleSolved and player.x >= limitPukus then
    player.x, player.y, c, l = self.world:move(player, limitPukus, player.y)
  end

  if not self.gameWinned and player.x >= limitGlobe then
     player.x, player.y, c, l = self.world:move(player, limitGlobe, player.y)
  end
 

   if player.x >= limitZombiesKilled and not self.killedAllZombies then
     player.x, player.y, c, l = self.world:move(player, limitZombiesKilled, player.y)
   end

  if not self.pukusPuzzleSolved and player.x > 2336 and player.y >= 575 then
    player:kill()
  end 
end

function gameLevel1:killZombies()
 for i, entity in ipairs(LevelBase.Entities.entityList) do
    if entity.isZombie then
      self.world:remove(entity)
      LevelBase.Entities:remove(entity)
    end
 end
end


function gameLevel1:createZombiesHorde(dt, offset, many, posY)
  for i=1, many do
    self.timing = dt
    
    LevelBase.Entities:addSndLast(zombie(self.world,
      offset + (i-1)*75*2, posY,  offset + (i-1)*75*2  , 4000 + offset + (i-1)*75*2, many + i))
    
   end
  
end

function gameLevel1:createFlowers()
  --flowers = {}
  
  LevelBase.Entities:addMany({
    flower(self.world, 3813, 100, mouse),
    flower(self.world, 5183, 100, mouse),
    flower(self.world, 6221, 100, mouse),
    flower(self.world, 6000, 100, mouse),
    flower(self.world, 12600, 100, mouse),
    flower(self.world, 12800, 100, mouse)
    }
  ) 
end

function gameLevel1:enter()
  self.world.camera = camera
  player = Player(self.world, 20, 540)
  mouse = mouse(self.world, 20, 20)
  self.world.player = player
  self.world.mouse = mouse
  

  startScreen = startScreen(self.world, 400, 128)
  globe = globe(self.world, 21909, 200)
  self:createPukus()
  dog = dog(self.world, 14650, 200)
  life = life(self.world, 1000, 10)
  self:createFlowers()
  mouseControl = mouseControl(self.world, 1100, 60)
  pukuCounterOne = pukuCounter(self.world, 2776,	288, self.pukuCounter)
  LevelBase.Entities:add(globe)
  LevelBase.Entities:add(pukuCounterOne)
  LevelBase.Entities:add(player)
  LevelBase.Entities:add(life)
  
  
  LevelBase.Entities:add(dog)
  deadScreen = deadScreen(self.world, 380, 250)
  LevelBase.Entities:add(mouseControl)
  LevelBase.Entities:add(deadScreen)
  LevelBase.Entities:add(startScreen)
  LevelBase.Entities:add(mouse)
 
  love.audio.play(self.sheIsARainbow)
  
end

function gameLevel1:checkPukus()
  local pukuOffset = 32
  for i = 1, #self.pukus do
    if self.pukus[i].x > 2332 and self.pukus[i].x < 2764 and self.pukus[i].isPuku and self.pukus[i].y > 600 then
      self.pukus[i]:kill()
      self.pukus[i] = pukuGrown(self.world, self.pukus[i].x, 673 - 300)
      LevelBase.Entities:addSndLast(self.pukus[i])
      self.pukuBase = self.pukuBase + pukuOffset
    end
  end


  local pukusGrown = (self.pukuBase - 2332) / pukuOffset
  self.pukuCounter.count = pukusGrown

  if pukusGrown >= 6 then 
    self.pukusPuzzleSolved = true
  end
end 

function gameLevel1:cameraGoingRight()
  return self.cameraDirection == 1
end

function gameLevel1:cameraGoingLeft()
  return self.cameraDirection == -1
end

function gameLevel1:cameraNeutral()
  return self.cameraDirection == 0
end

function gameLevel1:setCameraGoingRight()
  self.cameraDirection = 1
end

function gameLevel1:setCameraGoingLeft()
  self.cameraDirection = -1
end

function gameLevel1:setCameraNeutral()
  self.cameraDirection = 0
end




function gameLevel1:checkCameraMoveToRight(dt, limit)
  local offsetX = 675
  local playerPos = player.x - offsetX
  local cameraSpeed = 300
  local cameraSpeedComeback = 800 
  
  
  if self.cameraSceneRight and playerPos < limit then
       if self:cameraNeutral() then
        self.cameraPos = playerPos
       end

      player:lock()
      
      if self.cameraPos < limit and not self:cameraGoingLeft() then
        self.cameraPos = self.cameraPos + dt * cameraSpeed
        camera.x = self.cameraPos
        self:setCameraGoingRight() 
      
      elseif self.cameraPos  > playerPos then
        self.cameraPos = self.cameraPos - dt * cameraSpeedComeback
        camera.x = self.cameraPos
        self:setCameraGoingLeft()

      elseif self.cameraPos <= playerPos  and self:cameraGoingLeft() then
        player:unlock()
        self:setCameraNeutral() 
        self.cameraSceneRight = false
        self.cameraPos = 0
    end

  end
end



function gameLevel1:checkCameraMoveToLeft(dt, limit)
  local offsetX = 675
  local playerPos = player.x - offsetX
  local cameraSpeed = 300
  local cameraSpeedComeback = 800
  
  if self.cameraSceneLeft and playerPos > limit then
      if self:cameraNeutral() then 
        self.cameraPos = playerPos 
      end

      player:lock()
      
      if self.cameraPos > limit and not self:cameraGoingRight() then
        self.cameraPos = self.cameraPos - dt * cameraSpeed
        camera.x = self.cameraPos
        self:setCameraGoingLeft()
      
      
      elseif self.cameraPos < playerPos then
        self.cameraPos = self.cameraPos + dt * cameraSpeedComeback
        camera.x = self.cameraPos
        self:setCameraGoingRight()
        self.sepiaShader = false

      elseif self.cameraPos >= playerPos  and self:cameraGoingRight() then
        player:unlock()
        self.cameraSceneLeft = false
        self:setCameraNeutral()
    end

  end
end

function gameLevel1:cleanDeadEntities()
 for i, entity in ipairs(LevelBase.Entities.entityList) do
    if not entity:isAlive() and not entity.isPlayer then

      if entity.isZombie then
        self.killedZombies = self.killedZombies + 1
      end

      if entity.isMonkeyBoss then
        self.gameWinned = true 
      end
      
      self.world:remove(entity)
      LevelBase.Entities:remove(entity)
    end
  
 end
end


function gameLevel1:spawnZombies(dt)
  
  if self.creepySceneStarted and self.cameraPos ~= 0 then
      if self.cameraPos < 100 and not self.hordeCreated[1] then
        self:createZombiesHorde(dt, 0, 4, 580)
        self.hordeCreated[1] = true
      end

      if self.cameraPos < 800 and not self.hordeCreated[2] then
        self:createZombiesHorde(dt, 767, 3, 451)
        self.hordeCreated[2] = true
      end
  
      if self.cameraPos < 8900 and not self.hordeCreated[3] then
        self:createZombiesHorde(dt, 8467, 5, 323)
        self.hordeCreated[3] = true
      end

      if self.cameraPos < 3400 and not self.hordeCreated[4] then
        self:createZombiesHorde(dt, 3370, 1, 259)
        self.hordeCreated[4] = true
      end

      if self.cameraPos < 7409 and not self.hordeCreated[5] then 
        self:createZombiesHorde(dt, 7400, 2, 323)
        self.hordeCreated[5] = true
      end
  end
end


function gameLevel1:isTimeForInitialScene()
  if not self.initialDialogEnded and player.x >= 1000 then
    return true
  else
    return false
  end
end

function gameLevel1:startInitialScene()
  if self.checkPoint < 1 then
    mouse:lock()
    chat = dialog(self.world, 300, 550, dialogOne.sounds, dialogOne.texts)
    LevelBase.Entities:add(chat)
    self.checkPoint = 1
  end

  if chat:isDone() then
    mouse:unlock()
    chat:kill()
    self.cameraSceneRight = true
    self.initialDialogEnded = true
  end
end


function gameLevel1:isTimeForSndScene()
  if not self.sndDialogEnded and player.x >= 14650 then
    return true
  else
    return false
  end
end

function gameLevel1:startSndScene()
  if self.checkPoint < 2 then
    chat = dialog(self.world, 300, 550, dialogTwo.sounds, dialogTwo.texts)
    LevelBase.Entities:add(chat)
    self.checkPoint = 2
  end

  if chat:isDone() then
    chat:kill()
    self.sndDialogEnded = true
  end
end

function gameLevel1:isTimeForCreepyScene()
  if not self.creepySceneStarted and player.x > 14800 then
    return true
  else
    return false
  end
end

function gameLevel1:startCreepyScene()

  if self.checkPoint < 3 then
    self.sepiaShader = true
    self.cameraSceneLeft = true
    self.sheIsARainbow:stop()
    self.evilLaugh:play()
    self.creepySong:play()

    chat = dialog(self.world, 300, 550, dialogCreepyScene.sounds, dialogCreepyScene.texts)
    LevelBase.Entities:add(chat)
    self.checkPoint = 3
  end

  if chat:isDone() then
    chat:kill()
    self.creepySceneStarted = true
  end

end



function gameLevel1:isTimeForKilledZombiesScene()
  local cond1 = not self.killedZombiesDialogEnded
  local cond2 = self.killedZombies > 7
  
  if cond2 then
    self.killedAllZombies = true
  end
  
  return cond1 and cond2
end

function gameLevel1:startKilledZombiesScene()
  if self.checkPoint < 4 then
    self.creepySong:stop()
    self.soundPuzzleSucces:play()
    self.soundLDA:play()

    chat = dialog(self.world, 300, 550, dialogKilledZombies.sounds, dialogKilledZombies.texts)
    LevelBase.Entities:add(chat)
    self.checkPoint = 4
  end

  if chat:isDone() then
    chat:kill()
    self.killedZombiesDialogEnded = true
  end
  self.background = self.backgroundNight
end

function gameLevel1:isTimeForPreEndScene()
  if not self.preEndDialogEnded and player.x >= 15650 and self.killedAllZombies then
    return true
  else
    return false
  end
end

function gameLevel1:startPreEndScene()
  if self.checkPoint < 5 then
    chat = dialog(self.world, 300, 550, dialogPreEnd.sounds, dialogPreEnd.texts)
    LevelBase.Entities:add(chat)
    self.checkPoint = 5
  end

  if chat:isDone() then
    chat:kill()
    self.cameraSceneRight = true
    self.preEndDialogEnded = true
  end
end


function gameLevel1:isTimeForMonkeyBossScene() 
  local cond1 = not self.monkeyBossDialogEnded
  local cond2 = player.x >= 16900 

  return cond1 and cond2
end

function gameLevel1:startMonkeyBossScene()
  
  if self.checkPoint < 6 then
    self.soundLDA:stop()
    self.soundGenesis:play()
    self:startShake(4.8, 5) 
    self.boss = monkeyBoss(self.world, 17100, 80, 17100,  20747)
    LevelBase.Entities:addSndLast(self.boss)

    chat = dialog(self.world, 300, 550, dialogMonkeyBoss.sounds, dialogMonkeyBoss.texts)
    LevelBase.Entities:add(chat)
    self.checkPoint = 6
  end

 if chat:isDone() then
    chat:kill() 
    self.monkeyBossDialogEnded = true
  end
  

end


function gameLevel1:isTimeForEndScene()
  if not self.endDialogEnded and self.gameWinned then
    return true
  else
    return false
  end
end

function gameLevel1:startEndScene()
  if self.checkPoint < 7 then
    self.soundGenesis:play()
    self.soundPuzzleSucces:play()
    chat = dialog(self.world, 300, 550, dialogEnd.sounds, dialogEnd.texts)
    LevelBase.Entities:add(chat)
    self.checkPoint = 7
  end

  if chat:isDone() then
    chat:kill()
    self.cameraSceneRight = true
    self.endDialogEnded = true
  end
end




function gameLevel1:teleport(dt)
  if (love.keyboard.isDown("s") and not self.teleporting) or self.clickedDown then
    if math.abs(player.x - 16989) < 10 and player.y >= 418 then
      
      self.clickedDown = true
     
      player:teleport()
      
      if (self.wait < 1.6) then
        self.wait = self.wait + dt 
      else
        
        player.x = 21111.36
        player.y = 415
        self.world:update(player, 21111.36, 415)
        self.wait = 0
        self.teleporting = true
        self.clickedDown = false
      end

    elseif math.abs(player.x - 21111) < 10 and player.y >= 418 then
      self.clickedDown = true
      player:teleport()
      if (self.wait < 1.6) then
        self.wait = self.wait + dt
      else
        player.x = 16988.46
        player.y = 415
        self.world:update(player, 16988.46, 415)
        self.wait = 0
        self.teleporting = true
        self.clickedDown = false
      end
    end
  end
  if not love.keyboard.isDown("s") then
    self.teleporting = false
  end

end

function gameLevel1:shakeMonkeyBoss()
  if self.boss ~= nil then

    if self.boss.moving and not self.shaking then
      self:startShake(60*100, 1)
      self.shaking = true
    end

    if self.gameWinned then
      self.shakeDuration = 0
    end
  end

end

function gameLevel1:checkIfEndedGame()
  if globe.isAway and not self.endedGame then
    LevelBase.Entities:add(endScreen(self.world, 380, 250))
    self.endedGame = true 
  end
end


function gameLevel1:startGame()
  if not startScreen:startActive() then
    player:lock()
  else 
    player:unlock()
    startScreen:kill()
    self.gameStarted = true
  end
end

function gameLevel1:update(dt)
  self.map:update(dt) -- remember, we inherited map from LevelBase
  LevelBase.Entities:update(dt) -- this executes the update function for each individual Entity

  LevelBase.positionCamera(self, player, camera)

  self.backgroundX = -((-self.backgroundX + 0.2) % 1280 )
  
  if self.t < self.shakeDuration then
       self.t = self.t + dt
  end
  
  if not self.gameStarted then
    self:startGame()
  end

  if deadScreen.respawn then
    self:loadCheckPoint()
  end

  
  if self:isTimeForInitialScene() then
    self:startInitialScene()
  end

  if self:isTimeForSndScene() then
    self:startSndScene()
  end
  
 if self:isTimeForCreepyScene() then
    self:startCreepyScene()
 end
  
  if self:isTimeForKilledZombiesScene() then
    self:startKilledZombiesScene()
  end
  
  if self:isTimeForPreEndScene() then
    self:startPreEndScene()
  end
  
  if self:isTimeForMonkeyBossScene() then
    self:startMonkeyBossScene()
  end
  if self:isTimeForEndScene() then
    self:startEndScene()
  end
  
  
  self:shakeMonkeyBoss()
  self:limitPlayer()
  self:spawnZombies(dt)
  self:checkCameraMoveToLeft(dt, 0)
  self:checkCameraMoveToRight(dt, 4000)
  self:cleanDeadEntities()
  self:checkPukus()
  self:teleport(dt)
  self:checkIfEndedGame()
end


mainLevel1 = function()

    love.graphics.draw(gameLevel1.background,  gameLevel1.backgroundX, 0)
    -- Attach the camera before drawing the entities
    camera:set()
    gameLevel1.map:draw(-camera.x, -camera.y) -- Remember that we inherited map from LevelBase
    LevelBase.Entities:draw() -- this executes the draw function for each individual Entity

    camera:unset()
  -- Be sure to detach after running to avoid weirdness

end 

function gameLevel1:draw()
  if not self.sepiaShader then
    if self.t < self.shakeDuration then
        local dx = love.math.random(-self.shakeMagnitude, self.shakeMagnitude)
        local dy = love.math.random(-self.shakeMagnitude, self.shakeMagnitude)
        love.graphics.translate(dx, dy)
    end
    self.effect(mainLevel1)

  else
    self.creepyEffect(mainLevel1)
  end

end

-- All levels will have a pause menu
function gameLevel1:keypressed(key)
  LevelBase:keypressed(key)
end

return gameLevel1
