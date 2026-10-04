local function read(path)
    local file = assert(io.open(REPO_ROOT .. '/' .. path, 'rb'))
    local value = file:read('*a'); file:close()
    return (value:gsub('\r\n', '\n'))
end
local function region(source, first, following)
    local a = assert(source:find(first, 1, true), first)
    local b = assert(source:find(following, a + #first, true), following)
    return source:sub(a, b - 1)
end
local function load(source, name) return assert(loadstring(source, name))() end
local function pack(...) return {n = select('#', ...), ...} end
local native = read('../smods/src/utils.lua')
local vars_source = region(native, 'function SMODS.get_probability_vars(', '\nfunction SMODS.pseudorandom_probability(')
local probability_source = region(native, 'function SMODS.pseudorandom_probability(', '\nfunction SMODS.is_poker_hand_visible(')
local stack_source = region(native, 'SMODS.context_stack = {}', '\nfunction SMODS.calculate_context(')
local context_source = region(native, 'function SMODS.calculate_context(', '\nfunction SMODS.in_scoring(')
local effects_source = region(native, 'SMODS.trigger_effects = function(', '\n-- Calculate one key of an effect table')
local rare = read('src/jokers/rare.lua')
local lucky_source = region(rare, '-- Lucky One\n', '\n-- Miner\n')
local module_source = read('src/core/probability_rules.lua')
local calls, sample_values, sample_error, modifier, after_sample
local vars_args, roll_args, lower_card_args, definitions, dispatched
local function install(before_module)
    calls, sample_values, sample_error, modifier, after_sample = {}, {}, nil, nil, nil
    definitions, dispatched = {}, {}
    G = {GAME = {probabilities = {normal = 1}}, STAGE = 1, STAGES = {RUN = 1},
        play = {cards = {}}, jokers = {cards = {}}, hand = {cards = {}},
        C = {GREEN = {}, CLUBS = {}, MULT = {}}}
    SMODS = {find_card = function() return {} end, Sticker = {obj_buffer = {}},
        Joker = function(def) definitions[def.key] = def end}
    HEX = function(value) return value end
    sendWarnMessage = function(message) error(message) end
    pseudorandom = function(seed, ...)
        calls[#calls+1] = {seed = seed, args = pack(...)}
        if sample_error then error(sample_error) end
        return table.remove(sample_values, 1) or 0.9
    end
    load(stack_source, 'installed context stack')
    load(context_source, 'installed calculate_context')
    load(vars_source, 'installed get_probability_vars')
    load(probability_source, 'installed pseudorandom_probability')
    load(effects_source, 'installed trigger_effects')
    SMODS.calculate_effect_table_key = function() end -- effect/UI sinks are modeled
    SMODS.calculate_card_areas = function(kind, context)
        if kind ~= 'jokers' then return {} end
        local flags = modifier and modifier(context) or {}
        if context.pseudorandom_result then
            dispatched[#dispatched+1] = context
            for _, card in ipairs(G.jokers.cards) do
                if card.config.center.key == 'j_reality_warp_lucky_one_joker' then
                    definitions.lucky_one_joker:calculate(card, context)
                    context.retrigger_joker = true
                    definitions.lucky_one_joker:calculate(card, context)
                    context.retrigger_joker = nil
                end
            end
        end
        return flags
    end -- native calculate_context dispatches into this bounded Joker-area adapter
    local native_vars, native_roll = SMODS.get_probability_vars, SMODS.pseudorandom_probability
    SMODS.get_probability_vars = function(...)
        vars_args = pack(...)
        local n, d = native_vars(...)
        return n, d, nil, 'vars-tail', nil
    end
    SMODS.pseudorandom_probability = function(...)
        roll_args = pack(...)
        local result = native_roll(...)
        if after_sample then after_sample() end
        return result, nil, 'roll-tail', nil
    end
    Card = {calculate_joker = function(self, context, ...)
        lower_card_args = pack(...)
        if self.calculation then return self:calculation(context, ...) end
        return 'original', nil, 'card-tail', nil
    end}
    load(read('src/core/joker_effects.lua'), 'accepted Joker effect composer')
    if before_module then before_module() end
    local original_rng = pseudorandom
    load(module_source, 'Reality Warp probability ownership')
    assert(pseudorandom == original_rng, 'the global RNG must remain untouched')
    load(lucky_source, 'actual Lucky One definition')
    return definitions.lucky_one_joker
end
local function lucky(charges, extra)
    local card = setmetatable({area = G.jokers, config = {center = {key = 'j_reality_warp_lucky_one_joker'}},
        ability = {extra = extra or {charges = charges, clubs_scored = 0, clubs_needed = 5, xmult = 1.5, xmult_gain = 0.1}}}, {__index = Card})
    G.jokers.cards[#G.jokers.cards+1] = card
    return card
end
local function flush()
    local contexts = SMODS.post_prob
    SMODS.trigger_effects({})
    assert(#SMODS.post_prob == 0, 'native dispatcher drains the original post_prob list')
    return contexts
end
local function close(actual, expected) assert(math.abs(actual - expected) < 0.000001, tostring(actual) .. ' ~= ' .. expected) end

-- No global RNG interception, including a legacy global flag without any owner.
install()
G.GAME.lucky_one_guaranteed = true
for _, seed in ipairs({'unrelated_cosmetic', 'shop_category', 'boss_selection', 'lucky_edition_roll', 123456}) do
    assert(pseudorandom(seed) == 0.9)
end
assert(#calls == 5)
assert(SMODS.pseudorandom_probability({}, 'no-owner', 1, 10) == false)
assert(#calls == 6)
flush()

-- A guaranteed zero-numerator probability still advances the actual original seeded stream once.
install()
local owner = lucky(2)
local trigger = {}
sample_values = {0.8, 0.4, 0.7}
local output = pack(SMODS.pseudorandom_probability(trigger, 'space_joker', 0, 10, 'space-id', false, nil, 'future', nil))
assert(output.n == 4 and output[1] == true and output[2] == nil and output[3] == 'roll-tail' and output[4] == nil)
assert(roll_args.n == 9 and roll_args[1] == trigger and roll_args[2] == 'space_joker' and roll_args[7] == nil and roll_args[8] == 'future')
assert(#calls == 1 and calls[1].seed == 'space_joker' and calls[1].args.n == 0)
assert(owner.ability.extra.charges == 1 and owner.ability.extra.xmult == 1.5)
local result = SMODS.post_prob[1]
assert(result.numerator == 1 and result.denominator == 1)
flush()
assert(dispatched[1] == result, 'native trigger_effects passes the same owned context table')
close(owner.ability.extra.xmult, 1.6)
assert(not reality_warp_lucky_probability_success(owner, result), 'duplicate context cannot grow again')
assert(pseudorandom('same_stream') == 0.4 and #calls == 2)
assert(pseudorandom('same_stream') == 0.7 and #calls == 3)

-- Original modifier/fixer order and nil-inclusive getter returns survive the guarantee.
install(); owner = lucky(1)
local seen = {}
modifier = function(context)
    if context.mod_probability then seen[#seen+1] = 'mod'; return {numerator = 2, denominator = 8} end
    if context.fix_probability then seen[#seen+1] = 'fix'; assert(context.numerator == 2); return {numerator = 3, denominator = 9} end
end
local preview = pack(SMODS.get_probability_vars(trigger, 1, 5, 'ui', nil, false, nil, 'future', nil))
assert(preview.n == 5 and preview[1] == 3 and preview[2] == 9 and preview[3] == nil and preview[4] == 'vars-tail' and preview[5] == nil)
assert(vars_args.n == 9 and vars_args[7] == nil and vars_args[8] == 'future' and owner.ability.extra.charges == 1 and #calls == 0)
assert(SMODS.get_probability_vars(trigger, 1, 5, 'ui', true) == 3, 'from_roll alone is not an owned API call')
assert(owner.ability.extra.charges == 1)
assert(SMODS.pseudorandom_probability(trigger, 'real', 1, 5) == true)
assert(roll_args.n == 4, 'omitted probability options must stay omitted in the lower wrapper')
SMODS.get_probability_vars(trigger, 1, 5)
assert(vars_args.n == 3, 'omitted getter options must stay omitted in the lower wrapper')
assert(table.concat(seen, ',') == 'mod,fix,mod,fix,mod,fix,mod,fix' and owner.ability.extra.charges == 0)
flush()

-- no_mod fixed odds are preserved; successful fixed binary outcomes still obey documented growth.
install(); owner = lucky(1); G.GAME.probabilities.normal = 99
sample_values = {0.9, 0.1}
assert(not SMODS.pseudorandom_probability(trigger, 'baby_bell', 0.2, 1, nil, true))
assert(SMODS.pseudorandom_probability(trigger, 'baby_bell', 0.2, 1, nil, true))
assert(owner.ability.extra.charges == 1 and #calls == 2)
flush(); close(owner.ability.extra.xmult, 1.6)
assert(not reality_warp_lucky_probability_success(owner, {pseudorandom_result = true, result = true}), 'foreign results have no ownership')

-- Pure getters nested inside modifiers cannot reserve the outer ticket, even with the same identifier.
install(); owner = lucky(1)
local nested_getter = false
modifier = function(context)
    if context.mod_probability and not nested_getter then
        nested_getter = true
        local n, d = SMODS.get_probability_vars(context.trigger_obj, 1, 7, context.identifier, true)
        assert(n == 1 and d == 7 and owner.ability.extra.charges == 1)
        nested_getter = false
    end
end
assert(SMODS.pseudorandom_probability(trigger, 'nested-getter', 1, 10))
assert(owner.ability.extra.charges == 0 and #calls == 1)
flush(); close(owner.ability.extra.xmult, 1.6)

-- Nested real rolls complete chronologically and cannot double-spend a reserved token.
install(); owner = lucky(2)
local child = false
modifier = function(context)
    if context.mod_probability and not child then
        child = true
        assert(SMODS.pseudorandom_probability(trigger, 'child', 1, 20))
        child = false
    end
end
assert(SMODS.pseudorandom_probability(trigger, 'parent', 1, 20))
assert(#calls == 2 and calls[1].seed == 'child' and calls[2].seed == 'parent' and owner.ability.extra.charges == 0)
flush(); close(owner.ability.extra.xmult, 1.7)

-- Reentrant sampling after the outer token is reserved cannot use it again.
install(); owner = lucky(1)
local rng = pseudorandom
local in_sample = false
pseudorandom = function(seed, ...)
    if not in_sample then
        in_sample = true
        assert(not SMODS.pseudorandom_probability(trigger, 'nested-sample', 1, 100))
        in_sample = false
    end
    return rng(seed, ...)
end
assert(SMODS.pseudorandom_probability(trigger, 'outer-sample', 1, 100))
assert(#calls == 2 and owner.ability.extra.charges == 0)
flush(); close(owner.ability.extra.xmult, 1.6)

-- Errors before a native outcome release the reservation and restore all private scopes.
install(); owner = lucky(1); sample_error = 'sample failed'
local ok, err = pcall(SMODS.pseudorandom_probability, trigger, 'error', 1, 10)
assert(not ok and tostring(err):find('sample failed', 1, true) and owner.ability.extra.charges == 1)
sample_error = nil
assert(SMODS.pseudorandom_probability(trigger, 'after-error', 1, 10) and owner.ability.extra.charges == 0)
flush(); close(owner.ability.extra.xmult, 1.6)
install(); owner = lucky(1)
after_sample = function() error('wrapper after outcome') end
ok, err = pcall(SMODS.pseudorandom_probability, trigger, 'completed-error', 1, 10)
assert(not ok and tostring(err):find('wrapper after outcome', 1, true) and owner.ability.extra.charges == 0)
after_sample = nil
flush(); close(owner.ability.extra.xmult, 1.6)
assert(not SMODS.pseudorandom_probability(trigger, 'after-completed-error', 1, 10))
flush()

-- A completed nested child keeps its token if the parent later fails in a probability modifier.
install(); owner = lucky(2); child = false
modifier = function(context)
    if context.mod_probability and not child then
        child = true
        assert(SMODS.pseudorandom_probability(trigger, 'completed-child', 1, 10))
        child = false
        error('parent modifier failed')
    end
end
ok, err = pcall(SMODS.pseudorandom_probability, trigger, 'failed-parent', 1, 10)
assert(not ok and tostring(err):find('parent modifier failed', 1, true) and owner.ability.extra.charges == 1)
-- The installed calculate_context itself lacks error-finally stack cleanup; repair only this test fixture.
SMODS.context_stack = {}; SMODS.no_resolve = nil; modifier = nil
flush(); close(owner.ability.extra.xmult, 1.6)
assert(SMODS.pseudorandom_probability(trigger, 'parent-retry', 1, 10) and owner.ability.extra.charges == 0)
flush()

-- Invalid denominator/NaN ratios cannot reserve a token; the native result is otherwise unchanged.
install(); owner = lucky(2)
assert(SMODS.pseudorandom_probability(trigger, 'zero-denominator', 1, 0))
assert(not SMODS.pseudorandom_probability(trigger, 'nan-ratio', 0/0, 1))
assert(owner.ability.extra.charges == 2 and #calls == 2)
flush()
install(); owner = lucky(1)
assert(not SMODS.pseudorandom_probability(trigger, 'infinite-over-infinite', math.huge, math.huge))
assert(owner.ability.extra.charges == 1)
flush()

-- Every five real scored Clubs stacks a serialized charge, without Blueprint/Joker-retrigger duplication.
local definition = install(); owner = lucky(0)
local club = {is_suit = function(_, suit) return suit == 'Clubs' end}
local context = {individual = true, cardarea = G.play, other_card = club}
for _ = 1, 10 do definition:calculate(owner, context) end
assert(owner.ability.extra.charges == 2 and owner.ability.extra.clubs_scored == 0)
context.blueprint = true; definition:calculate(owner, context); context.blueprint = nil
context.retrigger_joker = true; definition:calculate(owner, context); context.retrigger_joker = nil
context.repetition = true; definition:calculate(owner, context); context.repetition = nil
context.potion_mirror_retrigger = true; definition:calculate(owner, context); context.potion_mirror_retrigger = nil
context.potion_espejo_retrigger = true; definition:calculate(owner, context); context.potion_espejo_retrigger = nil
assert(owner.ability.extra.charges == 2 and owner.ability.extra.clubs_scored == 0)
-- Red Seal's second actual individual pass has no Joker-retrigger flag and counts as a real scored Club.
definition:calculate(owner, context); definition:calculate(owner, context)
assert(owner.ability.extra.clubs_scored == 2)
assert(definition:calculate(owner, {joker_main = true, blueprint = true}).Xmult == 1.5)
assert(definition:calculate(owner, {individual = true, other_card = {lucky_trigger = true}}) == nil)

-- Legacy UI is pure, and the current charge field takes precedence over a stale boolean/global flag.
install(); owner = lucky(nil, {guaranteed = true, clubs_scored = 4, clubs_needed = 5, xmult = 1.5})
local legacy = owner.ability.extra
local loc = definitions.lucky_one_joker:loc_vars({}, owner)
assert(loc.vars[3] == 'Guaranteed! x1' and legacy.charges == nil and legacy.guaranteed == true)
G.GAME.lucky_one_guaranteed = true
assert(SMODS.pseudorandom_probability(trigger, 'legacy', 1, 20))
assert(legacy.charges == 0 and legacy.guaranteed == nil)
loc = definitions.lucky_one_joker:loc_vars({}, owner)
assert(loc.vars[3] == 'Pending')
flush()
legacy.charges, legacy.guaranteed = 0, true
assert(reality_warp_lucky_charges(owner) == 0)

-- Multiple physical owners have separate tickets; growth goes once to each actual roll's owner snapshot.
install(); local first, second = lucky(1), lucky(2)
assert(SMODS.pseudorandom_probability(trigger, 'first', 1, 100))
assert(first.ability.extra.charges == 0 and second.ability.extra.charges == 2)
local late = lucky(5)
flush(); close(first.ability.extra.xmult, 1.6); close(second.ability.extra.xmult, 1.6); close(late.ability.extra.xmult, 1.5)
assert(SMODS.pseudorandom_probability(trigger, 'second', 1, 100))
assert(second.ability.extra.charges == 1 and late.ability.extra.charges == 5)
second.debuff = true
flush(); close(second.ability.extra.xmult, 1.6)
late.debuff = true
assert(not SMODS.pseudorandom_probability(trigger, 'debuffed', 1, 100))
assert(second.ability.extra.charges == 1 and late.ability.extra.charges == 5)
late.debuff = nil; late.area = G.hand
assert(not SMODS.pseudorandom_probability(trigger, 'not-owned-area', 1, 100))
late.area = G.jokers; late.removed = true
assert(not SMODS.pseudorandom_probability(trigger, 'removed', 1, 100))
G.jokers.cards = {}
assert(not SMODS.pseudorandom_probability(trigger, 'sold-all', 1, 100))
flush()

-- Cold reconstruction serializes only ability data; stale native results cannot alter a fresh game.
install(); owner = lucky(2); owner.ability.extra.clubs_scored = 3
assert(SMODS.pseudorandom_probability(trigger, 'old-game', 1, 100))
local old_result = SMODS.post_prob[1]
local saved = {charges = owner.ability.extra.charges, clubs_scored = owner.ability.extra.clubs_scored,
    clubs_needed = 5, xmult = owner.ability.extra.xmult, xmult_gain = 0.1}
G.GAME = {probabilities = {normal = 1}}; G.jokers.cards = {}
local loaded = lucky(nil, saved)
assert(saved.charges == 1 and saved.clubs_scored == 3)
assert(not reality_warp_lucky_probability_success(loaded, old_result))
assert(SMODS.pseudorandom_probability(trigger, 'new-game', 1, 100) and saved.charges == 0)
flush(); close(saved.xmult, 1.6)
install(); loaded = lucky(nil, {charges = 2, clubs_scored = 3, clubs_needed = 5, xmult = 1.6})
assert(SMODS.pseudorandom_probability(trigger, 'fresh-process-model', 1, 100))
assert(loaded.ability.extra.charges == 1 and loaded.ability.extra.clubs_scored == 3)
flush()

-- Direct Falta/Doppel Card simulations and framework no_resolve previews never spend or grow.
for _, simulated_context in ipairs({{falta_de_lectura_check = true}, {doppel_sim = true}}) do
    install(); owner = lucky(1)
    owner.calculation = function(self)
        assert(not SMODS.pseudorandom_probability(self, 'simulation', 1, 100))
        return 'simulated', nil, 'tail', nil
    end
    output = pack(owner:calculate_joker(simulated_context, nil, 'future', nil))
    assert(output.n == 4 and output[1] == 'simulated' and output[3] == 'tail' and output[4] == nil)
    assert(lower_card_args.n == 3 and lower_card_args[1] == nil and lower_card_args[2] == 'future')
    assert(owner.ability.extra.charges == 1 and #calls == 1)
    flush(); close(owner.ability.extra.xmult, 1.5)
    owner.calculation = function() error('simulation failed') end
    ok, err = pcall(owner.calculate_joker, owner, simulated_context)
    assert(not ok and tostring(err):find('simulation failed', 1, true))
    assert(SMODS.pseudorandom_probability(trigger, 'after-simulation-error', 1, 100))
    flush(); close(owner.ability.extra.xmult, 1.6)
end
install(); owner = lucky(1); SMODS.no_resolve = true
sample_values = {0}
assert(SMODS.pseudorandom_probability(trigger, 'no-resolve', 1, 100))
assert(owner.ability.extra.charges == 1, 'entry snapshot survives native calculate_context clearing no_resolve')
flush(); close(owner.ability.extra.xmult, 1.5)
install(); owner = lucky(1)
SMODS.push_to_context_stack({falta_de_lectura_check = true}, owner)
sample_values = {0}
assert(SMODS.pseudorandom_probability(trigger, 'stack-simulation', 1, 100))
assert(owner.ability.extra.charges == 1)
SMODS.context_stack = {}; flush(); close(owner.ability.extra.xmult, 1.5)

-- A pure UI getter protects nested real API calls through both native modifier/fixer phases.
install(); owner = lucky(1)
local entered = false
modifier = function(context)
    if (context.mod_probability or context.fix_probability) and not entered then
        entered = true
        sample_values = {0}
        assert(SMODS.pseudorandom_probability(trigger, 'nested-ui', 1, 100))
        entered = false
    end
end
SMODS.get_probability_vars(trigger, 1, 10, 'ui-only')
assert(#calls == 2 and owner.ability.extra.charges == 1)
SMODS.get_probability_vars(trigger, 1, 10, 'ui-claims-from-roll', true)
assert(#calls == 4 and owner.ability.extra.charges == 1,
    'a direct getter claiming from_roll is still a preview without an official owned API frame')
modifier = nil; flush(); close(owner.ability.extra.xmult, 1.5)
assert(SMODS.pseudorandom_probability(trigger, 'real-after-ui', 1, 100))
flush(); close(owner.ability.extra.xmult, 1.6)

-- The simulation wrapper must surround the Familiar bypass too, matching actual loader order.
local familiar_source = read('src/core/botg_familiars.lua')
install(function()
    load(region(familiar_source, '-- Hook Card.calculate_joker exclusively for the familiar card',
        '\nfunction botg_calculate_familiar(self, context)'), 'actual Familiar Card wrapper')
end)
load(region(familiar_source, 'function botg_calculate_familiar(self, context)',
    '\n-- Baby Pillar, Baby Heart & Baby Leaf:'), 'actual Familiar callback')
botg_get_familiar_level = function() return 1 end -- nursery persistence is outside this probability test
owner = lucky(1)
G.botg_familiars = {cards = {}}
local familiar = setmetatable({area = G.botg_familiars, config = {center = {key = 'c_reality_warp_baby_wheel'}}}, {__index = Card})
G.botg_familiars.cards[1] = familiar
local wheel_context = {individual = true, cardarea = G.play, other_card = {}, falta_de_lectura_check = true}
assert(familiar:calculate_joker(wheel_context) == nil and owner.ability.extra.charges == 1)
flush(); close(owner.ability.extra.xmult, 1.5)
wheel_context.falta_de_lectura_check = nil
assert(familiar:calculate_joker(wheel_context).mult == 6 and owner.ability.extra.charges == 0)
flush(); close(owner.ability.extra.xmult, 1.6)
local loader = read('RealityWarp.lua')
assert(loader:find('"src/core/botg_combat.lua"', 1, true) < loader:find('"src/core/probability_rules.lua"', 1, true),
    'probability simulation scope must enclose the Familiar/Card bypass wrappers')

-- JokerDisplay reads the same authoritative charge count without spending or repairing gameplay state.
local jd_source = region(read('src/compat/jokerdisplay.lua'), '-- 27. Lucky One', '\n-- 28. Miner')
local jd = load('local jd_def = {}\n' .. jd_source .. '\nreturn jd_def', 'actual Lucky One JokerDisplay')
install(); owner = lucky(nil, {guaranteed = true, clubs_scored = 4, xmult = 1.5})
owner.joker_display_values = {}
jd.j_reality_warp_lucky_one_joker.calc_function(owner)
assert(owner.joker_display_values.active and owner.joker_display_values.clubs_str == 'Guaranteed! x1')
assert(owner.ability.extra.charges == nil and owner.ability.extra.guaranteed == true)
owner.ability.extra.charges = 0; G.GAME.lucky_one_guaranteed = true
jd.j_reality_warp_lucky_one_joker.calc_function(owner)
assert(not owner.joker_display_values.active and owner.joker_display_values.clubs_str == '4/5 ♣')

-- Physical copies retain independent serialized extras; Blueprint never manufactures a second ticket.
install(); first = lucky(2); second = lucky(2)
local copy_source = region(read('../lovely/dump/functions/common_events.lua'), 'function copy_card(', '\nfunction tutorial_info(')
load(copy_source, 'installed copy_card')
copy_table = function(value)
    local clone = {}
    for key, entry in pairs(value) do clone[key] = type(entry) == 'table' and copy_table(entry) or entry end
    return clone
end -- native copy implementation calls this serialization-shaped adapter
second.set_ability = function() end; second.set_base = function() end
second.set_edition = function(self, edition) self.edition = edition end
second.set_seal = function() end; second.set_cost = function() end
check_for_unlock = function() end
assert(copy_card(first, second) == second and first.ability.extra ~= second.ability.extra)
assert(second.ability.extra.charges == 2)
assert(read('../lovely/dump/card.lua'):find('self.ability = cardTable.ability', 1, true),
    'installed native load replaces ability with serialized data, preserving legacy nil charges')
assert(SMODS.pseudorandom_probability(trigger, 'copy-first', 1, 100))
assert(first.ability.extra.charges == 1 and second.ability.extra.charges == 2)
flush()
-- A card debuffed only after a completed roll still spends the ticket it already used.
install(); owner = lucky(1)
after_sample = function() owner.debuff = true end
assert(SMODS.pseudorandom_probability(trigger, 'completed-before-debuff', 1, 100))
assert(owner.ability.extra.charges == 0)
flush(); close(owner.ability.extra.xmult, 1.5)

-- Owners removed by the native modifiers cannot donate a ticket or receive that roll's later growth.
install(); owner = lucky(1)
modifier = function(context)
    if context.fix_probability then owner.getting_sliced = true end
end
assert(not SMODS.pseudorandom_probability(trigger, 'removed-during-modifiers', 1, 100))
assert(owner.ability.extra.charges == 1)
modifier = nil; flush(); close(owner.ability.extra.xmult, 1.5)

-- Native Blueprint/context-stack delegation distinguishes duplicate receivers from distinct real rolls.
local overrides = read('../smods/src/overrides.lua')
local card_stack_source = region(overrides, 'local calculate_joker_ref = Card.calculate_joker', '\nlocal set_ability = Card.set_ability')
local blueprint_source = region(native, 'function SMODS.blueprint_effect(', '\nfunction SMODS.get_mods_scoring_targets(')
install(function()
    load(card_stack_source, 'installed Card calculate context-stack wrapper')
    load(blueprint_source, 'installed Blueprint effect')
end)
owner = lucky(1)
owner.config.center.blueprint_compat = true
owner.calculation = function(self, context) return definitions.lucky_one_joker:calculate(self, context) end
local copier = setmetatable({area = G.jokers, config = {center = {key = 'j_blueprint'}}}, {__index = Card})
G.jokers.cards[#G.jokers.cards+1] = copier
assert(SMODS.pseudorandom_probability(trigger, 'receiver-test', 1, 100))
local receiver_context = SMODS.post_prob[1]
assert(SMODS.blueprint_effect(copier, owner, receiver_context) == nil,
    'a copied Lucky receiver must not grow from the same native result')
assert(receiver_context.blueprint == nil and #SMODS.context_stack == 0)
close(owner.ability.extra.xmult, 1.5)
flush(); close(owner.ability.extra.xmult, 1.6)
assert(SMODS.blueprint_effect(copier, owner, receiver_context) == nil)
receiver_context.retrigger_joker = copier
assert(owner:calculate_joker(receiver_context) == nil)
receiver_context.retrigger_joker = nil
assert(owner:calculate_joker(receiver_context) == nil)
close(owner.ability.extra.xmult, 1.6)
-- Blueprint copying the Lucky Club receiver likewise cannot award a charge.
local club_receiver = {individual = true, cardarea = G.play, other_card = club}
assert(SMODS.blueprint_effect(copier, owner, club_receiver) == nil)
assert(owner.ability.extra.clubs_scored == 0 and owner.ability.extra.charges == 0)

-- A separate actual probability made by a copied chance Joker still qualifies once.
owner.ability.extra.charges = 2
local chance_joker = setmetatable({area = G.jokers,
    config = {center = {key = 'j_chance_test', blueprint_compat = true}},
    calculation = function(self, context)
        assert(SMODS.context_stack[#SMODS.context_stack].context == context)
        assert(SMODS.pseudorandom_probability(self, 'copied-real-chance', 1, 100))
        return {message = 'Actual probability succeeded'}
    end}, {__index = Card})
G.jokers.cards[#G.jokers.cards+1] = chance_joker
local origin_context = {joker_main = true}
assert(SMODS.blueprint_effect(copier, chance_joker, origin_context).card == copier)
assert(origin_context.blueprint == nil and owner.ability.extra.charges == 1)
flush(); close(owner.ability.extra.xmult, 1.7)
origin_context.retrigger_joker = copier
assert(chance_joker:calculate_joker(origin_context))
assert(owner.ability.extra.charges == 0)
origin_context.retrigger_joker = nil
flush(); close(owner.ability.extra.xmult, 1.8)

-- Execute the two fixed integer-chance callsites identified by independent review.
local echo_source = region(read('src/jokers/uncommon.lua'), '-- Echo Chamber\n', '\n-- Claw Machine\n')
local miner_source = region(read('src/consumables/jobs.lua'), '-- Miner Sticker\n', '\n-- Jeweler Sticker\n')
local function fixed_callsites()
    install(); owner = lucky(2)
    play_sound = function() end
    load(echo_source, 'actual Echo Chamber definition')
    local stickers = SMODS.Sticker
    setmetatable(stickers, {__call = function(_, def) definitions[def.key] = def end})
    load(miner_source, 'actual Miner Sticker definition')
    G.consumeables = {cards = {}, config = {card_limit = 1}}
    return {ability = {extra = {base_chance = 50, bonus_chance = 0}}}
end
local echo = fixed_callsites()
sample_values = {0.49}
assert(definitions.echo_chamber:calculate(echo, {repetition = true, cardarea = G.play}).repetitions == 1)
assert(echo.ability.extra.bonus_chance == 2 and owner.ability.extra.charges == 2 and #calls == 1)
assert(roll_args[2] == 'echo_chamber' and roll_args[3] == 50 and roll_args[4] == 100 and roll_args[6] == true)
flush(); close(owner.ability.extra.xmult, 1.6)
sample_values = {0.52}
assert(definitions.echo_chamber:calculate(echo, {repetition = true, cardarea = G.play}) == nil)
flush(); close(owner.ability.extra.xmult, 1.6)
echo.ability.extra.base_chance, echo.ability.extra.bonus_chance = 49.9, 0
sample_values = {0.495}
assert(definitions.echo_chamber:calculate(echo, {repetition = true, cardarea = G.play}) == nil)
assert(roll_args[3] == 49, 'fractional saved percentage preserves the original integer-roll threshold')
flush(); close(owner.ability.extra.xmult, 1.6)
echo.ability.extra.base_chance = 100
sample_values = {0.99}
assert(definitions.echo_chamber:calculate(echo, {repetition = true, cardarea = G.play, blueprint = true}))
assert(echo.ability.extra.bonus_chance == 0 and owner.ability.extra.charges == 2)
flush(); close(owner.ability.extra.xmult, 1.7)

fixed_callsites()
local cash_total, created = 0, 0
local lower_rng = pseudorandom
pseudorandom = function(seed, ...)
    if seed == 'miner_cash' then
        local args = pack(...)
        assert(args.n == 2 and args[1] == 1 and args[2] == 3)
        calls[#calls+1] = {seed = seed, args = args}
        return 2 -- bounded native ranged RNG adapter; only the separate gem result is typed
    end
    return lower_rng(seed, ...)
end
ease_dollars = function(value) cash_total = cash_total + value end
SMODS.add_card = function(args)
    assert(args.set == 'Tarot' and args.key_append == 'miner_dig'); created = created + 1
end
local mined = {ability = {}}
sample_values = {0.124}
assert(definitions.miner_job:calculate(mined, {main_scoring = true, cardarea = G.play}).message:find('Unearthed', 1, true))
assert(cash_total == 2 and created == 1 and #calls == 2 and owner.ability.extra.charges == 2)
assert(calls[1].seed == 'miner_cash' and roll_args[2] == 'miner_gem' and roll_args[3] == 1 and roll_args[4] == 8 and roll_args[6] == true)
flush(); close(owner.ability.extra.xmult, 1.6)
G.consumeables.config.card_limit = 0
sample_values = {0.1}
assert(definitions.miner_job:calculate(mined, {individual = true, cardarea = G.play}).chips == 50)
assert(cash_total == 4 and created == 1 and #calls == 4 and owner.ability.extra.charges == 2)
flush(); close(owner.ability.extra.xmult, 1.7)
sample_values = {0.125}
assert(definitions.miner_job:calculate(mined, {individual = true, cardarea = G.play}).chips == nil)
assert(cash_total == 6 and created == 1 and #calls == 6 and owner.ability.extra.charges == 2)
flush(); close(owner.ability.extra.xmult, 1.7)

-- Optional actual installed Omega number contract, enabled only by the LuaJIT runner.
if LUCKY_BIG_PATH then
    package.path = LUCKY_BIG_PATH .. '/?.lua;' .. package.path
    local Big = require('big-num.omeganum')
    local globals = read('../amulet-main/talisman/break_inf/globals.lua')
    load(region(globals, 'function is_number(x)', '\n--- @return'), 'installed Amulet is_number')
    is_big = Big.is
    install(); owner = lucky(1)
    assert(SMODS.pseudorandom_probability(trigger, 'omega-guarantee', Big:create(1), Big:create('1e400')))
    assert(owner.ability.extra.charges == 0 and #calls == 1)
    flush(); close(owner.ability.extra.xmult, 1.6)
    install(); owner = lucky(1)
    sample_values = {0.9}
    assert(not SMODS.pseudorandom_probability(trigger, 'omega-fixed', Big:create(1), Big:create(100), nil, true))
    assert(owner.ability.extra.charges == 1 and #calls == 1)
    flush(); close(owner.ability.extra.xmult, 1.5)
end

-- Execute the real queued native end_round callback with the shipping Lovely payloads applied.
local state_events = read('../lovely/dump/functions/state_events.lua')
local end_round_source = region(state_events, 'function end_round()', '\nfunction new_round()')
local lovely = read('lovely/lovely.toml')
local patch_source = region(lovely, '# Complete all main/held end-of-round effects', '# End Lucky One round boundaries.')
local originals, applied = 0, 0
for block, payload in patch_source:gmatch("%[patches%.pattern%](.-)payload = '([^']+)'") do
    assert(block:match("target = '([^']+)'") == 'functions/state_events.lua')
    local pattern = assert(block:match("pattern = '([^']+)'"))
    assert(block:find("position = 'before'", 1, true) and block:find('times = 1', 1, true))
    local lines, matches = {}, 0
    for line in (end_round_source .. '\n'):gmatch('(.-)\n') do
        local trimmed = line:match('^%s*(.-)%s*$')
        if trimmed == pattern then
            matches = matches + 1
            local previous = lines[#lines] and lines[#lines]:match('^%s*(.-)%s*$')
            if previous == payload then
                applied = applied + 1
                assert(not (lines[#lines-1] and lines[#lines-1]:find(payload, 1, true)), 'duplicate applied reset')
            else
                originals = originals + 1
                lines[#lines+1] = (line:match('^(%s*)') or '') .. payload
            end
        end
        lines[#lines+1] = line
    end
    assert(matches == 1, 'round boundary must match once as a full native line')
    end_round_source = table.concat(lines, '\n')
end
assert((originals == 2 and applied == 0) or (originals == 0 and applied == 2), 'expected original or fully applied round patches: ' .. originals .. '/' .. applied)

local queue, phase, round_tokens
local function configure_round(win, saved)
    install(); owner = lucky(2)
    owner.ability.extra.clubs_scored = 4
    queue, phase, round_tokens = {}, {}, {}
    G.GAME.chips = win and 100 or 0
    G.GAME.blind = {chips = 90, boss = false, config = {blind = {}}, get_type = function() return 'Small' end}
    G.GAME.round_resets = {ante = 1, blind_states = {Small = 'Current'}}
    G.GAME.current_round = {hands_played = 1, discards_left = 2}
    G.GAME.win_ante, G.GAME.seeded, G.GAME.modifiers, G.GAME.hands = 8, true, {}, {}
    G.GAME.blind_on_deck = 'Small'
    G.FILE_HANDLER = {}
    G.STATES = {GAME_OVER = 'lost', ROUND_EVAL = 'finished'}
    G.save_settings = function() end
    G.E_MANAGER = {add_event = function(_, event) queue[#queue+1] = event end}
    Event = function(event) return event end
    discover_card = function() end
    inc_career_stat = function() end
    check_for_unlock = function() end
    set_joker_usage = function() end
    G.FUNCS = {
        draw_from_hand_to_discard = function()
            phase[#phase+1] = 'discard'
            assert(owner.ability.extra.charges == 0 and owner.ability.extra.clubs_scored == 0,
                'the completed-round reset must precede card movement')
        end,
        draw_from_discard_to_deck = function() end,
    }
    modifier = function(context)
        if context.end_of_round then
            phase[#phase+1] = 'main'
            round_tokens[#round_tokens+1] = owner.ability.extra.charges
            assert(SMODS.pseudorandom_probability(trigger, 'round-main', 1, 100))
            SMODS.trigger_effects({})
            if saved then SMODS.saved = true end
        end
    end
    SMODS.get_card_areas = function(kind, context)
        assert(kind == 'playing_cards' and context == 'end_of_round')
        return {G.hand}
    end
    SMODS.calculate_end_of_round_effects = function(context)
        assert(context.cardarea == G.hand and context.end_of_round)
        phase[#phase+1] = 'held'
        round_tokens[#round_tokens+1] = owner.ability.extra.charges
        assert(SMODS.pseudorandom_probability(trigger, 'round-held', 1, 100))
        SMODS.trigger_effects({})
    end -- held-evaluation boundary is modeled; native end_round queue and context dispatch are actual source
    load(end_round_source, 'installed queued end_round with shipping reset patches')
    end_round()
    assert(#queue == 1 and owner.ability.extra.charges == 2 and owner.ability.extra.clubs_scored == 4,
        'calling end_round only queues the native work; it must not expire a token early')
    assert(queue[1].trigger == 'after' and queue[1].delay == 0.2)
    assert(queue[1].func())
end
configure_round(true, false)
assert(table.concat(phase, ',') == 'main,held,discard' and round_tokens[1] == 2 and round_tokens[2] == 1)
close(owner.ability.extra.xmult, 1.7)
assert(owner.ability.extra.clubs_scored == 0 and owner.ability.extra.charges == 0)
configure_round(false, false)
assert(table.concat(phase, ',') == 'main' and G.STATE == G.STATES.GAME_OVER)
assert(owner.ability.extra.clubs_scored == 0 and owner.ability.extra.charges == 0)
close(owner.ability.extra.xmult, 1.6)
configure_round(false, true)
assert(table.concat(phase, ',') == 'main,held,discard', 'a native saved loss follows the winning held-effect/reset path')
close(owner.ability.extra.xmult, 1.7)

-- End-of-round contexts no longer individually clear charges; debuffed owners still expire at completion.
install(); owner = lucky(2); owner.ability.extra.clubs_scored = 4
definitions.lucky_one_joker:calculate(owner, {end_of_round = true})
assert(owner.ability.extra.charges == 2 and owner.ability.extra.clubs_scored == 4)
assert(SMODS.pseudorandom_probability(trigger, 'old-round', 1, 100))
local stale = SMODS.post_prob[1]
owner.debuff = true
reality_warp_reset_lucky_round()
assert(owner.ability.extra.charges == 0 and owner.ability.extra.clubs_scored == 0)
owner.debuff = nil
assert(not reality_warp_lucky_probability_success(owner, stale), 'deferred results from a completed round cannot mutate a later round')

-- These checks cover source/API contracts and modeled adapters, never real Balatro execution.
print('PASS: Lucky One native probability ownership, serialized charges, simulations and queued round boundaries')
