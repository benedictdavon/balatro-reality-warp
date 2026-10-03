local function read(path, optional)
    local f = io.open(path); if not f and optional then return end
    assert(f, path); local s = f:read('*a'); f:close(); return s
end
local function section(source, first, following)
    local a = assert(source:find(first, 1, true))
    return source:sub(a, assert(source:find(following, a + #first, true)) - 1)
end
local function pack(...) return {n = select('#', ...), ...} end
local queue, requested, transferred, rolls, lower_args = {}, {}, {}, 0, nil
G = {STATES = {DRAW_TO_HAND = 1, HAND_PLAYED = 2, SELECTING_HAND = 3, TAROT_PACK = 4,
    SPECTRAL_PACK = 5, SMODS_BOOSTER_OPENED = 6, GAME_OVER = 7}, C = {}, FUNCS = {}}
G.E_MANAGER = {add_event = function(_, event) queue[#queue + 1] = event end}
function Event(spec) return spec end
function delay() end
function HEX(s) return s end
function ease_discard(value) G.GAME.current_round.discards_left = G.GAME.current_round.discards_left + value end
function reality_warp_blind_key(blind) return blind and blind.config.blind.key end
function reality_warp_blind_is(blind, suffix) return reality_warp_blind_key(blind) == 'bl_reality_warp_' .. suffix end
function pseudoseed(s) return s end
function pseudorandom_element(pool, seed) assert(seed == 'hook_disc'); rolls = rolls + 1; return pool[1] end
local blinds, stickers = {}, {}
SMODS = {Atlas = function() end, Blind = function(b) blinds[b.key] = b end,
    Sticker = function(s) stickers[s.key] = s end, blind_modifies_draw = function(...)
        lower_args = pack(...); return false, 'lower', nil end,
    get_probability_vars = function(_, a, b) return a, b end,
    pseudorandom_probability = function() return false end}
dofile(REPO_ROOT .. '/src/core/draw_rules.lua')
dofile(REPO_ROOT .. '/src/blinds/fused_blinds.lua')
dofile(REPO_ROOT .. '/src/core/botg_possession.lua')
local function area()
    return {cards = {}, config = {card_limit = 8, card_limits = {}, fixed_limit = false},
        remove_card = function(self, target)
            for i, c in ipairs(self.cards) do if c == target then table.remove(self.cards, i); c.area = nil; break end end
            return target -- Native API returns an explicitly requested Card even if absent.
        end,
        emplace = function(self, c) self.cards[#self.cards + 1] = c; c.area = self end}
end
local function card(id, owner)
    local c = {id = id, sort_id = id, area = owner, ability = {card_limit = 0, extra_slots_used = 0}}
    owner.cards[#owner.cards + 1] = c; return c
end
local function reset(held, deck, key)
    queue, requested, transferred, rolls = {}, {}, {}, 0
    G.hand, G.deck, G.discard, G.jokers, G.play = area(), area(), area(), area(), area()
    G.GAME = {facing_blind = true, current_round = {hands_played = 1, discards_used = 0, discards_left = 3},
        blind = {config = {blind = {key = key or 'bl_reality_warp_ouroboros'}}, name = 'canonical'},
        reality_warp_active_encounter = {id = 1, key = key or 'bl_reality_warp_ouroboros', phase = 'active'}}
    G.STATE = G.STATES.DRAW_TO_HAND; SMODS.cards_to_draw = nil; SMODS.draw_queued = nil
    for i = 1, held do card('h' .. i, G.hand) end
    for i = 1, deck do card('d' .. i, G.deck) end
end
local function possession(key)
    local c = card(key, G.jokers); c.ability[key] = true; return c
end
function draw_card(from, to, _, _, _, target)
    requested[#requested + 1] = target or true
    queue[#queue + 1] = {func = function()
        local c = target or from.cards[#from.cards]
        local present = false; for _, candidate in ipairs(from.cards) do if candidate == c then present = true end end
        if present then
            from:remove_card(c); to:emplace(c); transferred[#transferred + 1] = c
            SMODS.drawn_cards = SMODS.drawn_cards or {}; SMODS.drawn_cards[#SMODS.drawn_cards + 1] = c
        end
        return true
    end}
end
local contexts = {}
function SMODS.calculate_context(context)
    contexts[#contexts + 1] = context
    local flags = {}
    if context.drawing_cards then
        if reality_warp_blind_is(G.GAME.blind, 'ouroboros') then
            local ret = blinds.ouroboros:calculate(G.GAME.blind, context)
            if ret then flags.cards_to_draw = ret.cards_to_draw end
        end
        for _, c in ipairs(G.jokers.cards) do
            if c.ability.possessed_serpent and not c.debuff then
                local ret = stickers.possessed_serpent:calculate(c, context)
                if ret then flags.cards_to_draw = ret.cards_to_draw or flags.cards_to_draw end
            end
        end
    end
    return flags
end
local function drain()
    local n = 0
    while #queue > 0 do n = n + 1; assert(n < 200); assert(table.remove(queue, 1).func() ~= false) end
end

-- Read installed framework/native source at runtime; never persist its licensed implementation.
local native = read(REPO_ROOT .. '/../lovely/dump/functions/state_events.lua', true)
local boundary = 'SMODS.cards_to_draw = (SMODS.cards_to_draw or 0) + hand_space'
if native then
    local body = section(native, 'G.FUNCS.draw_from_deck_to_hand = function(e)', 'G.FUNCS.discard_cards_from_highlighted = function')
    local a = assert(body:find(boundary, 1, true)); assert(not body:find(boundary, a + #boundary, true))
    local own_call = 'cards_to_draw, hand_space = reality_warp_prepare_action_draw(cards_to_draw, hand_space)'
    local applied = body:find(own_call, 1, true)
    if applied then assert(not body:find(own_call, applied + #own_call, true))
    else body = body:sub(1, a - 1) .. own_call .. '\n' .. body:sub(a) end
    assert(loadstring(body))()
else
    print('SKIP: installed native draw integration (no Lovely dump); pure selection controls still run')
end
local smods_source = read(REPO_ROOT .. '/../smods/src/utils.lua', true)
if smods_source then
    assert(loadstring(section(smods_source, 'function SMODS.draw_cards(hand_space)', 'function SMODS.showman')))()
else
    SMODS.draw_cards = function(n)
        local flags = SMODS.calculate_context({drawing_cards = true, amount = n})
        for _ = 1, math.min(#G.deck.cards, flags.cards_to_draw or flags.modify or n) do draw_card(G.deck, G.hand) end
    end
    print('SKIP: installed SMODS.draw_cards integration; independent API model only')
end

assert(blinds.ouroboros.modifies_draw == true)
for _, held in ipairs({0, 2, 4, 6, 8, 10}) do
    for deck = 0, 5 do
        reset(held, deck)
        local selected, n = reality_warp_prepare_action_draw({}, 8 - held)
        assert(n == math.min(3, deck) and #selected == n)
        for i, c in ipairs(selected) do assert(c == G.deck.cards[deck - i + 1]) end
        assert(select(2, reality_warp_prepare_action_draw({}, 8)) == 0, 'same action cannot draw again')
    end
end
if native then
    for _, held in ipairs({0, 2, 4, 6, 8, 10}) do
        for _, modifier in ipairs({0, 1, -1, 2}) do
            reset(held, 8)
            for _, c in ipairs(G.deck.cards) do c.ability.card_limit = math.max(0, modifier); c.ability.extra_slots_used = math.max(0, -modifier) end
            G.FUNCS.draw_from_deck_to_hand(99)
            assert(#requested == 3, 'exact three physical Cards despite ignored argument or slot cost')
            drain(); assert(#transferred == 3 and SMODS.cards_to_draw == 0)
            local seen = {}; for _, c in ipairs(transferred) do assert(not seen[c]); seen[c] = true end
            G.FUNCS.draw_from_deck_to_hand(); drain(); assert(#transferred == 3, 'no duplicate refill')
        end
    end
    reset(0, 10); G.GAME.current_round.hands_played = 0
    G.FUNCS.draw_from_deck_to_hand(); drain(); assert(#transferred == 8, 'initial hand remains native')
    for _, state in ipairs({G.STATES.TAROT_PACK, G.STATES.SPECTRAL_PACK, G.STATES.SMODS_BOOSTER_OPENED, G.STATES.SELECTING_HAND}) do
        reset(4, 10); G.STATE = state; G.FUNCS.draw_from_deck_to_hand(); drain(); assert(#transferred == 4)
    end
    reset(2, 10); G.GAME.blind.disabled = true; G.FUNCS.draw_from_deck_to_hand(); drain(); assert(#transferred == 6)
end
reset(2, 10, 'bl_other'); assert(not reality_warp_fixed_action_draw())
local s1, s2 = possession('possessed_serpent'), possession('possessed_serpent')
G.GAME.blind.disabled = true; assert(reality_warp_fixed_action_draw(), 'possession survives Blind disable')
local r = pack(SMODS.blind_modifies_draw('bl_other', 'extra', nil))
assert(r.n == 3 and r[1] and r[2] == 'lower' and r[3] == nil and lower_args.n == 3)
for i = 1, 5 do stickers.possessed_serpent:calculate(s1, {discard = true}) end
stickers.possessed_serpent:calculate(s1, {after = true}); assert(#requested == 0)
assert(stickers.possessed_serpent:calculate(s1, {individual = true, cardarea = G.play}).chips == 30)
assert(stickers.possessed_serpent:calculate(s2, {individual = true, cardarea = G.play}).chips == 30)
local selected, amount = reality_warp_prepare_action_draw({}, 6); assert(amount == 3)
-- A fresh game object models a cold process: requeue only the untransferred IDs.
local function restore_game()
    local restored = {}; for k, v in pairs(G.GAME) do restored[k] = v end
    local saved = G.GAME.reality_warp_action_draw_plan
    restored.reality_warp_action_draw_plan = {id = saved.id, key = saved.key, hands = saved.hands,
        discards = saved.discards, cards = {}}
    for _, id in ipairs(saved.cards) do
        restored.reality_warp_action_draw_plan.cards[#restored.reality_warp_action_draw_plan.cards + 1] =
            {sort_id = id.sort_id, playing_card = id.playing_card}
    end
    G.GAME = restored
    local function copy_data(value)
        if type(value) ~= 'table' then return value end
        local t = {}; for k, v in pairs(value) do t[k] = copy_data(v) end; return t
    end
    for _, key in ipairs({'deck', 'hand', 'discard', 'jokers'}) do
        local original_area, restored_area = G[key], area()
        for _, c in ipairs(original_area.cards) do
            local fresh = {id = c.id, sort_id = c.sort_id, playing_card = c.playing_card,
                area = restored_area, ability = copy_data(c.ability)}
            restored_area.cards[#restored_area.cards + 1] = fresh
        end
        G[key] = restored_area
    end
    SMODS.cards_to_draw = nil; queue = {}
end
G.deck:remove_card(selected[1]); G.hand:emplace(selected[1]); restore_game()
local remainder, n = reality_warp_prepare_action_draw({}, 6)
assert(n == 2 and remainder[1] ~= selected[2] and remainder[1].sort_id == selected[2].sort_id and
    remainder[2] ~= selected[3] and remainder[2].sort_id == selected[3].sort_id, 'resolve fresh Cards by stable ID')
for _, c in ipairs(remainder) do G.deck:remove_card(c); G.hand:emplace(c) end
restore_game(); assert(select(2, reality_warp_prepare_action_draw({}, 6)) == 0, 'completed cold restore draws no extra cards')
G.GAME.current_round.discards_used = 1; assert(select(2, reality_warp_prepare_action_draw({}, 6)) == 3)
G.GAME.reality_warp_active_encounter.id = 2; assert(select(2, reality_warp_prepare_action_draw({}, 6)) == 3)
s1, s2 = G.jokers.cards[1], G.jokers.cards[2]
s1.debuff = true; s2.removed = true; assert(not reality_warp_fixed_action_draw())
assert(pack(SMODS.blind_modifies_draw('bl_other')).n == 3)
-- Execute the native automatic hand-limit refill owner when installed.
if smods_source then
    CardArea = {}
    SMODS.should_handle_limit = function() return true end
    function check_for_unlock() end
    assert(loadstring(section(smods_source, 'function CardArea:handle_card_limit()', 'function SMODS.get_atlas')))()
    reset(2, 10, 'bl_other'); local serpent = possession('possessed_serpent')
    G.hand.config.card_limits = {base = 8, mod = 0, old_slots = 8}
    G.hand.count_property = function(self, key)
        local n = 0; for _, c in ipairs(self.cards) do n = n + (c.ability[key] or 0) end; return n
    end
    CardArea.handle_card_limit(G.hand); assert(#queue == 0, 'live Serpent suppresses native auto-refill')
    if native then
        serpent.debuff = true; CardArea.handle_card_limit(G.hand)
        assert(#queue == 1 and SMODS.draw_queued); drain(); assert(#transferred == 6)
    end
end
reset(2, 10, 'bl_other'); s1 = possession('possessed_serpent')
s1.debuff = nil; G.GAME.facing_blind = false; assert(not reality_warp_fixed_action_draw())
G.GAME.facing_blind = true; G.GAME.reality_warp_active_encounter.phase = 'defeated'; assert(not reality_warp_fixed_action_draw())

reset(2, 20, 'bl_other'); possession('possessed_serpent'); G.STATE = G.STATES.HAND_PLAYED
local w1, w2 = possession('possessed_water'), possession('possessed_water')
stickers.possessed_water:calculate(w1, {before = true}); assert(#requested == 4)
stickers.possessed_water:calculate(w1, {before = true, potion_mirror_retrigger = true}); assert(#requested == 4)
for _, flag in ipairs({'blueprint', 'individual', 'repetition', 'retrigger_joker'}) do
    local c = {before = true}; c[flag] = true; stickers.possessed_water:calculate(w2, c); assert(#requested == 4)
end
stickers.possessed_water:calculate(w2, {before = true}); assert(#requested == 8)
drain(); assert(#transferred == 8)
G.GAME.current_round.hands_played = 2; G.STATE = G.STATES.DRAW_TO_HAND
stickers.possessed_water:calculate(w1, {before = true}); assert(#requested == 12, 'explicit Water draw is not restricted to three')
drain(); assert(#transferred == 12)
local original_draw = SMODS.draw_cards; SMODS.draw_cards = function() error('test draw failure') end
G.GAME.current_round.hands_played = 3
assert(not pcall(reality_warp_draw_water_cards, w1, {before = true}))
assert(reality_warp_fixed_action_draw(), 'explicit scope restored after error')
SMODS.draw_cards = original_draw

reset(5, 0, 'bl_other'); G.STATE = G.STATES.HAND_PLAYED
local h1, h2 = possession('possessed_hook'), possession('possessed_hook')
stickers.possessed_hook:calculate(h1, {before = true})
assert(#G.discard.cards == 2 and #G.hand.cards == 3 and rolls == 2 and h1.ability.hook_bonus == 2.5)
assert(G.discard.cards[1] ~= G.discard.cards[2] and #queue == 0)
stickers.possessed_hook:calculate(h1, {before = true}); assert(#G.discard.cards == 2 and rolls == 2)
stickers.possessed_hook:calculate(h2, {before = true}); assert(#G.discard.cards == 4 and h2.ability.hook_bonus == 2.5)
assert(stickers.possessed_hook:calculate(h1, {joker_main = true}).x_mult == 2.5)
stickers.possessed_hook:calculate(h1, {after = true}); assert(h1.ability.hook_bonus == nil)
for held = 0, 1 do
    reset(held, 0, 'bl_other'); local h = possession('possessed_hook')
    stickers.possessed_hook:calculate(h, {before = true}); assert(#G.discard.cards == held and h.ability.hook_bonus == 1 + held * 0.75)
end
reset(2, 0, 'bl_other'); local h = possession('possessed_hook')
local original_remove = G.hand.remove_card
G.hand.remove_card = function(_, target) return target end
stickers.possessed_hook:calculate(h, {before = true}); assert(#G.discard.cards == 0 and h.ability.hook_bonus == 1)
G.hand.remove_card = original_remove
reset(2, 0, 'bl_other'); h = possession('possessed_hook'); h.debuff = true
stickers.possessed_hook:calculate(h, {before = true}); assert(#G.discard.cards == 0 and rolls == 0)
reset(2, 0, 'bl_other'); h = possession('possessed_hook')
local original_sample = pseudorandom_element
pseudorandom_element = function(pool)
    G.GAME.reality_warp_active_encounter.id = 999; return pool[1]
end
stickers.possessed_hook:calculate(h, {before = true})
assert(#G.discard.cards == 0 and h.ability.hook_bonus == nil, 'changed action cannot own a transfer or bonus')
pseudorandom_element = original_sample
assert(not read(REPO_ROOT .. '/src/blinds/fused_blinds.lua'):find('local orig_draw_from_deck_to_hand', 1, true))
