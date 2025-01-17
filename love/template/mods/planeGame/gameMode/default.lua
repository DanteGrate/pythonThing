local function load()
    for i = 1,5 do
        for key, value in pairs(gameModeSettings.currentTeams) do
            entityManager:AddPlane(key)
        end
    end
end

return {
    Load = load,
}