local function FillBackground()
    if not gameModeSettings.background then
        gameModeSettings.background = image.background.defaultBlue
    end

    backgroundCanvas = love.graphics.newCanvas(love.graphics.getWidth()/screen.scale, love.graphics.getHeight()/screen.scale)

    love.graphics.setCanvas(backgroundCanvas)
    
    for x = 0, 1920, gameModeSettings.background:getWidth() do
        for y = 0, 1080, gameModeSettings.background:getHeight() do
            love.graphics.draw(gameModeSettings.background, x, y)
        end
    end

    love.graphics.setCanvas()

end

local function resize()
    FillBackground()
end

local function load()
    gameModeSettings.teamsEnum = {}
    for key, value in pairs(gameModeSettings.currentTeams) do
        table.insert(gameModeSettings.teamsEnum, key)
    end

    FillBackground()

    entityManager = code.EntityManager:New()
    entityManager:GenerateSpawnPositions()

    if gameModes[gameModeSettings.name].Load then
        gameModes[gameModeSettings.name].Load()
    end
end

local function drawLeaderBoard(x, y)
    love.graphics.setColor(0,0,0,0.3)

    local orderdScores = dante.noQuantumEntanglememt(gameModeSettings.teamsEnum)
    table.sort(orderdScores, function(a, b)
        return gameModeSettings.currentTeams[a].score > gameModeSettings.currentTeams[b].score
    end)

    love.graphics.rectangle("fill", x + 10, y + 10, 250, #gameModeSettings.teamsEnum*40 + 20, 25)

    love.graphics.setColor(1,1,1,1)
    for i = 1,#orderdScores do
        love.graphics.setFont(font.black["30"])
        love.graphics.print(orderdScores[i] .. " " .. gameModeSettings.currentTeams[orderdScores[i]].score, x + 20, y + (i-1)*40 + 10)
    end
end

local function update(dt)
    entityManager:Update(dt)

    if gameModes[gameModeSettings.name].Update then
        gameModes[gameModeSettings.name].Update(dt)
    end
end

local function draw()
    --love.graphics.setBackgroundColor(0.2,0.2, 0.4)

    love.graphics.draw(backgroundCanvas)

    if gameModes[gameModeSettings.name].DrawBack then
        gameModes[gameModeSettings.name].DrawBack()
    end

    entityManager:Draw()

    if gameModes[gameModeSettings.name].DrawFront then
        gameModes[gameModeSettings.name].DrawFront()
    end

    drawLeaderBoard(0, 0)
end

return {
    load = load,
    update = update,
    resize = resize,
    draw = draw,
}