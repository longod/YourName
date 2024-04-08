---@class Rule
local this = {}

local logger = require("YourName.logger")
local memo = require("YourName.memory")


--exclude
-- glenmoril_witch_altar glenmoril_witch_altar_2
-- dreamer

-- TODO
local filter = {
    ---- morrowind
    ["dagoth_ur_1"] = true,
    ["dagoth_ur_2"] = false, -- in combat
    ["heart_akulakhan"] = false,
    ["vivec_god"] = true,
    ["yagrum bagarn"] = true,
    ---- tribunals
    ["almalexia"] = true,
    ["almalexia_warrior"] = false, -- in combat
    ["Imperfect"] = false,
    ["scrib_rerlas"] = false,
    ["rat_rerlas"] = false,
    ["Rat_pack_rerlas"] = false,
    ---- bloodmoon
    ["glenmoril_raven"] = true, -- TODO research
    ["glenmoril_raven_cave"] = false,
    ["BM_hircine"] = true,
    ["BM_hircine2"] = false, -- TODO research
    ["BM_hircine_huntaspect"] = false, -- in combat
    ["BM_hircine_spdaspect"] = false, -- in combat
    ["BM_hircine_straspect"] = false, -- in combat
    ["bm_frost_giant"] = false,
    ["BM_udyrfrykte"] = false,
    -- unique
    ---- morrowind
    ["dagoth fandril"] = false,
    ["dagoth molos"] = false,
    ["dagoth felmis"] = false,
    ["dagoth rather"] = false,
    ["dagoth garel"] = false,
    ["dagoth reler"] = false,
    ["dagoth goral"] = false,
    ["dagoth tanis"] = false,
    ["dagoth_hlevul"] = false,
    ["dagoth uvil"] = false,
    ["dagoth malan"] = false,
    ["dagoth vaner"] = false,
    ["dagoth ulen"] = false,
    ["dagoth irvyn"] = false,
    ["dagoth aladus"] = false,
    ["dagoth fovon"] = false,
    ["dagoth baler"] = false,
    ["dagoth girer"] = false,
    ["dagoth daynil"] = false,
    ["dagoth ienas"] = false,
    ["dagoth delnus"] = false,
    ["dagoth mendras"] = false,
    ["dagoth drals"] = false,
    ["dagoth mulis"] = false,
    ["dagoth muthes"] = false,
    ["dagoth elam"] = false,
    ["dagoth nilor"] = false,
    ["dagoth fervas"] = false,
    ["dagoth ralas"] = false,
    ["dagoth soler"] = false,
    ["dagoth fals"] = false,
    ["dagoth galmis"] = false,
    ["dagoth gares"] = false,
    ["dagoth velos"] = false,
    ["dagoth araynys"] = false,
    ["dagoth endus"] = false,
    ["dagoth gilvoth"] = false,
    ["dagoth odros"] = false,
    ["dagoth Tureynul"] = false,
    ["dagoth uthol"] = false,
    ["dagoth vemyn"] = false,
    ["mudcrab_unique"] = false,
    ["rat_cave_hhte1"] = false,
    ["atronach_flame_ttmk"] = false,
    ["atronach_frost_ttmk"] = false,
    ["atronach_frost_gwai_uni"] = false,
    ["atronach_storm_ttmk"] = false,
    ["daedroth_menta_unique"] = false,
    ["dremora_ttmg"] = true,
    ["dremora_ttpc"] = true,
    ["dremora_special_Fyr"] = false,
    ["golden saint_staada"] = false,
    ["lustidrike"] = false,
    ["scamp_creeper"] = false, -- Creeper
    ["winged twilight_grunda_"] = false,
    ["ancestor_guardian_fgdd"] = false,
    ["gateway_haunt"] = false,
    ["ancestor_guardian_heler"] = false,
    ["ancestor_mg_wisewoman"] = false,
    ["ancestor_ghost_vabdas"] = false,
    ["wraith_sul_senipul"] = false,
    ["Dahrk Mezalf"] = false,
    ["skeleton_Vemynal"] = false,
    ["worm lord"] = false,
    ---- tribunals
    ["goblin_warchief1"] = false,
    ["goblin_warchief2"] = false,
    ["lich_profane_unique"] = false,
    ["lich_relvel"] = false,
    ["lich_barilzar"] = false,
    ["ancestor_ghost_Variner"] = false,
    ["dwarven ghost_radac"] = false,
    ["dremora_lord_khash_uni"] = false,
    ---- bloodmoon
    ["draugr_aesliip"] = true,

}

---@param actor (tes3activator|tes3alchemy|tes3apparatus|tes3armor|tes3bodyPart|tes3book|tes3clothing|tes3container|tes3containerInstance|tes3creature|tes3creatureInstance|tes3door|tes3ingredient|tes3leveledCreature|tes3leveledItem|tes3light|tes3lockpick|tes3misc|tes3npc|tes3npcInstance|tes3probe|tes3repairTool|tes3static|tes3weapon)?
---@param config Config.Filtering
---@return boolean
function this.IsTarget(actor, config)
    if actor == nil then
        return false
    end
    if config.essential == false and actor.isEssential == true then
        logger:trace("%s is essential", actor.id)
        return false
    end
    if actor.objectType == tes3.objectType.npc then
        if config.guard == false and actor.isGuard == true then
            logger:trace("%s is guard", actor.id)
            return false
        end
        -- implicit true
        local f = filter[memo.GetAliasedID(actor.id)]
        return (f == nil) or (f == true)
    elseif actor.objectType == tes3.objectType.creature and config.creature == false then
        -- only special creatures
        return (filter[memo.GetAliasedID(actor.id)] == true)
    end
    return false
end

return this
