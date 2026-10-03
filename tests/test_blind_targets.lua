local function read(path)
    local file = assert(io.open(REPO_ROOT .. '/' .. path)); local source = file:read('*a'); file:close(); return source
end
local function region(source, first, following)
    local a = assert(source:find(first, 1, true)); local b = assert(source:find(following, a + #first, true))
    return source:sub(a, b - 1)
end
local function pack(...) return {n = select('#', ...), ...} end
G = {GAME = {battle_of_gods = true, starting_params = {ante_scaling = 1}, used_vouchers = {},
    round_resets = {ante = 1, reality_warp_encounters = {}}}, jokers = {cards = {}}, C = {RED = {}}}
SMODS = {get_card_areas = function() return {G.jokers, G.jokers} end}
local queues, resets = 0, 0
function number_format(x) return tostring(x) end
function reset_sale_tag_effects() resets = resets + 1 end
function ease_custom_blind_background() end
function reset_reality_warp_boss_ui() end
function reality_warp_queue_blind_event() queues = queues + 1 end
local original_args
function get_blind_amount(...) original_args = pack(...); return 300, 'base post', nil end
local battle = read('src/core/battle_of_gods.lua')
assert(loadstring(region(battle, 'function get_botg_godly_hubris_multiplier()', '-- UI reads committed slots')))()
dofile(REPO_ROOT .. '/src/core/blind_identity.lua')
dofile(REPO_ROOT .. '/src/core/blind_targets.lua')

local toml = read('lovely/lovely.toml')
local runtime_payload = assert(toml:match('payload = """\n(self.chips = reality_warp_initial_blind_target.-)\n"""'))
local ui_payload = assert(toml:match('payload = """\n(local blind_amt = reality_warp_preview_blind_target.-)\n"""'))
local initialize = assert(loadstring('return function(self, blind)\n' .. runtime_payload .. '\nend'))()
local preview = assert(loadstring('return function(blind_choice, type)\n' .. ui_payload .. '\nreturn blind_amt end'))()
local setup_args
Blind = {set_blind = function(self, definition, reset, silent, ...)
    setup_args = pack(definition, reset, silent, ...)
    if not reset then
        self.config = {blind = definition or {}}; self.effect = {}; self.disabled = false
        initialize(self, definition)
        if not definition then self.chips = 0 end
        if definition and definition.set_blind then definition:set_blind(self) end
        self.in_blind = definition ~= nil
    end
    return 'setup', nil, 'post', nil
end}
local utils = read('src/core/utils.lua')
assert(loadstring(region(utils, '-- Blind hook for Detective Job', '-- Blind disable hook')))()
assert(loadstring(region(battle, 'local botg_ante_bases', 'local orig_create_card = create_card')))()
assert(get_blind_amount(1) == 15000 and get_blind_amount(8) == 36000000000)
assert(get_blind_amount(24) == 1e300, 'preserve the documented no-extension numeric fallback')

local regular = {key = 'bl_big', mult = 1.5}
local boss = {key = 'bl_hook', mult = 2, boss = {min = 1}}
local fused = {key = 'bl_reality_warp_obelisk', mult = 2, boss = {min = 12}, reality_warp_fused = true}
local showdown = {key = 'bl_reality_warp_code', mult = 2, boss = {min = 8, showdown = true}}
local chronos = {key = 'bl_reality_warp_chronos', mult = 4, boss = {showdown = true}}
local vessel = {key = 'bl_vessel', mult = 6, boss = {showdown = true}}
local localized = {key = 'bl_other', name = 'Chronos', mult = 6, boss = {showdown = true}}
G.GAME.round_resets.blind_ante = 1
for count = 0, 3 do
    G.jokers.cards = {}
    for _ = 1, count do G.jokers.cards[#G.jokers.cards + 1] = {config = {center = {rarity = 4}}} end
    for _, stake in ipairs({1, 2}) do
        G.GAME.starting_params.ante_scaling = stake
        for _, slot in ipairs({'Small', 'Big', 'Boss'}) do
            G.GAME.blind_on_deck = slot
            for _, definition in ipairs({regular, boss, fused, showdown, chronos, vessel, localized}) do
                local original_mult = definition.mult
                local projected = preview({config = definition}, slot)
                local blind = setmetatable({}, {__index = Blind}); G.GAME.blind = blind
                local results = pack(blind:set_blind(definition, false, true, 'extra', nil))
                assert(results.n == 4 and results[1] == 'setup' and results[3] == 'post' and results[4] == nil)
                assert(setup_args.n == 5 and setup_args[4] == 'extra' and setup_args[5] == nil)
                assert(blind.chips == projected and definition.mult == original_mult)
                local m = (definition == chronos or definition == vessel) and 8 or
                    (reality_warp_blind_is_showdown(definition) and 5 or original_mult)
                local expected = 15000 * m * stake
                if definition.boss and count > 0 then expected = math.floor(expected * (1 + count * 0.5)) end
                assert(blind.chips == expected, 'category/stake/Hubris must ignore progression slot')
                blind.chips = 123456 -- intentional Code/Void/reduction state
                blind.disabled = true
                blind:set_blind(nil, true, false); blind:set_blind(nil, true, false)
                assert(blind.chips == 123456, 'refresh must not rebuild or compound current target')
            end
        end
    end
end

G.jokers.cards = {{config = {center = {rarity = 4}}},
    {ability = {possessed_wall = true}}, {ability = {possessed_wall = true}, debuff = true},
    {ability = {possessed_wall = true}, getting_sliced = true}, {ability = {possessed_wall = true}, removed = true}}
G.GAME.starting_params.ante_scaling = 2; G.GAME.stick_penalty = 1.4
G.GAME.used_vouchers.v_reality_warp_nectar = true
local projected = preview({config = boss}, 'Big')
assert(projected == 239400 and G.GAME.stick_penalty == 1.4, 'preview cannot consume Rod or double-count areas')
local blind = setmetatable({}, {__index = Blind}); G.GAME.blind = blind
blind:set_blind(boss, false, true)
assert(blind.chips == 119700 and G.GAME.stick_penalty == nil)
local stickers = {}; SMODS.Sticker = function(def) stickers[def.key] = def end
function HEX(x) return x end
assert(loadstring(region(read('src/core/botg_possession.lua'), '-- 8. Possessed: The Wall', '-- 9. Possessed: The Serpent')))()
local wall = G.jokers.cards[2]
stickers.possessed_wall:calculate(wall, {setting_blind = true})
assert(blind.chips == projected)
stickers.possessed_wall:calculate(wall, {setting_blind = true})
assert(blind.chips == projected)
G.GAME.stick_penalty = 3
blind:set_blind(nil, true); blind:set_blind(nil, true)
assert(blind.chips == projected and G.GAME.stick_penalty == 3)

-- Active run-info reads the saved dynamic requirement, never another slot.
G.GAME.reality_warp_active_encounter = {id = 9, key = boss.key, slot = 'Big'}
G.GAME.round_resets.reality_warp_encounters.Big = {id = 9}
blind.chips = 777
assert(preview({config = boss}, 'Big') == 777)
assert(preview({config = boss}, 'Boss') ~= 777)
blind.config.blind = showdown
assert(preview({config = boss}, 'Big') ~= 777)
blind.config.blind = boss; G.GAME.reality_warp_active_encounter.phase = 'defeated'
assert(preview({config = boss}, 'Big') ~= 777)

local snapshot = {botg = true, stake = 2, rod = 1.4, hubris = 1.5, nectar = true, walls = 2, cap = 200000}
assert(reality_warp_calculate_blind_target(15000, boss, snapshot) == 200000, 'cap follows all initial modifiers')
assert(snapshot.rod == 1.4 and boss.mult == 2)
G.GAME.battle_of_gods = false; G.GAME.stick_penalty = nil; G.GAME.used_vouchers = {}; G.jokers.cards = {}
local returns = pack(get_blind_amount(4, 'forward', nil))
assert(returns.n == 3 and original_args.n == 3 and original_args[2] == 'forward')
blind:set_blind(boss, false, false)
assert(blind.chips == 1200 and queues == 0)
boss.set_blind = function(self, runtime) runtime.chips = 456 end
blind:set_blind(boss, false, true); assert(blind.chips == 456, 'custom definition setup remains authoritative')
blind:set_blind(nil, true); assert(blind.chips == 456)
assert(not read('src/vouchers/vouchers.lua'):find('orig_blind_set_blind_nectar', 1, true))
assert(not read('src/decks/decks.lua'):find('local base_1 = 4000', 1, true))
assert(not battle:find('botg_hubris_in_blind_choice', 1, true))
assert(resets > 0)
G.GAME.battle_of_gods = true; G.jokers.cards = {{config = {center = {rarity = 4}}}}
boss.set_blind = nil; blind:set_blind(boss, false, false)
assert(queues == 1, 'new enabled semantic boss retains Hubris feedback')
blind:set_blind(nil, true, false); assert(queues == 1, 'refresh must not replay Hubris feedback')
