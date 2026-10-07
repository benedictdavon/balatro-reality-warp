-- Source-contract tests, not Balatro execution. Native UI, Card geometry and
-- FIFO event dispatch are adapters; installed functions are read at test time.
local function read(path)
    local file = io.open(REPO_ROOT .. '/' .. path, 'r')
    if not file then return nil end
    local value = file:read('*a'); file:close(); return value
end
local function section(source, first, following)
    local a = assert(source:find(first, 1, true), first)
    local b = assert(source:find(following, a + #first, true), following)
    return source:sub(a, b - 1)
end
local function load(source, env)
    local fn = assert(loadstring(source)); setfenv(fn, env); return fn()
end
local function pack(...) return {n = select('#', ...), ...} end
local function copy(value)
    if type(value) ~= 'table' then return value end
    local result = {}; for k, v in pairs(value) do result[k] = copy(v) end; return result
end
local function encode(value)
    if type(value) == 'string' then return string.format('%q', value) end
    if type(value) ~= 'table' then return tostring(value) end
    local fields = {}
    for k, v in pairs(value) do fields[#fields + 1] = '[' .. encode(k) .. ']=' .. encode(v) end
    table.sort(fields); return '{' .. table.concat(fields, ',') .. '}'
end
local battle = assert(read('src/core/battle_of_gods.lua'))
local encounters = assert(read('src/core/blind_encounters.lua'))
local wrappers = section(battle, '-- Intercept the framework', '-- Mechanic 24:')
local amount = section(battle, 'local botg_ante_bases', '-- Target initialization lives')
local cycle = section(battle, 'G.FUNCS.confirm_battle_of_gods =', '\nlocal function find_endless_node')
local native_events = read('../lovely/game-dump/functions/common_events.lua')
local native_card = read('../lovely/game-dump/card.lua')
local native_smods = read('../smods/src/game_objects/blind.lua')
local native_overrides = read('../smods/src/overrides.lua')

local function env_new(ante, botg, native)
    local env = setmetatable({}, {__index = _G})
    env.copy_table = copy
    env.G = {GAME = {battle_of_gods = botg, blind_on_deck = 'Small', banned_keys = {}, bosses_used = {},
        starting_params = {ante_scaling = 1}, used_vouchers = {}, current_round = {},
        round_resets = {ante = ante, blind_ante = ante, hands = 4, discards = 3,
            blind_choices = {}, blind_tags = {Small = 'tag_negative', Big = 'tag_double'},
            blind_states = {Small = 'Upcoming', Big = 'Upcoming', Boss = 'Upcoming'}}},
        P_BLINDS = {bl_small = {key = 'bl_small', mult = 1}, bl_big = {key = 'bl_big', big = true, mult = 1.5},
            bl_hook = {key = 'bl_hook', boss = {min = 1}, mult = 2},
            bl_reality_warp_athena = {key = 'bl_reality_warp_athena', boss = {min = 1, showdown = true}, mult = 2},
            bl_reality_warp_net = {key = 'bl_reality_warp_net', boss = {min = 1, showdown = true}, mult = 2}},
        jokers = {cards = {}}, P_CENTERS = {}, FUNCS = {}, SETTINGS = {paused = true}, STATES = {SHOP = 'shop'},
        C = {IMPORTANT = {}, RED = {}}, vouchers = {T = {x = 0, y = 0}, emplace = function() end}}
    env.queue, env.rolls, env.lower_choices, env.lower_reset, env.contexts = {}, 0, 0, 0, {}
    env.Event = function(spec) return spec end
    env.G.E_MANAGER = {add_event = function(_, event) env.queue[#env.queue + 1] = event end}
    env.pseudoseed = function(seed) env.rolls = env.rolls + 1; return seed end
    env.pseudorandom_element = function(pool) return pool[1] end
    env.is_reality_warp_boss_blinds_enabled = function() return true end
    env.SMODS = {add_to_pool = function() return true end,
        enh_cache = {clear = function() end}, calculate_context = function(context)
            env.contexts[#env.contexts + 1] = copy(context); return {}
        end}
    env.SMODS.get_new_blind = function(slot)
        env.lower_choices = env.lower_choices + 1
        return ({small = 'bl_small', big = 'bl_big', boss = 'bl_hook'})[slot]
    end
    env.Card = {}
    env.Blind = {set_blind = function(self, definition, reset, silent, ...)
        env.setup_args = pack(definition, reset, silent, ...)
        self.config = {blind = definition}; self.in_blind = true
        if not reset then self.chips = env.reality_warp_initial_blind_target(definition, env.G.GAME.round_resets.blind_ante) end
        return 'setup', nil, false, nil
    end, load = function(self, saved, ...)
        env.load_args = pack(saved, ...); self.config = {blind = env.G.P_BLINDS[saved.key]}; self.chips = saved.chips
        self.in_blind = true; return 'load', nil, false, nil
    end, set_text = function() end}
    env.get_blind_amount = function(...) env.amount_args = pack(...); return 300, nil, 'native', nil end
    env.get_nursery_selected_fam = function() return nil end
    env.unlock_colosseum_champion = function() end
    env.ease_chips, env.apply_battle_of_gods_bg = function() end, function() end
    env.ease_hands_played = function(n) env.hand_cost = n end
    env.ease_discard = function(n) env.discard_cost = n end
    env.copy_card = function() return {VT = {}} end
    env.get_next_tag_key = function() return 'tag_uncommon' end
    if native then
        load(section(native_smods, 'function SMODS.reset_blind_choices(choices)', '\nend') .. '\nend', env)
        load(section(native_events, 'function reset_blinds()', '\nfunction get_new_boss'), env)
        load(section(native_events, 'function ease_ante(mod)', '\nfunction ease_round'), env)
        load(section(native_overrides, 'local ease_ante_ref = ease_ante', '\nlocal eval_card_ref'), env)
        load(section(native_card, 'function Card:apply_to_run(center)', '\nfunction Card:explode'), env)
        -- Rendering, notification, numeric formatting adapters for native ease_ante.
        local text = {scale = 1, config = {scale = 1}, update_text = function() end, align_letters = function() end}
        env.G.hand_text_area = {ante = {config = {object = text}, parent = {}}}
        env.G.HUD = {recalculate = function() end}
        env.Talisman = {}; env.number_format = tostring
        env.check_and_set_high_score, env.attention_text, env.play_sound = function() end, function() end, function() end
    else
        env.SMODS.reset_blind_choices = function(choices, ...)
            env.choice_args = pack(choices, ...)
            choices.Small, choices.Big, choices.Boss = 'bl_small', 'bl_big', 'bl_hook'
            return 'choices', nil, false, nil
        end
        env.reset_blinds = function(...) env.reset_args = pack(...); return 'reset', nil, false, nil end
    end
    load(assert(read('src/core/blind_identity.lua')), env)
    load(encounters, env)
    load(section(battle, 'function get_botg_godly_hubris_multiplier()', '-- UI reads committed slots'), env)
    load(assert(read('src/core/blind_targets.lua')), env)
    load(amount, env); load(wrappers, env)
    return env
end
local function drain(env)
    while #env.queue > 0 do local event = table.remove(env.queue, 1); assert(not event.func or event.func()) end
end
local function protected_snapshot(env)
    local game = env.G.GAME
    return encode({entries = game.round_resets.reality_warp_encounters, choices = game.round_resets.blind_choices,
        states = game.round_resets.blind_states, tags = game.round_resets.blind_tags, active = game.reality_warp_active_encounter,
        used = game.bosses_used, sequence = game.reality_warp_encounter_sequence, slot = game.blind_on_deck,
        ward = game.round_resets.divine_ward_free, generation = game.round_resets.reality_warp_schedule_generation})
end

-- Cross-VM entry point used by test_ante_cold_restart.py (no game/disk save codec).
if ANTE_COLD_IMPORT then
    local env = env_new(1, true, false)
    env.G.GAME = load('return ' .. ANTE_COLD_IMPORT, env)
    local game = env.G.GAME; local before, rolls = protected_snapshot(env), env.rolls
    env.reality_warp_schedule_blinds(false)
    assert(protected_snapshot(env) == before and env.rolls == rolls)
    local blind = setmetatable({}, {__index = env.Blind})
    local result = pack(blind:load({key = game.reality_warp_active_encounter.key, chips = 777}, 'extra', nil))
    assert(result.n == 4 and result[1] == 'load' and result[3] == false and result[4] == nil)
    assert(env.load_args.n == 3 and env.load_args[2] == 'extra' and env.load_args[3] == nil)
    assert(not game.round_resets.divine_ward_free and protected_snapshot(env) == before)
    print('PASS: fresh-VM serialized schedule/targets/consumed Ward reconstruction (not native disk/game restart)')
    return
end

local env = env_new(8, true, false)
env.reality_warp_schedule_blinds(false)
local game, resets = env.G.GAME, env.G.GAME.round_resets
env.reality_warp_commit_blind('Big', 'bl_reality_warp_net')
resets.reality_warp_encounters.Big.params.target_rank = 'Queen'
resets.reality_warp_encounters.Boss.params.target_hand = 'Flush'
resets.divine_ward_free = false
game.blind_on_deck = 'Big'
local runtime = setmetatable({}, {__index = env.Blind}); game.blind = runtime
runtime:set_blind(env.G.P_BLINDS.bl_reality_warp_net, false, true, 'extra', nil)
assert(env.setup_args.n == 5 and env.setup_args[4] == 'extra')
game.reality_warp_active_encounter.phase = 'active'
for _, state in ipairs({'Defeated', 'Skipped', 'Current', 'Upcoming'}) do
    resets.blind_states = {Small = state, Big = state, Boss = state}
    local before, rolls = protected_snapshot(env), env.rolls
    resets.ante, resets.blind_ante = 7, 7
    env.reality_warp_schedule_blinds(false)
    assert(protected_snapshot(env) == before and env.rolls == rolls, 'difficulty edit changed ownership: ' .. state)
end
local old_id = resets.reality_warp_encounters.Big.id
local result = pack(runtime:set_blind(env.G.P_BLINDS.bl_reality_warp_net, false, true))
assert(result.n == 4 and result[3] == false and resets.reality_warp_encounters.Big.id == old_id)
runtime.chips = 777 -- dynamic runtime chips are authoritative at active preview.
assert(env.reality_warp_preview_blind_target(env.G.P_BLINDS.bl_reality_warp_net, 0, 'Big') == 777)
assert(env.get_blind_amount(0) == 5000 and env.get_blind_amount(-1) == 5000 and env.get_blind_amount(1) == 15000)
local bases = {15000, 60000, 300000, 1800000, 15000000, 150000000, 2100000000, 36000000000}
-- Accepted positive BOTG curve, including its no-extension numeric fallback.
for a = 1, 8 do assert(env.get_blind_amount(a) == bases[a]) end
for a = 9, 23 do
    local log = 10.55630 + 354.14267 * (((a - 8) / 16) ^ 1.35)
    local exponent = math.floor(log)
    local expected = exponent < 308 and math.floor((10 ^ (log - exponent)) * 10 ^ exponent) or 1e300
    assert(env.get_blind_amount(a) == expected)
end
assert(env.get_blind_amount(24) == 1e300 and env.get_blind_amount(25) == 1e300)
local preserved = copy(game); preserved.blind = nil
ANTE_COLD_EXPORT = encode(preserved)

-- Old saves acquire metadata without reroll or allowance refund, even at edited Ante.
for _, free in ipairs({false, true}) do
    local old = env_new(7, true, false); old.G.GAME = copy(preserved)
    local r = old.G.GAME.round_resets
    r.reality_warp_schedule_generation, r.reality_warp_ward_generation = nil, nil
    r.divine_ward_free, r.reality_warp_ward_ante = free, 8
    for _, entry in pairs(r.reality_warp_encounters) do entry.schedule_generation = nil end
    old.G.GAME.reality_warp_active_encounter.schedule_generation = nil
    local entries, sequence = encode(r.reality_warp_encounters), old.G.GAME.reality_warp_encounter_sequence
    old.reality_warp_schedule_blinds(false)
    assert(r.divine_ward_free == free and old.rolls == 0 and old.G.GAME.reality_warp_encounter_sequence == sequence)
    for _, entry in pairs(r.reality_warp_encounters) do assert(entry.schedule_generation == 1); entry.schedule_generation = nil end
    assert(encode(r.reality_warp_encounters) == entries)
end
local explicit_consumed = env_new(1, true, false)
explicit_consumed.G.GAME.round_resets.divine_ward_free = false
explicit_consumed.reality_warp_schedule_blinds(false)
assert(not explicit_consumed.G.GAME.round_resets.divine_ward_free)

-- A single explicit reroll and partial upcoming refresh change only eligible slots.
resets.blind_states = {Small = 'Defeated', Big = 'Skipped', Boss = 'Upcoming'}
local small, big, boss, generation = resets.reality_warp_encounters.Small.id,
    resets.reality_warp_encounters.Big.id, resets.reality_warp_encounters.Boss.id, resets.reality_warp_schedule_generation
resets.blind_choices.Boss = 'bl_reality_warp_net'
env.reality_warp_schedule_blinds(false)
assert(resets.reality_warp_encounters.Boss.id ~= boss and resets.reality_warp_encounters.Small.id == small)
env.reality_warp_schedule_blinds(true)
assert(resets.reality_warp_encounters.Small.id == small and resets.reality_warp_encounters.Big.id == big)
assert(resets.reality_warp_schedule_generation == generation and not resets.divine_ward_free)

-- Changed normal wrappers preserve all input positions and nil-inclusive results.
local normal = env_new(1, false, false)
local choices = normal.G.GAME.round_resets.blind_choices
result = pack(normal.SMODS.reset_blind_choices(choices, 'extra', nil, false))
assert(result.n == 4 and result[1] == 'choices' and result[3] == false)
assert(normal.choice_args.n == 4 and normal.choice_args[2] == 'extra' and normal.choice_args[4] == false)
result = pack(normal.reset_blinds('extra', nil, false))
assert(result.n == 4 and result[1] == 'reset' and result[3] == false)
assert(normal.reset_args.n == 3 and normal.reset_args[3] == false)
result = pack(normal.get_blind_amount(0, nil, false))
assert(result.n == 4 and result[1] == 300 and result[3] == 'native' and normal.amount_args.n == 3)

if native_events and native_card and native_smods and native_overrides then
    for _, ante in ipairs({1, 5}) do
        for _, voucher in ipairs({'Hieroglyph', 'Petroglyph'}) do
            local n = env_new(ante, true, true)
            n.SMODS.reset_blind_choices(n.G.GAME.round_resets.blind_choices)
            local g, r = n.G.GAME, n.G.GAME.round_resets
            g.blind_on_deck = 'Big'; r.blind_states.Small, r.blind_states.Big = 'Defeated', 'Current'
            r.divine_ward_free = false
            local before, rolls = protected_snapshot(n), n.rolls
            local active = setmetatable({}, {__index = n.Blind}); g.blind = active
            active:set_blind(n.G.P_BLINDS[r.blind_choices.Big], false, true)
            active.chips = 777; before = protected_snapshot(n)
            local center = {name = voucher, config = {extra = 1}}
            n.Card.apply_to_run({config = {center = center}}, center)
            assert(r.ante == ante and r.blind_ante == ante - 1 and #n.queue == 1)
            assert(n.contexts[1].modify_ante == -1 and n.contexts[2].ante_change == -1)
            local boss_definition = n.G.P_BLINDS[r.blind_choices.Boss]
            local target = n.get_blind_amount(ante - 1) * 5
            assert(n.reality_warp_preview_blind_target(boss_definition, r.blind_ante, 'Boss') == target,
                'future preview must use synchronously reduced blind_ante before the HUD Ante event')
            n.reset_blinds(); assert(protected_snapshot(n) == before)
            drain(n); n.reset_blinds()
            assert(r.ante == ante - 1 and protected_snapshot(n) == before and n.rolls == rolls)
            assert(active.chips == 777)
            assert(r.hands == (voucher == 'Hieroglyph' and 3 or 4))
            assert(r.discards == (voucher == 'Petroglyph' and 2 or 3))
            assert(n.get_blind_amount(r.blind_ante) < n.get_blind_amount(ante))
            assert(n.reality_warp_initial_blind_target(boss_definition, r.blind_ante, false) == target)
            local id, gen = r.reality_warp_encounters.Boss.id, r.reality_warp_schedule_generation
            -- Actual native progression boundary, numeric Ante returns to its old value.
            n.SMODS.ante_end = true; n.ease_ante(1); n.SMODS.ante_end = nil; drain(n)
            r.blind_states.Boss = 'Defeated'; n.reset_blinds()
            assert(r.ante == ante and r.reality_warp_schedule_generation == gen + 1)
            assert(r.reality_warp_encounters.Boss.id ~= id and r.divine_ward_free and g.blind_on_deck == 'Small')
            r.divine_ward_free = false; local after = protected_snapshot(n)
            n.reset_blinds(); assert(protected_snapshot(n) == after)
            -- Execute shipping cycle reset with UI/empty inventory adapters.
            load(cycle, n); n.G.FUNCS.confirm_battle_of_gods({})
            assert(r.ante == 1 and r.blind_ante == 1 and r.reality_warp_schedule_generation == gen + 2)
            assert(r.divine_ward_free and r.reality_warp_ward_generation == gen + 2)
        end
    end
    local n = env_new(1, false, true)
    n.SMODS.reset_blind_choices(n.G.GAME.round_resets.blind_choices)
    assert(n.lower_choices == 3 and n.G.GAME.round_resets.blind_choices.Small == 'bl_small')
    assert(encode(n.G.GAME.round_resets.blind_order) == encode({'Small', 'Big', 'Boss'}))
    print('PASS: installed native vouchers/queued Ante/SMODS contexts/progression and shipping BOTG cycle (labeled UI/FIFO adapters)')
else
    print('SKIP: native Ante integration (installed sources unavailable)')
end
print('PASS: schedule-generation identity, legacy Ward migration, forwarding and unchanged positive targets')
