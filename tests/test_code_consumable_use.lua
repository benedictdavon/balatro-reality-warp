local definitions, events = {}, {}
local removals, uses, listeners = 0, 0, 0
local during_use, during_destruction, last_arguments
G = {GAME = {probabilities = {normal = 1}, used_vouchers = {}, potion_pouch = {}},
    C = {GREEN = {}, GOLD = {}, RED = {}}, ARGS = {},
    hand = {cards = {}}, play = {cards = {}}, jokers = {cards = {}}, consumeables = {},
    playing_cards = {}, STATES = {SELECTING_HAND = 1}, STATE = 1, FUNCS = {},
    P_CARDS = {empty = {}}, P_CENTERS = {}, CARD_W = 1, CARD_H = 1,
    E_MANAGER = {add_event = function(_, event) events[#events + 1] = event end}}
function HEX(x) return x end
function Event(x) return x end
function play_sound() end
function attention_text() end
function number_format(x) return tostring(x) end
function pseudoseed(x) return x end
function pseudorandom_element(cards) return cards[1] end
function reality_warp_encounter_params() return {} end
Blind = {set_blind = function() end, defeat = function() end}
SMODS = {Atlas = function() end, Blind = function(def)
    def.key = 'bl_reality_warp_' .. def.key; definitions[def.key] = def
end, is_eternal = function(card) return card.eternal end}
function SMODS.destroy_cards(cards, args)
    assert(args.immediate and not args.bypass_eternal)
    local accepted = {}
    for _, card in ipairs(cards) do
        if not SMODS.is_eternal(card) then
            card.getting_sliced = true; card.destroyed = true
            accepted[#accepted + 1] = card
            removals = removals + 1
            card:start_dissolve()
        end
    end
    if during_destruction then during_destruction() end
    return accepted
end
function SMODS.calculate_context(context)
    if context.using_consumeable then listeners = listeners + 1 end
    local blind = G.GAME.blind
    local def = blind and blind.config.blind
    if def and def.calculate then def:calculate(blind, context) end
end
dofile(REPO_ROOT .. '/src/core/blind_identity.lua')
dofile(REPO_ROOT .. '/src/core/blind_effects.lua')
dofile(REPO_ROOT .. '/src/blinds/boss_blinds.lua')

Card = {}
function Card:use_consumeable(area, copier, ...)
    uses = uses + 1
    last_arguments = {self, area, copier, n = select('#', ...), ...}
    if self.debuff then return nil end
    if during_use then during_use() end
    return 'effect', nil, 'post', nil
end
function Card:remove() self.removed = true end
setmetatable(Card, {__call = function(_, _, _, _, _, _, center)
    return setmetatable({ability = {set = 'Potion'}, config = {center = center}}, {__index = Card})
end})
local function region_source(path, first, last)
    local file = assert(io.open(REPO_ROOT .. '/' .. path)); local source = file:read('*a'); file:close()
    local a = assert(source:find(first, 1, true)); local b = assert(source:find(last, a + #first, true))
    return source:sub(a, b - 1)
end
local function load_region(path, first, last)
    assert(loadstring(region_source(path, first, last), path))()
end
-- Load the real wrapper chain in repository order, without unrelated game/UI setup.
assert(loadstring(region_source('src/core/utils.lua', '-- Mountain Blind consumable check', '-- Safety guard for Card:update_alert') ..
    region_source('src/core/utils.lua', '-- The Code: one penalty', '-- Charles Colosseum Deck:'), 'utils use wrapper chain'))()
load_region('src/consumables/potions.lua', 'local card_use_potion_ref', 'local card_start_dissolve_potion_ref')
load_region('src/vouchers/vouchers.lua', '-- Hook Card.use_consumeable for Destilacion vouchers', '-- Voucher: ambrosia')
load_region('src/consumables/potions.lua', 'G.FUNCS.use_potion_from_pouch = function', '-- Hook card action buttons')
G.FUNCS.exit_overlay_menu = function() end

local function activate(disabled)
    removals, uses, listeners, events = 0, 0, 0, {}
    during_use, during_destruction = nil, nil
    G.GAME.reality_warp_active_encounter = {id = 1, key = 'bl_reality_warp_code'}
    G.GAME.blind = {config = {blind = definitions.bl_reality_warp_code}, chips = 1000,
        disabled = disabled, effect = {}}
    G.jokers.cards = {}
    return G.GAME.blind
end
local function joker(eternal, flags)
    local card = {area = G.jokers, eternal = eternal, ability = {}}
    for key, value in pairs(flags or {}) do card[key] = value end
    function card:start_dissolve() self.dissolutions = (self.dissolutions or 0) + 1 end
    G.jokers.cards[#G.jokers.cards + 1] = card
    return card
end
local function consumable()
    return setmetatable({ability = {set = 'Tarot'}, config = {center = {key = 'c_test'}}}, {__index = Card})
end
local function pack(...) return {n = select('#', ...), ...} end

local blind = activate(false)
local first, second, third = joker(), joker(), joker()
local item, area, copier, sentinel = consumable(), {}, {}, {}
local returns = pack(item:use_consumeable(area, copier, sentinel, nil))
assert(uses == 1 and removals == 1 and blind.chips == 1250 and first.dissolutions == 1)
assert(last_arguments[1] == item and last_arguments[2] == area and last_arguments[3] == copier)
assert(last_arguments[4] == sentinel and last_arguments.n == 2)
assert(returns.n == 4 and returns[1] == 'effect' and returns[2] == nil and returns[3] == 'post' and returns[4] == nil)
SMODS.calculate_context({using_consumeable = true, consumeable = item})
assert(listeners == 1 and removals == 1 and blind.chips == 1250, 'UI context must not punish again')
item:use_consumeable(area)
assert(uses == 2 and removals == 2 and blind.chips == 1562 and second.dissolutions == 1)
assert(not third.destroyed, 'one real use removes at most one eligible Joker')

blind = activate(false)
local eternal = joker(true); joker(false, {removed = true}); joker(false, {getting_sliced = true})
consumable():use_consumeable(area)
assert(removals == 0 and not eternal.destroyed and blind.chips == 1250, 'no Eternal fallback; target still grows once')

blind = activate(true); joker()
consumable():use_consumeable(area)
assert(uses == 1 and removals == 0 and blind.chips == 1000)
blind = activate(false); joker()
item = consumable(); item.debuff = true; item:use_consumeable(area)
assert(removals == 0 and blind.chips == 1000, 'a debuffed method invocation must not punish')

blind = activate(false); joker()
during_use = function() G.GAME.reality_warp_active_encounter.id = 2 end
consumable():use_consumeable(area)
assert(removals == 0 and blind.chips == 1000, 'changed encounter during use must cancel penalty')
blind = activate(false); joker()
during_use = function() blind.disabled = true end
consumable():use_consumeable(area)
assert(removals == 0 and blind.chips == 1000)

blind = activate(false); joker()
local later = {config = {blind = definitions.bl_reality_warp_code}, chips = 9000}
during_destruction = function()
    G.GAME.blind = later; G.GAME.reality_warp_active_encounter.id = 2
end
consumable():use_consumeable(area)
assert(removals == 1 and later.chips == 9000, 'destruction listeners must not redirect target mutation')

blind = activate(false); joker()
G.P_CENTERS.c_pouch_test = {key = 'c_pouch_test'}
G.GAME.potion_pouch = {{key = 'c_pouch_test'}}
G.FUNCS.use_potion_from_pouch({config = {ref_table = {idx = 1}}})
assert(#G.GAME.potion_pouch == 0 and uses == 1 and listeners == 1 and removals == 1 and blind.chips == 1250,
    'Pouch must use the ordinary method and emit one ordinary listener context')

blind = activate(false); joker()
G.GAME.reality_warp_active_encounter.phase = 'defeated'
consumable():use_consumeable(area)
assert(removals == 0 and blind.chips == 1000, 'finished encounter must not punish later use')

blind = activate(false)
consumable():use_consumeable(area)
assert(removals == 0 and blind.chips == 1250, 'an empty lineup still receives one target increase')
blind = activate(false); joker()
blind.config.blind = definitions.bl_reality_warp_ares
G.GAME.reality_warp_active_encounter.key = 'bl_reality_warp_ares'
consumable():use_consumeable(area)
assert(uses == 1 and removals == 0 and blind.chips == 1000, 'ordinary use outside Code must pass through')

blind = activate(false); joker()
local original_game = G.GAME
during_use = function()
    G.GAME = {blind = later, used_vouchers = {}, reality_warp_active_encounter = {id = 1, key = 'bl_reality_warp_code'}}
end
consumable():use_consumeable(area)
assert(removals == 0 and later.chips == 9000, 'same ID/key in a different run must not inherit punishment')
G.GAME = original_game
