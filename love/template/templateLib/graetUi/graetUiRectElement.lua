local GraetUiRect = {}
GraetUiRect.__index = GraetUiRect

function GraetUiRect:New(x, y, sx, sy, fill, curve) -- data is a table {{image/path, layer}}
    local obj = setmetatable({}, GraetUiRect)

    obj.x = x or 0
    obj.y = y or 0 
    obj.sx = sx or 100
    obj.sy = sy or 100

    obj.curve = curve or 0
    obj.fill = fill or "fill"

    return obj
end


function GraetUiRect:SetColour(colour1, colour2, colour3, cLerp)
    self.colour1 = colour1
    self.colour2 = colour2 or colour1
    self.colour3 = colour3 or colour2 or colour1
    self.cLerp = cLerp
end


function GraetUiRect:Draw(x, y, mouseMode, modeTryangle)
    if self.colour1 then
        if modeTryangle then
            local cLerp = self.cLerp or tweens.sineInOut
            
            local r = self.colour1[1]*cLerp(modeTryangle[1]) + self.colour2[1]*cLerp(modeTryangle[2]) + self.colour3[1]*cLerp(modeTryangle[3])
            local g = self.colour1[2]*cLerp(modeTryangle[1]) + self.colour2[2]*cLerp(modeTryangle[2]) + self.colour3[2]*cLerp(modeTryangle[3])
            local b = self.colour1[3]*cLerp(modeTryangle[1]) + self.colour2[3]*cLerp(modeTryangle[2]) + self.colour3[3]*cLerp(modeTryangle[3])
            local a = (self.colour1[4] or 1)*cLerp(modeTryangle[1]) + (self.colour2[4] or 1)*cLerp(modeTryangle[2]) + (self.colour3[4] or 1)*cLerp(modeTryangle[3])

            love.graphics.setColor(r, g, b, a)
        else
            if mouseMode == "click" then
                love.graphics.setColor(self.colour3)
            elseif mouseMode == "hover" then
                love.graphics.setColor(self.colour2)
            else
                love.graphics.setColor(self.colour1)
            end
        end
    else
        --a default colour
        love.graphics.setColor(1,1,1)
    end

    love.graphics.rectangle(self.fill, x + self.x, y + self.y, self.sx, self.sy, self.curve)
end

return GraetUiRect