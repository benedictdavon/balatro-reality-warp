--[[
    Balatro: Reality Warp
    Version: 1.0.0
    Author: Unknow102
    Framework: Steamodded (SMODS)

    "Reality warps around the cards. Step into the rift."
--]]

reality_warp_MOD = SMODS.current_mod
if reality_warp_MOD then
    reality_warp_MOD.name = "Balatro: Reality Warp"
    reality_warp_MOD.display_name = "Balatro: Reality Warp"
    reality_warp_MOD.badge_name = "Reality Warp"

    G.C.reality_warp_BADGE_COL = G.C.reality_warp_BADGE_COL or { 0, 0, 0, 1 }
    G.C.reality_warp_TEXT_COL = G.C.reality_warp_TEXT_COL or { 1, 1, 1, 1 }
    reality_warp_MOD.badge_colour = G.C.reality_warp_BADGE_COL
    reality_warp_MOD.badge_text_colour = G.C.reality_warp_TEXT_COL
end

local files = {
    -- Core & Engine Hooks
    "src/core/utils.lua",
    "src/core/localization.lua",
    "src/core/battle_of_gods.lua",
    "src/core/botg_possession.lua",
    "src/core/botg_familiars.lua",
    "src/core/botg_combat.lua",
    "src/core/black_market.lua",
    "src/core/cauldron_synthesis.lua",

    -- Jokers
    "src/jokers/common.lua",
    "src/jokers/uncommon.lua",
    "src/jokers/rare.lua",
    "src/jokers/legendary.lua",
    "src/jokers/secret.lua",


    -- Consumables, Enhancements & Seals
    "src/consumables/spectrals.lua",
    "src/consumables/enhancements.lua",
    "src/consumables/jobs.lua",
    "src/consumables/potions.lua",


    -- Blinds, Decks, Vouchers & Tags
    "src/blinds/boss_blinds.lua",
    "src/blinds/fused_blinds.lua",
    "src/decks/decks.lua",
    "src/vouchers/vouchers.lua",
    "src/tags/tags.lua",

    -- Mod Compatibility
    "src/compat/jokerdisplay.lua",
    "src/compat/cardsleeves.lua",

    -- Challenges
    "src/challenges/challenges.lua"
}

for _, file in ipairs(files) do
    assert(SMODS.load_file(file))()
end

if alias_all_reality_warp_centers then
    alias_all_reality_warp_centers()
end
                                                        