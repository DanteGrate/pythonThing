local Explosion = {}
Explosion.__index = Explosion


function Explosion:New(x, y)
    local obj = setmetatable({}, Explosion)

    -- basic values
    obj.x = x
    obj.y = y

    obj.despawnTimer = 0.3
    obj.smokeTimer = 0

    return obj
end


function Explosion:Update(dt)
    self.despawnTimer = self.despawnTimer - dt

    self.smokeTimer = self.smokeTimer + dt
    while self.smokeTimer > 1/60 do
        local dir = math.rad(math.random(1, 360))
        local dist = 1 + math.random(0, 50*(.3-self.despawnTimer))
        entityManager:AddEffect(self.x + math.cos(dir)*dist, self.y + math.sin(dir)*dist, "Smoke")

        self.smokeTimer = self.smokeTimer - 1/60
    end
end


function Explosion:Draw()
    love.graphics.setColor(1,1,1)
    
    for i = 1,5 do
        local dir = math.rad(math.random(1, 360))
        local dist = 1 + math.random(0, 40*(.3-self.despawnTimer))
        love.graphics.draw(image.other.fire, self.x + math.cos(dir)*dist, self.y + math.sin(dir)*dist, self.angle, 1, 1, image.other.fire:getWidth()/2, image.other.fire:getHeight()/2)
    end
end



return Explosion