local Text = require("templateLib.graetUi.graetUiTextElement")
local Rect = require("templateLib.graetUi.graetUiRectElement")
local Image = require("templateLib.graetUi.graetUiImageElement")


local GraetSlider = {}
GraetSlider.__index = GraetSlider

local drawHitboxes = false

function GraetSlider.toglehitboxes()
    drawHitboxes = not drawHitboxes
end

function GraetSlider:New(x, y, bsx, bsy, rsx, rsy, value) -- data is a table {{image/path, layer}}
    local obj = setmetatable({}, GraetSlider)

    obj.x = x
    obj.y = y

    obj.bsx = bsx
    obj.bsy = bsy

    obj.mox = 0

    obj.railSize = rsx
    obj.railHeight = rsy

    obj.railGraphics = {}
    obj.graphics = {}

    obj.value = value

    obj.func = {}

    obj.mouseMode = "none"

    obj.cLerpSpeed = 5
    obj.modeTryangle = {1,0,0}

    return obj
end

function GraetSlider:NewText(text, align, font, x, y, limit, colours, colourLerp)
    local font = font or love.graphics.getFont()

    local textSizeX = font:getWidth(text)
    local textSizeY = font:getHeight(text)

    local buttonX = x
    if align == "center" then
        buttonX = x - textSizeX/2
    elseif align == "right" then
        buttonX = x + limit - textSizeX
    end

    local obj = GraetSlider:New(buttonX, y, textSizeX, textSizeY)

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


function GraetSlider:AddText(text, align, font, x, y, limit, pos)
    table.insert(self.graphics, pos or #self.graphics+1, Text:New(text, align, font, x, y, limit))
end
function GraetSlider:AddTextRail(text, align, font, x, y, limit, pos)
    table.insert(self.railGraphics, pos or #self.railGraphics+1, Text:New(text, align, font, x, y, limit))
end

function GraetSlider:AddRect(x, y, sx, sy, fill, curve, pos)
    table.insert(self.graphics, pos or #self.graphics+1, Rect:New(x, y, sx or self.sx, sy or self.sy, fill or "fill", curve or 0))
end
function GraetSlider:AddRectRail(x, y, sx, sy, fill, curve, pos)
    table.insert(self.railGraphics, pos or #self.railGraphics+1, Rect:New(x, y, sx or self.sx, sy or self.sy, fill or "fill", curve or 0))
end

function GraetSlider:AddImage(x, y, image, sx, sy, pos)
    table.insert(self.graphics, pos or #self.graphics+1, Image:New(x, y, image, sx, sy))
end
function GraetSlider:AddImageRail(x, y, image, sx, sy, pos)
    table.insert(self.railGraphics, pos or #self.railGraphics+1, Image:New(x, y, image, sx, sy))
end


function GraetSlider:SetElementColour(c1, c2, c3, elementNo)
    self.graphics[elementNo or #self.graphics]:SetColour(c1, c2, c3)
end
function GraetSlider:SetElementColourRail(c1, c2, c3, elementNo)
    self.railGraphics[elementNo or #self.graphics]:SetColour(c1, c2, c3)
end



function GraetSlider:Update(dt, mx, my)
    local startX = ((self.railSize - self.bsx)*self.value)

    if mx > self.x + startX and mx < self.x + startX + self.bsx and my > self.y - self.bsy/2 and my < self.y + self.bsy/2 then
        if self.mouseMode == "none" or self.mouseMode == "railHover" then
            self.mouseMode = "hover"
        end
    elseif  mx > self.x and mx < self.x + self.railSize and my > self.y - self.railHeight/2 and my < self.y + self.railHeight/2 then
        if self.mouseMode == "none" or self.mouseMode == "hover" then
            self.mouseMode = "railHover"
        end
    elseif self.mouseMode == "hover" or self.mouseMode == "railHover" then
        self.mouseMode = "none"
    end

    if self.mouseMode == "click" then
        self.value = quindoc.clamp(((mx+self.mox) - self.bsx/2 - self.x) / (self.railSize - self.bsx), 0, 1)
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

function GraetSlider:Click(mx, my)
    --if mx > self.x and mx < self.x + self.sx and my > self.y and my < self.y + self.sy then
    if self.mouseMode == "hover" then  
        self.mouseMode = "click"

        local startX = ((self.railSize - self.bsx)*self.value) + self.bsx/2

        self.mox = self.x + startX - mx 

    elseif self.mouseMode == "railHover" then  
        self.mouseMode = "click"

        self.mox = 0
        self.value = quindoc.clamp(((mx+self.mox) - self.bsx/2 - self.x) / (self.railSize - self.bsx), 0, 1)

    end
end

function GraetSlider:Release(mx, my)

    if self.mouseMode == "click" then  

        if #self.func > 0 then
            self.func[1](self.value, self.func[2])
        end
        
    end

    self.mouseMode = "none"

end



function GraetSlider:Draw(ox, oy)
    local startX = ((self.railSize - self.bsx)*self.value)

    for i = 1,#self.graphics do
        self.graphics[i]:Draw(self.x + ox, self.y + oy, self.mouseMode, self.modeTryangle)
    end
    for i = 1,#self.railGraphics do
        self.railGraphics[i]:Draw(self.x + startX + ox, self.y + oy, self.mouseMode, self.modeTryangle)
    end


    if drawHitboxes then
        if self.mouseMode == "click" then
            love.graphics.setColor(0,1,0)
        elseif self.mouseMode == "hover" then
            love.graphics.setColor(0,0,1)
        elseif self.mouseMode == "railHover" then
            love.graphics.setColor(1,0,1)
        else 
            love.graphics.setColor(1,0,0)
        end

        love.graphics.rectangle("line", self.x + ox, self.y - self.railHeight/2 + oy, self.railSize, self.railHeight)

        love.graphics.rectangle("line", self.x + startX + ox, self.y - self.bsy/2 + oy, self.bsx, self.bsy)

    end
end



return GraetSlider