
local config = require("YourName.config")
local masking = require("YourName.masking")

local unitwind = require("unitwind").new({
    enabled = config.development.test,
    highlight = false,
    -- exitAfter = true,
})

unitwind:start("Your Name")
unitwind:mock(tes3, "player", {
    data = {},
})
do
    local unknown = masking.unknown
    local testSource = {
        { -- 1
            input = "J'Dhannar-Dhannar",
            expected = {
                { mask = 0x0, name = "J'Dhannar-Dhannar" },
                { mask = 0x1, name = unknown },
            }
        },
        { -- 2
            input = "J'Dhannar-Dhannar J'Hanir-J'Hanir",
            expected = {
                { mask = 0x0, name = "J'Dhannar-Dhannar J'Hanir-J'Hanir" },
                { mask = 0x1, name = "J'Hanir-J'Hanir" },
                { mask = 0x2, name = "J'Dhannar-Dhannar" },
                { mask = 0x3, name = unknown },
            }
        },
        { -- 3
            input = "J'Dhannar-Dhannar J'Hanir-J'Hanir J'Rasha-J'Rasha",
            expected = {
                { mask = 0x0, name = "J'Dhannar-Dhannar J'Hanir-J'Hanir J'Rasha-J'Rasha" },
                { mask = 0x1, name = "J'Hanir-J'Hanir J'Rasha-J'Rasha" },
                { mask = 0x2, name = "J'Dhannar-Dhannar J'Rasha-J'Rasha" },
                { mask = 0x4, name = "J'Dhannar-Dhannar J'Hanir-J'Hanir" },
                { mask = 0x3, name = "J'Rasha-J'Rasha" },
                { mask = 0x5, name = "J'Hanir-J'Hanir" },
                { mask = 0x6, name = "J'Dhannar-Dhannar" },
                { mask = 0x7, name = unknown },
            }
        },
        { -- the
            input = "Hylf the Harrier",
            expected = {
                { mask = 0x0, name = "Hylf the Harrier" },
                { mask = 0x1, name = "The Harrier" }, -- transform 'The' better
                { mask = 0x2, name = "Hylf" },
                { mask = 0x3, name = unknown },
            }
        },
        { -- the
            input = "The Udyrfrykte",
            expected = {
                { mask = 0x0, name = "The Udyrfrykte" },
                { mask = 0x1, name = unknown },
            }
        },
        { -- of
            input = "Ettiene of Glenmoril Wyrd",
            expected = {
                { mask = 0x0, name = "Ettiene of Glenmoril Wyrd" },
                { mask = 0x1, name = "Glenmoril Wyrd" },
                { mask = 0x2, name = "Ettiene Wyrd" }, -- wired
                { mask = 0x4, name = "Ettiene of Glenmoril" }, -- wired
                { mask = 0x3, name = "Wyrd" }, -- wired
                { mask = 0x5, name = "Glenmoril" }, -- wired
                { mask = 0x6, name = "Ettiene" },
                { mask = 0x7, name = unknown },
            }
        },
        { -- single quote
            input = "'Ten-Tongues' Weerhat",
            expected = {
                { mask = 0x0, name = "'Ten-Tongues' Weerhat" },
                { mask = 0x1, name = "Weerhat" },
                { mask = 0x2, name = "'Ten-Tongues'" },
                { mask = 0x3, name = unknown },
            }
        },
        { -- double quate
            -- The best practice is to treat the words within quotation marks as a single word, but simply treating them as unquoted should not be a problem in most cases.
            -- That way, if it appears in the text without quotation marks, there is no problem.
            -- In fact, Ten-Tongues can appear without quotation marks, but since they are connected by hyphens, that is not a problem.
            input = "Edd \"Fast Eddie\" Theman",
            expected = {
                { mask = 0x0, name = "Edd \"Fast Eddie\" Theman" },
                { mask = 0x1, name = "\"Fast Eddie\" Theman" },
                { mask = 0x2, name = "Edd Eddie\" Theman" },
                { mask = 0x3, name = "Eddie\" Theman" },
                { mask = 0x4, name = "Edd \"Fast Theman" },
                { mask = 0x5, name = "\"Fast Theman" },
                { mask = 0x6, name = "Edd Theman" },
                { mask = 0x7, name = "Theman" },
                { mask = 0x8, name = "Edd \"Fast Eddie\"" },
                { mask = 0x9, name = "\"Fast Eddie\"" },
                { mask = 0xA, name = "Edd Eddie\"" },
                { mask = 0xB, name = "Eddie\"" },
                { mask = 0xC, name = "Edd \"Fast" },
                { mask = 0xD, name = "\"Fast" },
                { mask = 0xE, name = "Edd" },
                { mask = 0xF, name = unknown },
            }
        },
        -- TODO edge case, mixed ofthe, case-insensitive
    }
    for _, s in ipairs(testSource) do
        unitwind:test("Create Mask (" .. s.input .. ")", function()
            local e = s.expected[table.size(s.expected)]
            local actual = masking.CreateMask(s.input)
            unitwind:expect(actual).toBe(e.mask)
        end)
    end
    for _, s in ipairs(testSource) do
        unitwind:test("Create Masked Name (" .. s.input .. ")", function()
            for _, e in ipairs(s.expected) do
                local actual = masking.CreateMaskedName(s.input, e.mask)
                unitwind:expect(actual).toBe(e.name)
            end
        end)
    end
end

do
    local testSource = {
        {
            input = "'Ten-Tongues' Weerhat",
            expected = "Ten-Tongues Weerhat",
        },
        {
            input = "Edd \"Fast Eddie\" Theman",
            expected = "Edd Fast Eddie Theman",
        },
        {
            input = "Abbard the Wild",
            expected = "Abbard Wild",
        },
        {
            input = "The Udyrfrykte",
            expected = "Udyrfrykte",
        },
        {
            input = "Ettiene of Glenmoril Wyrd",
            expected = "Ettiene Glenmoril Wyrd",
        },
        {
            input = "Morning-Star-Steals-Away-Clouds",
            expected = "Morning-Star-Steals-Away-Clouds",
        },
        {
            input = "!\"#$%&'()-=^~\\|@`[{;+:*]},<.>/?_",
            expected = "!\"#$%&'()-=^~\\|@`[{;+:*]},<.>/?_",
        },
        -- TODO edge case
    }
    for _, s in ipairs(testSource) do
        unitwind:test("Preprocess Name (" .. s.input:gsub("%%", "%%%%") .. ")", function()
            local actual = masking.PreprocessName(s.input)
            unitwind:expect(actual).toBe(s.expected)
        end)
    end
end
do
    local testSource = {
        {
            input = "'Ten-Tongues' does business with many adventurers -- hes and shes that run about the ruins down below. Now and then they find something nice, and they bring it to 'Ten-Tongues'. Maybe you are this kind of person? If so, you see people down there, look like poor helpless people with no home? Maybe they are, and maybe they aren't. Maybe they are the Black Dart Gang, and they surprise you, kill you dead *snap* like that with one poison dart, take your stuff, and goodbye to you forever.",
            expected = "Ten-Tongues does business with many adventurers -- hes and shes that run about the ruins down below Now and then they find something nice and they bring it to Ten-Tongues Maybe you are this kind of person If so you see people down there look like poor helpless people with no home Maybe they are and maybe they aren't Maybe they are the Black Dart Gang and they surprise you kill you dead snap like that with one poison dart take your stuff and goodbye to you forever",
        },
        {
            input = "They call me \"Fast Eddie.\" Who are you?",
            expected = "They call me Fast Eddie Who are you",
        },
        {
            input = "Ah. You understand me a bit, yes? Hello, %PCName. Yakum greet you. Bless and be blessed. Speak Old Elf, yes, so Yakum learn. You know @Ashlanders#, yes, a little. Yakum is Ashlander.",
            expected = "Ah You understand me a bit yes Hello %PCName Yakum greet you Bless and be blessed Speak Old Elf yes so Yakum learn You know Ashlanders yes a little Yakum is Ashlander",
        },
        {
            input = "Good day, stranger. Welcome to @Ald'ruhn#. I'm the local caravaner, and I can tell you about @silt strider# travel if you'll tell me your @destination#. Are you new to @Ald'ruhn#, I would be happy to tell you about local @services#, or help you find @someone in particular#. Is there a @specific place# in @Ald'ruhn# you're looking for?",
            expected = "Good day stranger Welcome to Ald'ruhn I'm the local caravaner and I can tell you about silt strider travel if you'll tell me your destination Are you new to Ald'ruhn I would be happy to tell you about local services or help you find someone in particular Is there a specific place in Ald'ruhn you're looking for",
        },
        {
            input = " a b   c  ",
            expected = "a b c",
        },
        {
            input = "!\"#$%&'()-=^~\\|@`[{;+:*]},<.>/?_",
            expected = "%'-",
        },
        -- TODO edge case
    }
    for i, s in ipairs(testSource) do
        unitwind:test("Preprocess Text (" .. tostring(i) .. ")", function()
            local actual = masking.PreprocessText(s.input)
            unitwind:expect(actual).toBe(s.expected)
        end)
    end
end

do
    local inputs = {
        "I am %Name, %class",
        "I am %name, %class",
        "We are %names, %class",
        "I am %%name", -- false positive, but not bad
    }
    for i, value in ipairs(inputs) do
        unitwind:test("Find %%Name (".. tostring(i).. ")", function()
            local actual = masking.FindMacroName(value)
            unitwind:expect(actual).toBe(true)
        end)
    end
end
do
    local inputs = {
        "I am %PCName, %class",
        "I am name",
        "I am %NAME, %class", -- false negative
    }
    for i, value in ipairs(inputs) do
        unitwind:test("NOT Find %%Name (".. tostring(i).. ")", function()
            local actual = masking.FindMacroName(value)
            unitwind:expect(actual).toBe(false)
        end)
    end
end

do
    local testSource = {
        {
            text = "'Ten-Tongues' does business with many adventurers -- hes and shes that run about the ruins down below. Now and then they find something nice, and they bring it to 'Ten-Tongues'. Maybe you are this kind of person? If so, you see people down there, look like poor helpless people with no home? Maybe they are, and maybe they aren't. Maybe they are the Black Dart Gang, and they surprise you, kill you dead *snap* like that with one poison dart, take your stuff, and goodbye to you forever.",
            name = "'Ten-Tongues' Weerhat",
            expected = 0x2,
        },
        {
            text = "They call me \"Fast Eddie.\" Who are you?",
            name = "Edd \"Fast Eddie\" Theman",
            expected = 0x9,
        },
        {
            text = "Greetings, %PCName. Does my form surprise you? As a witch of Glenmoril Wyrd, I have the ability to change my shape as suits my needs",
            name = "Ettiene of Glenmoril Wyrd",
            expected = 0x1,
        },
        {
            text = "I am Redoran guard",
            name = "Redoran Guard",
            expected = 0x0, -- should be 0x0, but case sensitive
        },
        {
            text = "What? Yes. I'm Caius Cosades. But, what do you mean, you were told to \"Report to Caius Cosades\"? What are you talking about?",
            name = "Caius Cosades",
            expected = 0x0, -- everything
        },
        {
            text = "I'm just an old man with a skooma problem.",
            name = "Caius Cosades",
            expected = 0x3, -- nothing
        },
        -- TODO edge case
    }
    for i, value in ipairs(testSource) do
        unitwind:test("Find Name (".. tostring(i).. ")", function()
            local actual = masking.FindName(value.text, value.name)
            unitwind:expect(actual).toBe(value.expected)
        end)
    end
end

-- test filtering
-- test memory

unitwind:finish()
