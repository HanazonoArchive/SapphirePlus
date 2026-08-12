function Sapphire:Log(message)
    local settings = self.Settings or {}

    -- Always persist to the log file: this mod's main failure mode is a SuperBLT
    -- hook silently not loading, and the on-disk log is the only way to confirm
    -- which hooks ran. The Debug flag gates only the (noisy) console echo.
    local path = self.ModPath .. "logs/Sapphire+.log"

    local file = io.open(path, "a")

    if file then

        file:write(os.date("[%H:%M:%S] "))
        file:write(tostring(message))
        file:write("\n")

        file:close()

    end

    if settings.Debug then
        log("[Sapphire+] " .. tostring(message))
    end

end