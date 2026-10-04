-- Lucky One owns supported probability rolls, never the global RNG stream.
local lucky_key = 'j_reality_warp_lucky_one_joker'
local result_owners = setmetatable({}, {__mode = 'k'})
local game_generations = setmetatable({}, {__mode = 'k'})
local reservations = setmetatable({}, {__mode = 'k'})
local generation = 0
local active_roll
local simulation_depth = 0

local function pack(...) return {n = select('#', ...), ...} end
local function returns(values, first) return unpack(values, first or 1, values.n) end

local function run_generation(game)
    if not game then return end
    if not game_generations[game] then
        generation = generation + 1
        game_generations[game] = {id = generation, round = 0}
    end
    return game_generations[game]
end

local function simulated(context)
    if simulation_depth > 0 or SMODS.no_resolve then return true end
    if context and (context.falta_de_lectura_check or context.doppel_sim) then return true end
    for _, entry in ipairs(SMODS.context_stack or {}) do
        local c = entry.context
        if c and (c.falta_de_lectura_check or c.doppel_sim) then return true end
    end
    return false
end

local function live_lucky(card, include_debuffed)
    if not (G and G.GAME and G.jokers and G.jokers.cards and card and card.area == G.jokers) then return false end
    if card.removed or card.destroyed or card.shattered or card.getting_sliced or
        (card.debuff and not include_debuffed) then return false end
    if not (card.config and card.config.center and card.config.center.key == lucky_key and
        card.ability and type(card.ability.extra) == 'table') then return false end
    for _, owned in ipairs(G.jokers.cards) do if owned == card then return true end end
    return false
end

local function count(value)
    if type(value) ~= 'number' or value ~= value or value <= 0 or value == math.huge then return 0 end
    return math.floor(value)
end

function reality_warp_lucky_charges(card)
    local ex = card and card.ability and card.ability.extra
    if type(ex) ~= 'table' then return 0 end
    if ex.charges == nil then return ex.guaranteed and 1 or 0 end
    return count(ex.charges)
end

local function migrate(card)
    local ex = card.ability.extra
    ex.charges = reality_warp_lucky_charges(card)
    ex.guaranteed = nil
    return ex
end

local function snapshot()
    local owners = setmetatable({}, {__mode = 'k'})
    for _, card in ipairs((G and G.jokers and G.jokers.cards) or {}) do
        if live_lucky(card) then owners[card] = true end
    end
    return owners
end

local function valid_ratio(numerator, denominator)
    local function number(value)
        return type(value) == 'number' or (is_number and is_number(value))
    end
    if not number(numerator) or not number(denominator) then return false end
    local ok, valid = pcall(function()
        local ratio = numerator / denominator
        return numerator == numerator and denominator == denominator and ratio == ratio and numerator >= 0 and denominator > 0
    end)
    return ok and valid
end

local function current(frame)
    if not (frame.game and G and G.GAME == frame.game) then return false end
    local state = run_generation(frame.game)
    return state.id == frame.generation and state.round == frame.round
end

local get_vars = SMODS.get_probability_vars
function SMODS.get_probability_vars(...)
    local args = pack(...)
    local trigger_obj, numerator, denominator, identifier, from_roll, no_mod = unpack(args, 1, 6)
    local frame = active_roll
    local official = frame and not frame.preparing and not frame.prepared and from_roll and
        trigger_obj == frame.trigger and identifier == frame.identifier
    local was_preparing = frame and frame.preparing
    if official then frame.preparing = true end
    local preview = not official or simulated()
    if preview then simulation_depth = simulation_depth + 1 end
    local output = pack(pcall(get_vars, returns(args)))
    if preview then simulation_depth = simulation_depth - 1 end
    if official then frame.preparing = was_preparing end
    if not output[1] then error(output[2], 0) end

    if official then
        frame.prepared = true
        if current(frame) and not frame.simulated and not preview then
            frame.owners = snapshot()
            if not no_mod and valid_ratio(output[2], output[3]) then
                for _, card in ipairs(G.jokers.cards) do
                    if frame.owners[card] and reality_warp_lucky_charges(card) > (reservations[card] or 0) then
                        migrate(card)
                        reservations[card] = (reservations[card] or 0) + 1
                        frame.reserved = card
                        output[2], output[3] = 1, 1
                        break
                    end
                end
            end
        end
    end
    return returns(output, 2)
end

local probability = SMODS.pseudorandom_probability
function SMODS.pseudorandom_probability(...)
    local args = pack(...)
    local trigger_obj, seed, numerator, denominator, identifier, no_mod = unpack(args, 1, 6)
    local game = G and G.GAME
    local state = run_generation(game)
    local frame = {
        game = game, generation = state and state.id, round = state and state.round,
        trigger = trigger_obj, identifier = identifier or seed, simulated = simulated(),
    }
    local previous = active_roll
    local old_results = SMODS.post_prob
    local old_count = old_results and #old_results or 0
    active_roll = frame
    local output = pack(pcall(probability, returns(args)))
    active_roll = previous
    local completed = false
    local start = SMODS.post_prob == old_results and old_count + 1 or 1
    for i = start, #(SMODS.post_prob or {}) do
        local result = SMODS.post_prob[i]
        if not result_owners[result] and result.pseudorandom_result and result.trigger_obj == trigger_obj and
            result.identifier == frame.identifier then
            result_owners[result] = {
                generation = frame.generation, round = frame.round, simulated = frame.simulated,
                owners = frame.owners or setmetatable({}, {__mode = 'k'}),
                handled = setmetatable({}, {__mode = 'k'}),
            }
            completed = true
        end
    end
    local owner = frame.reserved
    if owner then
        reservations[owner] = (reservations[owner] or 1) - 1
        if reservations[owner] == 0 then reservations[owner] = nil end
        -- A completed native outcome still owns its token if an outer wrapper subsequently throws.
        if completed and current(frame) and live_lucky(owner, true) then
            local ex = migrate(owner)
            ex.charges = math.max(0, ex.charges - 1)
        end
    end
    if not output[1] then error(output[2], 0) end
    return returns(output, 2)
end

-- Falta calls Card directly; it does not necessarily push its simulation context into SMODS.
local calculate_joker = Card.calculate_joker
function Card:calculate_joker(context, ...)
    local preview = simulated(context)
    if not preview then return calculate_joker(self, context, ...) end
    simulation_depth = simulation_depth + 1
    local output = pack(pcall(calculate_joker, self, context, ...))
    simulation_depth = simulation_depth - 1
    if not output[1] then error(output[2], 0) end
    return returns(output, 2)
end

function reality_warp_lucky_scored_club(card, context)
    if not live_lucky(card) or simulated(context) or context.blueprint or context.retrigger_joker or
        context.retrigger_joker_check or context.potion_mirror_retrigger or context.potion_espejo_retrigger or
        context.repetition or not context.individual or context.cardarea ~= G.play or
        not context.other_card or not context.other_card:is_suit('Clubs') then return end
    local ex = migrate(card)
    local needed = count(ex.clubs_needed or 5)
    if needed == 0 then needed = 5 end
    ex.clubs_scored = count(ex.clubs_scored) + 1
    if ex.clubs_scored >= needed then
        ex.clubs_scored = ex.clubs_scored - needed
        ex.charges = ex.charges + 1
        return true
    end
    return false
end

function reality_warp_lucky_probability_success(card, context)
    local record = result_owners[context]
    if not (record and context.pseudorandom_result and context.result and not record.simulated and
        not simulated(context) and not context.blueprint and not context.retrigger_joker and live_lucky(card)) then return false end
    local state = run_generation(G.GAME)
    if record.generation ~= state.id or record.round ~= state.round or not record.owners[card] or record.handled[card] then return false end
    record.handled[card] = true
    local ex = migrate(card)
    ex.xmult = (ex.xmult or 1.5) + (ex.xmult_gain or 0.1)
    return true
end

function reality_warp_reset_lucky_round()
    if not (G and G.GAME) then return end
    for _, card in ipairs((G.jokers and G.jokers.cards) or {}) do
        if live_lucky(card, true) then
            local ex = migrate(card)
            ex.clubs_scored, ex.charges = 0, 0
        end
    end
    G.GAME.lucky_one_guaranteed = nil
    local state = run_generation(G.GAME)
    state.round = state.round + 1
end
