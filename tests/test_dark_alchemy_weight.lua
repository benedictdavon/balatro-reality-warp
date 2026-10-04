local function read(path)
    local f = assert(io.open(REPO_ROOT .. '/' .. path)); local s = f:read('*a'); f:close(); return s
end
local function region(path, first, following)
    local s = read(path); local a = assert(s:find(first, 1, true))
    return s:sub(a, assert(s:find(following, a + #first, true)) - 1)
end
local function pack(...) return {n = select('#', ...), ...} end
local function area() return {T = {x = 0, y = 0, w = 1}} end
G = {GAME = {edition_rate = 1, banned_keys = {}, used_jokers = {}, modifiers = {},
    round_resets = {ante = 1}, selected_back = {pos = {}}, current_round = {reroll_cost_increase = 0}},
    shop_jokers = area(), pack_cards = area(), jokers = area(), consumeables = area(),
    P_CENTERS = {}, P_CARDS = {}, CARD_W = 1, CARD_H = 1, C = {DARK_EDITION = {}}}
SMODS = {optional_features = {}, Attributes = {}, ObjectTypes = {},
    Consumable = {legendaries = {}}, Sticker = {obj_buffer = {}}, Stickers = {},
    log_crash_info = function() return '' end}
function HEX(x) return x end
SMODS.Edition = {take_ownership = function(_, key, def)
    def.key = 'e_' .. key; def.set = 'Edition'; G.P_CENTERS[def.key] = def
end}
assert(loadstring(region('../smods/src/game_object.lua', "SMODS.Edition:take_ownership('foil',", '------- API CODE GameObject.Keybind')))()
dofile(REPO_ROOT .. '/../smods/src/utils/weights.lua')
local edition_pool = {'e_foil', 'e_holo', 'e_polychrome', 'e_negative'}
-- Known-eligible pool, culling/context and visual/Card sinks are adapters.
-- Native edition/create/poll_object algorithms and edition getters are loaded.
function get_current_pool(kind)
    if kind == 'Edition' then return edition_pool end
    return {'j_test'}, 'known-joker-pool'
end
SMODS.cull_pool = function(pool) return pool end
SMODS.calculate_context = function() return {} end
function pseudoseed(key) return key end
local sample, rng_calls, poll_args, initial_edition = 0.98, {}, {}, nil
function pseudorandom(key)
    rng_calls[key] = (rng_calls[key] or 0) + 1
    return sample
end
function pseudorandom_element(pool) return pool[1], 1 end
function check_for_unlock() end
function Card(_, _, _, _, _, center)
    return {ability = {set = center.set}, config = {center = center}, edition = initial_edition,
        set_edition = function(self, edition) self.edition = edition end,
        remove = function(self) self.removed = true end,
        start_materialize = function() end}
end
G.P_CENTERS.j_test = {key = 'j_test', set = 'Joker', rarity = 1, weight = 10}
G.P_CENTERS.c_test = {key = 'c_test', set = 'Tarot'}
assert(loadstring(region('../smods/src/overrides.lua', 'function poll_edition(', '\n-- local cge = Card.get_edition')))()
local native_poll = poll_edition
-- Record all forwarded arguments/returns without altering the native first result.
poll_edition = function(...)
    poll_args = pack(...)
    return native_poll(...), nil, 'post', nil
end
assert(loadstring(region('../lovely/dump/functions/common_events.lua', 'function create_card(', '\nfunction copy_card(')))()
local native_rng = pseudorandom
local native_create = create_card
dofile(REPO_ROOT .. '/src/core/edition_rules.lua')
local owned_create = reality_warp_wrap_alchemy_create(native_create)
local function generate(active, owner_area, kind, forced, append)
    G.GAME.dark_alchemy_tag_active = active
    rng_calls = {}
    return owned_create(kind or 'Joker', owner_area or G.shop_jokers, nil, nil, true, false, forced or 'j_test', append or 'sho')
end
local function owned_poll(active, no_neg, guaranteed, options, modifier)
    G.GAME.dark_alchemy_tag_active = active; rng_calls = {}
    local lower = reality_warp_wrap_alchemy_create(function()
        return poll_edition('edisho1', modifier, no_neg, guaranteed, options, 'tail', nil)
    end)
    return pack(lower('Joker', G.shop_jokers, nil, nil, true, false, 'j_test', 'sho'))
end
for _, weighted in ipairs({false, true}) do
    SMODS.optional_features.object_weights = weighted
    local function counts(active)
        local counts = {none = 0}
        for i = 1, 10000 do
            sample = (i - 0.5)/10000
            local card = generate(active)
            local edition = card.edition or 'none'
            counts[edition] = (counts[edition] or 0) + 1
            assert(rng_calls.edisho1 == 1, 'one native edition sample per creation')
            for key in pairs(rng_calls) do
                assert(not key:find('dark_alchemy', 1, true), 'no additional Alchemy sample')
            end
        end
        return counts
    end
    local baseline, boosted = counts(false), counts(true)
    assert(baseline.e_negative == 30 and boosted.e_negative == 300)
    for key, n in pairs({e_polychrome = 30, e_holo = 140, e_foil = 200}) do
        assert(baseline[key] == n and boosted[key] == n, 'other edition intervals unchanged')
    end
    assert(G.P_CENTERS.e_negative.weight == 3)
    -- Native exclusions/options retain exactly the native result for each sample.
    for _, value in ipairs({0.4, 0.97, 0.985, 0.9975, 0.9995}) do
        sample = value
        for _, control in ipairs({{true, false}, {false, true}, {false, false, {'e_foil'}},
            {false, false, {{name = 'e_foil', weight = 20}, {name = 'e_negative', weight = 3}}}}) do
            local a = owned_poll(false, unpack(control))
            local b = owned_poll(true, unpack(control))
            assert(a[1] == b[1] and b.n == 4 and b[2] == nil and b[3] == 'post' and b[4] == nil)
            assert(poll_args.n == 7 and poll_args[5] == control[3] and poll_args[6] == 'tail')
            assert(rng_calls.edisho1 == 1)
        end
    end
    sample = 0.98
    assert(owned_poll(true, false, false, {'e_negative', 'e_foil'})[1] == 'e_negative')
    sample = 0.996
    assert(generate(true, G.pack_cards).edition == 'e_negative')
    assert(generate(true, G.jokers).edition ~= 'e_negative')
    -- A suffix alone grants no ownership, and actual forced type wins.
    assert(generate(true, G.consumeables, 'Joker', 'j_test', 'shop_pack').edition ~= 'e_negative')
    assert(generate(true, G.shop_jokers, 'Spectral', 'j_test').edition == 'e_negative')
    assert(generate(true, G.shop_jokers, 'Joker', 'c_test').edition == nil)
    initial_edition = 'e_foil'; assert(generate(true).edition == 'e_foil' and not rng_calls.edisho1); initial_edition = nil
    SMODS.bypass_create_card_edition = true; assert(generate(true).edition == nil and not rng_calls.edisho1); SMODS.bypass_create_card_edition = nil
    -- Unit versus doubled native mod: Negative interval doubles under either backend.
    sample = 0.95; assert(owned_poll(true, false, false, nil, 2)[1] == 'e_negative')
    G.GAME.edition_rate = 2; sample = 0.98
    assert(generate(true).edition == 'e_negative'); assert(G.P_CENTERS.e_negative.weight == 3)
    G.GAME.edition_rate = 1
end
SMODS.optional_features.object_weights = false; G.GAME.dark_alchemy_tag_active = true; sample = 0.98
local short_create = reality_warp_wrap_alchemy_create(function(...) return select('#', ...), ... end)
assert(short_create() == 0 and short_create('Joker', G.jokers) == 2)
poll_edition('arity-only'); assert(poll_args.n == 1)
local outside = pack(poll_edition('edisho1', nil, nil, nil, {'e_foil'}, 'tail', nil))
assert(outside.n == 4 and outside[1] ~= 'e_negative' and poll_args[5][1] == 'e_foil')
assert(poll_edition('aura') ~= 'e_negative', 'unowned polls stay native')
-- Late external concrete getter modifiers compose once, including older RW wrappers.
local prior = G.P_CENTERS.e_negative.get_weight
G.P_CENTERS.e_negative.get_weight = function(self, ...) return prior(self, ...) * 2, 'weight-post', nil end
sample = 0.95; assert(generate(true).edition == 'e_negative') -- .06, not .60
sample = 0.9; assert(generate(true).edition ~= 'e_negative')
local unowned_weight = pack(G.P_CENTERS.e_negative:get_weight('extra', nil))
assert(unowned_weight.n == 3 and unowned_weight[1] == 6 and unowned_weight[2] == 'weight-post')
G.P_CENTERS.e_negative.get_weight = prior
-- An unowned nested poll must clear poll ownership, even inside the getter.
local nested_result
G.P_CENTERS.e_negative.get_weight = function(self, ...)
    if not self.in_nested then
        self.in_nested = true; nested_result = poll_edition('unowned-nested'); self.in_nested = nil
    end
    return prior(self, ...)
end
sample = 0.98; assert(generate(true).edition == 'e_negative'); assert(nested_result ~= 'e_negative')
G.P_CENTERS.e_negative.get_weight = prior
-- Nested creation restores its parent's scope; each owned creation gets one poll.
local forwarded_create
local nested_create = reality_warp_wrap_alchemy_create(function(...)
    forwarded_create = pack(...)
    assert(generate(true, G.jokers).edition ~= 'e_negative')
    return native_create(...), nil, 'create-post', nil
end)
local made = pack(nested_create('Joker', G.shop_jokers, nil, nil, true, false, 'j_test', 'outer', 'tail', nil))
assert(made.n == 4 and made[1].edition == 'e_negative' and made[3] == 'create-post')
assert(forwarded_create.n == 10 and forwarded_create[9] == 'tail' and forwarded_create[10] == nil)
local single = reality_warp_wrap_alchemy_create(function()
    local first = poll_edition('edisho1')
    local second = poll_edition('edisho1')
    assert(first == 'e_negative' and second ~= 'e_negative', 'only initial owned poll gets boost')
end)
single('Joker', G.shop_jokers, nil, nil, true, false, 'j_test', 'sho')
assert(G.P_CENTERS.e_negative:get_weight() == 3)
local marker = {}
local failure = reality_warp_wrap_alchemy_create(function() poll_edition('edisho1'); error(marker) end)
local ok, err = pcall(failure, 'Joker', G.shop_jokers, nil, nil, true, false, 'j_test', 'sho')
assert(not ok and err == marker and poll_edition('edisho1') ~= 'e_negative')
G.P_CENTERS.e_negative.get_weight = function() error(marker) end
ok, err = pcall(generate, true); assert(not ok and err == marker)
G.P_CENTERS.e_negative.get_weight = prior
assert(generate(true).edition == 'e_negative' and G.P_CENTERS.e_negative:get_weight() == 3)
-- A new run or expired tag during the getter cannot receive permanent old ownership.
G.P_CENTERS.e_negative.get_weight = function(self, ...) G.GAME.dark_alchemy_tag_active = nil; return prior(self, ...) end
assert(generate(true).edition ~= 'e_negative')
G.P_CENTERS.e_negative.get_weight = prior
local old_game = G.GAME
G.P_CENTERS.e_negative.get_weight = function(self, ...)
    local new_game = {}; for k,v in pairs(G.GAME) do new_game[k] = v end; G.GAME = new_game
    return prior(self, ...)
end
assert(generate(true).edition ~= 'e_negative', 'new run cannot inherit old scope')
G.GAME = old_game; G.P_CENTERS.e_negative.get_weight = prior
local old_shop = G.shop_jokers
G.P_CENTERS.e_negative.get_weight = function(self, ...) G.shop_jokers = area(); return prior(self, ...) end
assert(generate(true).edition ~= 'e_negative', 'replaced area cannot inherit old scope')
G.shop_jokers = old_shop; G.P_CENTERS.e_negative.get_weight = prior
assert(pseudorandom == native_rng, 'global RNG is untouched')
-- Execute the actual utils generation wrapper to cover voucher and duplicate lower calls.
local critic, duplicate_once, owned_calls, removed_cards = false, false, {}, 0
function clean_leaked_duplicate_flags() end
function sync_owned_jokers_to_used() end
function is_common_rarity(rarity) return rarity == 1 end
function has_critic_voucher() return critic end
function has_taster_voucher() return false end
function player_has_showman() return false end
function is_joker_owned_by_player() if duplicate_once then duplicate_once = false; return true end; return false end
create_card = function(kind, owner_area, legendary, rarity, skip, soulable, forced, append)
    local card = native_create(kind, owner_area, legendary, rarity, skip, soulable, forced, append)
    card.config = {center = {rarity = rarity or 1}} -- voucher selection adapter
    card.remove = function() removed_cards = removed_cards + 1 end
    owned_calls[#owned_calls + 1] = {append = append, edition = card.edition}
    return card
end
assert(loadstring(region('src/core/utils.lua', '-- Card generation hook for La Muchachada', '-- Falta de Lectura activation tracker')))()
G.GAME.dark_alchemy_tag_active = true; sample = 0.98; critic = true; duplicate_once = true
local replaced = create_card('Joker', G.shop_jokers, nil, nil, true, false, nil, 'sho')
assert(#owned_calls == 3 and removed_cards == 2 and replaced.edition == 'e_negative')
assert(owned_calls[1].append == 'sho' and owned_calls[2].append == 'sho_vup' and owned_calls[3].append == 'sho_nodup1')
for _, result in ipairs(owned_calls) do assert(result.edition == 'e_negative') end
-- Actual Tag activation is synchronous; delayed fee callback never gates first stock.
local tag_definition, fee_callback
SMODS.Tag = function(def) tag_definition = def end
function calculate_reroll_cost() end
assert(loadstring(region('src/tags/tags.lua', '-- 9. Dark Alchemy Tag', '-- 10. Contractor Tag')))()
G.GAME.dark_alchemy_tag_active = nil
local tag = {yep = function(_, _, _, callback) fee_callback = callback end}
assert(tag_definition:apply(tag, {type = 'shop_start'}) and G.GAME.dark_alchemy_tag_active and tag.triggered)
assert(create_card('Joker', G.shop_jokers, nil, nil, true, false, 'j_test', 'sho').edition == 'e_negative')
assert(G.GAME.round_resets.temp_reroll_cost == nil)
assert(fee_callback()); assert(G.GAME.round_resets.temp_reroll_cost == 7)
tag_definition:apply(tag, {type = 'end_of_round'}); assert(not G.GAME.dark_alchemy_tag_active)
assert(not read('src/core/utils.lua'):find("'_dark_alchemy'", 1, true))
assert(not read('src/core/utils.lua'):find("'dark_alchemy_'", 1, true))
-- Private scopes are absent from serialized run state; Lucky resources unchanged.
for key in pairs(G.GAME) do assert(not key:find('alchemy_scope', 1, true)) end
print('PASS: owned Dark Alchemy native creation/legacy/object weights, deterministic intervals, exclusions, nesting, errors, replacements and tag lifecycle')
