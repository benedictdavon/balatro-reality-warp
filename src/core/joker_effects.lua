-- Copy only the effect chain; Card objects and other referenced data stay intact.
function reality_warp_append_joker_effect(effect, bonus)
    if effect == nil then return bonus end
    local original_effect = effect
    if effect == true then effect = {remove = true} end
    if type(effect) ~= 'table' then return effect end
    local root, tail, seen = {}, nil, {}
    local source = effect
    while source ~= nil do
        -- Steamodded accepts true as the removal effect, including in extra chains.
        if source == true then source = {remove = true} end
        if type(source) ~= 'table' or seen[source] then return original_effect end
        seen[source] = true
        local copy = tail and {} or root
        for key, value in pairs(source) do
            if key ~= 'extra' then copy[key] = value end
        end
        local mt = getmetatable(source)
        if type(mt) == 'table' then setmetatable(copy, mt) end
        if tail then tail.extra = copy end
        tail = copy
        source = source.extra
    end
    tail.extra = bonus
    return root
end

function reality_warp_glitch_bonus(card, context)
    local ability = card.ability
    if context and context.joker_main and ability and ability.glitched and ability.glitch_mult and
        not card.debuff and not card.removed and not card.destroyed and not card.shattered and not card.getting_sliced and
        not (context.blueprint and not is_joker_copiable(card)) then
        return {x_mult = ability.glitch_mult,
            message = 'X' .. ability.glitch_mult .. ' Mult [Glitched]', colour = G.C.PURPLE}
    end
end

-- This wrapper is inside the activation tracker and its Blueprint/simulation gates.
if Card and Card.calculate_joker then
    local original = Card.calculate_joker
    local function pack(...) return {n = select('#', ...), ...} end
    function Card:calculate_joker(context, ...)
        local result = pack(original(self, context, ...))
        local ability = self.ability
        if context and context.joker_main and ability and not self.debuff and
            not self.removed and not self.destroyed and not self.shattered and not self.getting_sliced and
            not (context.blueprint and not is_joker_copiable(self)) then
            local function append(bonus)
                result[1] = reality_warp_append_joker_effect(result[1], bonus)
                if result[1] ~= nil then result.n = math.max(result.n, 1) end
            end
            if G.GAME and G.GAME.battle_of_gods and context.cardarea == G.jokers then
                if ability.deity_ascended then
                    append({x_mult = 2, message = 'Apotheosis! X2', colour = G.C.PURPLE})
                end
                local hand = G.GAME.hands and G.GAME.hands[context.scoring_name]
                if G.jokers and G.jokers.cards and self == G.jokers.cards[1] and hand and hand.level > 20 then
                    append({x_mult = 1.25, message = 'Exalted! X1.25', colour = G.C.GOLD})
                end
            end
            local glitch = reality_warp_glitch_bonus(self, context)
            if glitch then append(glitch) end
        end
        return unpack(result, 1, result.n)
    end
end
