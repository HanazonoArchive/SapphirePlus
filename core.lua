if rawget(_G, "Sapphire") then
    return
end

Sapphire = {}

Sapphire.ModPath = ModPath

dofile(ModPath .. "libs/Version.lua")
dofile(ModPath .. "libs/Config.lua")
dofile(ModPath .. "libs/Logger.lua")
dofile(ModPath .. "libs/Utils.lua")

Sapphire:LoadSettings()
Sapphire:Log("Core initialized.")