local queue, definitions = {}, {}
local destroy_calls, batches, notifications = 0, {}, {}
local random_calls = {}
G = {GAME = {
    probabilities = {normal = 1},
    reality_warp_active_encounter = {id = 1, key = 'bl_reality_warp_ares', params = {target_rank = 'Ace'}},
    blind = nil
}, hand = {cards = {}}, play = {cards = {}}, playing_cards = {}, jokers = {cards = {}},
    E_MANAGER = {add_event = function(_, event) queue[#queue + 1] = event end}}

function HEX(value) return value end
function Event(event) return event end
function attention_text() end
function play_sound() end
function pseudorandom(key)
    random_calls[key] = (random_calls[key] or 0) + 1
    return 0
end
function pseudoseed(key) return key end
function pseudorandom_element(pool) return pool[1], 1 end
function ease_custom_blind_background() end
function reset_reality_warp_boss_ui() end
function reality_warp_encounter_params(key)
    local active = G.GAME.reality_warp_active_encounter
    return active and active.params or {}
end

Blind = {set_blind = function() end, defeat = function() end}
SMODS = {
    Atlas = function() end,
    Blind = function(definition)
        definition.key = 'bl_reality_warp_' .. definition.key
        definitions[definition.key] = definition
    end,
    is_eternal = function(card) return card.eternal end,
    shatters = function(card) return card.glass end,
    calculate_context = function(context)
        if not context.remove_playing_cards then return end
        for _, card in ipairs(context.removed) do
            notifications[card] = (notifications[card] or 0) + 1
            for _, area in ipairs({G.hand, G.play}) do
                local cards = area and area.cards
                local index = 1
                while cards and index <= #cards do
                    if cards[index] == card then
                        table.remove(cards, index)
                    else
                        index = index + 1
                    end
                end
            end
        end
    end,
    destroy_cards = function(cards, args)
        assert(args and args.immediate == true, 'boss destruction must use immediate supported removal')
        destroy_calls = destroy_calls + 1
        local accepted, seen = {}, {}
        batches[destroy_calls] = {}
        for _, card in ipairs(cards) do
            assert(not seen[card], 'destroy_cards received a duplicate reference')
            seen[card] = true
            batches[destroy_calls][#batches[destroy_calls] + 1] = card
            assert(not card.removed and not card.destroyed and not card.shattered and not card.getting_sliced,
                'destroy_cards received a card already being removed')
            assert(not card.eternal, 'destroy_cards received an Eternal card')
            card.getting_sliced = true
            if card.glass then
                card.shattered = true
            else
                card.destroyed = true
            end
            accepted[#accepted + 1] = card
        end
        if #accepted > 0 then
            SMODS.calculate_context({scoring_hand = cards, remove_playing_cards = true, removed = accepted})
        end
        for _, card in ipairs(accepted) do
            if card.shattered then
                card:shatter(args)
            else
                card:start_dissolve(args)
            end
        end
        return accepted
    end
}

dofile(REPO_ROOT .. '/src/core/blind_identity.lua')
dofile(REPO_ROOT .. '/src/core/blind_effects.lua')
dofile(REPO_ROOT .. '/src/blinds/boss_blinds.lua')

local function card(id, value, flags)
    local result = {id = id, base = {name = 'Card', value = value}, ability = {}}
    for key, flag in pairs(flags or {}) do result[key] = flag end
    result.start_dissolve = function(self) self.dissolve_calls = (self.dissolve_calls or 0) + 1 end
    result.shatter = function(self) self.shatter_calls = (self.shatter_calls or 0) + 1 end
    return result
end

local function activate(key, params)
    local definition = definitions['bl_reality_warp_' .. key]
    local blind = {config = {blind = definition}, effect = {}, disabled = false}
    G.GAME.blind = blind
    G.GAME.reality_warp_active_encounter = {
        id = G.GAME.reality_warp_active_encounter.id + 1,
        key = definition.key,
        params = params or {}
    }
    return definition, blind
end

local function reset_destruction()
    destroy_calls, batches, notifications, queue = 0, {}, {}, {}
end

local function assert_batch(index, expected)
    local batch = batches[index]
    assert(batch and #batch == #expected, 'unexpected destruction batch size')
    for i, expected_card in ipairs(expected) do
        assert(batch[i] == expected_card, 'unexpected card in destruction batch')
        assert(notifications[expected_card] == 1, 'each accepted playing card must notify exactly once')
    end
end

-- Ares rolls once for scoring_hand after scoring, snapshots duplicate refs, and
-- commits removal notifications before its delayed visual feedback.
reset_destruction()
local ares, ares_blind = activate('ares')
local ace, glass = card('ace', 'Ace'), card('glass', 'King', {glass = true})
local native = card('native', 'Queen', {destroyed = true})
notifications[native] = 1 -- collected and notified by the earlier native stage
local removed = card('removed', 'Jack', {removed = true})
local shattered = card('shattered', '10', {shattered = true})
local sliced = card('sliced', '9', {getting_sliced = true})
local eternal = card('eternal', '8', {eternal = true})
local ares_context = {after = true, scoring_hand = {ace, glass, ace, native, removed, shattered, sliced, eternal}}
local result = ares:calculate(ares_blind, ares_context)
assert(result and result.message == 'Ares strikes!')
assert(random_calls.ares_destroy == 1, 'Ares must make one roll per scoring hand')
assert(destroy_calls == 1, 'Ares must make one supported batch call')
assert_batch(1, {ace, glass})
assert(notifications[native] == 1, 'native destruction must not be notified a second time')
assert(ace.destroyed and glass.shattered and ace.getting_sliced and glass.getting_sliced,
    'supported destruction must commit during context.after')
assert(ace.dissolve_calls == 1 and glass.shatter_calls == 1,
    'supported destruction must preserve card animation hooks')
assert(#queue == 1, 'Ares may defer visual feedback after permanent destruction commits')
ares:calculate(ares_blind, ares_context)
assert(destroy_calls == 1 and notifications[ace] == 1 and notifications[glass] == 1,
    'a repeated after callback must not notify the same cards again')
queue[1].func()
assert(destroy_calls == 1, 'Ares visual feedback must not defer or repeat permanent removal')

-- No scoring-hand scope, disabled state, and an all-Eternal batch do no destruction.
reset_destruction()
ares, ares_blind = activate('ares')
local rolls_before = random_calls.ares_destroy or 0
ares:calculate(ares_blind, {after = true, full_hand = {card('full', 'Ace')}})
assert((random_calls.ares_destroy or 0) == rolls_before and destroy_calls == 0,
    'Ares must only roll for scoring_hand')
ares_blind.disabled = true
ares:calculate(ares_blind, {after = true, scoring_hand = {card('disabled', 'Ace')}})
assert(destroy_calls == 0, 'disabled Ares must do nothing')
ares_blind.disabled = false
ares:calculate(ares_blind, {after = true, scoring_hand = {card('eternal_1', 'Ace', {eternal = true}),
    card('eternal_2', 'King', {eternal = true})}})
assert(destroy_calls == 0, 'an all-Eternal batch must not call destroy_cards')

-- Net uses the encounter's saved target rank and reports only accepted removals.
reset_destruction()
local net, net_blind = activate('net', {target_rank = 'Ace'})
local target, other = card('target', 'Ace'), card('other', 'King')
result = net:calculate(net_blind, {after = true, scoring_hand = {target, other, target}})
assert(result and result.message == 'Trapped in Net!')
assert(destroy_calls == 1)
assert_batch(1, {target})
assert(not other.destroyed and notifications[other] == nil, 'Net must preserve nonmatching ranks')

-- Hades passes a stable held-card snapshot even when notifications mutate G.hand.cards.
reset_destruction()
local hades, hades_blind = activate('hades')
G.GAME.blind.effect.reality_warp_hades_nullify = false
local held_1, held_2, held_3 = card('held_1', 'Ace'), card('held_2', 'King'), card('held_3', 'Queen')
G.hand.cards = {held_1, held_2, held_3}
result = hades:calculate(hades_blind, {after = true})
assert(result and result.message == 'Hand Annihilated!')
assert(destroy_calls == 1)
assert_batch(1, {held_1, held_2, held_3})
assert(#G.hand.cards == 0, 'the contract stub should mutate the held-card area during notifications')

-- Disabled Net/Hades and already-in-flight destruction cannot add another notification.
reset_destruction()
net, net_blind = activate('net', {target_rank = 'Ace'})
net_blind.disabled = true
net:calculate(net_blind, {after = true, scoring_hand = {card('disabled_net', 'Ace')}})
hades, hades_blind = activate('hades')
hades_blind.disabled = true
G.hand.cards = {card('disabled_hades', 'Ace')}
hades:calculate(hades_blind, {after = true})
assert(destroy_calls == 0, 'disabled Net and Hades must do nothing')

local in_flight = card('in_flight', 'Ace', {getting_sliced = true})
assert(#reality_warp_destroy_cards(net_blind, {in_flight, in_flight}) == 0)
assert(destroy_calls == 0, 'duplicate already-sliced refs must not be submitted')
