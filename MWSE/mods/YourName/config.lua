
---@class Config
local defaultConfig = {
    ---@class Config.Filtering
    filtering = {
        guard = true,
        essential = true,
        corpse = false,
        creature = true,
        -- follower = false, -- possible? from AI parameter? --
    },
    ---@class Config.Masking
    masking = {
        gender = true,
        race = true,
        -- fillUnknownPart = false,
        -- https://wiki.openmw.org/index.php?title=Research:Disposition_and_Persuasion
        -- modifier = true, -- Speechcraft, Personality, Luck, same race or not, disposition, fatigue, spell
    },

    -- game settings
    -- forgotten
    -- skill, attribute

    ---@class Config.Development
    development = {
        logLevel = "INFO",
        logToConsole = false,
        test = false,
    }
}

local settings = require("YourName.settings")
local config = nil ---@type Config

---@return Config
local function Load()
    config = config or mwse.loadConfig(settings.configPath, defaultConfig)
    return config
end

---@return Config
local function Default()
    return table.deepcopy(defaultConfig)
end

return Load()
