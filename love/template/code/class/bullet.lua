local Bullet = {}
Bullet.__index = Bullet


function Bullet:New(x, y, angle, team)
    local obj = setmetatable({}, Bullet)

    -- basic values
    obj.x = x
    obj.y = y
    obj.angle = angle

    obj.speed = 350

    obj.team = team

    obj.despawnTimer = 5

    return obj
end


function Bullet:Update(dt)
    self.despawnTimer = self.despawnTimer - dt

    self.x = self.x + math.cos(self.angle)*self.speed*dt
    self.y = self.y + math.sin(self.angle)*self.speed*dt
end


function Bullet:CheckForCollisions()
    for i = 1,#entityManager.planes do
        local p = entityManager.planes[i]
        if p.team ~= self.team then
            if quindoc.pythag(self.x - p.x, self.y - p.y) < 25 then
                self.despawnTimer = -1
                p:TakeDamage(1, self.team)

                entityManager:AddEffect(self.x, self.y, "Smoke")
            end
        end
    end
end



function Bullet:Draw()
    love.graphics.setColor(teams[self.team].bulletColour)
    love.graphics.draw(image.other.bullet, self.x, self.y, self.angle, 1, 1, image.other.bullet:getWidth()/2, image.other.bullet:getHeight()/2)
end



return Bullet