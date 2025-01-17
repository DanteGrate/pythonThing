local Smoke = {}
Smoke.__index = Smoke


function Smoke:New(x, y)
    local obj = setmetatable({}, Smoke)

    -- basic values
    obj.x = x
    obj.y = y

    obj.despawnTimer = 0.3

    return obj
end


function Smoke:Update(dt)
    self.despawnTimer = self.despawnTimer - dt
end


function Smoke:Draw()
    love.graphics.setColor(1,1,1)

    love.graphics.draw(image.other.smoke, self.x, self.y, self.angle, 1, 1, image.other.smoke:getWidth()/2, image.other.smoke:getHeight()/2)
end



return Smoke