-- Battle of Gods Game Mode (Post-Ante 8)
-- Enabled via config and requires Amulet mod

local function has_amulet_mod()
    if SMODS and SMODS.Mods then
        for k, v in pairs(SMODS.Mods) do
            local key_str = string.lower(tostring(k))
            local id_str = v.id and string.lower(tostring(v.id)) or ''
            local name_str = v.name and string.lower(tostring(v.name)) or ''
            if key_str == 'amulet' or id_str == 'amulet' or name_str == 'amulet' then
                return true
            end
        end
    end
    return false
end

function apply_battle_of_gods_bg()
    G.C.BOTG_BLACK = G.C.BOTG_BLACK or HEX('080808')
    G.C.BOTG_RED = G.C.BOTG_RED or HEX('b31010')
    if G.SPLASH_BACK then
        G.SPLASH_BACK:define_draw_steps({{
            shader = 'splash',
            send = {
                {name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
                {name = 'vort_speed', val = 0.4},
                {name = 'colour_1', ref_table = G.C, ref_value = 'BOTG_BLACK'},
                {name = 'colour_2', ref_table = G.C, ref_value = 'BOTG_RED'},
                {name = 'mid_flash', ref_table = {mid_flash = 0}, ref_value = 'mid_flash'},
                {name = 'vort_offset', val = 0},
            }
        }})
    end
    if ease_background_colour then
        ease_background_colour{
            new_colour = G.C.BOTG_BLACK,
            special_colour = G.C.BOTG_RED,
            contrast = 3.5
        }
    end
end

if ease_background_colour_blind then
    local orig_ease_bg = ease_background_colour_blind
    function ease_background_colour_blind(state, blind_override)
        if G.GAME and G.GAME.battle_of_gods then
            apply_battle_of_gods_bg()
            return
        end
        return orig_ease_bg(state, blind_override)
    end
end

-- Colosseum, Olympic & Mod Mechanics Achievements
local botg_basic_achievements = {
    { key = 'apprentice_alchemist', name = 'Apprentice Alchemist', desc = 'Drink or use any Witcher Brew Potion.' },
    { key = 'witcher_amalgam', name = 'Master Brewer', desc = 'Synthesize or use an Amalgam Potion.' },
    { key = 'mutagenic_trial', name = 'Trial of the Grasses', desc = 'Use any Witcher Brew Spectral card.' },
    { key = 'first_contract', name = 'Witcher on the Path', desc = 'Accept or complete a Witcher Guild Job.' },
    { key = 'divine_familiar', name = 'Faithful Companion', desc = 'Summon or bond with a Familiar in the Colosseum.' },
    { key = 'forbidden_craft', name = 'Esoteric Secrets', desc = 'Obtain or score with an Outsider Joker.' },
    { key = 'herb_forager', name = 'Herbalist Satchel', desc = 'Open a Witcher Brew Booster Pack.' },
    { key = 'god_slayer', name = 'Colosseum Gladiator', desc = 'Defeat any Boss Blind in the Colosseum.' },
    { key = 'glitch_in_the_aegis', name = 'Temporal Anomaly', desc = 'Create or score with a Glitched Card.' },

    -- Joker & Synergy Achievements
    { key = 'court_of_legends', name = 'Court of Legends', desc = 'Possess 2 or more Legendary Jokers at the same time.' },
    { key = 'forbidden_pantheon', name = 'Forbidden Pantheon', desc = 'Possess 3 or more Outsiders or Amalgam Jokers simultaneously.' },
    { key = 'wolf_school_arsenal', name = 'Wolf School Arsenal', desc = 'Equip 5 Witcher Brew mod Jokers in your active lineup.' },
    { key = 'grand_symphony', name = 'Grand Symphony', desc = 'Have 2 or more Song Jokers active simultaneously.' },
    { key = 'high_finance', name = 'High Finance', desc = 'Hold $100 or more while owning a financial Joker.' },
    { key = 'master_artificer', name = 'Master Artificer', desc = 'Forge or upgrade 10 cards with the Blacksmith Joker.' },
    { key = 'miracle_cure', name = 'Miracle Cure', desc = 'Have Doctor Jo cleanse or cure a Perishable Joker.' },
    { key = 'underworld_syndicate', name = 'Underworld Syndicate', desc = 'Accumulate 50 or more Dark Money (€) in a single run.' },
    { key = 'devoted_guardian', name = 'Devoted Guardian', desc = 'Raise any Nursery Familiar to Level 5.' },
    { key = 'godly_vessel', name = 'Godly Vessel', desc = 'Equip or trigger any Olympian God Joker ability.' },
}

if SMODS and SMODS.Achievement then
    SMODS.Achievement {
        key = 'campeon_del_coliseo',
        loc_txt = {
            name = 'Colosseum Champion',
            description = 'Reach Ante 24 in Battle of Gods mode.',
        },
        unlock_condition = function(self, args)
            return args.type == 'botg_ante_24' or args.type == 'campeon_del_coliseo' or args.type == 'ach_reality_warp_campeon_del_coliseo'
        end
    }

    SMODS.Achievement {
        key = 'dios_olimpico',
        loc_txt = {
            name = 'Olympic God',
            description = 'Earn a Gold Sticker on all mod Jokers.',
        },
        unlock_condition = function(self, args)
            return args.type == 'dios_olimpico' or (check_olympic_god_status and check_olympic_god_status())
        end
    }

    SMODS.Achievement {
        key = 'dios_olimpico_plus_plus',
        loc_txt = {
            name = 'Olympic God++',
            description = 'Win on Gold Stake with all mod Decks and complete Battle of Gods on Gold Stake.',
        },
        unlock_condition = function(self, args)
            return args.type == 'dios_olimpico_plus_plus' or (check_olympic_god_plus_plus_status and check_olympic_god_plus_plus_status())
        end
    }

    for _, ach in ipairs(botg_basic_achievements) do
        SMODS.Achievement {
            key = ach.key,
            loc_txt = {
                name = ach.name,
                description = ach.desc,
            },
            unlock_condition = function(self, args)
                return args.type == ach.key or args.type == ('ach_reality_warp_' .. ach.key)
            end
        }
    end
end

function register_achievement_loc(key, name, desc)
    local full_key = 'ach_reality_warp_' .. key
    G.ACHIEVEMENTS = G.ACHIEVEMENTS or {}
    G.SETTINGS.ACHIEVEMENTS_EARNED = G.SETTINGS.ACHIEVEMENTS_EARNED or {}

    if G.localization and G.localization.misc then
        G.localization.misc.achievement_names = G.localization.misc.achievement_names or {}
        G.localization.misc.achievement_descriptions = G.localization.misc.achievement_descriptions or {}
        G.localization.misc.achievement_names[key] = name
        G.localization.misc.achievement_descriptions[key] = desc
        G.localization.misc.achievement_names[full_key] = name
        G.localization.misc.achievement_descriptions[full_key] = desc
    end

    if not G.ACHIEVEMENTS[key] then
        G.ACHIEVEMENTS[key] = { name = name, earned = true, steamid = "STEAMODDED_" .. string.upper(key) }
    end
    if not G.ACHIEVEMENTS[full_key] then
        G.ACHIEVEMENTS[full_key] = { name = name, earned = true, steamid = "STEAMODDED_" .. string.upper(key) }
    end
end

for _, ach in ipairs(botg_basic_achievements) do
    register_achievement_loc(ach.key, ach.name, ach.desc)
end

function botg_trigger_mod_achievement(key)
    local full_key = 'ach_reality_warp_' .. key
    if check_for_unlock then
        pcall(function() check_for_unlock({ type = key }) end)
        pcall(function() check_for_unlock({ type = full_key }) end)
    end
    if unlock_achievement then
        pcall(function() unlock_achievement(key) end)
        pcall(function() unlock_achievement(full_key) end)
    else
        G.SETTINGS.ACHIEVEMENTS_EARNED = G.SETTINGS.ACHIEVEMENTS_EARNED or {}
        G.SETTINGS.ACHIEVEMENTS_EARNED[key] = true
        G.SETTINGS.ACHIEVEMENTS_EARNED[full_key] = true
        if notify_alert then pcall(function() notify_alert(key) end) end
    end
end

local function unlock_colosseum_champion()
    register_achievement_loc('campeon_del_coliseo', 'Colosseum Champion', 'Reach Ante 24 in Battle of Gods mode.')
    botg_trigger_mod_achievement('campeon_del_coliseo')
end

function check_olympic_god_status()
    local profile = G.PROFILES and G.PROFILES[G.SETTINGS.profile]
    if not profile or not profile.joker_usage then return false end
    local total_mod_jokers = 0
    local gold_jokers = 0

    for k, v in pairs(G.P_CENTERS) do
        if v.set == 'Joker' and not v.omit then
            local is_mod_joker = (v.mod and (v.mod.id == 'reality_warp' or v.mod.id == 'reality_warp'))
                or string.find(k, 'reality_warp') or string.find(k, 'reality_warp')
            if is_mod_joker then
                total_mod_jokers = total_mod_jokers + 1
                local win_stake = get_joker_win_sticker and get_joker_win_sticker(v, true) or 0
                if win_stake >= 8 then
                    gold_jokers = gold_jokers + 1
                end
            end
        end
    end
    return total_mod_jokers > 0 and gold_jokers >= total_mod_jokers
end

function check_olympic_god_plus_plus_status()
    local profile = G.PROFILES and G.PROFILES[G.SETTINGS.profile]
    if not profile or not profile.deck_usage then return false end
    if not profile.botg_gold_stake_win then return false end

    local total_decks = 0
    local gold_decks = 0
    for k, v in pairs(G.P_CENTERS) do
        if v.set == 'Back' and not v.omit then
            local is_mod_deck = (v.mod and (v.mod.id == 'reality_warp' or v.mod.id == 'reality_warp'))
                or string.find(k, 'reality_warp') or string.find(k, 'reality_warp')
            if is_mod_deck then
                total_decks = total_decks + 1
                local stake_win = get_deck_win_stake and get_deck_win_stake(v.key) or 0
                if stake_win >= 8 then
                    gold_decks = gold_decks + 1
                end
            end
        end
    end
    return total_decks > 0 and gold_decks >= total_decks
end

function check_and_unlock_olympic_achievements()
    if check_olympic_god_status() then
        register_achievement_loc('dios_olimpico', 'Olympic God', 'Earn a Gold Sticker on all mod Jokers.')
        trigger_achievement_unlock('dios_olimpico')
    end
    if check_olympic_god_plus_plus_status() then
        register_achievement_loc('dios_olimpico_plus_plus', 'Olympic God++', 'Win on Gold Stake with all mod Decks and complete Battle of Gods on Gold Stake.')
        trigger_achievement_unlock('dios_olimpico_plus_plus')
    end
end

if set_joker_win then
    local orig_set_joker_win = set_joker_win
    function set_joker_win()
        orig_set_joker_win()
        pcall(check_and_unlock_olympic_achievements)
    end
end

if set_deck_win then
    local orig_set_deck_win = set_deck_win
    function set_deck_win()
        orig_set_deck_win()
        pcall(check_and_unlock_olympic_achievements)
    end
end

-- Exclusive Pantheon Booster Pack (Mechanic 5)
SMODS.Booster {
    key = 'pantheon_pack',
    atlas = 'c_packs',
    pos = { x = 0, y = 1 },
    config = { extra = 3, choose = 1 },
    cost = 25,
    weight = 0.45,
    draw_hand = false,
    loc_txt = {
        name = 'Pantheon Pack',
        text = {
            'Choose {C:attention}#1#{} of up to',
            '{C:attention}#2#{} {C:spectral}Mythic Jokers{}',
            '{C:inactive}(Secret or Legendary){}'
        }
    },
    loc_vars = function(self, info_queue, card)
        local choose = (card and card.ability and card.ability.choose) or (self.config and self.config.choose) or 1
        local extra = (card and card.ability and card.ability.extra) or (self.config and self.config.extra) or 3
        return { vars = { choose, extra } }
    end,
    create_card = function(self, card, i)
        local roll = pseudorandom('pantheon_pack_roll_' .. (card.ID or '') .. i)
        if roll < 0.5 then
            return create_card('Joker', G.pack_cards, true, nil, nil, nil, nil, 'pantheon_leg')
        else
            local secret_keys = {}
            for k, v in pairs(G.P_CENTERS) do
                if v.set == 'Joker' and (v.is_secret or v.rarity == 'Secret' or (is_secret_card and is_secret_card({config = {center = v}}))) then
                    secret_keys[#secret_keys + 1] = k
                end
            end
            local key = pseudorandom_element(secret_keys, pseudoseed('pantheon_sec_' .. (card.ID or '') .. i))
            return create_card('Joker', G.pack_cards, nil, nil, nil, nil, key, 'pantheon_sec')
        end
    end,
    in_pool = function(self, args)
        return G.GAME and G.GAME.battle_of_gods == true
    end
}

function get_new_boss_filtered(showdown)
    return reality_warp_choose_blind(showdown and 'showdown' or 'boss', showdown and 'botg_showdown' or 'botg_boss')
end

function get_new_fused_boss()
    return reality_warp_choose_blind('fused', 'botg_fused_boss')
end

function get_botg_godly_hubris_multiplier()
    if not (G.GAME and G.GAME.battle_of_gods) then return 1, 0 end
    local god_count = 0
    if G.jokers and G.jokers.cards then
        for _, j in ipairs(G.jokers.cards) do
            local is_leg = j.config and j.config.center and (j.config.center.rarity == 4 or j.config.center.rarity == 'Legendary' or j.config.center.legendary)
            local is_sec = (is_secret_card and is_secret_card(j)) or (j.config and j.config.center and (j.config.center.is_secret or j.config.center.rarity == 'Secret'))
            if is_leg or is_sec then
                god_count = god_count + 1
            end
        end
    end
    return 1 + (god_count * 0.5), god_count
end

-- UI reads committed slots; only the preview context changes, never the schedule.
if create_UIBox_blind_choice then
    local original = create_UIBox_blind_choice
    function create_UIBox_blind_choice(slot, ...)
        return reality_warp_with_blind_preview(slot, original, slot, ...)
    end
end

-- Intercept the framework's explicit new-Ante schedule creation before it rolls candidates.
if SMODS.reset_blind_choices then
    local original = SMODS.reset_blind_choices
    local function pack(...) return {n = select('#', ...), ...} end
    function SMODS.reset_blind_choices(choices, ...)
        if G.GAME.battle_of_gods then
            reality_warp_begin_blind_schedule()
            G.GAME.round_resets.blind_order = {'Small', 'Big', 'Boss'}
            G.GAME.round_resets.blind_choices = choices or G.GAME.round_resets.blind_choices or {}
            reality_warp_schedule_blinds(true)
            return
        end
        local result = pack(original(choices, ...))
        reality_warp_begin_blind_schedule()
        reality_warp_schedule_blinds(false)
        return unpack(result, 1, result.n)
    end
end

if reset_blinds then
    local original = reset_blinds
    local function pack(...) return {n = select('#', ...), ...} end
    function reset_blinds(...)
        local boss_defeated = G.GAME.round_resets.blind_states and G.GAME.round_resets.blind_states.Boss == 'Defeated'
        local result = pack(original(...))
        local sel_fam = get_nursery_selected_fam and get_nursery_selected_fam()
        if G.GAME.battle_of_gods or sel_fam then
            if init_botg_familiars_area then init_botg_familiars_area() end
            if sel_fam and botg_set_active_familiar and G.botg_familiars and #G.botg_familiars.cards == 0 then
                botg_set_active_familiar('c_reality_warp_' .. sel_fam)
            end
        end
        if G.GAME.battle_of_gods then
            G.GAME.win_ante = 24
            if G.GAME.round_resets.ante >= 24 then unlock_colosseum_champion() end
            if boss_defeated and botg_trigger_mod_achievement then botg_trigger_mod_achievement('god_slayer') end
        end
        local migrating = not G.GAME.round_resets.reality_warp_encounters
        reality_warp_schedule_blinds(not boss_defeated and G.GAME.reality_warp_refresh_pending, migrating)
        G.GAME.reality_warp_refresh_pending = nil
        return unpack(result, 1, result.n)
    end
end

-- Mechanic 24: Divine Ward pays at the native reroll fee boundary.
local divine_ward_reroll_price_refs = setmetatable({}, {__mode = 'k'})

function reality_warp_divine_ward_free_available()
    local game = G and G.GAME
    local resets = game and game.round_resets
    return not not (game and game.battle_of_gods and resets and resets.divine_ward_free)
end

function reality_warp_boss_reroll_button_visible()
    local game = G and G.GAME
    if not game then return false end
    local vouchers = game.used_vouchers or {}
    return reality_warp_divine_ward_free_available() or vouchers.v_retcon or vouchers.v_directors_cut or false
end

function reality_warp_divine_ward_reroll_button()
    local price_ref = {
        label = localize('$') .. (reality_warp_divine_ward_free_available() and '0' or '10')
    }
    local button = UIBox_button({
        label = {localize('b_reroll_boss'), price_ref.label},
        button = 'reroll_boss',
        func = 'reroll_boss_button',
        ref_table = price_ref
    })
    local price_text = button and button.nodes and button.nodes[1] and button.nodes[1].nodes and
        button.nodes[1].nodes[2] and button.nodes[1].nodes[2].nodes and button.nodes[1].nodes[2].nodes[1]
    if price_text and price_text.config then
        price_text.config.ref_table = price_ref
        price_text.config.ref_value = 'label'
        divine_ward_reroll_price_refs[price_ref] = true
    end
    return button
end

local function reality_warp_update_divine_ward_reroll_prices()
    local label = localize('$') .. (reality_warp_divine_ward_free_available() and '0' or '10')
    for price_ref in pairs(divine_ward_reroll_price_refs) do
        price_ref.label = label
    end
end

function reality_warp_pay_boss_reroll()
    if G.from_boss_tag then return false end
    if reality_warp_divine_ward_free_available() then
        G.GAME.round_resets.divine_ward_free = false
        reality_warp_update_divine_ward_reroll_prices()
        attention_text({ text = 'Divine Ward: Free Reroll!', scale = 0.7, hold = 1.2, backdrop_colour = G.C.GOLD, align = 'cm', offset = {x = 0, y = -1} })
        return true
    end
    ease_dollars(-10)
    return false
end


if get_new_boss then
    local original = get_new_boss
    function get_new_boss(...)
        if not G.GAME.battle_of_gods then return original(...) end
        local key = reality_warp_choose_blind('showdown', 'botg_boss_reroll') or
            reality_warp_choose_blind('boss', 'botg_boss_reroll_fallback') or
            reality_warp_choose_blind('regular', 'botg_boss_reroll_regular')
        assert(key, 'Reality Warp: no eligible reroll Blind')
        reality_warp_commit_blind('Boss', key)
        return key
    end
end

if Blind and Blind.defeat then
    local orig_blind_defeat = Blind.defeat
    function Blind:defeat(silent)
        if G.GAME and G.GAME.battle_of_gods then
            -- Mechanic 25: Track bosses slain
            G.GAME.botg_bosses_slain = (G.GAME.botg_bosses_slain or 0) + 1

            -- Mechanic 4: Overkill to Divine Grace
            if G.GAME.chips and self.chips and G.GAME.chips > self.chips then
                local excess = G.GAME.chips - self.chips
                local grace_earned = math.min(10, math.max(1, math.floor((excess / self.chips) * 5)))
                G.GAME.divine_grace = (G.GAME.divine_grace or 0) + grace_earned
                attention_text({
                    text = '+' .. tostring(grace_earned) .. ' Divine Grace',
                    scale = 0.7, hold = 1.3, backdrop_colour = G.C.GOLD,
                    align = 'cm', offset = {x = 0, y = -1.2}
                })
            end

            -- Mechanic 15: Thanatos Hourglass (Perishable & Rental Cleansing on Showdown)
            local is_showdown = reality_warp_blind_is_showdown(self)
            if is_showdown and G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    local cleansed = false
                    if j.ability and j.ability.perishable then
                        j.ability.perish_tally = G.GAME.perishable_rounds or 5
                        SMODS.recalc_debuff(j)
                        cleansed = true
                    end
                    if j.ability and j.ability.rental then
                        j.ability.rental = nil
                        j.rental = nil
                        cleansed = true
                    end
                    if cleansed then
                        card_eval_status_text(j, 'extra', nil, nil, nil, { message = 'Thanatos Cleansed!', colour = G.C.GOLD })
                    end
                end
            end

            -- Idea 19: Mini-Boss Familiar drop chance (40%)
            if botg_offer_familiar and SMODS.pseudorandom_probability(self, 'botg_fam_drop', 40, 100, nil, true) then
                botg_offer_familiar()
            end

            -- Boss Possession drop chance (30%)
            if possess_joker and SMODS.pseudorandom_probability(self, 'botg_possession_drop', 30, 100, nil, true) and G.jokers and G.jokers.cards then
                local unpossessed = {}
                for _, j in ipairs(G.jokers.cards) do
                    if not (j.ability and j.ability.possessed) then unpossessed[#unpossessed + 1] = j end
                end
                if #unpossessed > 0 then
                    local target_joker = pseudorandom_element(unpossessed, pseudoseed('botg_possess_target'))
                    possess_joker(target_joker, self.config and self.config.blind and self.config.blind.key)
                end
            end

            -- Mechanic 19: Apotheosis check at Ante 20+
            if G.GAME.round_resets and G.GAME.round_resets.ante >= 20 and not G.GAME.apotheosis_done then
                if G.jokers and G.jokers.cards and #G.jokers.cards > 0 then
                    local target = G.jokers.cards[1]
                    target.ability.deity_ascended = true
                    target:set_edition({ polychrome = true }, true)
                    SMODS.recalc_debuff(target)
                    G.GAME.apotheosis_done = true
                    attention_text({
                        text = 'APOTHEOSIS! Ascended to Deity',
                        scale = 0.85, hold = 2.0, backdrop_colour = G.C.PURPLE,
                        align = 'cm', offset = {x = 0, y = -1.5}
                    })
                end
            end

            G.GAME.reality_warp_refresh_pending = true
        end
        return orig_blind_defeat(self, silent)
    end
end

local botg_ante_bases = {
    15000,       -- Ante 1: 15k (Boss 30k)
    60000,       -- Ante 2: 60k (Boss 120k)
    300000,      -- Ante 3: 300k (Boss 600k)
    1800000,     -- Ante 4: 1.8M (Boss 3.6M)
    15000000,    -- Ante 5: 15M (Boss 30M)
    150000000,   -- Ante 6: 150M (Boss 300M)
    2100000000,  -- Ante 7: 2.1B (Boss 4.2B)
    36000000000, -- Ante 8: 36B (Boss 72B)
}

local function make_botg_big_amount(mantissa, exponent)
    if to_big then
        local str = string.format("%.4fe%d", mantissa, exponent)
        local ok, val = pcall(function() return to_big(str) end)
        if ok and val then return val end
        local ok2, val2 = pcall(function() return to_big(mantissa) * (to_big(10) ^ to_big(exponent)) end)
        if ok2 and val2 then return val2 end
    end
    if exponent < 308 then
        return math.floor(mantissa * (10 ^ exponent))
    end
    return 1e300
end

local function get_botg_base_blind(ante)
    -- Preserve native below-one difficulty (100/300 of the Ante-one base).
    if ante < 1 then return botg_ante_bases[1] / 3 end
    local a = ante
    if a <= 8 then
        return botg_ante_bases[a]
    end
    if a >= 24 then
        -- Final showdown Boss has mult 2, so base of 0.5e365 yields exactly 1e365 for the final blind
        return make_botg_big_amount(5.0, 364)
    end
    -- Rapid exponential curve in log-space from Ante 8 (log10 ~ 10.556) to Ante 24 (log10 ~ 364.699)
    local t = (a - 8) / 16
    local log_val = 10.55630 + 354.14267 * (t ^ 1.35)
    local exponent = math.floor(log_val)
    local mantissa = 10 ^ (log_val - exponent)
    return make_botg_big_amount(mantissa, exponent)
end

if get_blind_amount then
    local orig_get_blind_amount = get_blind_amount
    function get_blind_amount(ante, ...)
        if G.GAME and G.GAME.battle_of_gods then return get_botg_base_blind(ante) end
        return orig_get_blind_amount(ante, ...)
    end
end

-- Target initialization lives in the native non-reset branch through Lovely.
-- This wrapper owns feedback only and never rebuilds an existing requirement.
if Blind and Blind.set_blind then
    local orig_blind_set_blind = Blind.set_blind
    local function pack(...) return {n = select('#', ...), ...} end
    function Blind:set_blind(blind, reset, silent, ...)
        local ret = pack(orig_blind_set_blind(self, blind, reset, silent, ...))
        if blind and not reset and not silent and G.GAME.battle_of_gods and
            reality_warp_blind_is_boss(self) and not self.disabled then
            local mult, count = get_botg_godly_hubris_multiplier()
            if count > 0 then
                reality_warp_queue_blind_event(self, {
                    trigger = 'after', delay = 0.4,
                    func = function()
                        attention_text({
                            text = 'Godly Hubris: Boss Chips X' .. string.format('%.1f', mult) .. ' (' .. count .. ' Divine Joker' .. (count > 1 and 's' or '') .. ')',
                            scale = 0.55, hold = 2.2, backdrop_colour = G.C.RED,
                            align = 'cm', offset = {x = 0, y = -1}
                        })
                        play_sound('cancel', 0.9, 0.7)
                        return true
                    end
                })
            end
        end
        return unpack(ret, 1, ret.n)
    end
end

local orig_create_card = create_card
function create_card(type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
    if G.GAME and G.GAME.battle_of_gods and type == 'Joker' and not forced_key and not legendary then
        local is_shop = (area == G.shop_jokers or (key_append and string.find(key_append, 'sho')))
        if is_shop then
            local roll = pseudorandom(pseudoseed('botg_shop_rarity' .. (key_append or 'sho') .. (G.GAME.round_resets and G.GAME.round_resets.ante or 1)))
            if roll < 0.01 then
                legendary = true
            elseif roll < 0.011 then
                local secret_keys = {}
                for k, v in pairs(G.P_CENTERS) do
                    if v.set == 'Joker' and (v.is_secret or v.rarity == 'Secret' or (is_secret_card and is_secret_card({config = {center = v}}))) then
                        if not (G.GAME.used_jokers and G.GAME.used_jokers[k] and not (player_has_showman and player_has_showman())) then
                            secret_keys[#secret_keys + 1] = k
                        end
                    end
                end
                if #secret_keys > 0 then
                    forced_key = pseudorandom_element(secret_keys, pseudoseed('botg_secret'))
                end
            end
        end
    end
    return orig_create_card(type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
end

function create_UIBox_botg_warning()
    return create_UIBox_generic_options({
        back_func = 'cancel_battle_of_gods',
        back_label = 'CANCEL',
        back_colour = G.C.RED,
        contents = {
            {n=G.UIT.R, config={align = "cm", padding = 0.08}, nodes={
                {n=G.UIT.T, config={text = "BATTLE OF GODS", scale = 0.65, colour = G.C.GOLD, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.04}, nodes={
                {n=G.UIT.T, config={text = "WARNING", scale = 0.45, colour = G.C.RED, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.08, maxw = 6.2}, nodes={
                {n=G.UIT.T, config={text = "Entering will reset Antes to 1 with a starting score requirement of 15,000 base chips.", scale = 0.35, colour = G.C.WHITE, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.06, maxw = 6.2}, nodes={
                {n=G.UIT.T, config={text = "• All current Jokers will be destroyed.", scale = 0.33, colour = G.C.FILTER, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.06, maxw = 6.2}, nodes={
                {n=G.UIT.T, config={text = "• Enter directly into the Shop with 2X your current money.", scale = 0.33, colour = G.C.MONEY, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.06, maxw = 6.2}, nodes={
                {n=G.UIT.T, config={text = "• Hand levels, vouchers, and other stats are preserved.", scale = 0.33, colour = G.C.BLUE, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.06, maxw = 6.2}, nodes={
                {n=G.UIT.T, config={text = "• Permanently obtain Taster and Critic vouchers.", scale = 0.33, colour = G.C.GREEN, shadow = true}}
            }},
            {n=G.UIT.R, config={align = "cm", padding = 0.15}, nodes={
                UIBox_button({
                    button = 'confirm_battle_of_gods',
                    label = {'ENTER THE COLISEUM'},
                    minw = 4.2,
                    minh = 0.9,
                    scale = 0.5,
                    shadow = true,
                    colour = G.C.GOLD,
                    focus_args = {nav = 'wide', button = 'x', set_button_pip = true}
                })
            }}
        }
    })
end

G.FUNCS.start_battle_of_gods = function(e)
    G.FUNCS.overlay_menu{
        definition = create_UIBox_botg_warning(),
        config = {no_esc = false}
    }
end

G.FUNCS.cancel_battle_of_gods = function(e)
    G.FUNCS.overlay_menu{
        definition = create_UIBox_win(),
        config = {no_esc = true}
    }
end

G.FUNCS.confirm_battle_of_gods = function(e)
    if G.FUNCS.exit_overlay_menu then
        G.FUNCS.exit_overlay_menu()
    end
    if G.OVERLAY_MENU then
        G.OVERLAY_MENU:remove()
        G.OVERLAY_MENU = nil
    end
    G.SETTINGS.paused = false

    -- Clean up all existing Blind Select & Round Eval UI
    if G.blind_prompt_box then
        G.blind_prompt_box:remove()
        G.blind_prompt_box = nil
    end
    if G.blind_select_opts then
        for _, opt in pairs(G.blind_select_opts) do
            if opt and opt.remove then
                pcall(function() opt:remove() end)
            end
        end
        G.blind_select_opts = nil
    end
    if G.blind_select then
        G.blind_select:remove()
        G.blind_select = nil
    end
    if G.round_eval then
        G.round_eval:remove()
        G.round_eval = nil
    end

    -- Clean up any existing shop objects
    if G.SHOP_SIGN then
        G.SHOP_SIGN:remove()
        G.SHOP_SIGN = nil
    end
    if G.shop then
        G.shop:remove()
        G.shop = nil
    end
    if G.shop_jokers then
        if G.shop_jokers.cards then
            for i = #G.shop_jokers.cards, 1, -1 do
                G.shop_jokers.cards[i]:remove()
            end
        end
        G.shop_jokers:remove()
        G.shop_jokers = nil
    end
    if G.shop_vouchers then
        if G.shop_vouchers.cards then
            for i = #G.shop_vouchers.cards, 1, -1 do
                G.shop_vouchers.cards[i]:remove()
            end
        end
        G.shop_vouchers:remove()
        G.shop_vouchers = nil
    end
    if G.shop_booster then
        if G.shop_booster.cards then
            for i = #G.shop_booster.cards, 1, -1 do
                G.shop_booster.cards[i]:remove()
            end
        end
        G.shop_booster:remove()
        G.shop_booster = nil
    end

    -- Clear all current jokers while keeping levels, vouchers, consumables
    if G.jokers and G.jokers.cards then
        for i = #G.jokers.cards, 1, -1 do
            local j = G.jokers.cards[i]
            if j then
                if j.remove_from_deck then
                    pcall(function() j:remove_from_deck() end)
                end
                G.jokers:remove_card(j)
                j:remove()
            end
        end
        G.jokers.cards = {}
    end

    -- Reset Battle of Gods state & Antes to 1
    reality_warp_begin_blind_schedule()
    G.GAME.battle_of_gods = true
    G.GAME.won = false
    G.GAME.win_notified = false
    G.GAME.win_ante = 24
    G.GAME.round = 1
    G.GAME.round_resets.ante = 1
    G.GAME.round_resets.ante_disp = 1
    G.GAME.round_resets.blind_ante = 1
    G.GAME.blind_on_deck = 'Small'
    G.GAME.round_resets.blind = G.P_BLINDS.bl_small
    G.GAME.facing_blind = nil
    G.GAME.round_resets.blind_states = {Small = 'Upcoming', Big = 'Upcoming', Boss = 'Upcoming'}
    G.GAME.round_resets.blind_choices = {}
    G.GAME.round_resets.reality_warp_encounters = nil
    G.GAME.reality_warp_active_encounter = nil
    reality_warp_schedule_blinds(true)
    G.GAME.round_resets.blind_tags = {
        Small = (get_next_tag_key and get_next_tag_key()) or 'tag_uncommon',
        Big = (get_next_tag_key and get_next_tag_key()) or 'tag_rare'
    }
    G.GAME.divine_grace = G.GAME.divine_grace or 0
    G.GAME.botg_bosses_slain = 0

    -- Double current money
    local cur_dollars = G.GAME.dollars or 0
    if cur_dollars > 0 then
        G.GAME.dollars = cur_dollars * 2
    end
    ease_chips(0)
    if G.HUD then
        G.HUD:recalculate()
    end

    -- Obtain Taster and Critic vouchers
    G.GAME.used_vouchers = G.GAME.used_vouchers or {}
    local v_keys = {
        'v_reality_warp_catador', 'v_Witch brew_catador', 'v_catador', 'catador',
        'v_reality_warp_critico', 'v_Witch brew_critico', 'v_critico', 'critico'
    }
    for _, k in ipairs(v_keys) do
        G.GAME.used_vouchers[k] = true
    end

    if G.P_CENTERS['v_reality_warp_catador'] and G.P_CENTERS['v_reality_warp_catador'].redeem then
        pcall(function() G.P_CENTERS['v_reality_warp_catador']:redeem() end)
    end
    if G.P_CENTERS['v_reality_warp_critico'] and G.P_CENTERS['v_reality_warp_critico'].redeem then
        pcall(function() G.P_CENTERS['v_reality_warp_critico']:redeem() end)
    end
    if botg_trigger_mod_achievement then
        botg_trigger_mod_achievement('royal_connoisseur')
    end

    -- Set up upcoming shop & stats
    if SMODS and SMODS.get_next_vouchers then
        G.GAME.current_round.voucher = SMODS.get_next_vouchers()
    elseif get_next_voucher_key then
        local v_key = get_next_voucher_key()
        G.GAME.current_round.voucher = { v_key, spawn = { [v_key] = true } }
    end
    G.GAME.current_round.jokers_purchased = 0
    G.GAME.current_round.used_packs = {}
    G.GAME.shop_free = nil
    G.GAME.shop_d6ed = nil
    G.GAME.current_round.discards_left = math.max(0, (G.GAME.round_resets.discards or 3) + (G.GAME.round_bonus and G.GAME.round_bonus.discards or 0))
    G.GAME.current_round.hands_left = math.max(1, (G.GAME.round_resets.hands or 4) + (G.GAME.round_bonus and G.GAME.round_bonus.next_hands or 0))

    apply_battle_of_gods_bg()

    -- Send directly to shop before starting to play
    G.STATE = G.STATES.SHOP
    G.STATE_COMPLETE = false
end

local function find_endless_node(node)
    if not node or type(node) ~= 'table' then return nil end
    if node.nodes then
        for i, child in ipairs(node.nodes) do
            if child.config and child.config.button == 'exit_overlay_menu' then
                return node, i
            end
            local found_parent, found_idx = find_endless_node(child)
            if found_parent then return found_parent, found_idx end
        end
    end
    return nil
end

-- Mechanic 25: Hall of Gods summary display & button integration
if create_UIBox_win then
    local orig_create_UIBox_win = create_UIBox_win
    function create_UIBox_win()
        local t = orig_create_UIBox_win()
        local cfg = (get_reality_warp_config and get_reality_warp_config())
            or (SMODS and SMODS.Mods and SMODS.Mods['reality_warp'] and SMODS.Mods['reality_warp'].config)
            or {}

        if G.GAME and G.GAME.battle_of_gods then
            unlock_colosseum_champion()
            if G.GAME.stake and G.GAME.stake >= 8 then
                if G.PROFILES and G.PROFILES[G.SETTINGS.profile] then
                    G.PROFILES[G.SETTINGS.profile].botg_gold_stake_win = true
                    G:save_settings()
                end
            end
            check_and_unlock_olympic_achievements()

            local function remove_unwanted_win_buttons(node)
                if not node or type(node) ~= 'table' then return end
                if node.nodes then
                    for i = #node.nodes, 1, -1 do
                        local child = node.nodes[i]
                        if child and type(child) == 'table' then
                            if child.config and child.config.button then
                                local b = child.config.button
                                if b == 'exit_overlay_menu' or b == 'notify_then_setup_run' or b == 'start_battle_of_gods' or b == 'show_main_cta' then
                                    table.remove(node.nodes, i)
                                else
                                    remove_unwanted_win_buttons(child)
                                end
                            else
                                remove_unwanted_win_buttons(child)
                            end
                        end
                    end
                end
            end
            remove_unwanted_win_buttons(t)

            table.insert(t.nodes, 1, {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.08 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.12, r = 0.15, colour = {0.1, 0.08, 0, 0.9}, outline = 1.5, outline_colour = G.C.GOLD },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = "🏆 COLOSSEUM CHAMPION 🏆",
                                    scale = 0.48,
                                    colour = G.C.GOLD,
                                    shadow = true
                                }
                            }
                        }
                    }
                }
            })
            return t
        end

        if cfg.battle_of_gods ~= false and has_amulet_mod() then
            local parent, idx = find_endless_node(t)
            if parent and idx then
                parent.nodes[idx] = UIBox_button({
                    button = 'exit_overlay_menu',
                    label = {localize('b_endless')},
                    minw = 3.1,
                    maxw = 3.1,
                    minh = 1.1,
                    scale = 0.58,
                    shadow = true,
                    colour = G.C.BLUE,
                    focus_args = {nav = 'wide', button = 'x', set_button_pip = true}
                })
                table.insert(parent.nodes, idx + 1, UIBox_button({
                    button = 'start_battle_of_gods',
                    label = {'Battle of Gods'},
                    minw = 3.1,
                    maxw = 3.1,
                    minh = 1.1,
                    scale = 0.58,
                    shadow = true,
                    colour = G.C.BLACK,
                    focus_args = {nav = 'wide', button = 'y', set_button_pip = true}
                }))
            end
        end

        return t
    end
end
