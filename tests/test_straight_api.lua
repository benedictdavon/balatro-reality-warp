local function read(path, optional)
    local file = io.open(REPO_ROOT .. '/' .. path)
    if not file and optional then return nil end
    assert(file, path)
    local source = file:read('*a')
    file:close()
    return source
end

local function region(source, first, following)
    local start = assert(source:find(first, 1, true), 'missing source start: ' .. first)
    local finish = assert(source:find(following, start + #first, true), 'missing source end: ' .. following)
    return source:sub(start, finish - 1)
end

local function pack(...)
    return {n = select('#', ...), ...}
end

local utils = read('src/core/utils.lua')
local rw_handlers = region(utils, '-- Colorful Street Hand Evaluation Handlers', '-- Spectral Shatter, Card dissolution effect')
local overrides = read('../smods/src/overrides.lua', true)
local smods_utils = read('../smods/src/utils.lua', true)
local misc_functions = read('../lovely/dump/functions/misc_functions.lua', true)
local native_straight = overrides and region(overrides,
    'function get_straight(hand, min_length, skip, wrap)', 'function G.UIDEF.deck_preview')
local native_helpers = smods_utils and region(smods_utils,
    'function SMODS.four_fingers(hand_type)', 'function SMODS.merge_effects')
local native_flush = misc_functions and region(misc_functions,
    'function get_flush(hand)', '-- Function overridden by SMODS in src/overrides.lua')
local smods_game_object = read('../smods/src/game_object.lua', true)

local function environment()
    local env = setmetatable({}, {__index = _G})
    env.G = {jokers = {cards = {}}, C = {}}
    env.SMODS = {Rank = {obj_buffer = {}}, Ranks = {}, Suit = {obj_buffer = {'Spades', 'Hearts', 'Clubs', 'Diamonds'}}}
    env.card_has_key = function(card, key)
        local center = card and card.config and card.config.center
        local name = center and center.key or (card and card.ability and card.ability.name) or ''
        return string.find(name, key, 1, true) ~= nil
    end
    env.SMODS.find_card = function(key)
        local found = {}
        for _, card in ipairs(env.G.jokers.cards) do
            local center = card.config and card.config.center
            if card.area == env.G.jokers and not card.debuff and not card.removed and
                center and center.key == key then
                found[#found + 1] = card
            end
        end
        return found
    end
    return env
end

local function load_in(source, name, env)
    local chunk, err = loadstring(source, name)
    assert(chunk, err)
    setfenv(chunk, env)
    return chunk()
end

local function add_joker(env, key, flags)
    local joker = {area = env.G.jokers, config = {center = {key = key}}, ability = {}}
    for name, value in pairs(flags or {}) do joker[name] = value end
    env.G.jokers.cards[#env.G.jokers.cards + 1] = joker
    return joker
end

local function install_native(env)
    assert(native_straight and native_helpers and native_flush,
        'installed Steamodded/Lovely sources are required for native detector coverage')
    load_in(native_helpers, 'installed_smods_helpers', env)
    load_in(native_straight, 'installed_get_straight', env)
    load_in(native_flush, 'installed_get_flush', env)
end

local function load_native_straight_dispatch(env)
    assert(smods_game_object, 'installed Steamodded game-object source is required for normal-dispatch coverage')
    local key_start = assert(smods_game_object:find("key = '_straight'", 1, true), 'missing installed _straight part')
    local function_start = assert(smods_game_object:find('func = function(hand) ', key_start, true),
        'missing installed _straight callback')
    local function_end = assert(smods_game_object:find(' end', function_start, true), 'missing installed _straight callback end')
    local function_source = smods_game_object:sub(function_start + #'func = ', function_end + #' end' - 1)
    local chunk, err = loadstring('return ' .. function_source, 'installed_straight_dispatch')
    assert(chunk, err)
    setfenv(chunk, env)
    return chunk()
end

local function install_ranks(env)
    local names = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}
    local values = {}
    for i, name in ipairs(names) do values[name] = i + 1 end
    values['2'] = 2
    values['3'] = 3
    values['4'] = 4
    values['5'] = 5
    values['6'] = 6
    values['7'] = 7
    values['8'] = 8
    values['9'] = 9
    values['10'] = 10
    values.Jack = 11
    values.Queen = 12
    values.King = 13
    values.Ace = 14
    for i, name in ipairs(names) do
        local next_key = names[i + 1] or '2'
        env.SMODS.Ranks[name] = {id = values[name], next = {next_key}, prev = {}, straight_edge = name == 'Ace'}
        env.SMODS.Rank.obj_buffer[#env.SMODS.Rank.obj_buffer + 1] = name
    end
    local custom = {'Star', 'Rune', 'Ember', 'Mist', 'Nova'}
    for i, name in ipairs(custom) do
        env.SMODS.Ranks[name] = {id = 20 + i, next = {custom[i + 1]}, prev = {}}
        env.SMODS.Rank.obj_buffer[#env.SMODS.Rank.obj_buffer + 1] = name
    end
    return values
end

local function make_hand(env, values, ranks, suits)
    local hand = {}
    for i, rank in ipairs(ranks) do
        local card = {rank = rank, suit = suits and suits[i] or 'Spades'}
        function card:get_id() return values[self.rank] or env.SMODS.Ranks[self.rank].id end
        function card:is_suit(suit) return self.suit == suit end
        hand[#hand + 1] = card
    end
    return hand
end

local function found_straight(result)
    return type(result) == 'table' and #result > 0
end

-- Exercise exact vararg and multiple-return preservation against a lower detector spy.
local spy_env = environment()
local detector_calls, helper_calls = {}, {}
local minimum = 6
spy_env.SMODS.four_fingers = function(...)
    helper_calls.four = pack(...)
    return minimum, 'four-tail', nil
end
spy_env.SMODS.shortcut = function(...)
    helper_calls.shortcut = pack(...)
    return false, 'shortcut-tail', nil
end
spy_env.SMODS.wrap_around_straight = function(...)
    helper_calls.wrap = pack(...)
    return false, 'wrap-tail', nil
end
spy_env.get_straight = function(hand, ...)
    detector_calls.args = pack(...)
    return 'straight-result', nil, 'post-result', nil
end
spy_env.get_flush = function(hand) return {}, 'flush-post', nil end
load_in(rw_handlers, 'reality_warp_straight_wrappers_spy', spy_env)
local colorful = add_joker(spy_env, 'j_reality_warp_colorful_street')
local spy_hand = {}
local explicit = pack(spy_env.get_straight(spy_hand, nil, false, true, 'trailing', nil))
assert(detector_calls.args.n == 5 and detector_calls.args[1] == nil and detector_calls.args[2] == false and
    detector_calls.args[3] == true and detector_calls.args[4] == 'trailing' and detector_calls.args[5] == nil,
    'explicit nil/false/trailing arguments must reach the lower detector unchanged')
assert(explicit.n == 4 and explicit[1] == 'straight-result' and explicit[2] == nil and
    explicit[3] == 'post-result' and explicit[4] == nil, 'all lower detector return positions must be preserved')
assert(helper_calls.four == nil and helper_calls.shortcut == nil and helper_calls.wrap == nil,
    'explicit calls do not consult Colorful Street modifiers')
local four_result = pack(spy_env.SMODS.four_fingers('flush', 'lower-arg', nil))
assert(helper_calls.four.n == 3 and helper_calls.four[1] == 'flush' and helper_calls.four[2] == 'lower-arg' and
    helper_calls.four[3] == nil and four_result.n == 3 and four_result[1] == 4 and
    four_result[2] == 'four-tail' and four_result[3] == nil, 'Colorful Street preserves helper args/returns and caps only the minimum')
local shortcut_result = pack(spy_env.SMODS.shortcut('lower-arg', nil))
assert(helper_calls.shortcut.n == 2 and helper_calls.shortcut[1] == 'lower-arg' and helper_calls.shortcut[2] == nil and
    shortcut_result.n == 3 and shortcut_result[1] == true and shortcut_result[2] == 'shortcut-tail' and
    shortcut_result[3] == nil, 'Shortcut helper forwarding preserves every lower return')
local legacy = pack(spy_env.get_straight(spy_hand))
assert(detector_calls.args.n == 3 and detector_calls.args[1] == 4 and detector_calls.args[2] == true and
    detector_calls.args[3] == false, 'legacy hand-only call uses first values from the current helpers')
assert(legacy.n == 4 and legacy[1] == 'straight-result' and legacy[2] == nil and
    legacy[3] == 'post-result' and legacy[4] == nil, 'legacy call also preserves all lower returns')
minimum = 3
assert(spy_env.SMODS.four_fingers('straight') == 3, 'Colorful Street never raises an existing smaller minimum')
colorful.area = nil
assert(spy_env.SMODS.four_fingers('straight') == 3 and spy_env.SMODS.shortcut() == false,
    'a Colorful Street outside the live Joker area has no effect')

-- Run the actual installed helper and detector source against small rank-graph fixtures.
local env = environment()
install_native(env)
local rank_ids = install_ranks(env)
load_in(rw_handlers, 'reality_warp_straight_wrappers_native', env)
local straight_dispatch = load_native_straight_dispatch(env)

local historical = make_hand(env, rank_ids, {'10', '9', '8', '7', '5'}, {'Diamonds', 'Hearts', 'Hearts', 'Clubs', 'Hearts'})
assert(not found_straight(env.get_straight(historical, 5, false, false)), 'historical one-gap hand fails without Shortcut')
local shortcut = add_joker(env, 'j_shortcut')
local with_shortcut = env.get_straight(historical, env.SMODS.four_fingers('straight'), env.SMODS.shortcut(), env.SMODS.wrap_around_straight())
assert(found_straight(with_shortcut), 'historical one-gap hand passes with native Shortcut helper')
assert(#with_shortcut[1] == 5, 'Shortcut retains the native detector’s exact card selection')
local original_cards = {}
for _, card in ipairs(historical) do original_cards[card] = true end
for _, card in ipairs(with_shortcut[1]) do assert(original_cards[card], 'detector returns original hand cards only') end
shortcut.debuff = true
assert(not found_straight(env.get_straight(historical)), 'debuffed Shortcut does not affect the legacy helper path')
shortcut.debuff = nil
assert(found_straight(env.get_straight(historical)), 'hand-only call derives Shortcut from current helpers')
local stricter = env.get_straight(historical, 6, true, true)
assert(not found_straight(stricter), 'explicit min_length=6 rejects five cards despite active Shortcut')

local ace_high = make_hand(env, rank_ids, {'Ace', 'King', 'Queen', 'Jack', '9'})
assert(found_straight(env.get_straight(ace_high, 5, true, false)), 'native rank graph supports a Shortcut gap near Ace')
local ace_low = make_hand(env, rank_ids, {'Ace', '2', '3', '4', '6'})
assert(found_straight(env.get_straight(ace_low, 5, true, false)), 'native rank graph supports Ace-low with Shortcut')
local separated_gaps = make_hand(env, rank_ids, {'5', '7', '8', '10', 'Jack'})
assert(found_straight(env.get_straight(separated_gaps, 5, true, false)), 'separated single-rank gaps remain valid')
local consecutive_gaps = make_hand(env, rank_ids, {'5', '8', '9', '10', 'Jack'})
assert(not found_straight(env.get_straight(consecutive_gaps, 5, true, false)), 'two consecutive missing ranks are not one Shortcut gap')
local duplicate_ranks = make_hand(env, rank_ids, {'5', '6', '6', '7', '8'})
assert(not found_straight(env.get_straight(duplicate_ranks, 5, false, false)), 'duplicate ranks cannot supply a missing rank')

local four_fingers = add_joker(env, 'j_four_fingers')
local four_card_gap = make_hand(env, rank_ids, {'5', '7', '8', '10'})
assert(env.SMODS.four_fingers('straight') == 4 and env.SMODS.shortcut() and
    found_straight(env.get_straight(four_card_gap)), 'native Four Fingers plus Shortcut derive 4 and skip')
four_fingers.debuff = true
shortcut.debuff = true
assert(not found_straight(env.get_straight(four_card_gap)), 'debuffed native components do not supply a four-card straight')

local colorful_alias = add_joker(env, 'j_calle_colorida')
assert(env.SMODS.four_fingers('straight') == 4 and env.SMODS.shortcut(), 'Spanish Colorful Street alias alone supplies both helpers')
assert(found_straight(env.get_straight(four_card_gap)), 'Colorful Street alone uses the native rank graph for 4-card Shortcut straights')
assert(found_straight(straight_dispatch(four_card_gap)), 'installed _straight dispatch observes Colorful Street helper composition')
local four_flush = make_hand(env, rank_ids, {'2', '4', '6', '8'}, {'Hearts', 'Hearts', 'Hearts', 'Hearts'})
local colorful_flush = env.get_flush(four_flush)
assert(env.SMODS.four_fingers('flush') == 4 and found_straight(colorful_flush) and #colorful_flush[1] == 4,
    'Colorful Street enables the native four-card flush helper without replacing get_flush')

colorful_alias.debuff = true
assert(env.SMODS.four_fingers('straight') == 5 and not env.SMODS.shortcut(),
    'debuffed Colorful Street alone stops supplying Four Fingers and Shortcut')
four_fingers.debuff = nil
shortcut.debuff = nil
assert(env.SMODS.four_fingers('straight') == 4 and env.SMODS.shortcut(),
    'independent live Four Fingers and Shortcut remain active when Colorful Street is debuffed')
four_fingers.debuff = true
shortcut.debuff = true
assert(env.SMODS.four_fingers('straight') == 5 and not env.SMODS.shortcut(), 'debuffed or removed modifiers stay inactive')
colorful_alias.debuff = nil
colorful_alias.removed = true
assert(env.SMODS.four_fingers('straight') == 5 and not env.SMODS.shortcut(), 'removed Colorful Street does not supply helpers')
colorful_alias.removed = nil
colorful_alias.area = nil
assert(env.SMODS.four_fingers('straight') == 5 and not env.SMODS.shortcut(), 'nonphysical Colorful Street does not supply helpers')
local colorful_canonical = add_joker(env, 'j_reality_warp_colorful_street')
assert(env.SMODS.four_fingers('straight') == 4 and env.SMODS.shortcut() and
    found_straight(env.get_straight(four_card_gap)), 'canonical Colorful Street alone supplies four-card skipped straights')
colorful_canonical.destroyed = true
assert(env.SMODS.four_fingers('straight') == 5 and not env.SMODS.shortcut(), 'destroyed Colorful Street does not supply helpers')
colorful_canonical.destroyed = nil
colorful_canonical.shattered = true
assert(env.SMODS.four_fingers('straight') == 5 and not env.SMODS.shortcut(), 'shattered Colorful Street does not supply helpers')
colorful_canonical.shattered = nil
colorful_canonical.getting_sliced = true
assert(env.SMODS.four_fingers('straight') == 5 and not env.SMODS.shortcut(), 'sliced Colorful Street does not supply helpers')
colorful_canonical.getting_sliced = nil
assert(env.SMODS.four_fingers('straight') == 4 and env.SMODS.shortcut(), 'live canonical Colorful Street still supplies both helpers')

-- A custom graph and explicit wrapping remain owned by the installed detector.
local custom_graph = make_hand(env, rank_ids, {'Star', 'Rune', 'Ember', 'Mist', 'Nova'})
assert(found_straight(env.get_straight(custom_graph, 5, false, false)), 'custom rank-name topology remains authoritative')
local ace_wrap = make_hand(env, rank_ids, {'King', 'Ace', '2', '3', '4'})
assert(not found_straight(env.get_straight(ace_wrap, 5, false, false)), 'edge stops without explicit wrap')
assert(found_straight(env.get_straight(ace_wrap, 5, false, true)), 'explicit wrap follows the native edge topology')

-- A custom lower helper can require fewer than four cards; Colorful Street must not raise it.
local custom_env = environment()
custom_env.SMODS.four_fingers = function() return 3, 'custom-minimum', nil end
custom_env.SMODS.shortcut = function() return false, 'custom-shortcut', nil end
custom_env.SMODS.wrap_around_straight = function() return false, 'custom-wrap', nil end
custom_env.get_straight = function(hand, min, skip, wrap)
    if min == 3 and skip == true and wrap == false then return {{hand[1], hand[2], hand[3]}} end
    return {}
end
custom_env.get_flush = function() return {} end
local custom_cs = add_joker(custom_env, 'j_reality_warp_colorful_street')
load_in(rw_handlers, 'reality_warp_custom_helper_wrapper', custom_env)
local custom_hand = {{}, {}, {}}
assert(custom_env.SMODS.four_fingers('straight') == 3 and custom_env.SMODS.shortcut(),
    'Colorful Street preserves a custom lower minimum')
assert(found_straight(custom_env.get_straight(custom_hand)), 'legacy path forwards custom minimum, skip, and wrap values')

print('PASS: straight detector API forwarding, helper composition, native rank graph, and Colorful Street controls')
