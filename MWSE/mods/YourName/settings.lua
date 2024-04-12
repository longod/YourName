local this = {}
this.modName = "Your Name."
this.configPath = "YourName"

---@class Config
local defaultConfig = {
    ---@class Config.Filtering
    filtering = {
        essential = true,
        corpse = true,
        guard = true,
        creature = true,
        -- non-unique name NPC -- real mode
        -- talking creature -- real mode
        -- follower = false, -- possible? from AI parameter? --
        -- filter list
    },
    ---@class Config.Masking
    masking = {
        gender = true,
        race = true,
        -- unknown name
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

---@return Config
function this.DefaultConfig()
    return table.deepcopy(defaultConfig)
end

return this
