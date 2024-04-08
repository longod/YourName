local this = {}
local logger = require("YourName.logger")

-- TODO
local alias = {
    ["dagoth_ur_2"] = "dagoth_ur_1", -- in combat
}

---@class Record
---@field mask integer
-----@field lastAccess number

---@class Memory
---@field records {[string]: Record}
local mockData = {
    records = {},
}

---@return Memory
function this.GetMemory()
    if tes3.onMainMenu() == false and tes3.player and tes3.player.data then
        if tes3.player.data.yourName == nil then
            tes3.player.data.yourName = { records = {} } ---@type Memory
        end
        return tes3.player.data.yourName
    end
    logger:trace("fallback mock memory")
    return mockData
end

-- get aliased id
---@param id string
function this.GetAliasedID(id)
    local a = alias[id]
    if a ~= nil then
        logger:trace("%s alias to %s", id, a)
        return a
    end
    return id
end

---@param id string
---@return Record? record
function this.ReadMemory(id)
    id = this.GetAliasedID(id)
    local memory = this.GetMemory()
    local record = memory.records[id]
    if record ~= nil then
        logger:trace("read: %s = %x", id, record.mask)
        return record
    end
    logger:trace("read: %s does not exist", id)
    return nil
end

---@param id string
---@param mask integer
function this.WriteMemory(id, mask)
    local memory = this.GetMemory()
    id = this.GetAliasedID(id)
    if memory.records[id] ~= nil then
        logger:trace("update: %s = %x", id, mask)
        memory.records[id].mask = mask
    else
        logger:trace("new: %s = %x", id, mask)
        memory.records[id] = { mask = mask }
    end
end

return this
