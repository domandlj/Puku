-- Import our libraries.
bump = require 'libs.bump.bump'
Gamestate = require 'libs.hump.gamestate'

-- Import our Entity system.
local Entities = require 'entities.Entities'
local Entity = require 'entities.Entity'

-- Create our Gamestate
local gameLevel2 = {}


-- Import the Entities we build.
local Player = require 'entities.player'
local Ground = require 'entities.ground'

-- Declare a couple immportant variables
player = nil
world = nil


function gameLevel2:init()
  self.exit = false
end

function gameLevel2:enter()
  tileSize = 16
  -- Game Levels do need collisions.
  world = bump.newWorld(tileSize) -- Create a world for bump to function in.

  -- Initialize our Entity System
  Entities:enter()
  player = Player(world, "juan",tileSize, tileSize)
  ground_0 = Ground(world,"piso 1", 120, 360, 1280, tileSize)
  ground_1 = Ground(world, "piso 2", 0, 0 , 1280, tileSize)

  -- Add instances of our entities to the Entity List
  Entities:addMany({player, ground_0, ground_1})
end

function gameLevel2:update(dt)
  Entities:update(dt) -- this executes the update function for each individual Entity
end

function gameLevel2:draw()
  Entities:draw() -- this executes the draw function for each individual Entity
end

return gameLevel2
