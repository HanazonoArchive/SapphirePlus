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
dofile(ModPath .. "libs/DoorActions.lua")
dofile(ModPath .. "libs/CivilianActions.lua")
dofile(ModPath .. "libs/ReviveActions.lua")
dofile(ModPath .. "libs/EnemyActions.lua")
dofile(ModPath .. "libs/GageActions.lua")
dofile(ModPath .. "libs/JokerActions.lua")
dofile(ModPath .. "libs/CustodyActions.lua")
dofile(ModPath .. "libs/CorpseActions.lua")
dofile(ModPath .. "libs/InGameMenu.lua")

Sapphire:LoadSettings()
Sapphire:Log("Core initialized.")