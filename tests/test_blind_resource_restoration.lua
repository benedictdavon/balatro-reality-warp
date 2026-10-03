local definitions = {}
local hand_size, operation_order
local cleanup_watch

G = {
    GAME = {round_resets = {hands = 4}, current_round = {hands_left = 4, discards_left = 3}},
    C = {BLIND = {}},
    E_MANAGER = {add_event = function() end},
    hand = {cards = {}, highlighted = {}}
}
function HEX(color) return color end
function Event(spec) return spec end
SMODS = {
    Atlases = {},
    Atlas = function() end,
    Blind = function(def)
        def.key = 'bl_reality_warp_' .. def.key
        definitions[def.key] = def
    end
}

local function assert_cleanup_claimed()
    if cleanup_watch then
        assert(cleanup_watch.blind.effect[cleanup_watch.key] == nil)
        if cleanup_watch.legacy_key then
            assert(cleanup_watch.blind.effect[cleanup_watch.legacy_key] == nil)
        end
    end
end

G.hand.change_size = function(_, delta)
    assert_cleanup_claimed()
    hand_size = hand_size + delta
    operation_order[#operation_order + 1] = 'hand:' .. delta
end
function ease_hands_played(delta)
    assert_cleanup_claimed()
    G.GAME.current_round.hands_left = G.GAME.current_round.hands_left + delta
    operation_order[#operation_order + 1] = 'hands:' .. delta
end
function ease_discard(delta)
    assert_cleanup_claimed()
    G.GAME.current_round.discards_left = G.GAME.current_round.discards_left + delta
    operation_order[#operation_order + 1] = 'discards:' .. delta
end

dofile(REPO_ROOT .. '/src/blinds/fused_blinds.lua')

local obelisk = definitions.bl_reality_warp_obelisk
local leviathan = definitions.bl_reality_warp_leviathan
local iron_maiden = definitions.bl_reality_warp_iron_maiden
local function fresh_state(hands_left, discards_left, size)
    G.GAME.round_resets.hands = 4
    G.GAME.current_round.hands_left = hands_left or 4
    G.GAME.current_round.discards_left = discards_left or 3
    hand_size = size or 8
    operation_order = {}
    G.hand.cards = {}
end
local function calculate(definition, blind, context)
    definition:calculate(blind, context)
end
local function copy_effect(effect)
    local copy = {}
    for key, value in pairs(effect or {}) do copy[key] = value end
    return copy
end

-- Iron Maiden applies one persistent hand-size delta, even if setup is dispatched twice.
fresh_state(4, 3, 8)
local iron = {effect = {}, disabled = false}
calculate(iron_maiden, iron, {setting_blind = true})
calculate(iron_maiden, iron, {setting_blind = true})
assert(hand_size == 7 and iron.effect.reality_warp_iron_maiden_hand_size_sub == -1)

-- The saved Blind effect reconstructs as primitive state and supports exact cleanup.
local restored_effect = copy_effect(iron.effect)
for _, value in pairs(restored_effect) do
    assert(type(value) == 'boolean' or type(value) == 'number')
end
local restored_iron = {effect = restored_effect, disabled = false}
calculate(iron_maiden, restored_iron, {setting_blind = true})
assert(hand_size == 7)
cleanup_watch = {blind = restored_iron, key = 'reality_warp_iron_maiden_hand_size_sub'}
calculate(iron_maiden, restored_iron, {blind_defeated = true})
cleanup_watch = nil
assert(hand_size == 8 and restored_iron.effect.reality_warp_iron_maiden_hand_size_sub == nil)
calculate(iron_maiden, restored_iron, {blind_defeated = true})
assert(hand_size == 8)

-- The next encounter starts from the restored size and applies its own single delta.
local next_iron = {effect = {}, disabled = false}
calculate(iron_maiden, next_iron, {setting_blind = true})
assert(hand_size == 7)
cleanup_watch = {blind = next_iron, key = 'reality_warp_iron_maiden_hand_size_sub'}
calculate(iron_maiden, next_iron, {blind_disabled = true})
cleanup_watch = nil
assert(hand_size == 8 and next_iron.effect.reality_warp_iron_maiden_hand_size_sub == nil)
calculate(iron_maiden, next_iron, {blind_disabled = true})
calculate(iron_maiden, next_iron, {blind_defeated = true})
assert(hand_size == 8)

-- A setup disabled by Chicot owns no delta and cannot grant a hand on cleanup.
fresh_state(4, 3, 8)
local disabled_iron = {effect = {}, disabled = true}
calculate(iron_maiden, disabled_iron, {setting_blind = true})
calculate(iron_maiden, disabled_iron, {blind_disabled = true})
assert(hand_size == 8 and disabled_iron.effect.reality_warp_iron_maiden_hand_size_sub == nil)

-- Disable followed by defeat reverses Iron Maiden only on the first cleanup.
fresh_state(4, 3, 8)
local disabled_then_defeated_iron = {effect = {}, disabled = false}
calculate(iron_maiden, disabled_then_defeated_iron, {setting_blind = true})
calculate(iron_maiden, disabled_then_defeated_iron, {blind_disabled = true})
calculate(iron_maiden, disabled_then_defeated_iron, {blind_defeated = true})
assert(hand_size == 8)

-- Obelisk preserves exactly one of the remaining hands, not one of the round's original hands.
fresh_state(2, 3, 8)
local obelisk_blind = {effect = {}, disabled = false}
calculate(obelisk, obelisk_blind, {setting_blind = true})
calculate(obelisk, obelisk_blind, {setting_blind = true})
assert(G.GAME.current_round.hands_left == 1)
assert(obelisk_blind.effect.reality_warp_obelisk_hands_sub == 1)
cleanup_watch = {blind = obelisk_blind, key = 'reality_warp_obelisk_hands_sub', legacy_key = 'hands_sub'}
calculate(obelisk, obelisk_blind, {blind_disabled = true})
cleanup_watch = nil
assert(G.GAME.current_round.hands_left == 2)
assert(obelisk_blind.effect.reality_warp_obelisk_hands_sub == nil)
calculate(obelisk, obelisk_blind, {blind_disabled = true})
assert(G.GAME.current_round.hands_left == 2)

-- The serialized Obelisk ledger prevents a second setup and refunds the same delta.
fresh_state(4, 3, 8)
local saving_obelisk = {effect = {}, disabled = false}
calculate(obelisk, saving_obelisk, {setting_blind = true})
assert(G.GAME.current_round.hands_left == 1)
local loaded_obelisk = {effect = copy_effect(saving_obelisk.effect), disabled = false}
calculate(obelisk, loaded_obelisk, {setting_blind = true})
assert(G.GAME.current_round.hands_left == 1)
cleanup_watch = {blind = loaded_obelisk, key = 'reality_warp_obelisk_hands_sub'}
calculate(obelisk, loaded_obelisk, {blind_disabled = true})
cleanup_watch = nil
assert(G.GAME.current_round.hands_left == 4)

-- A disabled Obelisk setup creates no hand refund.
fresh_state(2, 3, 8)
local disabled_obelisk = {effect = {}, disabled = true}
calculate(obelisk, disabled_obelisk, {setting_blind = true})
calculate(obelisk, disabled_obelisk, {blind_disabled = true})
assert(G.GAME.current_round.hands_left == 2)

-- Zero remaining hands cannot produce a refund, and defeat discards the ledger.
fresh_state(0, 3, 8)
local exhausted_obelisk = {effect = {}, disabled = false}
calculate(obelisk, exhausted_obelisk, {setting_blind = true})
calculate(obelisk, exhausted_obelisk, {blind_defeated = true})
calculate(obelisk, exhausted_obelisk, {blind_disabled = true})
assert(G.GAME.current_round.hands_left == 0)
assert(exhausted_obelisk.effect.reality_warp_obelisk_hands_sub == nil)

-- Old saved Obelisk deltas remain refundable once and are cleared before the refund.
fresh_state(1, 3, 8)
local legacy_obelisk = {effect = {hands_sub = 3}, disabled = false}
calculate(obelisk, legacy_obelisk, {setting_blind = true})
assert(G.GAME.current_round.hands_left == 1)
cleanup_watch = {blind = legacy_obelisk, key = 'reality_warp_obelisk_hands_sub', legacy_key = 'hands_sub'}
calculate(obelisk, legacy_obelisk, {blind_disabled = true})
cleanup_watch = nil
assert(G.GAME.current_round.hands_left == 4 and legacy_obelisk.effect.hands_sub == nil)
calculate(obelisk, legacy_obelisk, {blind_disabled = true})
assert(G.GAME.current_round.hands_left == 4)

-- Leviathan removes only remaining discards, restores them once, then flips cards.
fresh_state(4, 2, 8)
local back_card = {facing = 'back', flip = function(self)
    self.facing = 'front'
    operation_order[#operation_order + 1] = 'flip'
end}
G.hand.cards = {back_card}
local leviathan_blind = {effect = {}, disabled = false}
calculate(leviathan, leviathan_blind, {setting_blind = true})
calculate(leviathan, leviathan_blind, {setting_blind = true})
assert(G.GAME.current_round.discards_left == 0)
assert(leviathan_blind.effect.reality_warp_leviathan_discards_sub == 2)
operation_order = {}
cleanup_watch = {blind = leviathan_blind, key = 'reality_warp_leviathan_discards_sub', legacy_key = 'discards_sub'}
calculate(leviathan, leviathan_blind, {blind_disabled = true})
cleanup_watch = nil
assert(G.GAME.current_round.discards_left == 2)
assert(operation_order[1] == 'discards:2' and operation_order[2] == 'flip')
assert(leviathan_blind.effect.reality_warp_leviathan_discards_sub == nil)
calculate(leviathan, leviathan_blind, {blind_disabled = true})
assert(G.GAME.current_round.discards_left == 2)

-- A saved Leviathan effect reconstructs and returns the exact number removed.
fresh_state(4, 0, 8)
local saved_leviathan = {effect = {reality_warp_leviathan_setup = true,
    reality_warp_leviathan_discards_sub = 2}, disabled = false}
local loaded_leviathan = {effect = copy_effect(saved_leviathan.effect), disabled = false}
G.GAME.current_round.discards_left = 0
calculate(leviathan, loaded_leviathan, {setting_blind = true})
cleanup_watch = {blind = loaded_leviathan, key = 'reality_warp_leviathan_discards_sub'}
calculate(leviathan, loaded_leviathan, {blind_disabled = true})
cleanup_watch = nil
assert(G.GAME.current_round.discards_left == 2)
assert(loaded_leviathan.effect.reality_warp_leviathan_discards_sub == nil)

-- Disabled-at-setup with no discards cannot grant discards.
fresh_state(4, 0, 8)
local disabled_leviathan = {effect = {}, disabled = true}
calculate(leviathan, disabled_leviathan, {setting_blind = true})
calculate(leviathan, disabled_leviathan, {blind_disabled = true})
assert(G.GAME.current_round.discards_left == 0)

-- Defeating Leviathan clears a positive refund ledger without granting its discards.
fresh_state(4, 2, 8)
local defeated_leviathan = {effect = {}, disabled = false}
calculate(leviathan, defeated_leviathan, {setting_blind = true})
calculate(leviathan, defeated_leviathan, {blind_defeated = true})
calculate(leviathan, defeated_leviathan, {blind_disabled = true})
assert(G.GAME.current_round.discards_left == 0)
assert(defeated_leviathan.effect.reality_warp_leviathan_discards_sub == nil)

print('PASS: Iron Maiden, Obelisk, and Leviathan resource ownership')
