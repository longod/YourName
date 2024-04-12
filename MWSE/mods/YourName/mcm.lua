--- @param e modConfigReadyEventData
local function OnModConfigReady(e)
    local config = require("YourName.config")
    local settings = require("YourName.settings")
    local template = mwse.mcm.createTemplate(settings.modName)
    template:saveOnClose(settings.configPath, config)
    template:register()

    ---@param value boolean
    ---@return string
    local function GetOnOff(value)
        return (value and tes3.findGMST(tes3.gmst.sOn).value --[[@as string]] or tes3.findGMST(tes3.gmst.sOff).value --[[@as string]])
    end
    ---@param value boolean
    ---@return string
    local function GetYesNo(value)
        return (value and tes3.findGMST(tes3.gmst.sYes).value --[[@as string]] or tes3.findGMST(tes3.gmst.sNo).value --[[@as string]])
    end

    local page = template:createSideBarPage({
        label = settings.modName,
    })
    page.sidebar:createInfo({
        text = "More important to ask the people you are talking to about their *Background*."
    })

    page:createButton({
        buttonText = "Forget",
        label = "everyone's name",
        description = "Clear information recorded with the names of the people you have been in contact with. This feature is in-game only.",
        callback = function()
            if require("YourName.memory").ClearMemory() then
		        tes3.messageBox { message = "Succeeded in forgetting everyone's name.", buttons = { tes3.findGMST(tes3.gmst.sOK).value --[[@as string]] } }
            end
        end,
        inGameOnly = true
    })

    do
        local filter = page:createCategory({
            label = "Target Group",
            description = "Control who it applies to. Also as a general rule, it does not apply to those who do not have unique names.",
        })
        filter:createOnOffButton({
            label = "Essential",
            description = "Applies to NPCs with the essential.Many of them will identify themselves, but it makes it more difficult to carry out quests involving persons who do not name themselves.",
            variable = mwse.mcm.createTableVariable({
                id = "essential",
                table = config.filtering,
            })
        })
        filter:createOnOffButton({
            label = "Corpse",
            description = "Applied to permanent corpses. Most of them will not be named.",
            variable = mwse.mcm.createTableVariable({
                id = "corpse",
                table = config.filtering,
            })
        })
        filter:createOnOffButton({
            label = "Guard",
            description = "Applies to guards. They name themselves as guards, but that doesn't mean much.",
            variable = mwse.mcm.createTableVariable({
                id = "guard",
                table = config.filtering,
            })
        })
        filter:createOnOffButton({
            label = "Talking Creature",
            description = "Applies to talking creatures. They are more likely than people to not be named. This includes special persons such as Vivec.",
            variable = mwse.mcm.createTableVariable({
                id = "creature",
                table = config.filtering,
            })
        })
    end
    do
        local mask = page:createCategory({
            label = "Unknown Name",
            description = "Naming rule when the name is completely unknown. If it is partially known, it is partially displayed.",
        })
        mask:createOnOffButton({
            label = "Gender",
            description = " Display gender.",
            variable = mwse.mcm.createTableVariable({
                id = "gender",
                table = config.masking,
            })
        })
        mask:createOnOffButton({
            label = "Race",
            description = " Display race.",
            variable = mwse.mcm.createTableVariable({
                id = "race",
                table = config.masking,
            })
        })
    end
    do
        local dev = page:createCategory({
            label = "Development",
            description = "",
        })
        dev:createDropdown({
            label = "Logging Level",
            description = "Set the log level.",
            options = {
                { label = "TRACE", value = "TRACE" },
                { label = "DEBUG", value = "DEBUG" },
                { label = "INFO",  value = "INFO" },
                { label = "WARN",  value = "WARN" },
                { label = "ERROR", value = "ERROR" },
                { label = "NONE",  value = "NONE" },
            },
            variable = mwse.mcm.createTableVariable({
                id = "logLevel",
                table = config.development
            }),
            callback = function(self)
                local logger = require("YourName.logger")
                logger:setLogLevel(self.variable.value)
            end
        })
        dev:createOnOffButton({
            label = "Log to Console",
            description = "Output the log to console.",
            variable = mwse.mcm.createTableVariable({
                id = "logToConsole",
                table = config.development,
            }),
            callback = function(self)
                local logger = require("YourName.logger")
                logger.logToConsole = config.development.logToConsole
            end
        })
        dev:createOnOffButton({
            label = "Unit-Test",
            description = "Run unit-test.",
            variable = mwse.mcm.createTableVariable({
                id = "test",
                table = config.development,
                restartRequired = true,
            })
        })
    end
end
event.register(tes3.event.modConfigReady, OnModConfigReady)
