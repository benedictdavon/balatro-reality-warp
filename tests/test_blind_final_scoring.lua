local function read(path)
    local file = assert(io.open(REPO_ROOT .. '/' .. path)); local source = file:read('*a'); file:close(); return source
end

local function region(source, first, following)
    local start = assert(source:find(first, 1, true))
    local finish = assert(source:find(following, start + #first, true))
    return source:sub(start, finish - 1)
end

local function pack(...)
    return {n = select('#', ...), ...}
end

local definitions, order, messages, random_calls = {}, {}, {}, {}
local random_values = {}
local original_calls, original_varargs, original_argument = 0, {n = 0}, nil

G = {
    GAME = {chips = 0, probabilities = {normal = 1}, round_resets = {ante = 8},
        reality_warp_active_encounter = {id = 1, key = 'bl_reality_warp_chronos'}},
    C = {RED = {}, GREEN = {}, GOLD = {}, MONEY = {}},
    E_MANAGER = {add_event = function(_, event) order[#order + 1] = 'event'; return event end},
    play = {cards = {}}, hand = {cards = {}}, jokers = {cards = {}}, playing_cards = {},
    reality_warp_back_trigger_hooked = nil
}

function HEX(value) return value end
function Event(event) return event end
function number_format(value) return tostring(value) end
function mod_chips(value) return value end
function mod_mult(value) return value end
function update_hand_text() order[#order + 1] = 'update' end
function attention_text(args)
    messages[#messages + 1] = args.text
    order[#order + 1] = 'attention'
end
function play_sound(sound) order[#order + 1] = 'sound:' .. sound end
function pseudorandom(key)
    random_calls[#random_calls + 1] = key
    return table.remove(random_values, 1) or 1
end
function pseudorandom_element(cards) return cards[1], 1 end
function ease_custom_blind_background() end
function reset_reality_warp_boss_ui() end
function reality_warp_encounter_params() return {} end

Blind = {set_blind = function() end, defeat = function() end}
SMODS = {
    Atlas = function() end,
    Blind = function(definition)
        definition.key = 'bl_reality_warp_' .. definition.key
        definitions[definition.key] = definition
    end
}

dofile(REPO_ROOT .. '/src/core/blind_identity.lua')
-- This final-score harness models only the chance API; ownership has its own native API harness.
SMODS.pseudorandom_probability = function(_, seed, numerator, denominator)
    return pseudorandom(seed) < numerator * G.GAME.probabilities.normal / denominator
end
dofile(REPO_ROOT .. '/src/blinds/boss_blinds.lua')

local chronos = assert(definitions.bl_reality_warp_chronos)
local guillotine = assert(definitions.bl_reality_warp_guillotine)
local void = assert(definitions.bl_reality_warp_void)
assert(chronos.modify_hand == nil and guillotine.modify_hand == nil,
    'Chronos and Guillotine must not punish at pre-Joker modify_hand')

local utils_source = read('src/core/utils.lua')
local helper_region = region(utils_source, '-- Called by the outer Back dispatcher', '-- The Code: one penalty')
assert(loadstring(helper_region, 'final Blind scoring helper'))()

local native_zero_outputs = false
Back = {
    effect = {center = {key = 'b_test_deck'}},
    trigger_effect = function(self, args, ...)
        original_calls = original_calls + 1
        original_varargs = pack(...)
        original_argument = args
        order[#order + 1] = 'native'
        if self.name == 'Plasma Deck' and args and args.context == 'final_scoring_step' then
            local total = args.chips + args.mult
            args.chips = math.floor(total / 2)
            args.mult = math.floor(total / 2)
            order[#order + 1] = 'plasma'
            if args.no_native_return then return end
            return args.chips, args.mult, 'post', nil, 'tail', nil
        end
        if native_zero_outputs then return end
        return args and args.native_chips, args and args.native_mult, 'post', nil, 'tail', nil
    end
}

reality_warp_DECK_HOOKS = {
    test_deck = {function(_, args)
        order[#order + 1] = 'deck'
        if args and args.deck_chips ~= nil then return args.deck_chips, args.deck_mult end
    end}
}

local decks_source = read('src/decks/decks.lua')
local dispatcher_start = assert(decks_source:find('-- Extensible Deck Event Hook Dispatcher', 1, true))
assert(loadstring(decks_source:sub(dispatcher_start), 'outer Back dispatcher'))()

local function clear(list)
    for index = #list, 1, -1 do list[index] = nil end
end

local function configure(key, requirement, current_chips, disabled, display_name)
    local definition = type(key) == 'table' and key or assert(definitions['bl_reality_warp_' .. key])
    G.GAME.chips = current_chips or 0
    G.GAME.probabilities = {normal = 1}
    G.GAME.blind = {name = display_name or definition.name, config = {blind = definition},
        chips = requirement or 1000, disabled = not not disabled}
    Back.effect = {center = {key = 'b_test_deck'}}
    Back.name = nil
end

local function call(args, ...)
    local before = original_calls
    local returns = pack(Back:trigger_effect(args, ...))
    assert(original_calls == before + 1, 'the native Back callback must run once per dispatcher call')
    assert(original_argument == args, 'the original argument table must be forwarded unchanged')
    return returns
end

local function reset_observations(values, zero_outputs)
    clear(order); clear(messages); clear(random_calls); clear(original_varargs)
    random_values = values or {}
    native_zero_outputs = not not zero_outputs
end

-- A fractional product is floored before the cumulative projected-win comparison.
configure('chronos', 1000, 499)
reset_observations()
local fractional_below = call({context = 'final_scoring_step', chips = 50.09, mult = 10,
    native_chips = 50.09, native_mult = 10})
assert(fractional_below[1] == 50.09 and fractional_below[2] == 10,
    '499 + floor(50.09 * 10) stays below 1000')
assert(#messages == 0, 'fractional score below the projected target must not trigger Chronos')

-- Prior round chips count: equality after floor triggers Chronos exactly once.
configure('chronos', 1000, 500)
reset_observations()
local at_target_args = {context = 'final_scoring_step', chips = 50, mult = 10,
    native_chips = 50, native_mult = 10}
local at_target = call(at_target_args, 'extra', nil)
assert(at_target[1] == 45 and at_target[2] == 9 and #messages == 1,
    'cumulative prior chips plus the final hand score apply one X0.90')
assert(at_target.n == 6 and at_target[3] == 'post' and at_target[4] == nil and
    at_target[5] == 'tail' and at_target[6] == nil, 'extra, post and trailing-nil returns survive')
assert(original_varargs.n == 2 and original_varargs[1] == 'extra' and original_varargs[2] == nil,
    'all original wrapper arguments, including trailing nil, are forwarded')
assert(order[1] == 'native' and order[2] == 'deck' and order[3] == 'update' and order[4] == 'attention',
    'final Blind scoring runs after native Back and registered deck hooks')

-- Plasma's native Back callback mutates the shared args from their sum and returns the balanced pair.
configure('chronos', 1000, 0)
Back.name = 'Plasma Deck'
reset_observations()
local plasma_args = {context = 'final_scoring_step', chips = 80, mult = 10}
local plasma = call(plasma_args)
assert(plasma_args.chips == 45 and plasma_args.mult == 45 and plasma[1] == 40 and plasma[2] == 40,
    'Chronos judges the native Plasma return after its sum/2 mutation')
assert(order[1] == 'native' and order[2] == 'plasma' and order[3] == 'deck' and order[4] == 'update',
    'the final rule follows native Plasma and registered deck callbacks')

-- A native callback that mutates args but returns nothing still feeds the final rule through args fallback.
configure('chronos', 1000, 0)
Back.name = 'Plasma Deck'
reset_observations()
local plasma_no_return_args = {context = 'final_scoring_step', chips = 80, mult = 10, no_native_return = true}
local plasma_no_return = call(plasma_no_return_args)
assert(plasma_no_return_args.chips == 45 and plasma_no_return_args.mult == 45 and
    plasma_no_return[1] == 40 and plasma_no_return[2] == 40,
    'mutated args remain the final-score fallback when the native callback returns nothing')

-- A later registered deck result overrides Plasma's pair, then Chronos sees that last result.
configure('chronos', 1000, 0)
Back.name = 'Plasma Deck'
reset_observations()
local plasma_deck_override = call({context = 'final_scoring_step', chips = 80, mult = 10,
    deck_chips = 100, deck_mult = 30})
assert(plasma_deck_override[1] == 90 and plasma_deck_override[2] == 27,
    'registered deck overrides follow Plasma and precede Chronos')

configure('chronos', 1000, 500)
reset_observations()
local above_target = call({context = 'final_scoring_step', chips = 51, mult = 10,
    native_chips = 51, native_mult = 10})
assert(above_target[1] == 45 and above_target[2] == 9 and #messages == 1,
    'scores above the projected target receive one Chronos reduction')

-- The pre-Joker base can miss while the final, Joker-scored hand crosses the target.
configure('chronos', 1000, 0)
reset_observations()
local joker_final_win = call({context = 'final_scoring_step', chips = 60, mult = 20,
    native_chips = 60, native_mult = 20, pre_joker_chips = 20, pre_joker_mult = 20})
assert(20 * 20 < 1000 and joker_final_win[1] == 54 and joker_final_win[2] == 18,
    'a non-winning pre-Joker base is judged from final scoring outputs')

-- Registered deck hooks can supply scores after a zero-output native callback; zero is preserved.
configure({key = 'bl_other', name = 'Other'}, 1000, 0, false, 'Chronos')
reset_observations(nil, true)
local supplied_zero = call({context = 'final_scoring_step', chips = 7, mult = 8,
    deck_chips = 0, deck_mult = 0})
assert(supplied_zero.n == 2 and supplied_zero[1] == 0 and supplied_zero[2] == 0,
    'registered overrides survive a native callback with zero returns and keep zero values')
assert(#messages == 0, 'localized names cannot trigger canonical Chronos')

-- Nil args, non-final contexts and disabled blinds preserve original outputs without blind work.
configure('chronos', 1000, 0)
reset_observations()
local nil_args = call(nil, 'extra', nil)
assert(nil_args.n == 6 and nil_args[1] == nil and nil_args[2] == nil and nil_args[3] == 'post' and
    nil_args[4] == nil and nil_args[5] == 'tail' and nil_args[6] == nil and #messages == 0)
reset_observations()
local nonfinal = call({context = 'eval', chips = 40, mult = 10, native_chips = 40, native_mult = 10})
assert(nonfinal[1] == 40 and nonfinal[2] == 10 and #messages == 0)
configure('chronos', 1000, 0, true)
reset_observations()
local disabled = call({context = 'final_scoring_step', chips = 60, mult = 20,
    native_chips = 60, native_mult = 20})
assert(disabled[1] == 60 and disabled[2] == 20 and #messages == 0 and #random_calls == 0)

-- Guillotine rolls once at the final stage and zeros deck-scored values on success.
configure('guillotine', 100000, 0)
reset_observations({0.1})
local guillotine_success = call({context = 'final_scoring_step', chips = 40, mult = 10,
    native_chips = 40, native_mult = 10, deck_chips = 120, deck_mult = 20})
assert(guillotine_success[1] == 0 and guillotine_success[2] == 0 and #random_calls == 1 and
    random_calls[1] == 'guillotine', 'one successful Guillotine roll zeros the final deck-scored result')
assert(order[1] == 'native' and order[2] == 'deck' and order[3] == 'update',
    'Guillotine acts after native and registered deck scoring')
configure('guillotine', 100000, 0)
Back.name = 'Plasma Deck'
reset_observations({0.1})
local plasma_guillotine_args = {context = 'final_scoring_step', chips = 80, mult = 10,
    deck_chips = 60, deck_mult = 20}
local plasma_guillotine = call(plasma_guillotine_args)
assert(plasma_guillotine_args.chips == 45 and plasma_guillotine_args.mult == 45 and
    plasma_guillotine[1] == 0 and plasma_guillotine[2] == 0 and #random_calls == 1,
    'canonical Guillotine applies one seeded zero after native Plasma and deck overrides')
assert(order[1] == 'native' and order[2] == 'plasma' and order[3] == 'deck' and order[4] == 'update',
    'Guillotine runs after both native Plasma and registered deck scoring')
configure('guillotine', 100000, 0)
reset_observations({0.9})
local guillotine_failure = call({context = 'final_scoring_step', chips = 40, mult = 10,
    native_chips = 40, native_mult = 10})
assert(guillotine_failure[1] == 40 and guillotine_failure[2] == 10 and #random_calls == 1)
configure('guillotine', 100000, 0)
reset_observations()
call({context = 'eval', chips = 40, mult = 10, native_chips = 40, native_mult = 10})
assert(#random_calls == 0, 'Guillotine does not consume RNG outside the real final scoring stage')
configure({key = 'bl_other', name = 'Other'}, 100000, 0, false, 'The Guillotine')
reset_observations({0.1})
local misleading_guillotine = call({context = 'final_scoring_step', chips = 40, mult = 10,
    native_chips = 40, native_mult = 10})
assert(misleading_guillotine[1] == 40 and #random_calls == 0,
    'localized display names cannot trigger canonical Guillotine')

-- Preserve canonical Doppelgänger reduction and per-hand flag cleanup in the moved helper.
configure('doppelganger', 100000, 0)
G.GAME.doppel_triggered_in_hand = true
reset_observations()
local doppel = call({context = 'final_scoring_step', chips = 100, mult = 40,
    native_chips = 100, native_mult = 40, deck_chips = 80, deck_mult = 20})
assert(doppel[1] == 20 and doppel[2] == 5 and G.GAME.doppel_triggered_in_hand == nil,
    'Doppelgänger applies its canonical ÷4 once to final deck outputs and clears its flag')

-- Void compares the committed prior score plus the floored pending final score, mutating only its callback Blind.
local void_runtime = {config = {blind = void}, chips = 900, disabled = false}
G.GAME.blind = {chips = 777, config = {blind = {key = 'bl_other'}}}
G.GAME.chips = 800
SMODS.last_hand_score = 99.9
local void_losing = void:calculate(void_runtime, {after = true, scoring_hand = {{}}})
assert(void_runtime.chips == 1350 and G.GAME.blind.chips == 777 and void_losing.message == 'X1.5 Target!',
    'Void grows only its passed Blind when prior chips plus floor(last score) remain below target')

void_runtime.chips = 900
G.GAME.chips = 800
SMODS.last_hand_score = 100.9
void:calculate(void_runtime, {after = true, scoring_hand = {{}}})
assert(void_runtime.chips == 900, 'a floored projected winning hand does not increase Void')
void_runtime.chips = 900
SMODS.last_hand_score = 99.9
void:calculate(void_runtime, {after = true, scoring_hand = nil})
void:calculate(void_runtime, {before = true, scoring_hand = {{}}})
void:calculate(void_runtime, {after = true, scoring_hand = {{}}, blueprint = true})
void_runtime.disabled = true
void:calculate(void_runtime, {after = true, scoring_hand = {{}}})
assert(void_runtime.chips == 900, 'Void requires a real scoring-hand after context and enabled Blind')
