local function read(path)
    local f = assert(io.open(REPO_ROOT .. '/' .. path)); local s = f:read('*a'); f:close(); return s
end
local function region(path, first, following)
    local s = read(path); local a = assert(s:find(first, 1, true))
    return s:sub(a, assert(s:find(following, a + #first, true)) - 1)
end
local function pack(...) return {n = select('#', ...), ...} end
local calls, last_args, events = 0, {}, 0
G = {GAME = {battle_of_gods = true, hands = {Pair = {level = 21}}},
    C = {PURPLE = {}, GOLD = {}, WHITE = {}}, jokers = {cards = {}}, botg_familiars = {},
    E_MANAGER = {add_event = function() events = events + 1 end}}
function is_joker_copiable(c) return not c.debuff and c.compat ~= false end
function is_secret_card() return false end
function is_amalgam_card() return false end
function card_has_key() return false end
function reality_warp_blind_is(_, key) return G.GAME.active_blind == key end
function reality_warp_doppelganger_target() return G.GAME.target end
function play_sound() end
function card_eval_status_text() end
Card = {calculate_joker = function(self, context, ...)
    calls = calls + 1; self.original_calls = (self.original_calls or 0) + 1
    last_args = pack(...)
    if self.zero_returns then return end
    if self.copy_target and context and context.joker_main then
        local copied = {}; for k,v in pairs(context) do copied[k] = v end
        copied.blueprint = true
        return self.copy_target:calculate_joker(copied, ...)
    end
    if context and context.before then self.growth = (self.growth or 0) + 1 end
    return self.effect, self.post, 'tail', nil
end}
dofile(REPO_ROOT .. '/src/core/joker_effects.lua')
assert(loadstring(region('src/core/utils.lua', '-- Falta de Lectura activation tracker', '-- Hook card_eval_status_text')))()
assert(loadstring(region('src/core/botg_familiars.lua', '-- Hook Card.calculate_joker exclusively', 'function botg_calculate_familiar')))()
function botg_calculate_familiar(self, context, ...) return {chips = 7}, 'familiar-post', ... end
assert(loadstring(region('src/consumables/potions.lua', '-- Hook joker calculation for Pocion de Espejo', '-- Hook new_round for Pocion de Reloj')))()
local function card(effect)
    return setmetatable({effect = effect, post = {marker = 'post'}, ability = {set = 'Joker'},
        config = {center = {key = 'j_test'}}, juice_up = function() end}, {__index = Card})
end
local function context() return {joker_main = true, cardarea = G.jokers, scoring_name = 'Pair'} end
local function factor(effect)
    local total, seen = 1, {}
    while type(effect) == 'table' and not seen[effect] do
        seen[effect] = true
        total = total * (effect.x_mult or effect.Xmult_mod or effect.Xmult or 1)
        effect = effect.extra
    end
    return total
end

local original_child = {x_mult = 3, card = {marker = 'same-card'}}
local original = {mult_mod = 4, Xmult_mod = 2, extra = original_child}
local c = card(original); c.ability.deity_ascended = true; c.ability.glitched = true; c.ability.glitch_mult = 0.5
G.jokers.cards = {c}
local before = calls
local result = pack(c:calculate_joker(context(), 'argument', nil))
assert(calls == before + 1 and result.n == 4 and result[2] == c.post and result[3] == 'tail' and result[4] == nil)
assert(last_args.n == 2 and last_args[1] == 'argument' and last_args[2] == nil)
assert(result[1].mult_mod == 4 and factor(result[1]) == 7.5)
assert(result[1] ~= original and result[1].extra ~= original_child and result[1].extra.card == original_child.card)
assert(original.extra == original_child and original_child.extra == nil and original.Xmult_mod == 2)
assert(G.GAME.falta_de_lectura_other_activated, 'tracker must see composed effects')

-- Existing original side effects survive; bonuses apply only at joker_main.
before = calls; c:calculate_joker({before = true}, 'before-argument')
assert(calls == before + 1 and c.growth == 1)
G.GAME.hands.Pair.level = 20
assert(factor(c:calculate_joker(context())) == 6)
G.GAME.battle_of_gods = false
assert(factor(c:calculate_joker(context())) == 3, 'Glitch remains independent of BOTG, ordinary effect remains')
G.GAME.battle_of_gods = true; G.GAME.hands.Pair.level = 21

-- Mode-only effects and nested effects reach the existing Doppelganger tracker once.
c.effect = {card = c}; c.ability.glitched = false
G.GAME.active_blind = 'doppelganger'; G.GAME.target = c
G.GAME.blind = {juice_up = function() end}; G.GAME.doppel_triggered_in_hand = nil
assert(factor(c:calculate_joker(context())) == 2.5 and G.GAME.doppel_triggered_in_hand)
G.GAME.active_blind = nil; G.GAME.target = nil
c.effect = nil
assert(factor(c:calculate_joker(context())) == 2.5)
c.zero_returns = true
assert(pack(c:calculate_joker(nil)).n == 0, 'zero original returns stay zero without bonuses')
local zero_with_bonus = pack(c:calculate_joker(context()))
assert(zero_with_bonus.n == 1 and factor(zero_with_bonus[1]) == 2.5)
c.zero_returns = nil
for _, flag in ipairs({'debuff', 'removed', 'destroyed', 'shattered', 'getting_sliced'}) do
    c[flag] = true
    assert(c:calculate_joker(context()) == nil, 'no manufactured bonus for ' .. flag)
    c[flag] = nil
end
c.compat = false; local copy_context = context(); copy_context.blueprint = true
before = calls; assert(c:calculate_joker(copy_context) == nil and calls == before, 'copy gate remains outside composer')
c.compat = true
for _, value in ipairs({false, 'signal'}) do
    c.effect = value
    local r = pack(c:calculate_joker(context()))
    assert(r[1] == value and r[2] == c.post and r.n == 4, 'non-table signals stay unchanged')
end
c.effect = true
local removal = pack(c:calculate_joker(context()))
assert(removal.n == 4 and removal[1].remove == true and factor(removal[1]) == 2.5 and removal[2] == c.post)
local removal_count, node = 0, removal[1]
while node do
    if node.remove then removal_count = removal_count + 1 end
    node = node.extra
end
assert(removal_count == 1, 'supported true sentinel preserves one removal effect and all bonuses')
c.effect = {Xmult_mod = 2, extra = true}
local terminal_removal = c:calculate_joker(context())
assert(terminal_removal.extra.remove and factor(terminal_removal) == 5 and c.effect.extra == true)
c.effect = original

-- Compatible copy routes through the real composed target; neither call is replaced.
local copier = card(nil); copier.copy_target = c; G.jokers.cards = {c, copier}
before = calls
assert(factor(copier:calculate_joker(context())) == 15 and calls == before + 2)
local nil_context = pack(c:calculate_joker(nil, 'nil-context', nil))
assert(nil_context[1] == original and nil_context[2] == c.post and nil_context.n == 4)

-- Familiar-specific dispatch is retained, while ordinary returns pass all positions.
local familiar = card(nil); familiar.area = G.botg_familiars
before = calls
local f = pack(familiar:calculate_joker(context(), 'fam-tail', nil))
assert(calls == before and f.n == 4 and f[1].chips == 7 and f[2] == 'familiar-post' and f[3] == 'fam-tail' and f[4] == nil)
familiar.ability.glitched = true; familiar.ability.glitch_mult = 0.5
local glitched_familiar = pack(familiar:calculate_joker(context(), 'fam-tail', nil))
assert(glitched_familiar.n == 4 and glitched_familiar[1].chips == 7 and factor(glitched_familiar[1]) == 0.5)
assert(glitched_familiar[2] == 'familiar-post' and glitched_familiar[3] == 'fam-tail')

-- Simulation gate still suppresses events and preserves all returned positions.
local simulation = context(); simulation.falta_de_lectura_check = true
local original_event_method = G.E_MANAGER.add_event
local simulated = pack(c:calculate_joker(simulation, 'simulation', nil))
assert(simulated.n == 4 and simulated[2] == c.post and G.E_MANAGER.add_event == original_event_method)

-- Preserve Mirror's existing supported scalar-field behavior; broader N2 remains separate.
G.GAME.battle_of_gods = false; c.ability.deity_ascended = false
local m = card({chips = 10, mult = 4, x_mult = 2, dollars = 1}); G.jokers.cards = {m}
G.GAME.potion_mirror_active = true; before = calls
local mirror = pack(m:calculate_joker(context(), 'mirror', nil))
assert(calls == before + 2 and mirror[1].chips == 20 and mirror[1].mult == 8 and mirror[1].x_mult == 4 and mirror[1].dollars == 2)
assert(mirror.n == 4 and mirror[2] == m.post and mirror[3] == 'tail' and mirror[4] == nil)
assert(pack(m:calculate_joker(nil)).n == 4)
G.GAME.potion_mirror_active = nil
assert(not read('src/core/battle_of_gods.lua'):find('local orig_calculate_joker = Card.calculate_joker', 1, true))
assert(not read('src/core/botg_combat.lua'):find('local orig_calc_joker', 1, true))
local loader = read('RealityWarp.lua')
assert(loader:find('src/core/joker_effects.lua', 1, true) < loader:find('src/core/utils.lua', 1, true))
