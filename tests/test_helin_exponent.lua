local function read(path)
    local f = assert(io.open(REPO_ROOT .. '/' .. path)); local s = f:read('*a'); f:close(); return s
end
local function region(path, first, following)
    local s = read(path); local a = assert(s:find(first, 1, true))
    return s:sub(a, assert(s:find(following, a + #first, true)) - 1)
end
local function load_region(path, first, following)
    assert(loadstring(region(path, first, following), path))()
end
local definition, calls, ui_updates = nil, 0, 0
G = {GAME = {battle_of_gods = false, hands = {Pair = {level = 21}}},
    jokers = {cards = {}}, C = {DARK_EDITION = {}, PURPLE = {}, GOLD = {}, WHITE = {}, EDITION = {}}}
function register_secret_joker(d) definition = d end
load_region('src/jokers/secret.lua', '-- 8. Helin', '-- 9. RayTracing')
assert(definition.key == 'helin' and definition.blueprint_compat and definition.config.extra.power == 2)
function update_hand_text() ui_updates = ui_updates + 1 end
function juice_card() end
function card_eval_status_text() end
function localize(t) return tostring(t.key) end
function is_joker_copiable(c) return c.config.center.blueprint_compat and not c.debuff end
function is_secret_card() return false end
function is_amalgam_card() return false end
function card_has_key() return false end
function reality_warp_blind_is() return false end
-- Labeled Card eligibility/registration adapter; calculation/copy/composition
-- and Amulet handlers below are actual source, not a full Balatro Card runtime.
Card = {calculate_joker = function(self, context, ...)
    if self.debuff or self.removed or self.destroyed or self.getting_sliced then return end
    calls = calls + 1
    if self.copy_target then return SMODS.blueprint_effect(self, self.copy_target, context) end
    return definition:calculate(self, context), 'post', ...
end}
SMODS = {calculation_keys = {}, Scoring_Parameters = {},
    calculate_individual_effect = function() return nil end, -- native-unhandled extension key sink
    calculate_effect = function() end}
load_region('../smods/src/utils.lua', 'function SMODS.blueprint_effect(', '\nfunction SMODS.get_mods_scoring_targets(')
dofile(REPO_ROOT .. '/src/core/joker_effects.lua')
load_region('src/core/utils.lua', '-- Falta de Lectura activation tracker', '-- Hook card_eval_status_text')
Talisman = {config_file = {dev = false, disable_anims = false}}
dofile(REPO_ROOT .. '/../amulet-main/talisman/effects.lua')
dofile(REPO_ROOT .. '/../amulet-main/talisman/smods/ind_effect.lua')
assert(Talisman.effects.list.e_mult and Talisman.effects.list.emult and Talisman.effects.list.Emult_mod)
local Big
if HELIN_BIG_PATH then
    package.path = HELIN_BIG_PATH .. '/?.lua;' .. package.path
    Big = require('big-num.omeganum')
end
local function number(x) return Big and Big:create(x) or x end
local function equal(actual, expected)
    assert(actual == number(expected), 'unexpected Mult result')
end
local function card(target)
    return setmetatable({copy_target = target, ability = {set = 'Joker', extra = {power = 2}},
        config = {center = {key = 'j_reality_warp_helin', blueprint_compat = true}}}, {__index = Card})
end
local function context() return {joker_main = true, cardarea = G.jokers, scoring_name = 'Pair'} end
local function begin(value, supported)
    mult = number(value)
    to_big = supported and number or nil
    SMODS.Scoring_Parameters.mult = {current = mult, modify = function(self, delta)
        self.current = self.current + delta; mult = self.current
    end}
end
-- A labeled ordered effect-chain sink: Amulet consumes its own e_mult through
-- actual individual dispatch; ordinary x_mult changes use a simple numeric sink.
local function apply(effect)
    while type(effect) == 'table' do
        if effect.e_mult then
            local before = mult
            assert(SMODS.calculate_individual_effect(effect, nil, 'e_mult', effect.e_mult))
            assert(mult == before ^ effect.e_mult)
        end
        if effect.x_mult then
            mult = mult * effect.x_mult; SMODS.Scoring_Parameters.mult.current = mult
        end
        effect = effect.extra
    end
end
for _, supported in ipairs({false, true}) do
    if not Big or supported then
        for copies = 0, 2 do
            local h = card(); local first, second = card(h), card(h)
            G.jokers.cards = {h, first, second}
            begin(12, supported)
            local effect, post = h:calculate_joker(context(), 'tail')
            assert(post == 'post')
            if supported then assert(effect.e_mult == 2 and mult == number(12)) end
            apply(effect)
            for i = 1, copies do
                local ctx = context(); local copy = i == 1 and first or second
                local copied = copy:calculate_joker(ctx)
                if supported then assert(copied.e_mult == 2 and copied.card == copy) end
                apply(copied)
                assert(ctx.blueprint == nil and ctx.blueprint_card == nil and #ctx.blueprint_copiers_stack == 0)
            end
            equal(mult, ({144, 20736, 429981696})[copies + 1])
        end
        for _, value in ipairs({0, 1}) do
            begin(value, supported); local h = card(); apply(h:calculate_joker(context())); equal(mult, value)
        end
    end
end
local h, copier = card(), card(); copier.copy_target = h; G.jokers.cards = {h, copier}
for _, flag in ipairs({'debuff', 'removed', 'destroyed', 'getting_sliced'}) do
    begin(12, true); h[flag] = true; assert(copier:calculate_joker(context()) == nil); equal(mult, 12); h[flag] = nil
end
h.config.center.blueprint_compat = false
assert(copier:calculate_joker(context()) == nil); h.config.center.blueprint_compat = true
local ctx = context(); ctx.no_blueprint = true; assert(copier:calculate_joker(ctx) == nil)
-- Modes append after the original exponent; they must not replace it.
G.GAME.battle_of_gods = true
h.ability.deity_ascended = true; h.ability.glitched = true; h.ability.glitch_mult = 0.5
begin(12, true); local mode_effect = h:calculate_joker(context()); assert(mode_effect.e_mult == 2)
apply(mode_effect); equal(mult, 180) -- 144 ×2 ×1.25 ×0.5
G.GAME.battle_of_gods = false; h.ability.deity_ascended = nil; h.ability.glitched = nil
begin(12, true); apply(h:calculate_joker(context())); apply({x_mult = 2}); equal(mult, 288)
begin(12, true); apply({x_mult = 2}); apply(h:calculate_joker(context())); equal(mult, 576)
if Big then
    begin('1e400', true); apply(h:calculate_joker(context())); equal(mult, '1e800')
    print('PASS: actual installed Omega Helin exponent and Amulet individual dispatch under LuaJIT')
else
    assert(ui_updates > 0, 'numeric fallback must update hand text')
    print('PASS: Helin callback, supported Amulet e_mult, native Blueprint and accepted composition; labeled scoring adapters')
end
