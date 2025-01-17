require("requirements")

gameState = ""
previousGameState = ""
game = {}


local function loadGameStates()
    local gameStateList = love.filesystem.getDirectoryItems("gameStates")

    for key, value in pairs(gameStateList) do
        local stateName = string.sub(value, 1, -5)
        print("Loading Gamestate: " .. value .. " as " .. stateName)

        game[stateName] = require("gameStates/" .. stateName)

        if type(game[stateName]) == "table" then
            if game[stateName] and game[stateName].isFirst then
                gameState = stateName

                --this one will load anyway.
                previousGameState = stateName
            end
        else
            print("this state is a bool, removing")
            game[stateName] = nil
        end
    end

    if gameState == "" then
        gameState = string.sub(gameStateList[1], 1, -5)
        previousGameState = gameState
    end
end

loadGameStates()

screen = {
    scale = love.graphics.getWidth()/1920,
    width = 1920,
    height = 1080,
}

local function updateScale()
    screen.scale = love.graphics.getWidth()/1920

    if love.graphics.getHeight()/1080 > screen.scale then
        screen.scale = love.graphics.getHeight()/1080
    end

    screen.width = love.graphics.getWidth()/screen.scale
    screen.height = love.graphics.getHeight()/screen.scale

end
updateScale()



function love.resize(w, h)
    updateScale()
end


function love.load()
    if game[gameState] and game[gameState].load then
        game[gameState].load()
    end
end


function love.textinput(key)
    if game[gameState] and game[gameState].textinput then
        game[gameState].textinput(key)
    end
end



function love.wheelmoved(x,y)
    if game[gameState] and game[gameState].wheelmoved then
        game[gameState].wheelmoved(x, y)
    end
end


function love.keypressed(key)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen())

        love.resize(love.graphics.getWidth(), love.graphics.getHeight())
    end

    if key == "g" and love.keyboard.isDown("lctrl") and DEV then
        drawDebugRuler = not drawDebugRuler
    end
    
    if game[gameState] and game[gameState].keypressed then
        game[gameState].keypressed(key)
    end
end

function love.keyreleased(key)
    if key == "escape" then
        settingsMenu.isOpen = true
    end
    if game[gameState] and game[gameState].keyreleased then
        game[gameState].keyreleased(key)
    end

    if settingsMenu.displayTimer > 0 then
        settingsMenu:KeyRelased(key)
    end
end


function love.mousepressed(mx, my, button)
    if game[gameState] and game[gameState].mousepressed then
        game[gameState].mousepressed(mx, my, button)
    end

    if settingsMenu.displayTimer > 0 then
        settingsMenu:Click(love.mouse.getX()/screen.scale, love.mouse.getY()/screen.scale)
    end
end
function love.mousereleased(x, y, button)
    if game[gameState] and game[gameState].mousereleased then
        game[gameState].mousereleased(x, y, button)
    end

    if settingsMenu.displayTimer > 0 then
        settingsMenu:Release(love.mouse.getX()/screen.scale, love.mouse.getY()/screen.scale)
    end
end


function love.update(dt)

    if gameState ~= previousGameState then
        if game[gameState] and game[gameState].load then
            game[gameState].load()
        end
        previousGameState = gameState
    end


    if game[gameState] and game[gameState].update then
        game[gameState].update(dt)
    end

    settingsMenu:Update(dt, love.mouse.getX()/screen.scale, love.mouse.getY()/screen.scale)
end


function love.draw()
    love.graphics.reset()

    love.graphics.scale(screen.scale)

    if game[gameState] and game[gameState].draw then
        game[gameState].draw()
    end

    if settingsMenu.displayTimer > 0 then
        settingsMenu:Draw()
    end

    if drawDebugRuler then quindoc.drawRuler() end
end