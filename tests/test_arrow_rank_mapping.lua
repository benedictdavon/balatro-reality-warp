local definitions = {}
local sounds = {}
G = {GAME = {round_resets = {ante = 8}, probabilities = {normal = 1}}, C = {}, ARGS = {},
    E_MANAGER = {add_event = function() end}, play = {cards = {}}, hand = {cards = {}},
    jokers = {cards = {}}, playing_cards = {}, P_CARDS = {}}
function HEX(value) return value end
function Event(value) return value end
function play_sound(...) sounds[#sounds + 1] = {...} end
function pseudorandom() return 0 end
function pseudoseed(value) return value end
function pseudorandom_element(pool) return pool[1], 1 end
function attention_text() end
function reset_reality_warp_boss_ui() end
Blind = {set_blind = function() end, defeat = function() end}
SMODS = {
    Ranks = {},
    Suits = {},
    Atlas = function() end,
    Blind = function(definition)
        definition.key = 'bl_reality_warp_' .. definition.key
        definitions[definition.key] = definition
    end,
}

local function read_file(path)
    local file = io.open(path, 'r')
    if not file then return nil end
    local content = file:read('*a')
    file:close()
    return content
end

local installed_utils = read_file(REPO_ROOT .. '/../smods/src/utils.lua')
local extracted_framework_api = false
if installed_utils then
    local start_at = assert(installed_utils:find('-- Change a card\'s suit, rank, or both.', 1, true),
        'Installed Steamodded rank API marker not found')
    local end_at = assert(installed_utils:find('-- Return an array of all (non-debuffed) jokers', start_at, true),
        'Installed Steamodded rank API end marker not found')
    local chunk = assert(loadstring(installed_utils:sub(start_at, end_at - 1), '@installed Steamodded rank API'))
    chunk()
    extracted_framework_api = true
else
    -- Portable fallback for checkouts without the sibling Steamodded source.
    function SMODS.change_base(card, suit, rank)
        local registered_suit = SMODS.Suits[suit or card.base.suit]
        local registered_rank = SMODS.Ranks[rank or card.base.value]
        if not registered_suit or not registered_rank then return nil end
        card:set_base(G.P_CARDS[registered_suit.card_key .. '_' .. registered_rank.card_key])
        return card
    end
    function SMODS.modify_rank(card, amount)
        local rank_key = card.base.value
        local rank_data = SMODS.Ranks[rank_key]
        for _ = 1, math.max(0, -amount) do
            local behavior = rank_data.prev_behavior or {fixed = 1}
            if not next(rank_data.prev) or behavior.ignore then break end
            rank_key = rank_data.prev[behavior.fixed or 1]
            rank_data = SMODS.Ranks[rank_key]
        end
        return SMODS.change_base(card, nil, rank_key)
    end
end

-- Register the installed vanilla suit/rank topology used by the extracted API.
local suits = {
    {key = 'Spades', code = 'S'}, {key = 'Hearts', code = 'H'},
    {key = 'Clubs', code = 'C'}, {key = 'Diamonds', code = 'D'},
}
local order = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}
local rank_codes = {['10'] = 'T', Jack = 'J', Queen = 'Q', King = 'K', Ace = 'A'}
for index, rank in ipairs(order) do
    local previous = order[((index - 2) % #order) + 1]
    SMODS.Ranks[rank] = {key = rank, card_key = rank_codes[rank] or rank, prev = {previous}}
end
for _, suit in ipairs(suits) do
    SMODS.Suits[suit.key] = {key = suit.key, card_key = suit.code}
    for _, rank in ipairs(order) do
        local key = suit.code .. '_' .. SMODS.Ranks[rank].card_key
        G.P_CARDS[key] = {key = key, value = rank, suit = suit.key}
    end
end

dofile(REPO_ROOT .. '/src/core/blind_identity.lua')
dofile(REPO_ROOT .. '/src/core/blind_effects.lua')
dofile(REPO_ROOT .. '/src/blinds/boss_blinds.lua')
local arrow = assert(definitions.bl_reality_warp_arrow)

local real_modify_rank, modify_calls = SMODS.modify_rank, 0
SMODS.modify_rank = function(...)
    modify_calls = modify_calls + 1
    return real_modify_rank(...)
end
local blind = {disabled = false, config = {blind = arrow}}
G.GAME.blind = blind

local function make_card(suit, rank)
    local suit_data, rank_data = SMODS.Suits[suit], SMODS.Ranks[rank]
    local front_key = suit_data.card_key .. '_' .. rank_data.card_key
    local card = {base = G.P_CARDS[front_key], front_key = front_key, ability = {bonus = 17},
        seal = 'Gold', edition = {key = 'e_foil'}, permanent_bonus = 3, juice_count = 0}
    function card:set_base(front) self.base, self.front_key = front, front.key end
    function card:juice_up() self.juice_count = self.juice_count + 1 end
    return card
end

local function run(card_list, context, runtime_blind)
    if context == nil and card_list ~= nil then context = {after = true, scoring_hand = card_list} end
    return arrow:calculate(runtime_blind or blind, context)
end

local expected_previous = {
    ['2'] = 'Ace', ['3'] = '2', ['4'] = '3', ['5'] = '4', ['6'] = '5', ['7'] = '6',
    ['8'] = '7', ['9'] = '8', ['10'] = '9', Jack = '10', Queen = 'Jack', King = 'Queen', Ace = 'King',
}
for _, suit in ipairs(suits) do
    for _, rank in ipairs(order) do
        local card = make_card(suit.key, rank)
        local ability, seal, edition, permanent_bonus = card.ability, card.seal, card.edition, card.permanent_bonus
        local calls_before, sounds_before = modify_calls, #sounds
        local result = run({card})
        local previous = expected_previous[rank]
        local expected_key = suit.code .. '_' .. SMODS.Ranks[previous].card_key
        assert(card.base.value == previous and card.front_key == expected_key,
            suit.key .. ' ' .. rank .. ' should become registered ' .. expected_key)
        assert(modify_calls == calls_before + 1 and card.juice_count == 1)
        assert(#sounds == sounds_before + 1 and sounds[#sounds][1] == 'tarot2')
        assert(result and result.message == '-1 Rank!' and result.colour == '8f2d56')
        assert(card.base.suit == suit.key and card.ability == ability and card.seal == seal and
            card.edition == edition and card.permanent_bonus == permanent_bonus,
            'Arrow must preserve non-rank card properties')
    end
end

-- Steamodded's default prev topology is generated from each rank's next list;
-- Ace.next = {'2'} therefore makes the explicit 2 -> Ace wrap above.
assert(SMODS.Ranks['2'].prev[1] == 'Ace')

-- Custom suit/rank card keys and prev_behavior remain framework-owned.
SMODS.Suits.Moon = {key = 'Moon', card_key = 'M'}
SMODS.Ranks.CustomCurrent = {key = 'CustomCurrent', card_key = 'X',
    prev = {'CustomFirst', 'CustomSelected'}, prev_behavior = {fixed = 2}}
SMODS.Ranks.CustomFirst = {key = 'CustomFirst', card_key = 'F', prev = {}}
SMODS.Ranks.CustomSelected = {key = 'CustomSelected', card_key = 'Y', prev = {}}
G.P_CARDS.M_X = {key = 'M_X', value = 'CustomCurrent', suit = 'Moon'}
G.P_CARDS.M_F = {key = 'M_F', value = 'CustomFirst', suit = 'Moon'}
G.P_CARDS.M_Y = {key = 'M_Y', value = 'CustomSelected', suit = 'Moon'}
local custom = make_card('Moon', 'CustomCurrent')
run({custom})
assert(custom.base.value == 'CustomSelected' and custom.front_key == 'M_Y' and custom.juice_count == 1)

SMODS.Ranks.CustomNoPrev = {key = 'CustomNoPrev', card_key = 'N', prev = {}, prev_behavior = {ignore = true}}
G.P_CARDS.M_N = {key = 'M_N', value = 'CustomNoPrev', suit = 'Moon'}
local no_previous = make_card('Moon', 'CustomNoPrev')
local calls_before, sounds_before = modify_calls, #sounds
assert(run({no_previous}) == nil)
assert(no_previous.base.value == 'CustomNoPrev' and no_previous.juice_count == 0)
assert(modify_calls == calls_before + 1 and #sounds == sounds_before)

SMODS.Ranks.CustomIgnored = {key = 'CustomIgnored', card_key = 'I', prev = {'CustomFirst'},
    prev_behavior = {ignore = true}}
G.P_CARDS.M_I = {key = 'M_I', value = 'CustomIgnored', suit = 'Moon'}
local ignored = make_card('Moon', 'CustomIgnored')
calls_before, sounds_before = modify_calls, #sounds
assert(run({ignored}) == nil and ignored.base.value == 'CustomIgnored')
assert(ignored.juice_count == 0 and modify_calls == calls_before + 1 and #sounds == sounds_before)

-- Repeated references and native-removal flags must never cause extra rank calls.
local repeated = make_card('Hearts', '9')
calls_before = modify_calls
run({repeated, repeated})
assert(modify_calls == calls_before + 1 and repeated.base.value == '8' and repeated.juice_count == 1)
for _, flag in ipairs({'removed', 'destroyed', 'shattered', 'getting_sliced'}) do
    local card = make_card('Spades', 'Jack')
    card[flag] = true
    calls_before = modify_calls
    local sounds_before = #sounds
    assert(run({card}) == nil)
    assert(modify_calls == calls_before and card.base.value == 'Jack' and card.juice_count == 0)
    assert(#sounds == sounds_before)
end

-- The actual API is one global after action: disabled, pseudo, unrelated and empty contexts are inert.
local controls = {
    {context = nil},
    {context = {before = true, scoring_hand = {make_card('Hearts', '9')}}},
    {context = {after = true, scoring_hand = {make_card('Hearts', '9')}, blueprint = true}},
    {context = {after = true, scoring_hand = {make_card('Hearts', '9')}, individual = true}},
    {context = {after = true, scoring_hand = {make_card('Hearts', '9')}, repetition = true}},
    {context = {after = true, scoring_hand = {}}},
    {context = {after = true}},
}
for _, control in ipairs(controls) do
    calls_before = modify_calls
    local scoring_hand = control.context and control.context.scoring_hand
    assert(run(scoring_hand, control.context) == nil)
    assert(modify_calls == calls_before)
end
local disabled = {disabled = true, config = {blind = arrow}}
calls_before = modify_calls
assert(run({make_card('Hearts', '9')}, {after = true, scoring_hand = {make_card('Hearts', '9')}}, disabled) == nil)
assert(modify_calls == calls_before)

print(extracted_framework_api and 'PASS: Arrow uses dynamically extracted installed Steamodded rank APIs'
    or 'PASS: Arrow used the explicitly labeled local Steamodded rank API contract stub')
