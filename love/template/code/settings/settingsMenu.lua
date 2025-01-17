local width = 1000
local height = 660
local y = 50


local SettingsMenu = {}
SettingsMenu.__index = SettingsMenu

function saveSettings()
    local savingSettings = {}

    for key, value in pairs(settings) do
        if (key ~= "DEV" or DEV) and key ~= "order" then
            savingSettings[key] = {}

            for setting, data in pairs(value) do

                savingSettings[key][setting] = data.value

            end

        end
    end

    dante.save(savingSettings, "save", "settings")
end

function SettingsMenu:New() -- data is a table {{image/path, layer}}
    local obj = setmetatable({}, SettingsMenu)

    obj.curentCatagroy = 1
    obj.catagories = {
        {name = "graphics", displayName = "Graphics", targetScroll = 0},
        {name = "audio", displayName = "Audio", targetScroll = 0},
    }
    if DEV then
        table.insert(obj.catagories, {name = "dev", displayName = "Dev", targetScroll = 0})
    end



    obj.isOpen = false
    obj.displayTimer = 0
    obj.scroll = 0

    settings = love.filesystem.load("code/settings/defaultSettings.lua")()

    local savedSettings = dante.load("save/settings")
    if savedSettings then
        for key, value in pairs(settings) do
            if (key ~= "DEV" or DEV) and key ~= "order" then
                if savedSettings[key] then
                    for setting, data in pairs(value) do
                        if savedSettings[key][setting] then
                            data.value = savedSettings[key][setting]
                        end
                    end
                end
            end
        end
    end

    if settings.graphics.fullscreen.value then
        love.window.setFullscreen(true)
    end


    obj.Ui = GraetUi:New()

    obj:GenerateButtons()

    SettingsMenu.SetCatagory({obj, 1})

    return obj
end

function SettingsMenu:GenerateButtons()
    local xSize = width - 100
    xSize = xSize/#self.catagories

    for i = 1,#self.catagories do
        local c = self.catagories[i]

        self.Ui:AddButton(c.name, -width/2 + (i-1)*xSize, -height/2, xSize, 100)
        self.Ui:GetButtons()[c.name].functions.release = {SettingsMenu.SetCatagory, {self, i}}
        self.Ui:GetButtons()[c.name]:AddText(c.displayName, "center", font.black["40"], nil, 15, xSize)
    end

    -- create the close button here
    self.Ui:AddButton("close", width/2 - 100, -height/2, 100, 100)
    self.Ui:GetButtons()["close"].functions.release = {SettingsMenu.Close, self}
end

local function sliderFunction(value, slider)
    slider.value = value
end

local function toggleFunction(value, toggle)
    toggle.value = value


    if toggle == settings.graphics.fullscreen then
        settingsMenu:toggleFullscreen()
    end
end

function SettingsMenu:toggleFullscreen()
    local mx, my = love.mouse.getPosition()

    mx, my = mx/screen.scale, my/screen.scale
    love.window.setFullscreen(not love.window.getFullscreen())
    love.resize(love.graphics.getWidth(), love.graphics.getHeight())

    if self.catagories[self.curentCatagroy].name == "graphics" then
        self.Ui:GetButtons("settings")["fullscreen"].value = love.window.getFullscreen()
    end

    love.mouse.setPosition(mx*screen.scale, my*screen.scale)
end


function SettingsMenu.SetCatagory(data)
    local self = data[1] 
    self.curentCatagroy = data[2]
    
    
    -- Create the settings buttons here
    local colours = {
        {.9,.9,.9},
        {.7,.9,.7},
        {.6,.6,.6},
    }
    local currentHeight = -height/2 + y + 55
    local currentX = -width/2 + 10
    self.Ui:RemoveAll("settings")

    if settings.order[self.catagories[self.curentCatagroy].name] then
        for i = 1,#settings.order[self.catagories[self.curentCatagroy].name] do
            local name = settings.order[self.catagories[self.curentCatagroy].name][i]
            local currentSetting = settings[self.catagories[self.curentCatagroy].name][name]
            
            if currentSetting.type == "button" then
                self.Ui:AddTextButton(name, currentSetting.displayName, nil, font.black["30"], currentX, currentHeight, 400, colours, "settings")
                self.Ui:GetButtons("settings")[name].functions.release = {currentSetting.func}

            elseif currentSetting.type == "slider" then
                self.Ui:AddSlider(name, currentX+font.black["30"]:getWidth(currentSetting.displayName) + 10, currentHeight + 20, 25, 30, 250, 20, currentSetting.value, "settings")

                self.Ui:GetButtons("settings")[name]:AddImageRail(0, -9, image.button.indicator)
                self.Ui:GetButtons("settings")[name]:AddImage(0, -4, image.button.bar)
                self.Ui:GetButtons("settings")[name]:SetElementColourRail({.9,.9,.9},{.7,.9,.7},{.6,.6,.6})

                self.Ui:GetButtons("settings")[name]:AddText(currentSetting.displayName, nil, font.black["30"], -font.black["30"]:getWidth(currentSetting.displayName) - 10, -20, 1000)
                self.Ui:GetButtons("settings")[name].func = {sliderFunction, currentSetting}



            elseif currentSetting.type == "toggle" then
                self.Ui:AddToggle(name, currentX, currentHeight, font.black["30"]:getWidth(currentSetting.displayName) + 40, font.black["30"]:getHeight(), currentSetting.value, "settings")

                self.Ui:GetButtons("settings")[name].button1:AddText(currentSetting.displayName, nil, font.black["30"], 40, 0, 1000)
                self.Ui:GetButtons("settings")[name].button1:AddImage(0, 9, image.button.check)
                self.Ui:GetButtons("settings")[name].button1:SetElementColour({1,1,1}, {0.9,0.9,0.9}, {0.8,0.8,0.8})

                self.Ui:GetButtons("settings")[name].button2:AddText(currentSetting.displayName, nil, font.black["30"], 40, 0, 1000)
                self.Ui:GetButtons("settings")[name].button2:AddImage(0, 9, image.button.empty)
                self.Ui:GetButtons("settings")[name].button2:SetElementColour({1,1,1}, {0.9,0.9,0.9}, {0.8,0.8,0.8})



                self.Ui:GetButtons("settings")[name].func = {toggleFunction, currentSetting}

            elseif currentSetting.type == "header" then
                self.Ui:AddTextButton(name, currentSetting.displayName, nil, font.black["35"], currentX, currentHeight + 10, 400, {{1,1,1}}, "settings")

                currentHeight = currentHeight + font.black["35"]:getHeight() - font.black["30"]:getHeight() + 10
            end

            currentHeight = currentHeight + font.black["30"]:getHeight()
        end
    end
end
function SettingsMenu.Close(self)
    saveSettings()
    self.isOpen = false 
end

function SettingsMenu:KeyRelased(key)
    if key == "escape" then
        self.isOpen = false
        saveSettings() 
    end
end

function SettingsMenu:Click(x, y)
    local sox = ((love.graphics.getWidth()/screen.scale) - 1920) /2
    local soy = ((love.graphics.getHeight()/screen.scale) - 1080) /2

    self.Ui:Click(x - 960 - sox, y - 540 - soy)
    self.Ui:Click(x - 960 - sox, y - 540 - soy, "settings")

end

function SettingsMenu:Release(x, y)
    local sox = ((love.graphics.getWidth()/screen.scale) - 1920) /2
    local soy = ((love.graphics.getHeight()/screen.scale) - 1080) /2

    self.Ui:Release(x - 960 - sox, y - 540 - soy)
    self.Ui:Release(x - 960 - sox, y - 540 - soy, "settings")

end

function SettingsMenu:Update(dt, x, y)
    local sox = ((love.graphics.getWidth()/screen.scale) - 1920) /2
    local soy = ((love.graphics.getHeight()/screen.scale) - 1080) /2

    self.Ui:Update(dt, x - 960 - sox, y - 540 - soy)
    self.Ui:Update(dt, x - 960 - sox, y - 540 - soy, "settings")

    if self.isOpen then
        self.displayTimer = math.min(self.displayTimer + dt*3, 1)
    else
        self.displayTimer = math.max(self.displayTimer - dt*3, 0)
            
    end
end


--Colours: lightwood 743f30, darkwood 45261b
function SettingsMenu:Draw(gs, dark)
    gs = gs or self.displayTimer

    print(gs)
    love.graphics.reset()

    if not dark then
        love.graphics.setColor(0,0,0,0.5*gs)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    end


    love.graphics.scale(screen.scale)

    local sox = ((love.graphics.getWidth()/screen.scale) - 1920) /2 + 960
    local soy = ((love.graphics.getHeight()/screen.scale) - 1080) /2 + 540
    love.graphics.translate(sox, soy + 1500*(1-gs))

    --this looks quite wierd otherwise
    love.graphics.setColor(0,0,0,1)

    love.graphics.rectangle("fill", -width/2, -height/2-5, width, 100, 25)

    --Draw a basic outline
    love.graphics.setColor(quindoc.hexcode("743f30"))
    love.graphics.rectangle("fill", -width/2, -height/2 + y, width, height, 25)

    love.graphics.setColor(0,0,0,1)
    love.graphics.setLineWidth(10)
    love.graphics.rectangle("line", -width/2, -height/2 + y, width, height, 25)

    local xSize = width - 100
    xSize = xSize/#self.catagories

    for i = 1,#self.catagories do

        if i == self.curentCatagroy then
            love.graphics.setColor(quindoc.hexcode("743f30"))
            love.graphics.rectangle("fill", -width/2 + (i-1)*xSize, -height/2, xSize, 100, 25)

           love.graphics.setScissor(0, 0, love.graphics.getWidth(), love.graphics.getHeight()/2 - (height/2 - 75)*screen.scale)
           --love.graphics.setColor(1,0,0,0.5)
           --love.graphics.rectangle("fill", -2000, -2000, 5000, 5000)
        else
            love.graphics.setColor(quindoc.hexcode("45261b"))

            love.graphics.rectangle("fill", -width/2 + (i-1)*xSize, -height/2, xSize, 100, 25)
    
        end


        love.graphics.setColor(0,0,0,1)

        love.graphics.rectangle("line", -width/2 + (i-1)*xSize, -height/2, xSize, 100, 25)

        if i == self.curentCatagroy then
           love.graphics.setScissor() 
            if i == 1 then
                love.graphics.line( -width/2, -height/2 + 50, -width/2, 0)
            else
                love.graphics.rectangle("line", -width/2 + (i-2)*xSize, -height/2, xSize, 100, 25)
            end
        end
    end

    --screws
    local offSet = 25
    local extraYOffset = 50

    love.graphics.setColor(1,1,1,1)

    --Draw the close button here to hide graphical isues
    love.graphics.setColor(.8,0,0,1)--temporary only
    love.graphics.rectangle("fill", width/2 - 100, -height/2, 100, 100, 25)
    love.graphics.setColor(0,0,0,1)
    love.graphics.rectangle("line", width/2 - 100, -height/2, 100, 100, 25)

    love.graphics.setLineWidth(1)
    self.Ui:Draw()
    self.Ui:Draw("settings", 0, self.scroll)
end

return SettingsMenu