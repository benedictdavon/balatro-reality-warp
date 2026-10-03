G = {GAME = {blind_on_deck = 'Big', round_resets = {blind_choices = {Big = 'bl_reality_warp_ares'}}}}
dofile(REPO_ROOT .. '/src/core/blind_identity.lua')
local definition = {key = 'bl_reality_warp_ares', boss = {min = 1}}
local blind = {config = {blind = definition}, name = 'misleading display name', big = true}
G.GAME.blind = blind
assert(reality_warp_blind_key() == definition.key)
assert(reality_warp_blind_is(blind, 'ares'))
assert(not reality_warp_blind_is(blind, 'ar'))
assert(reality_warp_blind_is_boss(blind))
assert(not reality_warp_blind_is_showdown(blind))
assert(reality_warp_current_slot() == 'Big')
assert(reality_warp_selected_blind_key() == definition.key)
definition.boss.showdown = true
assert(reality_warp_blind_is_showdown(blind))
assert(not reality_warp_blind_is({name = 'The Mountain'}, 'mountain'))

-- Pincer unlock recalculates rather than erasing independently owned debuffs.
definition.key = 'bl_reality_warp_pinza'
local calls = 0
local joker = {debuff = true, expired = true}
G.jokers = {cards = {joker}}
SMODS = {recalc_debuff = function(card) calls = calls + 1; card.debuff = card.expired end}
play_sound = function() end
blind.disabled = true
reality_warp_pincer_card_destroyed()
assert(calls == 0 and not G.GAME.pinza_card_destroyed)
blind.disabled = false
reality_warp_pincer_card_destroyed()
reality_warp_pincer_card_destroyed()
assert(calls == 1 and joker.debuff and G.GAME.pinza_card_destroyed)
