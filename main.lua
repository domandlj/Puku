-- Pull in Gamestate from the HUMP library
Gamestate = require 'libs.hump.gamestate'
mouseActivated = false

-- Pull in each of our game states
local gameLevel1 = require 'gamestates.gameLevel1'
local mainMenu = require 'gamestates.mainMenu'
local pause = require 'gamestates.pause'

local fullscreen = true
function love.load()
  love.window.setTitle('Puku')
  love.window.setMode(1280, 720, {resizable=false})
  love.window.setFullscreen(fullscreen)
  love.mouse.setVisible(false)
  love.graphics.setDefaultFilter("nearest", "nearest")
  Gamestate.registerEvents()
  Gamestate.switch(mainMenu)
end



function love.mousepressed(x, y, button, istouch)
   if button == 1 then 
    mouseActivated = not mouseActivated      
   end
end

function love.keypressed(key)
  if key == "0" then 
    fullscreen = not fullscreen
    love.window.setFullscreen(fullscreen)
  end
  if key == "escape" then
    love.event.push("quit")
  end

end
