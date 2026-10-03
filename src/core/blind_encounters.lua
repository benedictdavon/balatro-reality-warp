-- Serialized schedules own preview parameters; runtime effect owns active penalties.
local preview_slot
local slots = {'Small', 'Big', 'Boss'}

function reality_warp_blind_category(definition)
    if reality_warp_blind_is_showdown(definition) then return 'showdown' end
    if definition and definition.reality_warp_fused then return 'fused' end
    if reality_warp_blind_is_boss(definition) then return 'boss' end
    return 'regular'
end

function reality_warp_blind_eligible(definition, category, exclude)
    local game = G.GAME
    if not definition or definition.key == exclude or (game.banned_keys or {})[definition.key] then return false end
    if reality_warp_blind_category(definition) ~= category then return false end
    if definition.key:match('^bl_reality_warp_') and is_reality_warp_boss_blinds_enabled and not is_reality_warp_boss_blinds_enabled() then return false end
    local ante = math.max(1, game.round_resets.ante or 1)
    local boss = type(definition.boss) == 'table' and definition.boss or {}
    if ante < (boss.min or 1) or ante > (boss.max or math.huge) then return false end
    -- BOTG deliberately schedules showdowns outside vanilla modulo-win-Ante rules.
    return not not SMODS.add_to_pool(definition, {battle_of_gods = game.battle_of_gods})
end

function reality_warp_blind_candidates(category, exclude)
    local pool, minimum = {}, math.huge
    local used = G.GAME.bosses_used or {}
    local counts = used.boss or used
    for key, definition in pairs(G.P_BLINDS) do
        if reality_warp_blind_eligible(definition, category, exclude) then
            local count = counts[key] or 0
            if count < minimum then pool, minimum = {}, count end
            if count == minimum then pool[#pool + 1] = key end
        end
    end
    table.sort(pool)
    return pool
end

function reality_warp_choose_blind(category, seed, exclude)
    local pool = reality_warp_blind_candidates(category, exclude)
    if #pool == 0 and exclude then pool = reality_warp_blind_candidates(category) end
    if #pool == 0 then return nil end
    return pseudorandom_element(pool, pseudoseed(seed))
end

local function parameters(key, id, migrating)
    local params = {}
    if key == 'bl_reality_warp_athena' then
        params.target_hand = migrating and 'Pair' or pseudorandom_element(
            {'Pair', 'Two Pair', 'Three of a Kind', 'Straight', 'Flush', 'Full House'}, pseudoseed('athena_encounter_' .. id))
    elseif key == 'bl_reality_warp_net' then
        params.target_rank = migrating and 'Ace' or pseudorandom_element(
            {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}, pseudoseed('net_encounter_' .. id))
    end
    if migrating then params.legacy_target_unknown = true end
    return params
end

function reality_warp_commit_blind(slot, key, migrating)
    assert(G.P_BLINDS[key], 'Reality Warp: cannot commit unknown Blind ' .. tostring(key))
    local game, resets = G.GAME, G.GAME.round_resets
    game.reality_warp_encounter_sequence = (game.reality_warp_encounter_sequence or 0) + 1
    resets.reality_warp_encounters = resets.reality_warp_encounters or {}
    local entry = {id = game.reality_warp_encounter_sequence, key = key, slot = slot,
        ante = resets.ante, category = reality_warp_blind_category(G.P_BLINDS[key])}
    entry.params = parameters(key, entry.id, migrating)
    resets.reality_warp_encounters[slot] = entry
    resets.blind_choices[slot] = key
    if G.GAME.battle_of_gods and not migrating and reality_warp_blind_is_boss(G.P_BLINDS[key]) then
        game.bosses_used = game.bosses_used or {}
        local used = game.bosses_used.boss or game.bosses_used
        used[key] = (used[key] or 0) + 1
    end
    return entry
end

local function choose_slot(slot)
    local ante = G.GAME.round_resets.ante or 1
    local seed = 'botg_' .. slot .. '_' .. ante .. '_' .. (G.GAME.reality_warp_encounter_sequence or 0)
    if slot == 'Small' and ante > 1 then
        if G.P_BLINDS.bl_big and not (G.GAME.banned_keys or {}).bl_big then return 'bl_big' end
    end
    local category = slot == 'Boss' and 'showdown' or 'boss'
    if slot == 'Big' and ante > 1 then
        local available = {}
        for _, candidate in ipairs({'boss', 'fused', 'showdown'}) do
            if #reality_warp_blind_candidates(candidate) > 0 then available[#available + 1] = candidate end
        end
        if #available > 0 then category = pseudorandom_element(available, pseudoseed(seed .. '_category')) end
    end
    local other = slot == 'Boss' and reality_warp_selected_blind_key('Big') or nil
    local key = reality_warp_choose_blind(category, seed, other)
    -- Empty categories fall back only to eligible content, never a prohibited boss.
    if not key then key = reality_warp_choose_blind('boss', seed .. '_fallback') end
    if not key then key = reality_warp_choose_blind('regular', seed .. '_regular') end
    assert(key, 'Reality Warp: all Blind pools are empty or banned')
    return key
end

function reality_warp_schedule_blinds(refresh, migrating)
    local resets = G.GAME.round_resets
    resets.blind_choices = resets.blind_choices or {}
    local entries = resets.reality_warp_encounters or {}
    for _, slot in ipairs(slots) do
        local entry, key = entries[slot], resets.blind_choices[slot]
        local state = (resets.blind_states or {})[slot]
        local new_ante = not entry or entry.ante ~= resets.ante
        local refresh_slot = refresh and state ~= 'Defeated' and state ~= 'Skipped' and state ~= 'Current'
        if new_ante or refresh_slot or not G.P_BLINDS[key] then
            if (G.GAME.battle_of_gods and not migrating) or not G.P_BLINDS[key] then key = choose_slot(slot) end
            reality_warp_commit_blind(slot, key, migrating)
        elseif entry.key ~= key then
            -- An explicit external reroll/choice replaces only its own slot.
            reality_warp_commit_blind(slot, key, migrating)
        end
        entries = resets.reality_warp_encounters
    end
    if G.GAME.battle_of_gods and resets.reality_warp_ward_ante ~= resets.ante then
        resets.reality_warp_ward_ante = resets.ante
        resets.divine_ward_free = true
    end
end

function reality_warp_encounter_params(key)
    local game = G and G.GAME
    if not game then return {} end
    local resets = game.round_resets or {}
    local entry = preview_slot and (resets.reality_warp_encounters or {})[preview_slot] or game.reality_warp_active_encounter
    if not entry then entry = (resets.reality_warp_encounters or {})[game.blind_on_deck] end
    return entry and entry.key == key and entry.params or {}
end

function reality_warp_doppelganger_target()
    if G.GAME and G.GAME.doppelganger_target then
        G.GAME.doppelganger_target_id = G.GAME.doppelganger_target.sort_id
        G.GAME.doppelganger_target = nil
    end
    local id = G.GAME and G.GAME.doppelganger_target_id
    if not id then return nil end
    for _, card in ipairs((G.jokers and G.jokers.cards) or {}) do
        if card.sort_id == id and not card.removed then return card end
    end
end

function reality_warp_with_blind_preview(slot, callback, ...)
    local previous = preview_slot
    preview_slot = slot
    local function pack(...) return {n = select('#', ...), ...} end
    local results = pack(pcall(callback, ...))
    preview_slot = previous
    if not results[1] then error(results[2], 0) end
    return unpack(results, 2, results.n)
end

local set_blind = Blind.set_blind
function Blind:set_blind(definition, reset, silent, ...)
    if definition and not reset then
        local slot, resets = reality_warp_current_slot(), G.GAME.round_resets
        local entry = (resets.reality_warp_encounters or {})[slot]
        if not entry or entry.key ~= definition.key or entry.ante ~= resets.ante then
            entry = reality_warp_commit_blind(slot, definition.key)
        end
        G.GAME.reality_warp_active_encounter = copy_table(entry)
    end
    return set_blind(self, definition, reset, silent, ...)
end

local load_blind = Blind.load
function Blind:load(saved, ...)
    local result = load_blind(self, saved, ...)
    local active = G.GAME.reality_warp_active_encounter
    if not active or active.key ~= reality_warp_blind_key(self) then
        -- Old saves never serialized these targets. Migrate explicitly without a UI RNG roll.
        local key, slot = reality_warp_blind_key(self), reality_warp_current_slot()
        if key and key ~= '' and G.P_BLINDS[key] then
            local entry = reality_warp_commit_blind(slot, key, true)
            G.GAME.reality_warp_active_encounter = copy_table(entry)
        end
    end
    local target = reality_warp_doppelganger_target()
    if target and reality_warp_blind_is(self, 'doppelganger') then target.doppelganger_reflected = true end
    self:set_text()
    return result
end
