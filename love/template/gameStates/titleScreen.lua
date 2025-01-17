local ui

local function loadGameMode(name)
    if not gameModeSettings then
        gameModeSettings = {}
    end
    gameModeSettings.name = name

    gameModeSettings.currentTeams = {}

    for key, value in pairs(teams) do
        gameModeSettings.currentTeams[key] = {
            score = 0
        }
    end

    gameState = "simulationSettings" --simulationSettings
end

local function load()
    ui = GraetUi:New()
    local buttonHeight = 0
    for key, value in pairs(gameModes) do
        ui:AddTextButton("gameMode_" ..key, key, "left", font.black["70"], 20, buttonHeight, 2000, {{1,1,1}, {.8,.8,.8}, {1,1,1}})
        ui:GetButtons()["gameMode_" ..key].functions.release = {loadGameMode, key}

        buttonHeight = buttonHeight + font.black["70"]:getHeight()
    end
end

local function mousepressed(x, y, button)
    ui:Click(x/screen.scale, y/screen.scale)
end

local function mousereleased(x, y, button)
    ui:Release(x/screen.scale, y/screen.scale)
    
end

local function update(dt)
    ui:Update(dt, love.mouse.getX()/screen.scale, love.mouse.getY()/screen.scale)
end

local function draw()
    ui:Draw()
end

return {
    load = load,
    mousepressed = mousepressed,
    mousereleased = mousereleased,
    update = update,
    draw = draw,

    isFirst = true
}