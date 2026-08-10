if rawget(_G, "Sapphire") then
    return
end

Sapphire = {}

Sapphire.ModPath = ModPath

dofile(ModPath .. "libs/Version.lua")
dofile(ModPath .. "libs/Config.lua")
dofile(ModPath .. "libs/Logger.lua")
dofile(ModPath .. "libs/Utils.lua")
dofile(ModPath .. "libs/LootActions.lua")
dofile(ModPath .. "libs/InGameMenu.lua")

Sapphire:LoadSettings()
Sapphire:Log("Core initialized.")