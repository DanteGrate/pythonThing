local EntityManager = {}
EntityManager.__index = EntityManager


function EntityManager:New()
    local obj = setmetatable({}, EntityManager)

    obj.planes = {}

    obj.bullets = {}

    obj.effects = {}

    return obj
end

function EntityManager:GenerateSpawnPositions()
    local currentAngle = 0

    local teamCount = 0
    for key, value in pairs(gameModeSettings.currentTeams) do
        teamCount = teamCount + 1
    end

    if teamCount % 2 == 0 then
        -- we have an even amount of teams
        currentAngle = 0
    else
        -- odd number of teams, start from the top
        currentAngle = math.pi/2
    end

    local angleIncrement = math.pi*2/teamCount

    for i, value in pairs(gameModeSettings.currentTeams) do
        gameModeSettings.currentTeams[i].spawnAngle = {currentAngle-math.min(angleIncrement/2, math.pi/4), currentAngle+math.min(angleIncrement/2, math.pi/4)} 
        currentAngle = currentAngle + angleIncrement
    end
end

function EntityManager:AddPlane(team)
    local angle = math.rad(math.random(math.deg(gameModeSettings.currentTeams[team].spawnAngle[1]), math.deg(gameModeSettings.currentTeams[team].spawnAngle[2])))
    table.insert(self.planes, code.Plane:New(math.cos(angle)*-1250 + screen.width/2, math.sin(angle)*-1250  + screen.height/2, angle, team))
end

function EntityManager:AddBullet(x, y, angle, team)
    table.insert(self.bullets, code.Bullet:New(x, y, angle, team))
end

function EntityManager:AddEffect(x, y, type)
    table.insert(self.effects, code.effect[type]:New(x, y))
end


function EntityManager:Update(dt)
    for i = #self.planes, 1, -1 do
        local p = self.planes[i]
        if not p.despawnTimer then
            p:UpdateTarget(dt)
            p:FindTargetLocation(dt)
            p:UpdateSpeed(dt)
            p:Update(dt)
            p:UpdateShooting(dt)
            p:UpdateDamageEffect(dt)
        else
            if p:UpdateDespawn() then
                entityManager:AddPlane(p.team)
                table.remove(self.planes, i) 
            end
        end
    end

    for i = #self.bullets,1, -1 do
        local b = self.bullets[i]
        b:Update(dt)
        if b.CheckForCollisions then
            b:CheckForCollisions()
        end

        if b.despawnTimer <= 0 then
            table.remove(self.bullets, i)
        end
    end


    for i = #self.effects,1, -1 do
        local e = self.effects[i]
        e:Update(dt)

        if e.despawnTimer <= 0 then
            table.remove(self.effects, i)
        end
    end
end

function EntityManager:Draw()
    for i = 1,#self.planes do
        local p = self.planes[i]
        p:Draw()
    end

    for i = 1,#self.bullets do
        local b = self.bullets[i]
        b:Draw()
    end

    love.graphics.setColor(1,1,1)
    for i = 1,#self.effects do
        local e = self.effects[i]
        e:Draw()
    end
end

return EntityManager