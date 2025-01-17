local function loadParticles()
    particleTable = {}
    particleClass = {}
    particleUpdate = {}
    particleDraw = {} 
    particles.loadParticleClasses()
end

local function spawnParticle(spawnClass,spawnX,spawnY,spawnAngle,spawnData)

    local particle = {}
    particle.class = spawnClass

    particleClass["default"](particle,spawnX,spawnY,spawnAngle,spawnData)
    if type(spawnClass) == "string" then particleClass[particle.class](particle,spawnX,spawnY,spawnData) end

    table.insert(particleTable,particle)

end

local function updateParticles(dt)

    for i = #particleTable, 1, -1 do
        particleUpdate[particleTable[i].class](particleTable[i],dt)
        if particleTable[i].delete then
            table.remove(particleTable,i)
        end
    end

end

local function drawParticles()
    for i = #particleTable, 1, -1 do
        particleDraw[particleTable[i].class](particleTable[i])
    end
    love.graphics.setColor(1,1,1,1)
end

return {
    loadParticles = loadParticles,
    spawnParticle = spawnParticle,
    updateParticles = updateParticles,
    drawParticles = drawParticles,
}