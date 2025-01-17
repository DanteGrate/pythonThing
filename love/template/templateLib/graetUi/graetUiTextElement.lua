local GraetUiText = {}
GraetUiText.__index = GraetUiText

function GraetUiText:New(text, align, font, x, y, limit) -- data is a table {{image/path, layer}}
    local obj = setmetatable({}, GraetUiText)

    obj.text = text

    obj.align = align or "left"
    obj.font = font or love.graphics.getFont()

    obj.x = x or 0
    obj.y = y or 0 
    obj.limit = limit or math.huge
    
    --[[if align == "center" then
        obj.x = obj.x - limit/2 + obj.font:getWidth(text)/2
    elseif align == "right" then
        obj.x = obj.x - limit + obj.font:getWidth(text)
    end]]

    return obj
end


function GraetUiText:SetColour(colour1, colour2, colour3, cLerp)
    self.colour1 = colour1 or {1,1,1}
    self.colour2 = colour2 or colour1 or {1,1,1}
    self.colour3 = colour3 or colour2 or colour1 or {1,1,1}
    self.cLerp = cLerp
end


function GraetUiText:Draw(x, y, mouseMode, modeTryangle)
    if self.colour1 then
        local cLerp = self.cLerp or tweens.sineInOut

        if modeTryangle then
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

    love.graphics.setFont(self.font)
    love.graphics.printf(self.text, x + self.x, y + self.y, self.limit, self.align)
end

return GraetUiText