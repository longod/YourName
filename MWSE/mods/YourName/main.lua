local config = require("YourName.config")
local logger = require("YourName.logger")
local masking = require("YourName.masking")
local filtering = require("YourName.filtering")

local MenuIDs = {
    tes3ui.registerID("MenuBarter"),
    tes3ui.registerID("MenuContents"),
    tes3ui.registerID("MenuDialog"),
}
local PartHelpMenu_main = "PartHelpMenu_main"
local PartDragMenu_title = tes3ui.registerID("PartDragMenu_title")
local HelpMenu_name = tes3ui.registerID("HelpMenu_name")

---@type (tes3creature|tes3npc)?
local targetObject = nil

---@param source tes3uiElement
---@param actor tes3creature|tes3npc
local function SetName(source, actor)
    local mask = masking.QueryUnknown(actor)
    if mask > 0 then
        local name = masking.CreateMaskedName(actor.name, mask)
        if name then
            source.text = name
        else
            source.text = masking.CreateUnknownName(actor, config.masking)
        end
    else
        --source.text = actor.name
    end
end

---@param source tes3uiElement
---@param actor tes3creature|tes3npc
local function UpdateName(source, actor)
    local mask = masking.QueryUnknown(actor)
    if mask > 0 then
        local name = masking.CreateMaskedName(actor.name, mask)
        if name then
            source.text = name
        else
            source.text = masking.CreateUnknownName(actor, config.masking)
        end
    else
        source.text = actor.name
    end
end

---@param actor tes3creature|tes3npc
local function RefreshMenu(actor)
    for _, value in ipairs(MenuIDs) do
        local menu = tes3ui.findMenu(value)
        if menu then
            local title = menu:findChild(PartDragMenu_title)
            if title then
                UpdateName(title, actor)
            end
        end
    end
    -- possible not match id and pointing actor
--[[

    local help = tes3ui.findHelpLayerMenu(PartHelpMenu_main)
    if help then
        local title = help:findChild(HelpMenu_name)
        if title then
            UpdateName(title, id, memory)
        end
    end
--]]
end



--- @param e uiActivatedEventData
local function uiActivatedCallback(e)
    if not targetObject then
        local serviceActor = tes3ui.getServiceActor() -- MenuContents return nil
        if serviceActor and serviceActor.object then
            if serviceActor.object.isInstance then
                targetObject = serviceActor.object.baseObject
            else
                targetObject = serviceActor.object --[[@as (tes3creature|tes3npc)]]
            end
        end
    end

    if targetObject and filtering.IsTarget(targetObject, config.filtering) then
        local title = e.element:findChild(PartDragMenu_title)
        if title then
            SetName(title, targetObject)
        end

        e.element:registerAfter(tes3.uiEvent.destroy, function(_)
            targetObject = nil
        end)
    end
end

--- @param e uiObjectTooltipEventData
local function uiObjectTooltipCallback(e)
    if filtering.IsTarget(e.object, config.filtering) then
        local title = e.tooltip:findChild(HelpMenu_name)
        if title then
            local actor ---@type tes3creature|tes3npc
            if e.object.isInstance then
                actor = e.object.baseObject --[[@as (tes3creature|tes3npc)]]
            else
                actor = e.object --[[@as (tes3creature|tes3npc)]]
            end
            SetName(title, actor)
        end
    end
end

--- @param e activateEventData
local function activateCallback(e)
    if e.activator ~= tes3.player then
        return
    end

    targetObject = nil
    if filtering.IsTarget(e.target.object, config.filtering) then
        if e.target.object.isInstance then
            targetObject = e.target.object.baseObject --[[@as tes3creature|tes3npc]]
        else
            targetObject = e.target.object --[[@as tes3creature|tes3npc]]
        end
    end
end

--- @param e infoGetTextEventData
local function infoGetTextCallback(e)
    if not e.info then
        return
    end
    if e.info.type == tes3.dialogueType.journal then
        return
    end

    local text = e.text -- contain modded text by other?
    if not text then
        text = e:loadOriginalText()
        if not text then
            return
        end
        logger:trace("text: %s", text)
    end

    ---@type (tes3creature|tes3npc)?
    local actor = nil
    if e.info.actor then
        if e.info.actor.isInstance then
            actor = e.info.actor.baseObject --[[@as tes3creature|tes3npc]]
        else
            actor = e.info.actor --[[@as tes3creature|tes3npc]]
        end
    end

    -- some common topic has no actor, typically Background most imported in this mod.
    -- seems voice has not actor
    if not actor then
        actor = targetObject
    end
    if actor and filtering.IsTarget(actor, config.filtering) then
        local unknown = masking.QueryUnknown(actor)
        if unknown > 0 then
            local mask = masking.ContainName(text, actor.name, unknown)
            if unknown ~= mask then
                masking.RevealName(actor.id, mask)
                RefreshMenu(actor)
            end
        end
    end
end

--- @param e initializedEventData
local function initializedCallback(e)
    event.register(tes3.event.uiActivated, uiActivatedCallback, { filter = "MenuBarter" })
    event.register(tes3.event.uiActivated, uiActivatedCallback, { filter = "MenuContents" })
    event.register(tes3.event.uiActivated, uiActivatedCallback, { filter = "MenuDialog" })
    event.register(tes3.event.uiObjectTooltip, uiObjectTooltipCallback)
    event.register(tes3.event.activate, activateCallback)
    event.register(tes3.event.infoGetText, infoGetTextCallback) -- can be fileterd info
end
event.register(tes3.event.initialized, initializedCallback)
require("YourName.mcm")

if config.development.test then
    require("YourName.test")
end

--- Since the annotation are not defined in MWSE, this is to supress the warning caused by this.
--- @class tes3scriptVariables
