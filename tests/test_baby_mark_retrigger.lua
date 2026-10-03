local function read(path)
    local file = assert(io.open(REPO_ROOT .. '/' .. path, 'rb'))
    local value = file:read('*a')
    file:close()
    return (value:gsub('\r\n', '\n'))
end

local function region(source, first, following)
    local start = assert(source:find(first, 1, true), 'missing source anchor: ' .. first)
    local finish = assert(source:find(following, start + #first, true), 'missing source boundary: ' .. following)
    return source:sub(start, finish - 1)
end

local familiar_source = read('src/core/botg_familiars.lua')
local native_utils = read('../smods/src/utils.lua')
local native_card = read('../lovely/dump/card.lua')
local native_objects = read('../smods/src/game_object.lua')

local native_area_source = region(native_utils, 'function SMODS.get_card_areas(_type, _context)', '\nfunction Back:calculate(context)')
local repetition_insert_source = region(native_utils,
    'SMODS.insert_repetitions = function(ret, eval, effect_card, _type)',
    '\nSMODS.calculate_repetitions = function(card, context, reps)')
local repetition_source = region(native_utils,
    'SMODS.calculate_repetitions = function(card, context, reps)',
    '\nSMODS.calculate_retriggers = function(card, context, _ret)')
local score_card_source = region(native_utils,
    'function SMODS.score_card(card, context)',
    '\nfunction SMODS.calculate_main_scoring(context, scoring_hand)')
local seal_source = region(native_card,
    'function Card:calculate_seal(context)',
    '\nfunction Card:calculate_joker(context)')
local area_wrapper_source = region(familiar_source,
    '-- Register G.botg_familiars as a valid scoring area in SMODS',
    '\nif SMODS and SMODS.optional_features then')
local calculate_joker_wrapper_source = region(familiar_source,
    '-- Hook Card.calculate_joker exclusively for the familiar card',
    '\nfunction botg_calculate_familiar(self, context)')
local familiar_level_source = region(familiar_source,
    'function botg_get_familiar_level(fam_key)',
    '\n-- Initialize Familiar CardArea directly above G.deck')
local familiar_callback_source = region(familiar_source,
    'function botg_calculate_familiar(self, context)',
    '\n-- Baby Pillar, Baby Heart & Baby Leaf: Protect cards from debuffs')
local poly_definition = region(native_objects,
    "SMODS.Edition:take_ownership('polychrome', {",
    '\n    })')
local poly_function_start = assert(poly_definition:find('calculate = ', 1, true)) + #'calculate = '
local poly_function_end = assert(poly_definition:find('\n        end', poly_function_start, true))
local poly_function_source = poly_definition:sub(poly_function_start, poly_function_end + #'\n        end' - 1)
assert(poly_definition:find('x_mult = card.edition.x_mult', 1, true),
    'installed Polychrome must provide its multiplier from the edition callback')
assert(not poly_definition:find('repetitions', 1, true),
    'installed Polychrome must not define a repetition effect')

local function compile(source, name)
    local chunk, err = loadstring(source, name)
    assert(chunk, err)
    return chunk
end

local observation
local active_level
local native_get_card_areas_chunk = compile(native_area_source, 'installed SMODS.get_card_areas')
local install_area_wrapper = compile(area_wrapper_source, 'Reality Warp Familiar-area registration')
local install_joker_wrapper = compile(calculate_joker_wrapper_source, 'Reality Warp Familiar calculate_joker wrapper')
local load_level = compile(familiar_level_source, 'Reality Warp Familiar level helper')
local load_familiar_callback = compile(familiar_callback_source, 'Reality Warp Familiar callback')
local load_seal = compile(seal_source, 'installed Card:calculate_seal')
local load_insert_repetitions = compile(repetition_insert_source, 'installed SMODS.insert_repetitions')
local load_calculate_repetitions = compile(repetition_source, 'installed SMODS.calculate_repetitions')
local load_score_card = compile(score_card_source, 'installed SMODS.score_card')
local load_polychrome = compile('return ' .. poly_function_source, 'installed Polychrome calculate callback')

local function install_runtime(familiar_key, level, physical_id)
    active_level = level
    observation = {
        score_passes = 0,
        mark_callback_calls = 0,
        mark_individual_calls = 0,
        mark_repetition_checks = 0,
        mark_effects = 0,
        mark_xmults = {},
        mark_messages = 0,
        bell_messages = 0,
        native_repeat_effects = 0,
        polychrome_effects = 0,
        random_calls = 0,
        lower_joker_calls = 0,
    }

    G = {
        GAME = {battle_of_gods = true, selected_back = {effect = {center = {key = 'b_test'}}}},
        deck = {cards = {}},
        play = {cards = {}},
        hand = {cards = {}},
        jokers = {cards = {}},
        consumeables = {cards = {}},
        vouchers = {cards = {}},
        P_SEALS = {},
        C = {GOLD = {}},
    }
    SMODS = {optional_features = {post_trigger = false}}
    native_get_card_areas_chunk()
    SMODS.get_stake_scoring_targets = function() return {} end
    SMODS.get_mods_scoring_targets = function() return {} end
    SMODS.eval_individual = function() return {}, {} end
    load_insert_repetitions()
    load_calculate_repetitions()
    load_score_card()
    SMODS.calculate_quantum_enhancements = function() end
    SMODS.check_looping_context = function() return false end
    SMODS.trigger_effects = function(effects)
        for _, effect in ipairs(effects) do
            if effect.jokers and effect.jokers.x_mult then
                observation.mark_effects = observation.mark_effects + 1
                if effect.jokers.message then observation.mark_messages = observation.mark_messages + 1 end
            elseif effect.jokers and effect.jokers.repetitions and effect.jokers.message then
                observation.bell_messages = observation.bell_messages + 1
            end
        end
        return {calculated = true}
    end
    SMODS.calculate_effect = function(effect)
        if effect.message then
            if type(effect.message) == 'string' and effect.message:find('Baby Bell', 1, true) then
                observation.bell_messages = observation.bell_messages + 1
            else
                observation.native_repeat_effects = observation.native_repeat_effects + 1
            end
        end
    end
    -- This adapter models the native eval_card-to-area boundary only. The repetition loop,
    -- repetition insertion, area list and Familiar callback below are the real sourced functions.
    SMODS.calculate_card_areas = function(kind, context, return_table)
        if kind ~= 'jokers' then return {} end
        for _, area in ipairs(SMODS.get_card_areas('jokers')) do
            for _, card in ipairs(area.cards or {}) do
                local evaluation, post = eval_card(card, context)
                if evaluation and next(evaluation) then return_table[#return_table + 1] = evaluation end
                for _, extra in ipairs(post or {}) do return_table[#return_table + 1] = extra end
            end
        end
        return {}
    end

    local play_area = G.play
    local familiar_area = {cards = {}, name = 'one Familiar slot'}
    G.botg_familiars = familiar_area
    local familiar = setmetatable({
        area = familiar_area,
        physical_id = physical_id,
        config = {center = {key = familiar_key}},
    }, {__index = Card})
    familiar_area.cards[1] = familiar

    Card = {}
    Card.calculate_joker = function(self)
        observation.lower_joker_calls = observation.lower_joker_calls + 1
        return {x_mult = 99}
    end
    load_seal()
    setmetatable(familiar, {__index = Card})
    install_area_wrapper()
    install_joker_wrapper()
    load_level()
    load_familiar_callback()
    get_nursery_data = function() return {level = active_level} end
    botg_trigger_mod_achievement = function() end
    HEX = function(value) return value end
    localize = function(key) return key end
    pseudorandom = function(key)
        observation.random_calls = observation.random_calls + 1
        if key == 'baby_bell' then return 0 end
        return 1
    end

    local poly_calculate = load_polychrome()
    local scored_card
    eval_card = function(card, context)
        if card == scored_card then
            if context.repetition_only then
                local seal = card:calculate_seal(context)
                return seal and {seals = seal} or {}, {}
            end
            if context.main_scoring then
                observation.score_passes = observation.score_passes + 1
                local evaluation = {playing_card = {chips = 0}}
                if card.edition and card.edition.polychrome then
                    evaluation.edition = poly_calculate(nil, card, context)
                    if evaluation.edition then
                        observation.polychrome_effects = observation.polychrome_effects + 1
                    end
                end
                return evaluation, {}
            end
            return {}, {}
        end

        local in_joker_area = false
        for _, area in ipairs(SMODS.get_card_areas('jokers')) do
            if area == card.area then in_joker_area = true; break end
        end
        if not in_joker_area then return {}, {} end

        local key = card.config and card.config.center and card.config.center.key
        if key == 'c_reality_warp_baby_mark' then
            observation.mark_callback_calls = observation.mark_callback_calls + 1
            if context.individual then observation.mark_individual_calls = observation.mark_individual_calls + 1 end
            if context.repetition then observation.mark_repetition_checks = observation.mark_repetition_checks + 1 end
        end
        local effect = card:calculate_joker(context)
        if key == 'c_reality_warp_baby_mark' and effect and effect.x_mult then
            assert(effect.repetitions == nil, 'Baby Mark must never add a repetition field')
            observation.mark_xmults[#observation.mark_xmults + 1] = effect.x_mult
        end
        if effect then return {jokers = effect}, {} end
        return {}, {}
    end

    return familiar, play_area, function(seal, edition, face, scored_area)
        local target_area = scored_area or play_area
        scored_card = setmetatable({
            area = target_area,
            base = {value = face and 'King' or '5'},
            seal = seal,
            edition = edition,
            is_face = function(self) return self.base.value == 'King' end,
            config = {center = {key = 'm_base'}},
        }, {__index = Card})
        target_area.cards[1] = scored_card
        percent, percent_delta = 0, 0.1
        SMODS.score_card(scored_card, {
            cardarea = target_area,
            scoring_hand = target_area == play_area and {scored_card} or nil,
        })
        return scored_card
    end
end

local function area_occurrences(areas, expected)
    local found = 0
    for _, area in ipairs(areas) do if area == expected then found = found + 1 end end
    return found
end

local function assert_one_registered_area(familiar_area, old_area)
    for _ = 1, 5 do
        local areas = SMODS.get_card_areas('jokers')
        assert(area_occurrences(areas, familiar_area) == 1,
            'repeated native Joker-area queries must return the one physical Familiar area once')
        assert(#familiar_area.cards == 1 and familiar_area.cards[1].area == familiar_area,
            'the runtime model has exactly one physical Familiar card in its one-card area')
        if old_area then assert(area_occurrences(areas, old_area) == 0, 'reconstructed runs must not retain the old area') end
    end
end

local function assert_mark_scenario(level, seal, edition, face, scored_area, expected_passes, expected_mark_effects)
    local familiar, play_area, score = install_runtime('c_reality_warp_baby_mark', level, 'mark-' .. level)
    local familiar_area = familiar.area
    assert_one_registered_area(familiar_area)
    local scored = score(seal, edition, face, scored_area)
    assert(observation.score_passes == expected_passes,
        'native SMODS.score_card should make exactly ' .. expected_passes .. ' scoring pass(es)')
    assert(observation.mark_effects == expected_mark_effects,
        'the actual Mark callback should return one effect per eligible individual scoring pass')
    assert(observation.mark_messages == expected_mark_effects,
        'the modeled effect sink should count one Mark message per returned Mark effect')
    if face and scored.area == play_area then
        assert(observation.mark_individual_calls == expected_passes,
            'every scoring pass should dispatch the Familiar for the face card')
    else
        assert(observation.mark_effects == 0, 'held/unscored or non-face cards receive no Mark bonus')
    end
    if seal == 'Red' then
        assert(observation.native_repeat_effects == 1,
            'the installed Red Seal callback should add one native repetition effect')
        assert(observation.score_passes == 2, 'one Red Seal repeat produces a second actual scoring pass')
    else
        assert(observation.native_repeat_effects == 0,
            'without Red Seal, Mark and Polychrome must not add a card repetition')
        assert(observation.score_passes == 1, 'without a repetition source, the native loop scores once')
    end
    if edition and edition.polychrome then
        assert(observation.polychrome_effects == expected_passes,
            'installed Polychrome contributes its main-scoring XMult on each actual pass')
    end
    assert(observation.mark_repetition_checks >= 1,
        'native repetition discovery queries the Familiar without granting Mark on a non-individual context')
    assert(observation.lower_joker_calls == 0,
        'Familiar cards use the dedicated Reality Warp callback rather than the captured lower Joker wrapper')
    return observation
end

-- Mark's XMult remains level-scaled and applies once for the plain scoring pass.
for _, level in ipairs({1, 5}) do
    local plain = assert_mark_scenario(level, nil, nil, true, nil, 1, 1)
    assert(plain.mark_repetition_checks == 1, 'the one native repetition eligibility check is distinct from Mark scoring')
    local expected_x_mult = 1 + 0.1 * level
    assert(plain.mark_xmults[1] == expected_x_mult,
        'Baby Mark should preserve the configured level multiplier')
end

-- The installed Red Seal callback is an actual positive control; Mark participates once on each pass.
for _, level in ipairs({1, 5}) do
    local red = assert_mark_scenario(level, 'Red', nil, true, nil, 2, 2)
    assert(red.mark_individual_calls == 2 and red.mark_messages == 2)
    assert(red.mark_xmults[1] == 1 + 0.1 * level and red.mark_xmults[2] == 1 + 0.1 * level)
end

-- Polychrome's installed scoring callback gives XMult but no repetitions.
local poly = assert_mark_scenario(5, nil, {polychrome = true, x_mult = 1.5}, true, nil, 1, 1)
assert(poly.polychrome_effects == 1)

-- Reproduce the full historical card combination while attributing the one extra pass to Red Seal.
for _, level in ipairs({1, 5}) do
    local combined = assert_mark_scenario(level, 'Red', {polychrome = true, x_mult = 1.5}, true, nil, 2, 2)
    assert(combined.polychrome_effects == 2 and combined.mark_xmults[1] == 1 + 0.1 * level and
        combined.mark_xmults[2] == 1 + 0.1 * level,
        'Red Seal plus Polychrome keeps exactly two passes and one scaled Mark effect per pass')
end

-- Face and area gates: non-face scoring, held/unscored, and normal repetition-only context.
local nonface = assert_mark_scenario(5, nil, nil, false, nil, 1, 0)
assert(nonface.mark_effects == 0)
local held = assert_mark_scenario(5, nil, nil, true, {cards = {}, name = 'unscored'}, 1, 0)
assert(held.mark_effects == 0 and held.mark_individual_calls == 1,
    'an unscored card dispatch cannot pass the actual G.play gate')

-- Baby Bell is a deterministic Familiar-generated retrigger positive control at level five.
local bell, _, bell_score = install_runtime('c_reality_warp_baby_bell', 5, 'bell-5')
assert_one_registered_area(bell.area)
bell_score(nil, nil, true)
assert(observation.score_passes == 2 and observation.random_calls == 1 and observation.bell_messages == 1,
    'the real Baby Bell callback provides a one-repeat positive control')
assert(observation.mark_effects == 0, 'the positive-control repeat is owned by Baby Bell, not Mark')

-- Reconstruct a cold-load model with the same serialized Familiar key/level and one fresh CardArea.
local old_area = bell.area
local loaded_familiar, _, loaded_score = install_runtime('c_reality_warp_baby_mark', 5, 'mark-5')
assert(loaded_familiar.config.center.key == 'c_reality_warp_baby_mark')
assert(loaded_familiar.area ~= old_area)
assert_one_registered_area(loaded_familiar.area, old_area)
loaded_score(nil, nil, true)
assert(observation.score_passes == 1 and observation.mark_effects == 1,
    'the reconstructed run keeps one Familiar area and one plain-King Mark effect')

-- The captured lower method remains available to ordinary Jokers outside the Familiar area.
local ordinary = setmetatable({area = G.jokers, config = {center = {key = 'j_test'}}}, {__index = Card})
local ordinary_result = ordinary:calculate_joker({})
assert(ordinary_result.x_mult == 99 and observation.lower_joker_calls == 1)

print('PASS: Baby Mark source-extracted native scoring/repetition and Familiar dispatch contracts')
