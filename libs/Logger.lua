function Sapphire:Log(message)
    local settings = self.Settings or {}
    if settings.Debug == false then
        return
    end

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