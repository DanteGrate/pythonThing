local Text = require("templateLib.graetUi.graetUiTextElement")
local Rect = require("templateLib.graetUi.graetUiRectElement")
local Image = require("templateLib.graetUi.graetUiImageElement")


local GraetButton = {}
GraetButton.__index = GraetButton

local drawHitboxes = false

function GraetButton.toglehitboxes()
    drawHitboxes = not drawHitboxes
end

function GraetButton:New(x, y, sx, sy) -- data is a table {{image/path, layer}}
    local obj = setmetatable({}, GraetButton)

    obj.x = x
    obj.y = y
    obj.sx = sx
    obj.sy = sy

    obj.graphics = {}

    obj.functions = {
        click = {},
        hover = {},
        release = {},
    }

    obj.mouseMode = "none"

    obj.cLerpSpeed = 5
    obj.modeTryangle = {1,0,0}

    return obj
end

function GraetButton:NewText(text, align, font, x, y, limit, colours, colourLerp)
    local font = font or love.graphics.getFont()

    local textSizeX = font:getWidth(text)
    local textSizeY = font:getHeight(text)

    local buttonX = x
    if align == "center" then
        buttonX = x - textSizeX/2
    elseif align == "right" then
        buttonX = x + limit - textSizeX
    end

    local obj = GraetButton:New(buttonX, y, textSizeX, textSizeY)

    local textX = 0
    local textY = 0

    if align == "center" then
        textX = 0 - limit/2 + font:getWidth(text)/2
    elseif align == "right" then
        textX = 0 - limit + font:getWidth(text)
    end

    obj:AddText(text, align, font, textX, 0, limit)
    if colours then
        obj:SetElementColour(colours[1], colours[2], colours[3], colourLerp)
    end

    return obj
end


function GraetButton:AddText(text, align, font, x, y, limit, pos)
    table.insert(self.graphics, pos or #self.graphics+1, Text:New(text, align, font, x, y, limit))
end
function GraetButton:AddRect(x, y, sx, sy, fill, curve, pos)
    table.insert(self.graphics, pos or #self.graphics+1, Rect:New(x, y, sx or self.sx, sy or self.sy, fill or "fill", curve or 0))
end
function GraetButton:AddImage(x, y, image, sx, sy, pos)
    table.insert(self.graphics, pos or #self.graphics+1, Image:New(x, y, image, sx, sy))
end

function GraetButton:SetElementColour(c1, c2, c3, elementNo)
    self.graphics[elementNo or #self.graphics]:SetColour(c1, c2, c3)
end


function GraetButton:Update(dt, mx, my)
    if mx > self.x and mx < self.x + self.sx and my > self.y and my < self.y + self.sy then
        if self.mouseMode == "none" then
            
            self.mouseMode = "hover"
            if #self.functions.hover > 0 then
                for i = 1,#self.functions.hover do
                    self.functions.hover[1](self.functions.hover[2])
                end
            end

        end
    elseif self.mouseMode == "hover" then
        self.mouseMode = "none"
    end

    --colour Lerping :D     Could b a function, 
    if self.mouseMode == "none" then
        -- tryabgle move towward 1
        local ratio = self.modeTryangle[2]/self.modeTryangle[3] or 0

        if self.modeTryangle[3] == 0 and self.modeTryangle[2] == 0 then
            ratio = 0.5
        elseif self.modeTryangle[2] == 0 then
            ratio = 1
        elseif self.modeTryangle[3] == 0 then
            ratio = 0
        end

        self.modeTryangle[1] = math.min(self.modeTryangle[1] + self.cLerpSpeed*dt, 1)
        self.modeTryangle[2] = math.max(self.modeTryangle[2] - (self.cLerpSpeed*dt)*(1-ratio), 0)
        self.modeTryangle[3] = math.max(self.modeTryangle[3] - (self.cLerpSpeed*dt)*(ratio), 0)

    elseif self.mouseMode == "hover" then
        -- tryabgle move towward 2
        local ratio = self.modeTryangle[1]/self.modeTryangle[3] or 0

        if self.modeTryangle[3] == 0 and self.modeTryangle[1] == 0 then
            ratio = 0.5
        elseif self.modeTryangle[1] == 0 then
            ratio = 1
        elseif self.modeTryangle[3] == 0 then
            ratio = 0
        end

        self.modeTryangle[2] = math.min(self.modeTryangle[2] + self.cLerpSpeed*dt, 1)
        self.modeTryangle[1] = math.max(self.modeTryangle[1] - (self.cLerpSpeed*dt)*(1-ratio), 0)
        self.modeTryangle[3] = math.max(self.modeTryangle[3] - (self.cLerpSpeed*dt)*(ratio), 0)
    else
        -- tryabgle move towward 3
        local ratio = self.modeTryangle[1]/self.modeTryangle[2] or 0

        if self.modeTryangle[2] == 0 and self.modeTryangle[1] == 0 then
            ratio = 0.5
        elseif self.modeTryangle[1] == 0 then
            ratio = 1
        elseif self.modeTryangle[2] == 0 then
            ratio = 0
        end

        self.modeTryangle[3] = math.min(self.modeTryangle[3] + self.cLerpSpeed*dt, 1)
        self.modeTryangle[1] = math.max(self.modeTryangle[1] - (self.cLerpSpeed*dt)*(1-ratio), 0)
        self.modeTryangle[2] = math.max(self.modeTryangle[2] - (self.cLerpSpeed*dt)*(ratio), 0)
    end
end

function GraetButton:Click(mx, my)
    --if mx > self.x and mx < self.x + self.sx and my > self.y and my < self.y + self.sy then
    if self.mouseMode == "hover" then  
        self.mouseMode = "click"
        if #self.functions.click > 0 then
            self.functions.click[1](self.functions.click[2])
        end
    end
end

function GraetButton:Release(mx, my)

    if mx > self.x and mx < self.x + self.sx and my > self.y and my < self.y + self.sy and self.mouseMode == "click" then
        
        self.mouseMode = "hover"
        if #self.functions.release > 0 then
            self.functions.release[1](self.functions.release[2])
        end
    else
        self.mouseMode = "none"
        
    end

end



function GraetButton:Draw(ox, oy)
    for i = 1,#self.graphics do
        self.graphics[i]:Draw(self.x + ox, self.y + oy, self.mouseMode, self.modeTryangle)
    end

    if drawHitboxes then
        if self.mouseMode == "click" then
            love.graphics.setColor(0,1,0)
        elseif self.mouseMode == "hover" then
            love.graphics.setColor(0,0,1)
        else 
            love.graphics.setColor(1,0,0)
        end

        love.graphics.rectangle("line", self.x + ox, self.y + oy, self.sx, self.sy)

    end
end



return GraetButton