function copy_table(value)
    if type(value) ~= 'table' then return value end
    local result = {}; for k, v in pairs(value) do result[k] = copy_table(v) end; return result
end
G = {GAME = {battle_of_gods = true, blind_on_deck = 'Small', banned_keys = {}, bosses_used = {},
    round_resets = {ante = 2, blind_choices = {}, blind_states = {Small = 'Upcoming', Big = 'Upcoming', Boss = 'Upcoming'}}},
    P_BLINDS = {
        bl_big = {key = 'bl_big', big = true},
        bl_hook = {key = 'bl_hook', boss = {min = 1}},
        bl_reality_warp_athena = {key = 'bl_reality_warp_athena', boss = {min = 8, showdown = true}},
        bl_reality_warp_net = {key = 'bl_reality_warp_net', boss = {min = 8, max = 10, showdown = true}},
        bl_reality_warp_obelisk = {key = 'bl_reality_warp_obelisk', boss = {min = 12, max = 99}, reality_warp_fused = true},
        bl_excluded = {key = 'bl_excluded', boss = {min = 1}, in_pool = function() return false end}
    }}
SMODS = {add_to_pool = function(def) return not def.in_pool or def:in_pool() end}
local rng = 0
function pseudoseed(seed) rng = rng + 1; return seed end
function pseudorandom_element(pool) return pool[1] end
function is_reality_warp_boss_blinds_enabled() return true end
Blind = {set_blind = function(self, def, reset)
    if not reset then self.config = {blind = def}; self.effect = {} end
    return 'base', 'post'
end, load = function(self, saved) self.config = saved.config; self.effect = saved.effect end}
function Blind:set_text() end
dofile(REPO_ROOT .. '/src/core/blind_identity.lua')
dofile(REPO_ROOT .. '/src/core/blind_encounters.lua')
assert(#reality_warp_blind_candidates('boss') == 1)
assert(#reality_warp_blind_candidates('fused') == 0)
assert(#reality_warp_blind_candidates('showdown') == 0)
reality_warp_schedule_blinds(true)
local entries = copy_table(G.GAME.round_resets.reality_warp_encounters)
local used, rolls = G.GAME.bosses_used.bl_hook, rng
reality_warp_schedule_blinds(false)
assert(G.GAME.bosses_used.bl_hook == used and rng == rolls)
assert(G.GAME.round_resets.reality_warp_encounters.Big.id == entries.Big.id)
G.GAME.round_resets.blind_states.Small = 'Defeated'
G.GAME.round_resets.blind_states.Big = 'Skipped'
reality_warp_schedule_blinds(true)
assert(G.GAME.round_resets.reality_warp_encounters.Small.id == entries.Small.id)
assert(G.GAME.round_resets.reality_warp_encounters.Big.id == entries.Big.id)
G.GAME.round_resets.divine_ward_free = false
reality_warp_schedule_blinds(false)
assert(not G.GAME.round_resets.divine_ward_free)
G.GAME.round_resets.ante = 12
assert(#reality_warp_blind_candidates('fused') == 1)
assert(#reality_warp_blind_candidates('boss') == 1)
assert(#reality_warp_blind_candidates('showdown') == 1) -- Net max respected.
G.GAME.banned_keys.bl_reality_warp_obelisk = true
assert(#reality_warp_blind_candidates('fused') == 0)
G.GAME.round_resets.ante = 8
local first = reality_warp_commit_blind('Big', 'bl_reality_warp_athena')
local second = reality_warp_commit_blind('Boss', 'bl_reality_warp_athena')
second.params.target_hand = 'Flush'
rolls = rng
assert(reality_warp_with_blind_preview('Big', function() return reality_warp_encounter_params(first.key).target_hand end) == 'Pair')
assert(reality_warp_with_blind_preview('Boss', function() return reality_warp_encounter_params(second.key).target_hand end) == 'Flush')
assert(rng == rolls)
local active = setmetatable({}, {__index = Blind}); G.GAME.blind = active; G.GAME.blind_on_deck = 'Big'
local result, post = active:set_blind(G.P_BLINDS[first.key])
assert(result == 'base' and post == 'post')
assert(reality_warp_encounter_params(first.key).target_hand == 'Pair')
active.effect.reality_warp_hades_nullify = true
local saved_game, saved_blind = copy_table(G.GAME), {config = copy_table(active.config), effect = copy_table(active.effect)}
G.GAME = saved_game; G.GAME.blind = setmetatable({}, {__index = Blind}); G.GAME.blind:load(saved_blind)
assert(reality_warp_encounter_params(first.key).target_hand == 'Pair' and rng == rolls)
assert(G.GAME.blind.effect.reality_warp_hades_nullify)
G.jokers = {cards = {{sort_id = 42}}}; G.GAME.doppelganger_target_id = 42
assert(reality_warp_doppelganger_target() == G.jokers.cards[1])
G.jokers.cards = {{sort_id = 42}} -- reconstructed Card, same saved sort ID.
assert(reality_warp_doppelganger_target() == G.jokers.cards[1])
