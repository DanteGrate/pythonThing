local ui

local function load()
    ui = GraetUi:New()

    ui:AddTextButton("play", "Play", "left", font.black["40"] ,10, 1000, 2000, {{1,1,1}, {.8,.8,.8}, {1,1,1}})
    ui:GetButtons()["play"].functions.release = {function() gameState = "simulation" end}


end

local function mousepressed(x, y, button)
    ui:Click(x/screen.scale, y/screen.scale)

    local count = 0
    for key, value in pairs(teams) do
        local plane = {
            x = (count % 5)*96 + 96,
            y = math.floor(count/5)*96 + 96,
        }

        if quindoc.pythag(plane.x - x/screen.scale, plane.y - y/screen.scale) < 32 then
            if gameModeSettings.currentTeams[key] then
                gameModeSettings.currentTeams[key] = nil
            else
                gameModeSettings.currentTeams[key] = {
                    score = 0
                }
            end
        end

        count = count + 1

    end
end

local function mousereleased(x, y, button)
    ui:Release(x/screen.scale, y/screen.scale)
    
end

local function update(dt)
    ui:Update(dt, love.mouse.getX()/screen.scale, love.mouse.getY()/screen.scale)
end

local function draw()
    ui:Draw()

    local count = 0
    love.graphics.setFont(font.black["15"])
    for key, value in pairs(teams) do
        local plane = {
            x = (count % 5)*96 + 96,
            y = math.floor(count/5)*96 + 96,
            angle = -math.pi/2,
            team = key,
            animationTimer = 0,

        }
        code.Plane.Draw(plane)

        love.graphics.setColor(1,1,1)
        love.graphics.printf(key, (count % 5)*96 + 64, math.floor(count/5)*96 + 96 + 16, 64, "center")

        if not gameModeSettings.currentTeams[key] then
            love.graphics.setColor(1,0,0)
            love.graphics.setLineWidth(5)
            love.graphics.line((count % 5)*96 + 16 + 96, math.floor(count/5)*96 + 16+ 96, (count % 5)*96 - 16+ 96, math.floor(count/5)*96 - 16+ 96)
        end
        

        count = count + 1

    end
end

return {
    load = load,
    mousepressed = mousepressed,
    mousereleased = mousereleased,
    update = update,
    draw = draw,

    isFirst = true
}