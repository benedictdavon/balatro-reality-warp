-- Initial requirements are projections; the serialized runtime chips remain
-- authoritative after setup, including every intentional dynamic adjustment.
function reality_warp_cap_blind_target(amount, cap, as_big)
    if cap then
        local ok, exceeds = pcall(function() return (as_big and as_big(amount) or amount) > cap end)
        if ok and exceeds then return cap end
    end
    return amount
end

local function target_cap()
    if G.GAME.battle_of_gods and to_big then
        local ok, cap = pcall(to_big, '1e365')
        if ok then return cap, to_big end
    end
end

function reality_warp_target_modifiers(preview)
    local game = G.GAME
    local vouchers = game.used_vouchers or {}
    local hubris = get_botg_godly_hubris_multiplier and get_botg_godly_hubris_multiplier() or 1
    local cap, as_big = target_cap()
    local walls, seen = 0, {}
    if preview then
        local areas = SMODS.get_card_areas and SMODS.get_card_areas('jokers') or {G.jokers}
        for _, area in ipairs(areas) do
            for _, card in ipairs(area.cards or {}) do
                if not seen[card] then
                    seen[card] = true
                    if card.ability and card.ability.possessed_wall and not card.removed and
                        (card.can_calculate and card:can_calculate() or
                            (not card.can_calculate and not card.debuff and not card.getting_sliced)) then
                        walls = walls + 1
                    end
                end
            end
        end
    end
    return {botg = game.battle_of_gods, stake = (game.starting_params or {}).ante_scaling or 1,
        rod = game.stick_penalty, hubris = hubris,
        nectar = vouchers.v_reality_warp_nectar or vouchers.v_nectar or vouchers.nectar,
        walls = walls, cap = cap, as_big = as_big}
end

-- Pure given base, registered definition and modifier snapshot; no slot flags,
-- RNG, inventory changes or shared definition writes participate in the formula.
function reality_warp_calculate_blind_target(base, definition, modifiers)
    definition = definition or {}
    local mult = definition.mult or 0
    if modifiers.botg and reality_warp_blind_is_showdown(definition) then
        local key = definition.key
        mult = (key == 'bl_final_vessel' or key == 'bl_reality_warp_chronos') and 8 or 5
    end
    local amount = base * mult * modifiers.stake
    if modifiers.rod then amount = math.floor(amount * modifiers.rod) end
    if modifiers.botg and reality_warp_blind_is_boss(definition) and modifiers.hubris > 1 then
        amount = math.floor(amount * modifiers.hubris)
    end
    if modifiers.nectar then amount = math.max(1, math.floor(amount * 0.95)) end
    for _ = 1, modifiers.walls do amount = amount * 2 end
    return reality_warp_cap_blind_target(amount, modifiers.cap, modifiers.as_big)
end

function reality_warp_initial_blind_target(definition, ante, preview)
    return reality_warp_calculate_blind_target(get_blind_amount(ante), definition,
        reality_warp_target_modifiers(preview))
end

function reality_warp_preview_blind_target(definition, ante, slot)
    local game = G.GAME
    local active = game.reality_warp_active_encounter
    local scheduled = ((game.round_resets or {}).reality_warp_encounters or {})[slot]
    if active and scheduled and active.id == scheduled.id and active.slot == slot and
        active.key == definition.key and active.phase ~= 'defeated' and game.blind and game.blind.in_blind and
        reality_warp_blind_key(game.blind) == definition.key then
        return game.blind.chips
    end
    return reality_warp_initial_blind_target(definition, ante, true)
end

function reality_warp_wall_blind_target(amount)
    local cap, as_big = target_cap()
    return reality_warp_cap_blind_target(amount * 2, cap, as_big)
end
