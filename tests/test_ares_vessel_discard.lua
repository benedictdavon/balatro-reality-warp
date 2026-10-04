local function read(path)
    local file = assert(io.open(path, 'r'), path)
    local source = file:read('*a')
    file:close()
    return source
end

local function section(source, start_marker, end_marker)
    local first = assert(source:find(start_marker, 1, true), start_marker)
    local last = assert(source:find(end_marker, first + #start_marker, true), end_marker)
    return source:sub(first, last - 1)
end

local native_blind = read(REPO_ROOT .. '/../lovely/dump/blind.lua')
local native_press_play = section(native_blind, 'function Blind:press_play()', '\nfunction Blind:modify_hand(')
local smods_overrides = read(REPO_ROOT .. '/../smods/src/overrides.lua')
local press_play_dispatch = section(smods_overrides, 'local press_play = Blind.press_play', '\nlocal debuff_card = Blind.debuff_card')
local native_game = read(REPO_ROOT .. '/../lovely/dump/game.lua')
local smods_attributes = read(REPO_ROOT .. '/../smods/src/game_objects/attributes.lua')
assert(native_game:find("bl_final_vessel =", 1, true) and native_game:find("name = 'Violet Vessel'", 1, true),
    'installed native Violet Vessel registration/key changed')
assert(smods_attributes:find("'bl_final_vessel'", 1, true), 'Steamodded Violet Vessel key is missing')
assert(not smods_attributes:find("'bl_vessel'", 1, true), 'do not use the nonexistent native bl_vessel alias')

local definitions, stickers = {}, {}
-- Load the real native record; its key and metadata come from registration.
function HEX(colour) return colour end
local vessel_line = assert(native_game:match('([^\n]*bl_final_vessel =[^\n]*)'))
local native_definitions = assert(loadstring('return {' .. vessel_line .. '}'))()
native_definitions.bl_final_vessel.key = 'bl_final_vessel'
definitions.bl_final_vessel = native_definitions.bl_final_vessel
local queue, contexts, destruction_calls = {}, {}, {}
local roll_success, probability_calls = false, 0
local function area()
    return {
        cards = {}, highlighted = {},
        add_to_highlighted = function(self, card) self.highlighted[#self.highlighted + 1] = card end,
        remove_card = function(self, target)
            for i, card in ipairs(self.cards) do
                if card == target then
                    table.remove(self.cards, i)
                    card.area = nil
                    return card
                end
            end
        end,
        emplace = function(self, card)
            self.cards[#self.cards + 1] = card
            card.area = self
        end
    }
end

G = {C = {PURPLE = 'purple', RED = 'red'}, STATES = {}, FUNCS = {}}
Blind = {set_blind = function() end, defeat = function() end}
G.E_MANAGER = {add_event = function(_, event) queue[#queue + 1] = event end}
function Event(spec) return spec end
function HEX(colour) return colour end
function delay() end
function play_sound() end
function attention_text() end
function pseudoseed(seed) return seed end
function pseudorandom_element(pool, seed)
    assert(seed == 'hook' or seed == 'hook_disc')
    return pool[1], 1
end

local function remove_card(from, target)
    for i, card in ipairs(from.cards) do
        if card == target then
            table.remove(from.cards, i)
            card.area = nil
            return card
        end
    end
end

local function move_highlighted_to_discard()
    local selected = G.hand.highlighted
    for _, card in ipairs(selected) do
        if card.area == G.hand then
            remove_card(G.hand, card)
            card.area = G.discard
            G.discard.cards[#G.discard.cards + 1] = card
        end
    end
    G.hand.highlighted = {}
    G.GAME.current_round.discards_used = G.GAME.current_round.discards_used + 1
end

G.FUNCS.discard_cards_from_highlighted = move_highlighted_to_discard
SMODS = {
    Blind = function(definition)
        if not definition.key:match('^bl_') then definition.key = 'bl_reality_warp_' .. definition.key end
        definitions[definition.key] = definition
    end,
    Sticker = function(definition) stickers[definition.key] = definition end,
    blind_modifies_draw = function() return false end,
    juice_up_blind = function() end,
    pseudorandom_probability = function(_, seed, numerator, denominator)
        assert(seed == 'ares_destroy' and numerator == 1 and denominator == 5)
        probability_calls = probability_calls + 1
        return roll_success
    end,
    destroy_cards = function(cards, options)
        assert(options.immediate == true, 'Ares must use the supported immediate destruction contract')
        destruction_calls[#destruction_calls + 1] = cards
        for _, card in ipairs(cards) do card.destroyed = true end
        return cards
    end
}

function SMODS.calculate_context(context)
    contexts[#contexts + 1] = context
    local key = reality_warp_blind_key(G.GAME and G.GAME.blind)
    local definition = definitions[key]
    if definition and definition.calculate then
        definition:calculate(G.GAME.blind, context)
    end
    -- This small sink models the later Joker-before pass only; the actual
    -- possessed Hook callback and transfer helper are loaded from source below.
    if context.before then
        for _, joker in ipairs((G.jokers and G.jokers.cards) or {}) do
            if joker.ability and joker.ability.possessed_hook then
                stickers.possessed_hook:calculate(joker, context)
            end
        end
    end
    return {}
end

dofile(REPO_ROOT .. '/src/core/blind_identity.lua')
dofile(REPO_ROOT .. '/src/core/blind_effects.lua')
dofile(REPO_ROOT .. '/src/core/draw_rules.lua')

local boss_source = read(REPO_ROOT .. '/src/blinds/boss_blinds.lua')
assert(loadstring(section(boss_source, '-- 13. Ares (Supreme Showdown Boss)', '-- 14. Athena (Supreme Showdown Boss)')))()
local fused_source = read(REPO_ROOT .. '/src/blinds/fused_blinds.lua')
assert(loadstring(section(fused_source, '-- 2. The Minotaur (Ox + Hook)', '-- 3. The Fortress (Wall + Flint)')))()
local possession_source = read(REPO_ROOT .. '/src/core/botg_possession.lua')
assert(loadstring(section(possession_source, 'SMODS.Sticker {\n    key = "possessed_hook"', '-- 5. Possessed: The Psychic')))()

assert(loadstring(native_press_play, 'installed Blind:press_play'))()
assert(loadstring(press_play_dispatch, 'installed Steamodded press_play dispatch'))()

local function make_card(id, owner)
    local card = {id = id, area = owner, ability = {}}
    owner.cards[#owner.cards + 1] = card
    return card
end

local function reset(key, name, held, disabled)
    queue, contexts, destruction_calls = {}, {}, {}
    probability_calls, roll_success = 0, false
    G.hand, G.play, G.discard, G.jokers = area(), area(), area(), area()
    local definition = definitions[key] or {key = key}
    local blind = setmetatable({config = {blind = definition}, name = name, disabled = disabled or false}, {__index = Blind})
    G.GAME = {
        facing_blind = true,
        blind = blind,
        current_round = {hands_played = 1, discards_used = 0},
        reality_warp_active_encounter = {id = 1, key = key, phase = 'active'}
    }
    for i = 1, held or 0 do make_card('held-' .. i, G.hand) end
    return blind
end

local function discard_count()
    return #G.discard.cards
end

-- The installed native and Steamodded press-play wrappers dispatch the active
-- Blind's calculate callback. Violet Vessel's actual canonical key has no such
-- Reality Warp callback and no native Hook name branch.
local violet = reset('bl_final_vessel', 'Violet Vessel', 5)
assert(violet:press_play() == nil)
assert(#queue == 0 and discard_count() == 0, 'Violet Vessel must not discard held cards')
assert(#contexts == 1 and contexts[1].press_play, 'Steamodded must dispatch the native press-play context')
SMODS.calculate_context({before = true})
assert(#queue == 0 and discard_count() == 0)

local ares = reset('bl_reality_warp_ares', 'Ares', 5)
assert(ares:press_play() == nil)
assert(#queue == 0 and discard_count() == 0, 'Ares has no held-card press-play penalty')
assert(#contexts == 1 and contexts[1].press_play)

-- Ares is an independent after-scoring destruction path over scoring_hand.
-- The 1-in-5 failure is a negative control; success destroys only scored cards
-- synchronously and queues feedback, never a random held-card discard.
local scored = make_card('scored', G.play)
local unscored = G.hand.cards[1]
local failed = definitions.bl_reality_warp_ares:calculate(ares, {after = true, scoring_hand = {scored}})
assert(failed == nil and #destruction_calls == 0 and discard_count() == 0)
roll_success = true
local success = definitions.bl_reality_warp_ares:calculate(ares, {after = true, scoring_hand = {scored}})
assert(success and success.message == 'Ares strikes!')
assert(#destruction_calls == 1 and #destruction_calls[1] == 1 and destruction_calls[1][1] == scored)
assert(scored.destroyed and not unscored.destroyed and discard_count() == 0)
assert(#queue == 1, 'only the delayed feedback event follows the committed scoring-card destruction')

-- Native/SMODS routing into the current Minotaur callback is a positive
-- Hook-like control. Its two held cards are selected without replacement.
local minotaur = reset('bl_reality_warp_minotaur', 'The Minotaur', 5)
assert(minotaur:press_play() == nil)
assert(#contexts == 1 and contexts[1].press_play and #queue == 1)
queue[1].func()
assert(discard_count() == 2 and #G.hand.cards == 3)
assert(G.discard.cards[1] ~= G.discard.cards[2], 'Minotaur must select distinct physical cards')

local function queued_minotaur_transition(transition)
    local blind = reset('bl_reality_warp_minotaur', 'The Minotaur', 5)
    blind:press_play()
    local queued = queue[1]
    assert(queued and #G.hand.cards == 5)
    transition(blind)
    queued.func()
    assert(discard_count() == 0 and #G.hand.cards == 5,
        'a stale Minotaur event must not discard from a later state')
end

queued_minotaur_transition(function(blind) blind.disabled = true end)
queued_minotaur_transition(function(blind) blind:defeat() end)
queued_minotaur_transition(function()
    G.GAME.reality_warp_active_encounter = {id = 2, key = 'bl_reality_warp_minotaur', phase = 'active'}
end)
queued_minotaur_transition(function(blind)
    -- Reuse the runtime object with a new active ID/key, as can happen while a
    -- delayed event is still pending across an encounter transition.
    blind.config.blind = {key = 'bl_final_vessel'}
    G.GAME.reality_warp_active_encounter = {id = 2, key = 'bl_final_vessel', phase = 'active'}
end)

-- Vanilla Hook is an independent native positive control: the actual installed
-- Blind:press_play branch schedules and discards two cards. No RW callback is
-- responsible for this legacy Boss behavior.
local hook = reset('bl_hook', 'The Hook', 5)
assert(hook:press_play() == true)
assert(#queue == 1 and #contexts == 1 and contexts[1].press_play)
queue[1].func()
assert(discard_count() == 2 and #G.hand.cards == 3)
assert(G.discard.cards[1] ~= G.discard.cards[2])

-- Possessed Hook is a separate Joker-before owner, including while Chicot has
-- disabled the current Blind. Repeating the same action context is idempotent.
local disabled_violet = reset('bl_final_vessel', 'Violet Vessel', 5, true)
local possessed_hook = make_card('possessed-hook', G.jokers)
possessed_hook.ability.possessed_hook = true
SMODS.calculate_context({before = true})
assert(discard_count() == 2 and #G.hand.cards == 3 and possessed_hook.ability.hook_bonus == 2.5)
SMODS.calculate_context({before = true})
assert(discard_count() == 2 and #G.hand.cards == 3, 'same owned possession action must not discard twice')
assert(disabled_violet.disabled, 'positive control intentionally keeps the Blind disabled')

print('PASS: Ares/Violet have no Hook discard path; native Hook, Minotaur and possessed Hook owners remain distinct')
