--[[
    Balatro: Reality Warp
    Version: 1.0.0
    Author: Unknow102
    Framework: Steamodded (SMODS)

    "Reality warps around the cards. Step into the rift."
--]]

Witch_brew_MOD = SMODS.current_mod
if Witch_brew_MOD then
    Witch_brew_MOD.name = "Balatro: Reality Warp"
    Witch_brew_MOD.display_name = "Balatro: Reality Warp"
    Witch_brew_MOD.badge_name = "Reality Warp"

    G.C.WITCH_BREW_BADGE_COL = G.C.WITCH_BREW_BADGE_COL or { 0, 0, 0, 1 }
    G.C.WITCH_BREW_TEXT_COL = G.C.WITCH_BREW_TEXT_COL or { 1, 1, 1, 1 }
    Witch_brew_MOD.badge_colour = G.C.WITCH_BREW_BADGE_COL
    Witch_brew_MOD.badge_text_colour = G.C.WITCH_BREW_TEXT_COL
    Witch_brew_MOD.set_mod_badge = function(self, card, badges)
        if badges and create_badge then
            badges[#badges + 1] = create_badge('Reality Warp', G.C.WITCH_BREW_BADGE_COL, G.C.WITCH_BREW_TEXT_COL, 1.2 * 0.9)
        end
    end
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

if alias_all_witch_brew_centers then
    alias_all_witch_brew_centers()
end
                                                        