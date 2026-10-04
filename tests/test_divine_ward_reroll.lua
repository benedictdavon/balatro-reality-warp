local function read(path)
    local file = assert(io.open(REPO_ROOT .. '/' .. path, 'rb'))
    local value = file:read('*a')
    file:close()
    return (value:gsub('\r\n', '\n'))
end

local function count(text, needle)
    local total, position = 0, 1
    while true do
        local first = text:find(needle, position, true)
        if not first then return total end
        total = total + 1
        position = first + #needle
    end
end

local function split_lines(text)
    local lines, first = {}, 1
    while true do
        local newline = text:find('\n', first, true)
        if not newline then
            lines[#lines + 1] = text:sub(first)
            return lines
        end
        lines[#lines + 1] = text:sub(first, newline - 1)
        first = newline + 1
    end
end

local function trim_line(line)
    return line:gsub('^%s+', ''):gsub('%s+$', '')
end

local function normalize_source_lines(source)
    local lines = split_lines(source)
    for index, line in ipairs(lines) do lines[index] = trim_line(line) end
    return table.concat(lines, '\n')
end

local function normalized_matches(source, snippet)
    local lines, expected = split_lines(source), split_lines(snippet)
    local hits = {}
    for start = 1, #lines - #expected + 1 do
        local matched = true
        for offset = 1, #expected do
            if trim_line(lines[start + offset - 1]) ~= trim_line(expected[offset]) then
                matched = false
                break
            end
        end
        if matched then hits[#hits + 1] = start end
    end
    return hits, lines, expected
end

local function count_normalized(source, snippet)
    local hits = normalized_matches(source, snippet)
    return #hits
end

local function replace_normalized(source, old, new)
    local hits, source_lines, old_lines = normalized_matches(source, old)
    local new_lines = split_lines(new)
    for hit_index = #hits, 1, -1 do
        local first = hits[hit_index]
        local indent = source_lines[first]:match('^([ \t]*)') or ''
        local inserted = {}
        for _, line in ipairs(new_lines) do inserted[#inserted + 1] = indent .. line end
        for _ = 1, #old_lines do table.remove(source_lines, first) end
        for offset = #inserted, 1, -1 do table.insert(source_lines, first, inserted[offset]) end
    end
    return table.concat(source_lines, '\n'), #hits
end

local function compile(source, name)
    local fn, err = loadstring(source, name)
    assert(fn, err)
    return fn
end

local function normalize_lines(text)
    local lines = {}
    for line in (text .. '\n'):gmatch('(.-)\n') do
        lines[#lines + 1] = line:gsub('^%s+', ''):gsub('%s+$', '')
    end
    return table.concat(lines, '\n')
end

local function indent_lines(text, indent)
    return indent .. text:gsub('\n', '\n' .. indent)
end

local function replace_literal(text, pattern, replacement)
    local pieces, previous, total = {}, 1, 0
    while true do
        local first, last = text:find(pattern, previous, true)
        if not first then break end
        pieces[#pieces + 1] = text:sub(previous, first - 1)
        pieces[#pieces + 1] = replacement
        previous, total = last + 1, total + 1
    end
    pieces[#pieces + 1] = text:sub(previous)
    return table.concat(pieces), total
end

local function replace_first_literal(text, pattern, replacement)
    local first, last = text:find(pattern, 1, true)
    if not first then return text, 0 end
    return text:sub(1, first - 1) .. replacement .. text:sub(last + 1), 1
end

local function normalize_patch_state(source, patch, expected_count, name)
    local original_count = count_normalized(source, patch.pattern)
    local applied_count = count_normalized(source, patch.payload)
    if original_count == expected_count and applied_count == 0 then return source, 'original' end
    if original_count == 0 and applied_count == expected_count then
        local restored, replaced = replace_normalized(source, patch.payload, patch.pattern)
        assert(replaced == expected_count)
        return restored, 'applied'
    end
    error(name .. ' must be wholly original or wholly applied; found original=' .. original_count ..
        ', applied=' .. applied_count .. ', expected=' .. expected_count)
end

local function assert_consistent_dump_states(fees, affordability, ui)
    assert(fees == affordability and affordability == ui,
        'Installed reroll source must be entirely original or contain every complete Reality Warp payload')
end

local function toml_field(section, name)
    local marker = name .. ' = '
    local start = assert(section:find(marker, 1, true)) + #marker
    local opening = section:sub(start, start + 2)
    if opening == "'''" or opening == '"""' then
        local closing = assert(section:find(opening, start + 3, true))
        return section:sub(start + 3, closing - 1)
    end
    local quote = section:sub(start, start)
    if quote == "'" or quote == '"' then
        local closing = assert(section:find(quote, start + 1, true))
        return section:sub(start + 1, closing - 1)
    end
    return section:sub(start):match('^([^\r\n]+)')
end

local function find_toml_patch(toml, target_name, pattern_part)
    local cursor = 1
    while true do
        local first = toml:find('[[patches]]', cursor, true)
        if not first then break end
        local next_patch = toml:find('[[patches]]', first + 1, true)
        local section = toml:sub(first, next_patch and next_patch - 1 or #toml)
        local target = toml_field(section, 'target')
        local pattern = toml_field(section, 'pattern')
        if target == target_name and pattern:find(pattern_part, 1, true) then
            return {pattern = pattern, payload = toml_field(section, 'payload'),
                times = tonumber(section:match('times = (%d+)'))}
        end
        cursor = next_patch or (#toml + 1)
    end
    error('Missing Lovely patch for ' .. target_name .. ' containing ' .. pattern_part)
end

local lovely = read('lovely/lovely.toml')
local fee_line = 'if not G.from_boss_tag then ease_dollars(-10) end'
local fee_patch = find_toml_patch(lovely, 'functions/button_callbacks.lua', fee_line)
local afford_patch = find_toml_patch(lovely, 'functions/button_callbacks.lua', 'G.GAME.dollars-G.GAME.bankrupt_at')
local ui_patch = find_toml_patch(lovely, 'functions/UI_definitions.lua', 'UIBox_button({label = {localize')
assert(fee_patch.times == 2 and fee_patch.payload:find('reality_warp_pay_boss_reroll()', 1, true))
assert(afford_patch.times == 1 and afford_patch.payload:find('reality_warp_divine_ward_free_available()', 1, true))
assert(ui_patch.times == 1 and ui_patch.payload:find('reality_warp_boss_reroll_button_visible()', 1, true))

local raw_callbacks = read('../lovely/dump/functions/button_callbacks.lua')
local native_callbacks, fee_dump_state = normalize_patch_state(
    raw_callbacks, fee_patch, 2, 'installed reroll fee patch')
local affordability_dump_state
native_callbacks, affordability_dump_state = normalize_patch_state(
    native_callbacks, afford_patch, 1, 'installed reroll affordability patch')
assert((fee_dump_state == 'original' or fee_dump_state == 'applied') and
    (affordability_dump_state == 'original' or affordability_dump_state == 'applied'))
local callbacks = normalize_source_lines(native_callbacks)
local applied_fee_fixture, applied_fee_count = replace_normalized(native_callbacks, fee_patch.pattern, fee_patch.payload)
assert(applied_fee_count == 2)
local restored_fee_fixture, fee_fixture_state = normalize_patch_state(applied_fee_fixture, fee_patch, 2, 'applied fee fixture')
assert(fee_fixture_state == 'applied' and normalize_lines(restored_fee_fixture) == normalize_lines(native_callbacks))
local mixed_fee_fixture = replace_first_literal(applied_fee_fixture, fee_patch.payload, fee_patch.pattern)
assert(not pcall(normalize_patch_state, mixed_fee_fixture, fee_patch, 2, 'mixed fee fixture'))
local duplicate_fee_fixture = applied_fee_fixture .. '\n' .. fee_patch.payload
assert(not pcall(normalize_patch_state, duplicate_fee_fixture, fee_patch, 2, 'duplicate fee fixture'))
local applied_afford_fixture, applied_afford_count = replace_normalized(native_callbacks, afford_patch.pattern, afford_patch.payload)
assert(applied_afford_count == 1)
local restored_afford_fixture, afford_fixture_state = normalize_patch_state(
    applied_afford_fixture, afford_patch, 1, 'applied affordability fixture')
assert(afford_fixture_state == 'applied' and normalize_lines(restored_afford_fixture) == normalize_lines(native_callbacks))
local mixed_afford_fixture = native_callbacks .. '\n' .. afford_patch.payload
assert(not pcall(normalize_patch_state, mixed_afford_fixture, afford_patch, 1, 'mixed affordability fixture'))
local both_applied_fixture = replace_normalized(applied_afford_fixture, fee_patch.pattern, fee_patch.payload)
local both_applied_fee_restored, both_fee_state = normalize_patch_state(both_applied_fixture, fee_patch, 2, 'both-applied fee fixture')
local both_applied_restored, both_afford_state = normalize_patch_state(both_applied_fee_restored, afford_patch, 1, 'both-applied affordability fixture')
assert(both_fee_state == 'applied' and both_afford_state == 'applied')
assert(normalize_lines(normalize_source_lines(both_applied_restored)) == normalize_lines(normalize_source_lines(native_callbacks)))
local button_start = assert(callbacks:find('G.FUNCS.reroll_boss_button = function(e)', 1, true))
local reroll_start = assert(callbacks:find('G.FUNCS.reroll_boss = function(e)', button_start, true))
local shop_start = assert(callbacks:find('\n\nG.FUNCS.reroll_shop = function(e)', reroll_start, true))
local button_source = callbacks:sub(button_start, reroll_start - 1)
local reroll_source = callbacks:sub(reroll_start, shop_start - 1)
local patched_button_source, replaced_affordability = replace_normalized(button_source, afford_patch.pattern, afford_patch.payload)
assert(replaced_affordability == 1)

-- The installed dump already contains Steamodded's priority -10 no-UI branch.
-- It has one fee there and one in the native UI path; the priority-0 patch replaces both.
assert(count(reroll_source, 'if not G.blind_select_opts then') == 1)
assert(count(reroll_source, fee_line) == 2)
assert(reroll_source:find('if not G.blind_select_opts then', 1, true) < reroll_source:find(fee_line, 1, true))
assert(reroll_source:find(fee_line, 1, true) < reroll_source:find('stop_use()', 1, true))
local first_fee = reroll_source:find(fee_line, 1, true)
assert(reroll_source:find(fee_line, first_fee + #fee_line, true) > reroll_source:find('stop_use()', 1, true))
local patched_reroll_source, replaced_fees = replace_normalized(reroll_source, fee_patch.pattern, fee_patch.payload)
assert(replaced_fees == 2)
assert(count(patched_reroll_source, fee_line) == 0 and count(patched_reroll_source, fee_patch.payload) == 2)

local smods_tags = read('../smods/lovely/tag.toml')
assert(smods_tags:find('priority = -10', 1, true))
assert(count(smods_tags, fee_line) == 1)
local smods_patch_start = assert(smods_tags:find('pattern = "G.FUNCS.reroll_boss = function(e)"', 1, true))
local smods_payload_marker = "payload = '''"
local smods_payload_start = assert(smods_tags:find(smods_payload_marker, smods_patch_start, true)) + #smods_payload_marker
local smods_payload_end = assert(smods_tags:find("'''", smods_payload_start, true))
local smods_payload = smods_tags:sub(smods_payload_start, smods_payload_end - 1)
local header_end = assert(reroll_source:find('\n', 1, true))
local injected_start = assert(reroll_source:find('if not G.blind_select_opts then', header_end, true))
local injected_line_start = header_end + 1
local injected_end = assert(reroll_source:find('\nstop_use()', injected_start, true))
local installed_smods_payload = reroll_source:sub(injected_line_start, injected_end - 1)
assert(normalize_lines(installed_smods_payload) == normalize_lines(smods_payload),
    'The installed dump should contain Steamodded’s one injected no-UI branch exactly once')
local without_smods_injection = reroll_source:sub(1, injected_line_start - 1) .. reroll_source:sub(injected_end)
assert(count(without_smods_injection, fee_line) == 1, 'Removing the priority -10 payload should leave the one native UI fee')
local reinserted_smods = without_smods_injection:sub(1, header_end) ..
    indent_lines(smods_payload, '  ') .. without_smods_injection:sub(header_end + 1)
assert(count(reinserted_smods, fee_line) == 2, 'Applying the priority -10 payload once should create two fee sites')
assert(normalize_lines(reinserted_smods) == normalize_lines(reroll_source),
    'The reconstructed post-Steamodded callback should match the installed dump')
local battle_source = read('src/core/battle_of_gods.lua')
local helpers_start = assert(battle_source:find('-- Mechanic 24: Divine Ward pays at the native reroll fee boundary.', 1, true))
local helpers_end = assert(battle_source:find('\n\nif get_new_boss then', helpers_start, true))
local helper_source = battle_source:sub(helpers_start, helpers_end - 1)

local raw_ui_definitions = read('../lovely/dump/functions/UI_definitions.lua')
local native_ui_definitions, ui_dump_state = normalize_patch_state(
    raw_ui_definitions, ui_patch, 1, 'installed reroll UI insertion')
assert(ui_dump_state == 'original' or ui_dump_state == 'applied')
assert_consistent_dump_states(fee_dump_state, affordability_dump_state, ui_dump_state)
local ui_definitions = normalize_source_lines(native_ui_definitions)
local applied_ui_fixture, applied_ui_count = replace_normalized(native_ui_definitions, ui_patch.pattern, ui_patch.payload)
assert(applied_ui_count == 1)
local restored_ui_fixture, ui_fixture_state = normalize_patch_state(applied_ui_fixture, ui_patch, 1, 'applied UI fixture')
assert(ui_fixture_state == 'applied' and normalize_lines(normalize_source_lines(restored_ui_fixture)) == normalize_lines(ui_definitions))
local mixed_ui_fixture = native_ui_definitions .. '\n' .. ui_patch.payload
assert(not pcall(normalize_patch_state, mixed_ui_fixture, ui_patch, 1, 'mixed UI fixture'))
assert_consistent_dump_states(both_fee_state, both_afford_state, ui_fixture_state)
assert(not pcall(assert_consistent_dump_states, 'applied', 'original', 'original'))
local ui_button_start = assert(ui_definitions:find('function UIBox_button(args)', 1, true))
local ui_button_source = ui_definitions:sub(ui_button_start)
assert(not ui_button_source:find('\nfunction ', 1, true), 'The extracted installed UIBox_button must be bounded to its final definition')
local smods_ui_source = read('../smods/src/ui.lua')
local smods_button_start = assert(smods_ui_source:find('local UIBox_button_ref = UIBox_button', 1, true))
local smods_button_end = assert(smods_ui_source:find('\n\nfunction getModtagInfo', smods_button_start, true))
local smods_button_wrapper = smods_ui_source:sub(smods_button_start, smods_button_end - 1)

local engine_ui = read('../lovely/dump/engine/ui.lua')
local update_text_start = assert(engine_ui:find('function UIElement:update_text()', 1, true))
local update_object_start = assert(engine_ui:find('\nfunction UIElement:update_object()', update_text_start, true))
local update_text_source = engine_ui:sub(update_text_start, update_object_start - 1)

G = {FUNCS = {}, UIT = {R = 'row', C = 'column', T = 'text'},
    C = {RED = 'red', GOLD = 'gold', BLACK = 'black',
        UI = {BACKGROUND_INACTIVE = 'inactive', TEXT_LIGHT = 'light'}},
    LANG = {font = {FONT = {}}}}
UIElement = {}
love = {graphics = {newText = function(_, args)
    return {value = args[2], set = function(self, value) self.value = value end}
end}}
function localize(key)
    if key == '$' then return '$' end
    return key
end

compile(helper_source, 'Reality Warp Divine Ward helpers')()
compile(ui_button_source, 'installed UIBox_button')()
compile(smods_button_wrapper, 'installed Steamodded UIBox_button wrapper')()
compile(update_text_source, 'installed UIElement:update_text')()
local build_reroll_button = compile('return function() return ' .. ui_patch.payload .. ' end',
    'Reality Warp Lovely blind-select button expression')()

local function install_callbacks()
    compile(patched_button_source, 'installed reroll_boss_button with Reality Warp allowance')()
    compile(patched_reroll_source, 'installed post-Steamodded reroll_boss with Reality Warp fees')()
end

local function setup(dollars, ward, vouchers)
    local context = {events = {}, money = {}, fee_calls = 0, selected = 0, saves = 0, stop_uses = 0,
        sounds = 0, attention = 0, ui_recalculations = 0}
    G = {GAME = {battle_of_gods = true, dollars = dollars, bankrupt_at = 0,
        used_vouchers = vouchers or {}, tags = {},
        round_resets = {divine_ward_free = ward, boss_rerolled = false, blind_choices = {}}},
        FUNCS = {}, from_boss_tag = nil,
        C = {RED = 'red', GOLD = 'gold', BLACK = 'black', CLEAR = 'clear',
            UI = {BACKGROUND_INACTIVE = 'inactive', TEXT_LIGHT = 'light'}},
        UIT = {ROOT = 'root', R = 'row', C = 'column', T = 'text'},
        LANG = {font = {FONT = {}}}, CONTROLLER = {locks = {}}, ROOM = {T = {y = 4}},
        E_MANAGER = {add_event = function(_, event) context.events[#context.events + 1] = event end}}
    G.ROOM.jiggle = 0
    ease_dollars = function(amount)
        context.fee_calls = context.fee_calls + 1
        context.money[#context.money + 1] = amount
    end
    attention_text = function() context.attention = context.attention + 1 end
    stop_use = function() context.stop_uses = context.stop_uses + 1 end
    play_sound = function() context.sounds = context.sounds + 1 end
    save_run = function() context.saves = context.saves + 1 end
    Event = function(event) return event end
    get_new_boss = function()
        context.selected = context.selected + 1
        return 'bl_test_boss_' .. context.selected
    end
    get_blind_main_colour = function() return 'blind' end
    mix_colours = function() return 'mixed' end
    create_UIBox_blind_choice = function(slot) return {slot = slot} end
    UIBox_dyn_container = function(nodes) return {nodes = nodes} end
    UIBox = function(args)
        return {args = args, alignment = {offset = {y = 0}},
            set_role = function() end, remove = function() end,
            recalculate = function() context.ui_recalculations = context.ui_recalculations + 1 end}
    end
    G.tags = {}
    G.GAME.tags = {}
    install_callbacks()
    function context:drain_money()
        for _, amount in ipairs(self.money) do G.GAME.dollars = G.GAME.dollars + amount end
        self.money = {}
    end
    return context
end

local function native_button()
    return {config = {}, children = {
        {children = {{config = {}}}}, {children = {{config = {}}}}
    }}
end

local function check_button_enabled(enabled)
    local e = native_button()
    G.FUNCS.reroll_boss_button(e)
    assert((e.config.button == 'reroll_boss') == enabled)
    assert((e.config.colour == G.C.RED) == enabled)
    assert((e.children[1].children[1].config.shadow == true) == enabled)
    return e
end

local function setup_ui_boss()
    local parent = {T = {x = 3}, config = {}, recalculate = function() end}
    local boss = {parent = parent, alignment = {offset = {y = 0}},
        set_role = function() end, remove = function() end}
    G.blind_select_opts = {boss = boss}
end

local function drain_ui_events(context)
    local index = context.event_index or 1
    while index <= #context.events do
        local event = context.events[index]
        index = index + 1
        event.func()
    end
    context.event_index = index
end

local function price_node(button)
    return button.nodes[1].nodes[2].nodes[1]
end

local function make_price_ref()
    local button = build_reroll_button()
    assert(button, 'The shipping blind-select expression should create a button when Ward or a voucher allows it')
    local price = price_node(button)
    assert(price.config.text == '$0')
    assert(price.config.ref_value == 'label' and price.config.ref_table.label == '$0')
    price.UIBox = {recalculate = function() price.recalculations = (price.recalculations or 0) + 1 end}
    UIElement.update_text(price)
    assert(price.config.text_drawable.value == '$0')
    return price
end

-- No-UI route: the available Ward bypasses the fee at every tested balance.
for _, dollars in ipairs({0, 5, 20}) do
    local context = setup(dollars, true)
    assert(reality_warp_boss_reroll_button_visible())
    assert(price_node(build_reroll_button()).config.text == '$0')
    check_button_enabled(true)
    local result = G.FUNCS.reroll_boss({config = {origin = 'no-ui'}})
    assert(result == true and G.GAME.round_resets.boss_rerolled)
    assert(G.GAME.round_resets.divine_ward_free == false and G.GAME.round_resets.blind_choices.Boss == 'bl_test_boss_1')
    assert(context.selected == 1 and context.fee_calls == 0 and #context.money == 0 and #context.events == 0)
    assert(context.attention == 1 and G.GAME.dollars == dollars)
    context:drain_money()
    assert(G.GAME.dollars == dollars)
    assert(not reality_warp_boss_reroll_button_visible())
    assert(build_reroll_button() == nil, 'The shipping UI expression hides a consumed Ward when no voucher applies')
    check_button_enabled(false)
end

-- UI route: multiple live labels follow the same Ward state through the real text drawable.
for _, dollars in ipairs({0, 5, 20}) do
    local context = setup(dollars, true)
    setup_ui_boss()
    assert(reality_warp_boss_reroll_button_visible())
    local first_price, second_price = make_price_ref(), make_price_ref()
    check_button_enabled(true)
    local result = G.FUNCS.reroll_boss({config = {origin = 'ui'}})
    assert(result == nil, 'The existing UI callback has no return value')
    assert(G.GAME.round_resets.boss_rerolled and not G.GAME.round_resets.divine_ward_free)
    assert(context.fee_calls == 0 and #context.money == 0 and G.GAME.dollars == dollars)
    drain_ui_events(context)
    assert(context.selected == 1 and G.GAME.round_resets.blind_choices.Boss == 'bl_test_boss_1')
    assert(context.saves == 1 and context.attention == 1)
    assert(build_reroll_button() == nil)
    UIElement.update_text(first_price)
    UIElement.update_text(second_price)
    assert(first_price.config.ref_table.label == '$10' and first_price.config.text == '$10')
    assert(second_price.config.ref_table.label == '$10' and second_price.config.text == '$10')
    assert(first_price.config.text_drawable.value == '$10' and second_price.config.text_drawable.value == '$10')
    assert(first_price.recalculations == 2 and second_price.recalculations == 2)
    check_button_enabled(false)
end

-- Once consumed, normal payment is queued once; Retcon allows a repeat, while Director's Cut stays spent.
local paid_context = setup(20, true, {v_retcon = true, v_directors_cut = true})
setup_ui_boss()
local paid_price = make_price_ref()
check_button_enabled(true)
G.FUNCS.reroll_boss({config = {}})
drain_ui_events(paid_context)
UIElement.update_text(paid_price)
assert(paid_price.config.text_drawable.value == '$10')
assert(G.GAME.round_resets.boss_rerolled and not G.GAME.round_resets.divine_ward_free)
assert(check_button_enabled(true)) -- Retcon remains repeatable after the Director's Cut use is spent.
assert(price_node(build_reroll_button()).config.text == '$10')
G.FUNCS.reroll_boss({config = {}})
assert(paid_context.fee_calls == 1 and #paid_context.money == 1 and paid_context.money[1] == -10)
assert(G.GAME.dollars == 20, 'The native payment remains deferred until its queued ease settles')
drain_ui_events(paid_context)
paid_context:drain_money()
assert(G.GAME.dollars == 10 and paid_context.selected == 2)

local hidden_context = setup(20, false)
assert(not reality_warp_boss_reroll_button_visible() and build_reroll_button() == nil)
local dc_context = setup(20, false, {v_directors_cut = true})
assert(reality_warp_boss_reroll_button_visible())
assert(price_node(build_reroll_button()).config.text == '$10')
assert(check_button_enabled(true).config.button == 'reroll_boss')
G.GAME.round_resets.boss_rerolled = true
assert(not check_button_enabled(false).config.button)
local retcon_context = setup(20, false, {v_retcon = true})
assert(reality_warp_boss_reroll_button_visible() and check_button_enabled(true).config.button == 'reroll_boss')
assert(price_node(build_reroll_button()).config.text == '$10')
G.GAME.round_resets.boss_rerolled = true
assert(check_button_enabled(true).config.button == 'reroll_boss')
local broke_context = setup(5, false, {v_retcon = true})
assert(price_node(build_reroll_button()).config.text == '$10')
assert(not check_button_enabled(false).config.button)
G.GAME.dollars = 10
G.GAME.bankrupt_at = 1
assert(not check_button_enabled(false).config.button)
G.GAME.bankrupt_at = 0
assert(check_button_enabled(true).config.button == 'reroll_boss')
assert(dc_context.fee_calls == 0 and retcon_context.fee_calls == 0 and broke_context.fee_calls == 0)

-- Boss Tag follows its own free route and leaves an available Ward untouched.
local tag_context = setup(0, true)
G.from_boss_tag = true
local tag_result = G.FUNCS.reroll_boss({config = {origin = 'tag'}})
assert(tag_result == true and G.from_boss_tag == nil)
assert(G.GAME.round_resets.divine_ward_free and tag_context.fee_calls == 0 and tag_context.selected == 1)
assert(tag_context.attention == 0)

-- The UI Boss Tag route also preserves Ward, and a real new_blind_choice tag still runs once.
local ui_tag_context = setup(0, true)
setup_ui_boss()
local new_choice_triggers = 0
G.GAME.tags = {{apply_to_run = function(_, context)
    assert(context.type == 'new_blind_choice')
    new_choice_triggers = new_choice_triggers + 1
    return true
end}, {apply_to_run = function() error('A consumed new_blind_choice tag must stop the native loop') end}}
assert(price_node(build_reroll_button()).config.text == '$0')
G.from_boss_tag = true
local ui_tag_result = G.FUNCS.reroll_boss({config = {origin = 'ui-tag'}})
assert(ui_tag_result == nil)
drain_ui_events(ui_tag_context)
assert(G.from_boss_tag == nil and G.GAME.round_resets.divine_ward_free)
assert(ui_tag_context.fee_calls == 0 and ui_tag_context.selected == 1 and new_choice_triggers == 1)
assert(ui_tag_context.attention == 0)

-- A normal non-Ward reroll remains a single deferred $10 fee.
local normal_context = setup(20, false, {v_retcon = true})
local normal_result = G.FUNCS.reroll_boss({config = {origin = 'ordinary'}})
assert(normal_result == true and normal_context.fee_calls == 1 and normal_context.money[1] == -10)
assert(G.GAME.dollars == 20)
normal_context:drain_money()
assert(G.GAME.dollars == 10)

-- Reconstruct the serialized free/consumed Ward state as a cold-load control.
G = {GAME = {battle_of_gods = true, round_resets = {divine_ward_free = true, reality_warp_ward_ante = 12}}}
assert(reality_warp_divine_ward_free_available())
G = {GAME = {battle_of_gods = true, round_resets = {divine_ward_free = false, reality_warp_ward_ante = 12}}}
assert(not reality_warp_divine_ward_free_available())
G.GAME.battle_of_gods = false
G.GAME.round_resets.divine_ward_free = true
assert(not reality_warp_divine_ward_free_available())

-- Reuse the installed encounter scheduler harness and verify the serialized allowance grants only on a new Ante.
dofile(REPO_ROOT .. '/tests/test_blind_encounters.lua')
local ward_resets = G.GAME.round_resets
local last_ante = ward_resets.ante
reality_warp_schedule_blinds(false)
assert(ward_resets.divine_ward_free and ward_resets.reality_warp_ward_ante == last_ante)
ward_resets.divine_ward_free = false
reality_warp_schedule_blinds(false)
assert(not ward_resets.divine_ward_free, 'A partial reset in the same Ante must not grant another Ward')
ward_resets.ante = last_ante + 1
reality_warp_schedule_blinds(false)
assert(ward_resets.divine_ward_free and ward_resets.reality_warp_ward_ante == ward_resets.ante)
ward_resets.divine_ward_free = false
reality_warp_schedule_blinds(false)
assert(not ward_resets.divine_ward_free, 'The new-Ante grant is consumed once and not repeated on another reset')
