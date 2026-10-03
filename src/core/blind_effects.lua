function reality_warp_capture_encounter(blind)
    local active = G.GAME.reality_warp_active_encounter
    return {game = G.GAME, id = active and active.id, key = reality_warp_blind_key(blind)}
end

function reality_warp_encounter_owns(token)
    local active, blind = G.GAME.reality_warp_active_encounter, G.GAME.blind
    return token.game == G.GAME and active and active.id == token.id and active.key == token.key and
        active.phase ~= 'defeated' and blind and not blind.disabled and reality_warp_blind_key(blind) == token.key
end

function reality_warp_queue_blind_event(blind, spec)
    local token, callback = reality_warp_capture_encounter(blind), spec.func
    local cancelled = spec.cancelled
    spec.cancelled = nil
    spec.func = function(...)
        if not reality_warp_encounter_owns(token) then
            if cancelled then cancelled() end
            return true
        end
        return callback(...)
    end
    G.E_MANAGER:add_event(Event(spec))
end

function reality_warp_destroy_cards(blind, cards)
    if not blind or blind.disabled or not SMODS or type(SMODS.destroy_cards) ~= 'function' then return {} end

    local seen, candidates = {}, {}
    for _, card in ipairs(cards or {}) do
        if card and not seen[card] then
            seen[card] = true
            if not card.removed and not card.destroyed and not card.shattered and not card.getting_sliced then
                candidates[#candidates + 1] = card
            end
        end
    end

    if #candidates == 0 then return {} end
    return SMODS.destroy_cards(candidates, {immediate = true}) or {}
end

-- The Card use method is the sole punishment owner; the UI's later context is
-- still dispatched for ordinary consumable listeners, without a second penalty.
function reality_warp_code_consumable_used(blind, token)
    if not reality_warp_encounter_owns(token) or not reality_warp_blind_is(blind, 'code') then return end
    local candidates = {}
    for _, joker in ipairs((G.jokers and G.jokers.cards) or {}) do
        if joker.area == G.jokers and not joker.removed and not joker.destroyed and
            not joker.shattered and not joker.getting_sliced and
            not SMODS.is_eternal(joker, {destroy_cards = true}) then
            candidates[#candidates + 1] = joker
        end
    end
    if not reality_warp_encounter_owns(token) then return end
    if #candidates > 0 then
        local chosen = pseudorandom_element(candidates, pseudoseed('code_destruct'))
        if chosen and chosen.area == G.jokers and reality_warp_encounter_owns(token) then
            -- The API revalidates protection at commitment and runs destruction hooks.
            reality_warp_destroy_cards(blind, {chosen})
        end
    end
    if not reality_warp_encounter_owns(token) then return end
    blind.chips = math.floor(blind.chips * 1.25)
    blind.chip_text = number_format(blind.chips)
    if G.HUD_blind then G.HUD_blind:recalculate() end
    reality_warp_queue_blind_event(blind, {func = function()
        attention_text({text = 'Code: X1.25 Target!', scale = 0.9, hold = 1.4,
            major = G.play or G.HUD_blind, backdrop_colour = HEX('00f0ff'), align = 'cm'})
        play_sound('slice1', 0.8, 0.7)
        return true
    end})
end

function reality_warp_release_debuffs(source, cards)
    for _, card in ipairs(cards or {}) do
        if card.ability and (card.ability.debuff_sources or {})[source] then
            SMODS.debuff_card(card, false, source)
        end
    end
end

function reality_warp_clear_athena_debuffs()
    reality_warp_release_debuffs('reality_warp_athena', (G.jokers and G.jokers.cards) or {})
end

function reality_warp_clear_phone_debuffs()
    local seen = {}
    local function clear(cards)
        for _, card in ipairs(cards or {}) do
            if not seen[card] then
                seen[card] = true
                reality_warp_release_debuffs('reality_warp_phone', {card})
                if card.debuffed_by_phone then
                    card.debuffed_by_phone = nil -- old-save migration
                    SMODS.recalc_debuff(card)
                end
            end
        end
    end
    clear(G.playing_cards)
    for _, area in pairs({G.hand, G.play, G.deck, G.discard}) do if area then clear(area.cards) end end
end

local set_blind = Blind.set_blind
function Blind:set_blind(definition, reset, silent, ...)
    if not reset then
        reality_warp_clear_athena_debuffs()
        reality_warp_clear_phone_debuffs()
    end
    return set_blind(self, definition, reset, silent, ...)
end

local defeat = Blind.defeat
function Blind:defeat(...)
    local active = G.GAME.reality_warp_active_encounter
    local result = defeat(self, ...)
    if active then active.phase = 'defeated' end
    return result
end
