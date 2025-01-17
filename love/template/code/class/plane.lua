local Plane = {}
Plane.__index = Plane


function Plane:New(x, y, angle, team)
    local obj = setmetatable({}, Plane)

    -- basic values
    obj.x = x
    obj.y = y
    obj.angle = angle

    obj.speed = math.random(100, 150)
    obj.targetSpeed = obj.speed 
    obj.rotationSpeed = math.pi

    obj.health = 5

    obj.team = team

    -- set up timers
    obj.animationTimer = math.random(1, 40)*10
    obj.targetChangeTimer = 0
    obj.targetSpeedTimer = math.random(50, 100)/10
    obj.effectTimer = math.random(1, 60)/60

    obj.target = nil
    obj.targetX = screen.width/2
    obj.targetY = screen.height/2
    obj.targetAngle = obj.angle

    -- shooting
    obj.bulletCount = 6
    obj.reloadTimer = math.random(10, 300)/100
    obj.shootCool = 0

    return obj
end


function Plane:RotateTowards(targetAngle, dt)

    local currentAngle = self.angle % (math.pi*2)
    local targetAngle = targetAngle  % (math.pi*2)

    local angleDiff = (targetAngle - currentAngle + math.pi) % (math.pi*2) - math.pi 

    local maxRotation = self.rotationSpeed*dt

    self.angle = self.angle + quindoc.clamp(angleDiff, -maxRotation, maxRotation)
end


function Plane:Update(dt)
    self.animationTimer = self.animationTimer + dt*10

    self:RotateTowards(self.targetAngle, dt)
    self.x = self.x + math.cos(self.angle)*self.speed*dt
    self.y = self.y + math.sin(self.angle)*self.speed*dt
end

function Plane:UpdateShooting(dt)
    self.reloadTimer = self.reloadTimer - dt
    
    if self.reloadTimer < 0 then
        if self.target and self.target.team ~= self.team and math.abs(self.angle - self.targetAngle + math.pi)% (math.pi*2) - math.pi < math.pi/4 then
            if self.bulletCount > 0 then
                self.shootCool = self.shootCool - dt

                if self.shootCool < 0 then
                    self.shootCool = 0.2
                    self.bulletCount = self.bulletCount - 1

                    entityManager:AddBullet(self.x, self.y, self.angle, self.team)
                    audioPlayer.playSound(audio.shoot, "sfxVolume")

                end
                    
            else
                self.reloadTimer = math.random(1, 3)
                self.bulletCount = 10
            end
        end
    end
end

function Plane:UpdateSpeed(dt)
    self.targetSpeedTimer = self.targetSpeedTimer -dt
    if self.targetSpeedTimer <= 0 then
        self.targetSpeed = math.random(75, 200)
        self.targetSpeedTimer = math.random(15, 50)/10
    end

    if self.speed < self.targetSpeed then
        self.speed = math.min(self.speed + dt*10, self.targetSpeed)
    elseif self.speed > self.targetSpeed then
        self.speed =  math.max(self.speed - dt*10, self.targetSpeed)
    end
end


function Plane:FindTargetLocation()
    if self.target then
        self.targetX = self.target.x
        self.targetY = self.target.y

        local distToMid = quindoc.pythag(self.x - screen.width/2, self.y - screen.height/2)

        if distToMid > 100 then
            local lerp = math.min( (distToMid-500) / 500, 1)

            self.targetX = (1-lerp) * self.targetX + lerp * screen.width/2
            self.targetY = (1-lerp) * self.targetY + lerp * screen.height/2
        end
    end

    self.targetAngle = math.atan2(self.targetY - self.y, self.targetX - self.x )
end


function Plane:UpdateTarget(dt)
    self.targetChangeTimer = self.targetChangeTimer - dt

    if self.targetChangeTimer <= 0 then
        self.target = entityManager.planes[math.random(1, #entityManager.planes)]
        self.targetChangeTimer = math.random(3.0, 8.0)
    else
        if not self.target or self.target.health <= 0 then
            self.target = nil
        end
    end
end


function Plane:UpdateDamageEffect(dt)
    self.effectTimer = self.effectTimer + dt

    -- smoke effects
    if self.effectTimer > 1/60 then
        if self.health < 5 then
            for i = 1,5-self.health do
                if math.random(1, 10) == 1 then
                    entityManager:AddEffect(self.x + math.random(-10, 10), self.y + math.random(-10, 10), "Smoke")

                end
            end
        end
        self.effectTimer = self.effectTimer - (1/60)
    end
end

function Plane:UpdateDespawn()
    self.despawnTimer = self.despawnTimer - 1
    

    --
    return self.despawnTimer <= -3
end


function Plane:Draw()
    love.graphics.setColor(teams[self.team].planeColour)
    love.graphics.draw(image.plane.base, self.x, self.y, self.angle, 1, 1, image.plane.base:getWidth()/2, image.plane.base:getHeight()/2)

    love.graphics.setColor(1,1,1)
    love.graphics.draw(image.plane.colour, self.x, self.y, self.angle, 1, 1, image.plane.colour:getWidth()/2, image.plane.colour:getHeight()/2)
    local prop = "prop" .. math.floor(self.animationTimer%4)
    love.graphics.draw(image.plane[prop], self.x, self.y, self.angle, 1, 1, image.plane[prop]:getWidth()/2, image.plane[prop]:getHeight()/2)

    --love.graphics.line(self.x, self.y, self.targetX, self.targetY)

    --love.graphics.line(self.x, self.y, self.x + math.cos(self.targetAngle)*100, self.y + math.cos(self.targetAngle)*100)

end


function Plane:DrawHitbox()

end


function Plane:TakeDamage(amount, bulletTeam)
    if not self.despawnTimer then
        self.health = self.health - amount

        audioPlayer.playSound(audio.hit, "sfxVolume")

        if self.health <= 0 then
            audioPlayer.playSound(audio.explosion, "sfxVolume")
            
            if bulletTeam then
                gameModeSettings.currentTeams[bulletTeam].score = gameModeSettings.currentTeams[bulletTeam].score + 1
            end

            entityManager:AddEffect(self.x, self.y, "Explosion")

            self.despawnTimer = 0
        end
    end
end

return Plane