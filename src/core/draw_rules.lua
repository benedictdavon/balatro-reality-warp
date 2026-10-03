function reality_warp_owned_possession(card, key)
    if not card or card.area ~= G.jokers or not card.ability or not card.ability[key] or
        card.debuff or card.removed or card.destroyed or card.shattered or card.getting_sliced then return false end
    for _, joker in ipairs((G.jokers and G.jokers.cards) or {}) do
        if joker == card then return true end
    end
    return false
end

local function action_marker()
    local game = G.GAME
    local active = game and game.reality_warp_active_encounter
    local round = game and game.current_round
    if not game or not game.facing_blind or not active or active.phase == 'defeated' or not round or
        active.key ~= reality_warp_blind_key(game.blind) then return end
    return {id = active.id, key = active.key, hands = round.hands_played or 0,
        discards = round.discards_used or 0}
end

local function same_action(a, b)
    return a and b and a.id == b.id and a.key == b.key and a.hands == b.hands and a.discards == b.discards
end

local explicit_draw = false
function reality_warp_fixed_action_draw()
    local marker = action_marker()
    if explicit_draw or not marker or G.STATE ~= G.STATES.DRAW_TO_HAND or
        (marker.hands == 0 and marker.discards == 0) then return false end
    local blind = G.GAME.blind
    if blind and not blind.disabled and reality_warp_blind_is(blind, 'ouroboros') then return true end
    for _, joker in ipairs((G.jokers and G.jokers.cards) or {}) do
        if reality_warp_owned_possession(joker, 'possessed_serpent') then return true end
    end
    return false
end

-- Keep serialized Card IDs for a cold restart during a partially drained draw.
-- The private reservation prevents same-process duplicate calls, even when
-- Negative Cards make the native pending slot counter zero.
local pending_actions = setmetatable({}, {__mode = 'k'})
function reality_warp_prepare_action_draw(cards, amount)
    if not reality_warp_fixed_action_draw() then return cards, amount end
    local marker = action_marker()
    local saved = G.GAME.reality_warp_action_draw_plan
    if same_action(pending_actions[G.GAME], marker) then return {}, 0 end
    local selected = {}
    if same_action(saved, marker) then
        for _, id in ipairs(saved.cards or {}) do
            for _, card in ipairs(G.deck.cards) do
                if (id.sort_id ~= nil and card.sort_id == id.sort_id) or
                    (id.sort_id == nil and id.playing_card ~= nil and card.playing_card == id.playing_card) then
                    selected[#selected + 1] = card
                    break
                end
            end
        end
    else
        marker.cards = {}
        for i = #G.deck.cards, math.max(1, #G.deck.cards - 2), -1 do
            local card = G.deck.cards[i]
            selected[#selected + 1] = card
            marker.cards[#marker.cards + 1] = {sort_id = card.sort_id, playing_card = card.playing_card}
        end
        G.GAME.reality_warp_action_draw_plan = marker
    end
    pending_actions[G.GAME] = marker
    return selected, #selected
end

local pack = function(...) return {n = select('#', ...), ...} end
local modifies_draw = SMODS.blind_modifies_draw
function SMODS.blind_modifies_draw(...)
    local result = pack(modifies_draw(...))
    if select(1, ...) == reality_warp_blind_key(G.GAME and G.GAME.blind) and reality_warp_fixed_action_draw() then
        result[1] = true
        result.n = math.max(result.n, 1)
    end
    return unpack(result, 1, result.n)
end

function reality_warp_draw_water_cards(card, context)
    if not context.before or context.blueprint or context.individual or context.repetition or context.retrigger_joker or
        not reality_warp_owned_possession(card, 'possessed_water') then return end
    local marker = action_marker()
    if not marker or same_action(card.ability.reality_warp_water_draw_action, marker) then return end
    card.ability.reality_warp_water_draw_action = marker
    local previous = explicit_draw
    explicit_draw = true
    local result = pack(pcall(SMODS.draw_cards, 4))
    explicit_draw = previous
    if not result[1] then error(result[2], 0) end
    return unpack(result, 2, result.n)
end

local function contains(area, card)
    for _, candidate in ipairs((area and area.cards) or {}) do
        if candidate == card then return true end
    end
    return false
end

function reality_warp_hook_discard(card, context)
    if not context.before or context.blueprint or context.individual or context.repetition or context.retrigger_joker or
        not reality_warp_owned_possession(card, 'possessed_hook') then return end
    local marker, game = action_marker(), G.GAME
    if not marker or same_action(card.ability.reality_warp_hook_discard_action, marker) then return end
    card.ability.reality_warp_hook_discard_action = marker
    local hand, discard, pool, seen = G.hand, G.discard, {}, {}
    for _, target in ipairs((hand and hand.cards) or {}) do
        if not seen[target] and target.area == hand and not target.removed and not target.destroyed and
            not target.shattered and not target.getting_sliced then
            seen[target] = true
            pool[#pool + 1] = target
        end
    end
    local count = 0
    for _ = 1, math.min(2, #pool) do
        local target = pseudorandom_element(pool, pseudoseed('hook_disc'))
        for i = #pool, 1, -1 do if pool[i] == target then table.remove(pool, i) end end
        if game ~= G.GAME or not same_action(marker, action_marker()) or
            not reality_warp_owned_possession(card, 'possessed_hook') then break end
        if discard and contains(hand, target) and target.area == hand and not target.removed and not target.destroyed and
            not target.shattered and not target.getting_sliced then
            local moved = hand:remove_card(target)
            if moved == target and not contains(hand, target) and not target.area and not target.removed and not target.destroyed then
                discard:emplace(target)
                if target.area == discard and contains(discard, target) then count = count + 1 end
            end
        end
    end
    if game == G.GAME and same_action(marker, action_marker()) and reality_warp_owned_possession(card, 'possessed_hook') then
        card.ability.hook_bonus = 1 + count * 0.75
    end
end
