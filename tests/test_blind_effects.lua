local queue, definitions = {}, {}
G = {GAME = {round_resets = {ante = 8}, probabilities = {normal = 1},
    reality_warp_active_encounter = {id = 1, key = 'bl_reality_warp_ares', params = {target_hand = 'Pair'}}},
    C = {}, ARGS = {}, E_MANAGER = {add_event = function(_, event) queue[#queue + 1] = event end},
    play = {cards = {}}, hand = {cards = {}}, jokers = {cards = {}}, playing_cards = {}}
function HEX(x) return x end
function Event(x) return x end
function attention_text() end
function play_sound() end
function pseudorandom() return 0 end
function pseudoseed(x) return x end
function pseudorandom_element(pool) return pool[1], 1 end
function reset_reality_warp_boss_ui() end
Blind = {set_blind = function() end, defeat = function() end}
SMODS = {Atlas = function() end, Blind = function(def)
    def.key = 'bl_reality_warp_' .. def.key; definitions[def.key] = def
end, recalc_debuff = function(card)
    local debuffed = card.ability.perishable and card.ability.perish_tally <= 0
    for _, source in pairs(card.ability.debuff_sources or {}) do debuffed = debuffed or source end
    card.debuff = not not debuffed
end}
function SMODS.debuff_card(card, debuff, source)
    card.ability.debuff_sources = card.ability.debuff_sources or {}
    card.ability.debuff_sources[source] = debuff or nil
    SMODS.recalc_debuff(card)
end
dofile(REPO_ROOT .. '/src/core/blind_identity.lua')
dofile(REPO_ROOT .. '/src/core/blind_effects.lua')
function reality_warp_encounter_params() return G.GAME.reality_warp_active_encounter.params end
dofile(REPO_ROOT .. '/src/blinds/boss_blinds.lua')
queue = {}
local mutations = 0
local card = {ability = {}, start_dissolve = function() mutations = mutations + 1 end}
local blind = {config = {blind = definitions.bl_reality_warp_ares}, effect = {}, disabled = false}
G.GAME.blind = blind
local ares = definitions.bl_reality_warp_ares
ares:calculate(blind, {after = true, scoring_hand = {card}})
assert(#queue == 1)
blind.disabled = true; queue[1].func(); assert(mutations == 0)
queue = {}; blind.disabled = false
ares:calculate(blind, {after = true, scoring_hand = {card}})
G.GAME.reality_warp_active_encounter.id = 2; queue[1].func(); assert(mutations == 0)
queue = {}
ares:calculate(blind, {after = true, scoring_hand = {card}})
queue[1].func(); assert(mutations == 1)
-- Every normal/showdown active calculate callback suppresses disabled penalties.
queue = {}; blind.disabled = true
for key, def in pairs(definitions) do
    if def.calculate then
        blind.config.blind = def
        def:calculate(blind, {before = true, after = true, using_consumeable = true,
            individual = true, scoring_hand = {card}, scoring_name = 'Pair', cardarea = G.play, other_card = card})
    end
end
assert(#queue == 0 and mutations == 1)
-- Source cleanup preserves both expiration and independently owned restrictions.
local expired = {ability = {perishable = true, perish_tally = 0}}
local other = {ability = {debuff_sources = {external = true}}}
G.jokers.cards = {expired, other}; blind.disabled = false
local athena = definitions.bl_reality_warp_athena; blind.config.blind = athena
athena:modify_hand({}, {}, 'Flush', 10, 10)
assert(expired.debuff and other.debuff)
blind.disabled = true; athena:calculate(blind, {blind_disabled = true})
assert(expired.debuff and other.debuff)
assert(not expired.ability.debuff_sources.reality_warp_athena)
local phone = definitions.bl_reality_warp_phone; blind.config.blind = phone; blind.disabled = false
G.playing_cards = {card, other}
phone:calculate(blind, {before = true, scoring_hand = {card, other}})
assert(other.ability.debuff_sources.reality_warp_phone)
phone:calculate(blind, {after = true})
assert(other.debuff and other.ability.debuff_sources.external and not other.ability.debuff_sources.reality_warp_phone)
