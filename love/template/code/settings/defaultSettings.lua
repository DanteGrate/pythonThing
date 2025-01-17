--Functions required for "click" type buttons
local function ReloadGameState()
    previousGameState = "getRecked"
end


-- load each setting as catagories with special order table
return {
    graphics = {
        fullscreen = {type = "toggle", displayName = "Fullscreen", value = true}
    },
    audio = {
        masterVolume = {type = "slider", displayName = "Master Volume", value = 1}, 
        sfxVolume = {type = "slider", displayName = "SFX Volume", value = 1},
        musicVolume = {type = "slider", displayName = "music? Volume", value = 1},
    },
    -- the player should NEVER have acsess to these :D
    dev = {
        
    },

    -- Order is here so we load it in at the same time, we can then hvae key, value tables in an ordeer that is not alphabetti-spaghetti.
    order = {
        graphics = {

        },
        audio = {
            "masterVolume",
            "sfxVolume",
    
        },
        keybinds = {
    
        },
        dev = {

        },
    }
}