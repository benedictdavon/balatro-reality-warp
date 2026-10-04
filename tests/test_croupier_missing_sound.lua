local function read(path)
    local file = assert(io.open(REPO_ROOT .. '/' .. path, 'r'))
    local source = file:read('*a')
    file:close()
    return source
end

local function region(path, first, following)
    local source = read(path)
    local start_at = assert(source:find(first, 1, true), 'Croupier sticker definition start missing')
    local end_at = assert(source:find(following, start_at + #first, true), 'Croupier sticker definition end missing')
    return source:sub(start_at, end_at - 1)
end

local function pack(...) return {n = select('#', ...), ...} end
local function same_fields(actual, expected, label)
    assert(type(actual) == 'table', label .. ' should return an effect table')
    local actual_count, expected_count = 0, 0
    for key, value in pairs(expected) do
        expected_count = expected_count + 1
        assert(actual[key] == value, label .. ' returned incorrect field ' .. tostring(key))
    end
    for key in pairs(actual) do
        actual_count = actual_count + 1
        assert(expected[key] ~= nil, label .. ' added unexpected field ' .. tostring(key))
    end
    assert(actual_count == expected_count, label .. ' changed its returned field set')
end

local registered = {}
local rolls = {}
local sounds = {}
local chosen_roll

G = {play = {}, C = {MULT = {name = 'mult'}, CHIPS = {name = 'chips'}}}
SMODS = {Sticker = function(definition) registered[definition.key] = definition end}
function HEX(value) return 'hex:' .. value end
function pseudorandom(...)
    rolls[#rolls + 1] = pack(...)
    return chosen_roll
end
function play_sound(...)
    sounds[#sounds + 1] = pack(...)
end

local definition_source = region(
    'src/consumables/jobs.lua',
    '-- Croupier Sticker\nSMODS.Sticker {',
    '\n\n-- Job Cards Atlas')
assert(loadstring(definition_source, '@src/consumables/jobs.lua Croupier sticker'))()
local sticker = assert(registered.croupier_job, 'actual Croupier sticker registration was not loaded')

local contexts = {
    {name = 'main_scoring', make = function() return {main_scoring = true, cardarea = G.play} end},
    {name = 'individual', make = function() return {individual = true, cardarea = G.play} end},
}

for _, scoring_context in ipairs(contexts) do
    for die = 1, 6 do
        local card = {ability = {}}
        chosen_roll = die
        rolls, sounds = {}, {}

        local result = pack(sticker.calculate(sticker, card, scoring_context.make()))
        assert(result.n == 1, scoring_context.name .. ' should return exactly one effect')

        local expected
        if die == 1 or die == 3 then
            local mult = die * 8
            expected = {mult = mult, message = 'Die: ' .. die .. ' (+' .. mult .. ' Mult)',
                colour = G.C.MULT, card = card}
        elseif die == 2 or die == 4 then
            local chips = die * 30
            expected = {chips = chips, message = 'Die: ' .. die .. ' (+' .. chips .. ' Chips)',
                colour = G.C.CHIPS, card = card}
        else
            expected = {x_mult = 2.0, message = 'Jackpot Die: ' .. die .. '! X2 Mult',
                colour = HEX('8e44ad'), card = card}
            -- The missing retrigger-flag producer is separate POST-A1; this scoring callback
            -- does not write that flag, and the sound fix must not invent it.
            assert(card.ability.croupier_rolled_high == nil)
        end
        same_fields(result[1], expected, scoring_context.name .. ' die ' .. die)

        assert(#rolls == 1 and rolls[1].n == 3, 'one three-argument die sample per scoring callback')
        assert(rolls[1][1] == 'dice_job' and rolls[1][2] == 1 and rolls[1][3] == 6,
            'the original seeded 1..6 roll must be preserved')
        assert(#sounds == 1 and sounds[1].n == 2, 'one two-argument sound call per scoring callback')
        assert(sounds[1][1] == 'generic1' and sounds[1][2] == 1.0 + die * 0.05,
            'scoring must use the packaged sound and retain the die pitch')
    end
end

local card = {ability = {}}
local non_scoring_contexts = {
    {main_scoring = true, cardarea = {}},
    {individual = true, cardarea = {}},
    {cardarea = G.play},
    {repetition = true, cardarea = G.play, other_card = {}},
    {repetition = true, cardarea = G.play, other_card = card},
}
for index, context in ipairs(non_scoring_contexts) do
    rolls, sounds = {}, {}
    local result = pack(sticker.calculate(sticker, card, context))
    assert(result.n == 0, 'non-scoring context ' .. index .. ' should return no values without the legacy flag')
    assert(#rolls == 0 and #sounds == 0, 'non-scoring contexts must not roll or play audio')
end

-- Keep the existing repetition consumer unchanged and separate from the absent producer.
card.ability.croupier_rolled_high = true
rolls, sounds = {}, {}
local repetition = pack(sticker.calculate(sticker, card, {
    repetition = true, cardarea = G.play, other_card = card
}))
assert(repetition.n == 1)
same_fields(repetition[1], {message = 'Retrigger!', repetitions = 1, card = card}, 'legacy repetition callback')
assert(card.ability.croupier_rolled_high == nil)
assert(#rolls == 0 and #sounds == 0, 'the separate repetition callback must not sample or play audio')

print('PASS: actual Croupier sticker scoring outputs and valid sound call contract; POST-A1 remains separate')
