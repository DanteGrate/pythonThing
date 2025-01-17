local function playSound(sound, catagory, pitchChange, position)
    local tempSound

    --create the sound from either a table (pick random) or sound
    if type(sound) == "table" then
        tempSound = sound[math.random(1,#sound)]:clone()
    else
        tempSound = sound:clone()
    end

    -- modify pitch
    local pitch = (pitchChange or 0.05)/2
    tempSound:setPitch(1 + math.random(-pitch*100, pitch*100)/100)

    -- modify volume
    local subVolume = 1
    if catagory and settings.audio[catagory] then
        subVolume = settings.audio[catagory].value
    end
    local volume = settings.audio.masterVolume.value * subVolume
    tempSound:setVolume(volume)

    -- 'move' the sound
    if position then
        if position.absoloute ~= true then
            tempSound:setRelative(true)
        end
        tempSound:setPosition(position.x or 0, position.y or 0, position.z or 0)
    end
    
    tempSound:play()
end

return {
    playSound = playSound,
}