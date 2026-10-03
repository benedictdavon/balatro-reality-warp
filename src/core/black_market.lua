--[[
    Dark Coins & Kyra's Black Market System
    Part of Witcher Brew Expansion
--]]

-- Kyra Quotes (English 100%)
local kyra_enter_quotes = {
    "*Yawn*... Oh, it's you. Don't ask where I got these Jokers. Some other player wasn't using them.",
    "Keep your voice down. The official shopkeeper thinks I'm organizing stock. Dark Coins only.",
    "Back again? Browse quickly. I've got a batch of White Honey distilling in five minutes.",
    "I 'acquired' some interesting goods from discarded runs. Totally legit. Got Dark Coins or not?",
    "Don't touch the flasks unless you're buying. Regular gold is useless here.",
    "Ugh, visitors... Make it quick. Pick a potion, grab a Joker, and don't make a scene.",
    "Everything here was ethically borrowed from alternate dimensions. Probably."
}

local kyra_buy_quotes = {
    "Pleasure doing business... or whatever. Now carry it carefully, it might be unstable.",
    "One less piece of clutter in my satchel. Thanks for the Dark Coins, I guess.",
    "Tch, you actually have decent taste. Don't go losing that in the next Blind.",
    "Dark Coins accepted. No refunds, no warranties, and if Jimbo asks: you never saw me.",
    "Fine, it's yours. Try not to blow yourself up with that concoction.",
    "Sold. Hey, don't tell the other Jokers I parted with this so cheaply.",
    "*Sigh*... Another sale. Now I have to go scavenge more runs for stock."
}

local kyra_reroll_quotes = {
    "*Sigh*... Fine, let me rummage through the other contraband trunk.",
    "Rerolling again? You're pickier than the Grand Alchemists.",
    "One Dark Coin taken. Let's see what else fell out of the dimensional rift.",
    "Here, fresh goods. Try to find something you actually like this time."
}

local function get_random_kyra_quote(category)
    local pool = kyra_enter_quotes
    if category == 'buy' then
        pool = kyra_buy_quotes
    elseif category == 'reroll' then
        pool = kyra_reroll_quotes
    end
    if pseudorandom_element and pseudoseed then
        return pseudorandom_element(pool, pseudoseed('kyra_' .. tostring(category) .. '_' .. tostring(math.random(1, 100000))))
    end
    return pool[math.random(#pool)]
end

local function update_kyra_dialogue(quote)
    if G.GAME then
        G.GAME.kyra_current_quote = quote
    end
    if G.black_market and G.black_market.get_UIE_by_ID then
        local ui_text = G.black_market:get_UIE_by_ID('kyra_dialogue_dynatext')
        if ui_text and ui_text.config and ui_text.config.object then
            ui_text.config.object:pop_in(0.2)
            ui_text.config.object:update()
        end
    end
    if G.bm_kyra_card then
        G.bm_kyra_card:juice_up(0.4, 0.4)
    end
end

-- Dark Coins Currency Modification
function ease_dark_coins(mod, instant)
    local function _mod(mod)
        G.GAME.dark_coins = math.max(0, (G.GAME.dark_coins or 0) + mod)
        local dark_coin_UI = G.HUD and G.HUD:get_UIE_by_ID('dark_coin_text_UI')
        if dark_coin_UI and dark_coin_UI.config and dark_coin_UI.config.object then
            dark_coin_UI.config.object:update()
            if G.HUD.recalculate then G.HUD:recalculate() end
        end
        local col = HEX('c084fc')
        local text = (mod >= 0 and '+' or '-') .. '$' .. tostring(math.abs(mod))
        local target_UI = dark_coin_UI or (G.HUD and G.HUD:get_UIE_by_ID('dollar_text_UI'))
        local cover_box = (dark_coin_UI and dark_coin_UI.parent) or (target_UI and target_UI.parent and target_UI.parent.parent and target_UI.parent.parent.parent)
        if cover_box then
            attention_text({
                text = text,
                scale = 0.8,
                hold = 0.7,
                cover = cover_box,
                cover_colour = col,
                align = 'cm'
            })
        end
        if mod > 0 then
            play_sound('coin3', 0.9, 0.7)
        elseif mod < 0 then
            play_sound('coin1', 0.8, 0.6)
        end
    end

    if instant then
        _mod(mod)
    else
        G.E_MANAGER:add_event(Event({
            trigger = 'immediate',
            func = function()
                _mod(mod)
                return true
            end
        }))
    end
end

-- Game Initialization Hook
if Game and Game.init_game_object then
    local orig_init_game_object = Game.init_game_object
    function Game:init_game_object()
        local g = orig_init_game_object(self)
        g.dark_coins = 0
        g.black_market_available = false
        g.in_black_market = false
        g.last_round_dark_coins_earned = 0
        return g
    end
end

-- Helper to calculate Dark Coins for the current completed round
local function calculate_round_dark_coins()
    if not (G and G.GAME) then return 0, 0, 0 end
    local blind = G.GAME.blind
    local is_boss = reality_warp_blind_is_boss(blind)
    local is_showdown = reality_warp_blind_is_showdown(blind)
    local is_big = not is_boss and reality_warp_current_slot() == 'Big'

    local blind_coins = is_showdown and 5 or is_boss and 3 or is_big and 2 or 1
    local deck_coins = (is_boss and G.GAME.dark_merchant_deck) and 5 or 0
    local total_coins = blind_coins + deck_coins
    return total_coins, blind_coins, deck_coins
end

-- Blind Defeat Currency Rewards Hook: Store pending Dark Coins to be paid upon Cash Out
if Blind and Blind.defeat then
    local orig_defeat = Blind.defeat
    function Blind:defeat(silent)
        if G.GAME and not silent then
            local round_key = tostring(G.GAME.round or 0) .. '_' .. tostring((G.GAME.round_resets and G.GAME.round_resets.ante) or 0) .. '_' .. tostring(G.GAME.blind_on_deck or 'Blind')
            if G.GAME.last_dark_coin_defeat_key ~= round_key then
                G.GAME.last_dark_coin_defeat_key = round_key
                local total_coins, blind_coins, deck_coins = calculate_round_dark_coins()
                G.GAME.pending_dark_coins_blind = blind_coins
                G.GAME.pending_dark_coins_deck = deck_coins
                G.GAME.pending_dark_coins = total_coins
                G.GAME.last_round_dark_coins_earned = total_coins
            end
        end
        return orig_defeat(self, silent)
    end
end

-- Cash Out Hook: Pay out pending Dark Coins when clicking Cash Out
if G.FUNCS and G.FUNCS.cash_out then
    local orig_cash_out = G.FUNCS.cash_out
    G.FUNCS.cash_out = function(e)
        if G.GAME then
            local pending = (G.GAME.pending_dark_coins and G.GAME.pending_dark_coins > 0) and G.GAME.pending_dark_coins or (G.GAME.last_round_dark_coins_earned or 0)
            if pending > 0 then
                G.GAME.pending_dark_coins = 0
                G.GAME.pending_dark_coins_blind = 0
                G.GAME.pending_dark_coins_deck = 0
                G.GAME.last_round_dark_coins_earned = 0
                ease_dark_coins(pending)
            end
        end
        orig_cash_out(e)
    end
end

-- Round Evaluation Cash Out Hook: Display Dark Coins & Deck Reward in Eval & next to Cash Out button
if add_round_eval_row then
    local orig_add_round_eval_row = add_round_eval_row
    function add_round_eval_row(config)
        if config and config.name == 'bottom' and G.GAME then
            local total_coins, blind_coins, deck_coins = calculate_round_dark_coins()
            G.GAME.pending_dark_coins_blind = blind_coins
            G.GAME.pending_dark_coins_deck = deck_coins
            G.GAME.pending_dark_coins = total_coins
            G.GAME.last_round_dark_coins_earned = total_coins

            local scale = 0.9
            delay(0.4)
            G.E_MANAGER:add_event(Event({
                trigger = 'before', delay = 0.5,
                func = function()
                    local width = (G.round_eval and G.round_eval.T and G.round_eval.T.w or 6) - 0.51
                    local eval_target = G.round_eval and (G.round_eval:get_UIE_by_ID('eval_bottom') or G.round_eval:get_UIE_by_ID('base_round_eval'))
                    if eval_target then
                        local dark_eval_row = {
                            n = G.UIT.R, config = { align = "cm", minw = width }, nodes = {
                                {
                                    n = G.UIT.C, config = { padding = 0.05, minw = width * 0.55, minh = 0.45, align = "cl" }, nodes = {
                                        { n = G.UIT.T, config = { text = "Dark Coins Earned", scale = 0.7 * scale, colour = HEX('c084fc'), shadow = true } }
                                    }
                                },
                                {
                                    n = G.UIT.C, config = { padding = 0.05, minw = width * 0.45, align = "cr" }, nodes = {
                                        { n = G.UIT.T, config = { text = "+$" .. tostring(blind_coins), scale = 0.85 * scale, colour = HEX('c084fc'), shadow = true, juice = true } }
                                    }
                                }
                            }
                        }
                        G.round_eval:add_child(dark_eval_row, eval_target)

                        if deck_coins > 0 then
                            local deck_reward_row = {
                                n = G.UIT.R, config = { align = "cm", minw = width }, nodes = {
                                    {
                                        n = G.UIT.C, config = { padding = 0.05, minw = width * 0.55, minh = 0.45, align = "cl" }, nodes = {
                                            { n = G.UIT.T, config = { text = "Deck Reward (Dark Merchant)", scale = 0.65 * scale, colour = HEX('d8b4fe'), shadow = true } }
                                        }
                                    },
                                    {
                                        n = G.UIT.C, config = { padding = 0.05, minw = width * 0.45, align = "cr" }, nodes = {
                                            { n = G.UIT.T, config = { text = "+$" .. tostring(deck_coins), scale = 0.85 * scale, colour = HEX('d8b4fe'), shadow = true, juice = true } }
                                        }
                                    }
                                }
                            }
                            G.round_eval:add_child(deck_reward_row, eval_target)
                        end
                    end

                    UIBox{
                        definition = {
                            n = G.UIT.ROOT, config = { align = 'cm', colour = G.C.CLEAR },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = {
                                        id = 'cash_out_button',
                                        align = "cm",
                                        padding = 0.1,
                                        minw = 7.4,
                                        r = 0.15,
                                        colour = G.C.ORANGE,
                                        shadow = true,
                                        hover = true,
                                        one_press = true,
                                        button = 'cash_out',
                                        focus_args = { snap_to = true }
                                    },
                                    nodes = {
                                        { n = G.UIT.T, config = { text = localize('b_cash_out') .. ": ", scale = 1, colour = G.C.UI.TEXT_LIGHT, shadow = true } },
                                        { n = G.UIT.T, config = { text = localize('$') .. config.dollars, scale = 1.2 * scale, colour = G.C.WHITE, shadow = true, juice = true } },
                                        { n = G.UIT.B, config = { w = 0.25, h = 0.1 } },
                                        {
                                            n = G.UIT.C,
                                            config = { align = "cm", padding = 0.06, r = 0.1, colour = HEX('200f38'), outline = 0.03, outline_colour = HEX('c084fc'), emboss = 0.04 },
                                            nodes = {
                                                { n = G.UIT.T, config = { text = "+$" .. tostring(total_coins), scale = 1.10 * scale, colour = HEX('c084fc'), shadow = true, juice = true } }
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        config = {
                            align = 'tmi',
                            offset = { x = 0, y = 0.4 },
                            major = G.round_eval
                        }
                    }

                    G.GAME.current_round.dollars = config.dollars
                    play_sound('coin6', config.pitch or 1)
                    play_sound('coin3', 1.1, 0.7)
                    G.VIBRATION = G.VIBRATION + 1
                    return true
                end
            }))
            return
        end
        return orig_add_round_eval_row(config)
    end
end

-- HUD UI Injection for Unified Dollars & Dark Money Box
local function inject_dark_coin_hud(tree)
    if not tree or type(tree) ~= 'table' then return false end
    if tree.nodes then
        for _, child in ipairs(tree.nodes) do
            if child and child.nodes and child.nodes[1] and child.nodes[1].nodes then
                local dollar_box = child.nodes[1].nodes[1]
                if dollar_box and dollar_box.nodes and dollar_box.nodes[1] and dollar_box.nodes[1].config and dollar_box.nodes[1].config.id == 'dollar_text_UI' then
                    local scale = 0.4
                    local temp_col = (child.config and child.config.colour) or G.C.DYN_UI.BOSS_MAIN
                    local temp_col2 = (dollar_box.config and dollar_box.config.colour) or G.C.DYN_UI.BOSS_DARK

                    tree.nodes = {
                        {
                            n = G.UIT.C,
                            config = {
                                id = 'hud_unified_money_box',
                                align = "cm",
                                padding = 0.05,
                                minw = 2.85,
                                minh = 1.15,
                                colour = temp_col,
                                emboss = 0.05,
                                r = 0.12
                            },
                            nodes = {
                                {
                                    n = G.UIT.R,
                                    config = { align = "cm", padding = 0.02 },
                                    nodes = {
                                        -- 1. Regular Dollars ($)
                                        {
                                            n = G.UIT.C,
                                            config = {
                                                id = 'hud_dollars_section',
                                                align = "cm",
                                                r = 0.10,
                                                minw = 1.30,
                                                minh = 1.0,
                                                colour = temp_col2
                                            },
                                            nodes = {
                                                {
                                                    n = G.UIT.O,
                                                    config = {
                                                        object = DynaText({
                                                            string = {{ ref_table = G.GAME, ref_value = 'dollars', prefix = localize('$') }},
                                                            maxw = 1.2,
                                                            colours = { G.C.MONEY },
                                                            font = G.LANGUAGES['en-us'].font,
                                                            shadow = true,
                                                            spacing = 2,
                                                            bump = true,
                                                            scale = 2.0 * scale
                                                        }),
                                                        id = 'dollar_text_UI'
                                                    }
                                                }
                                            }
                                        },
                                        -- Subtle Vertical Divider
                                        {
                                            n = G.UIT.C,
                                            config = { align = "cm", minw = 0.04, minh = 0.85, colour = HEX('301548'), r = 0.02 },
                                            nodes = {}
                                        },
                                        -- 2. Dark Money (€)
                                        {
                                            n = G.UIT.C,
                                            config = {
                                                id = 'hud_dark_coins_section',
                                                align = "cm",
                                                r = 0.10,
                                                minw = 1.30,
                                                minh = 1.0,
                                                colour = HEX('17072b'),
                                                outline = 0.02,
                                                outline_colour = HEX('c084fc')
                                            },
                                            nodes = {
                                                {
                                                    n = G.UIT.O,
                                                    config = {
                                                        object = DynaText({
                                                            string = {{ ref_table = G.GAME, ref_value = 'dark_coins', prefix = "$" }},
                                                            maxw = 1.2,
                                                            colours = { HEX('c084fc') },
                                                            font = G.LANGUAGES['en-us'].font,
                                                            shadow = true,
                                                            spacing = 2,
                                                            bump = true,
                                                            scale = 2.0 * scale
                                                        }),
                                                        id = 'dark_coin_text_UI'
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    return true
                end
            end
            if inject_dark_coin_hud(child) then
                return true
            end
        end
    end
    return false
end

if create_UIBox_HUD then
    local orig_create_UIBox_HUD = create_UIBox_HUD
    function create_UIBox_HUD()
        if G.GAME then
            G.GAME.dark_coins = G.GAME.dark_coins or 0
        end
        local hud = orig_create_UIBox_HUD()
        inject_dark_coin_hud(hud)
        return hud
    end
end

-- Black Market Slot Buying & UI Refresh Callbacks
G.FUNCS.buy_black_market_slot = function(e)
    local slot_idx = e.config and e.config.ref_table and e.config.ref_table.slot
    if not slot_idx or not G.GAME.black_market_stock or not G.GAME.black_market_stock[slot_idx] then return end
    local item = G.GAME.black_market_stock[slot_idx]
    if item.sold then return end

    local cost = item.cost or 1
    if (G.GAME.dark_coins or 0) < cost then
        play_sound('cancel')
        return
    end

    local is_consumeable = (item.set == 'Potion' or item.set == 'Tarot' or item.set == 'Spectral' or item.set == 'Consumeables')
    if is_consumeable then
        if #G.consumeables.cards >= G.consumeables.config.card_limit then
            card_eval_status_text(G.consumeables, 'extra', nil, nil, nil, { message = localize('k_no_space_ex'), colour = G.C.RED })
            play_sound('cancel')
            return
        end
    else
        if #G.jokers.cards >= G.jokers.config.card_limit then
            card_eval_status_text(G.jokers, 'extra', nil, nil, nil, { message = localize('k_no_space_ex'), colour = G.C.RED })
            play_sound('cancel')
            return
        end
    end

    item.sold = true
    ease_dark_coins(-cost)
    play_sound('card1')
    play_sound('coin3')

    local target_area = is_consumeable and G.consumeables or G.jokers
    local new_card = create_card(item.set, target_area, nil, nil, nil, nil, item.key, 'bm_buy')
    if new_card then
        new_card:add_to_deck()
        target_area:emplace(new_card)
        new_card:juice_up()

        for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:calculate_joker({ buying_card = true, card = new_card })
        end
    end

    local quote = get_random_kyra_quote('buy')
    update_kyra_dialogue(quote)

    G.FUNCS.refresh_black_market_ui()
end

G.FUNCS.refresh_black_market_ui = function()
    if G.black_market and not G.black_market.REMOVED then
        pcall(function() G.black_market:remove() end)
        G.black_market = UIBox{
            definition = G.UIDEF.black_market(),
            config = { align = 'tmi', offset = { x = 0, y = -5.3 }, major = G.hand, bond = 'Weak' }
        }
    end
end

-- Card Stock Generation for Black Market (4 Fixed Categories with Controlled Rarities)
local function generate_black_market_stock()
    G.GAME.black_market_stock = {}
    local ante = (G.GAME.round_resets and G.GAME.round_resets.ante) or 1
    local round = G.GAME.round or 1

    local secret_keys = {
        'j_reality_warp_esteban', 'j_reality_warp_thiago', 'j_reality_warp_black_hole_joker',
        'j_reality_warp_squele', 'j_reality_warp_bluxdir', 'j_reality_warp_charles', 'j_reality_warp_mochi',
        'j_reality_warp_helin', 'j_reality_warp_raytracing', 'j_reality_warp_paco', 'j_reality_warp_yairo',
        'j_reality_warp_kyra'
    }
    local valid_secret_keys = {}
    for _, k in ipairs(secret_keys) do
        if G.P_CENTERS and G.P_CENTERS[k] then
            table.insert(valid_secret_keys, k)
        end
    end

    local legendary_keys = {
        'j_caino', 'j_triboulet', 'j_yorick', 'j_chicot', 'j_perkeo',
        'j_reality_warp_world_devourer', 'j_reality_warp_living_paradox', 'j_reality_warp_star_chronicler'
    }
    local valid_legendary_keys = {}
    for _, k in ipairs(legendary_keys) do
        if G.P_CENTERS and G.P_CENTERS[k] then
            table.insert(valid_legendary_keys, k)
        end
    end

    local gang_key = (G.P_CENTERS and G.P_CENTERS['c_reality_warp_the_gang'] and 'c_reality_warp_the_gang')
        or (G.P_CENTERS and G.P_CENTERS['c_the_gang'] and 'c_the_gang')
        or (G.P_CENTERS and G.P_CENTERS['c_reality_warp_la_muchachada'] and 'c_reality_warp_la_muchachada')

    for slot = 1, 4 do
        local key = nil
        local set = 'Joker'
        local cost = 2
        local roll = pseudorandom('bm_gen_' .. tostring(round) .. '_' .. tostring(slot) .. '_' .. tostring(ante))

        if slot == 1 then
            -- Slot 1: Potions (Kyra's specialty!) - 100% Potion
            set = 'Potion'
            cost = 2
            if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Potion'] and #G.P_CENTER_POOLS['Potion'] > 0 then
                local chosen = pseudorandom_element(G.P_CENTER_POOLS['Potion'], pseudoseed('bm_pot_' .. tostring(round) .. '_' .. tostring(slot)))
                key = chosen and chosen.key
            end
            if not key or not G.P_CENTERS[key] then
                key = 'c_reality_warp_potion_stretch'
            end
        elseif slot == 2 then
            -- Slot 2: Consumables (Tarots & Spectrals)
            if roll < 0.02 and (G.P_CENTERS['c_soul'] or G.P_CENTERS['c_black_hole'] or gang_key) then
                local rare_pool = {}
                if G.P_CENTERS['c_soul'] then table.insert(rare_pool, { key = 'c_soul', cost = 6 }) end
                if G.P_CENTERS['c_black_hole'] then table.insert(rare_pool, { key = 'c_black_hole', cost = 5 }) end
                if gang_key then table.insert(rare_pool, { key = gang_key, cost = 7 }) end
                local chosen = pseudorandom_element(rare_pool, pseudoseed('bm_rare_spec_' .. tostring(round) .. '_' .. tostring(slot)))
                key = chosen.key
                set = 'Spectral'
                cost = chosen.cost
            elseif roll < 0.30 then
                set = 'Spectral'
                cost = 2
                if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Spectral'] and #G.P_CENTER_POOLS['Spectral'] > 0 then
                    local chosen = pseudorandom_element(G.P_CENTER_POOLS['Spectral'], pseudoseed('bm_spec_' .. tostring(round) .. '_' .. tostring(slot)))
                    key = chosen and chosen.key
                end
                if not key or not G.P_CENTERS[key] then key = 'c_ankh' end
            else
                set = 'Tarot'
                cost = 1
                if G.P_CENTER_POOLS and G.P_CENTER_POOLS['Tarot'] and #G.P_CENTER_POOLS['Tarot'] > 0 then
                    local chosen = pseudorandom_element(G.P_CENTER_POOLS['Tarot'], pseudoseed('bm_tar_' .. tostring(round) .. '_' .. tostring(slot)))
                    key = chosen and chosen.key
                end
                if not key or not G.P_CENTERS[key] then key = 'c_fool' end
            end
        elseif slot == 3 then
            -- Slot 3: Stolen Jokers from other players
            set = 'Joker'
            if roll < 0.015 and #valid_legendary_keys > 0 then
                key = pseudorandom_element(valid_legendary_keys, pseudoseed('bm_leg3_' .. tostring(round)))
                cost = 15
            elseif roll < 0.050 and #valid_secret_keys > 0 then
                key = pseudorandom_element(valid_secret_keys, pseudoseed('bm_sec3_' .. tostring(round)))
                cost = 20
            elseif roll < 0.350 then
                cost = 4
                if G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[3] and #G.P_JOKER_RARITY_POOLS[3] > 0 then
                    local chosen = pseudorandom_element(G.P_JOKER_RARITY_POOLS[3], pseudoseed('bm_jok3r_' .. tostring(round)))
                    key = chosen and chosen.key
                end
                if not key or not G.P_CENTERS[key] then key = 'j_blueprint' end
            else
                cost = 3
                if G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[2] and #G.P_JOKER_RARITY_POOLS[2] > 0 then
                    local chosen = pseudorandom_element(G.P_JOKER_RARITY_POOLS[2], pseudoseed('bm_jok3u_' .. tostring(round)))
                    key = chosen and chosen.key
                end
                if not key or not G.P_CENTERS[key] then key = 'j_half' end
            end
        else
            -- Slot 4: Contraband Goods
            if roll < 0.020 and #valid_legendary_keys > 0 then
                key = pseudorandom_element(valid_legendary_keys, pseudoseed('bm_leg4_' .. tostring(round)))
                set = 'Joker'
                cost = 15
            elseif roll < 0.060 and #valid_secret_keys > 0 then
                key = pseudorandom_element(valid_secret_keys, pseudoseed('bm_sec4_' .. tostring(round)))
                set = 'Joker'
                cost = 20
            elseif roll < 0.085 and (gang_key or G.P_CENTERS['c_soul'] or G.P_CENTERS['c_black_hole']) then
                local rare_pool = {}
                if G.P_CENTERS['c_soul'] then table.insert(rare_pool, { key = 'c_soul', cost = 6 }) end
                if G.P_CENTERS['c_black_hole'] then table.insert(rare_pool, { key = 'c_black_hole', cost = 5 }) end
                if gang_key then table.insert(rare_pool, { key = gang_key, cost = 7 }) end
                local chosen = pseudorandom_element(rare_pool, pseudoseed('bm_rare4_' .. tostring(round)))
                key = chosen.key
                set = 'Spectral'
                cost = chosen.cost
            elseif roll < 0.440 then
                set = 'Joker'
                cost = 4
                if G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[3] and #G.P_JOKER_RARITY_POOLS[3] > 0 then
                    local chosen = pseudorandom_element(G.P_JOKER_RARITY_POOLS[3], pseudoseed('bm_jok4r_' .. tostring(round)))
                    key = chosen and chosen.key
                end
                if not key or not G.P_CENTERS[key] then key = 'j_invisible' end
            else
                set = 'Joker'
                cost = 3
                if G.P_JOKER_RARITY_POOLS and G.P_JOKER_RARITY_POOLS[2] and #G.P_JOKER_RARITY_POOLS[2] > 0 then
                    local chosen = pseudorandom_element(G.P_JOKER_RARITY_POOLS[2], pseudoseed('bm_jok4u_' .. tostring(round)))
                    key = chosen and chosen.key
                end
                if not key or not G.P_CENTERS[key] then key = 'j_joker' end
            end
        end

        local center = key and G.P_CENTERS[key]
        local name = (center and center.loc_txt and center.loc_txt.name)
            or (key and localize{type = 'name_text', key = key, set = set})
            or (center and center.name)
            or "Contraband"

        G.GAME.black_market_stock[slot] = {
            slot = slot,
            key = key,
            set = set,
            cost = cost,
            name = name,
            sold = false
        }
    end
end

-- Black Market Reroll Callbacks
G.FUNCS.can_reroll_black_market = function(e)
    if (G.GAME.dark_coins or 0) < 1 then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        e.config.colour = HEX('7e22ce')
        e.config.button = 'reroll_black_market'
    end
end

G.FUNCS.reroll_black_market = function(e)
    if (G.GAME.dark_coins or 0) < 1 then return end
    ease_dark_coins(-1)
    play_sound('coin2', 0.9, 0.7)
    play_sound('other1', 1.0, 0.7)

    local quote = get_random_kyra_quote('reroll')
    update_kyra_dialogue(quote)

    generate_black_market_stock()
    G.FUNCS.refresh_black_market_ui()
end

-- Black Market UI Definition (Pouch Slot-Rack Style with Dedicated Price Pills and Textured Slot Boxes)
function G.UIDEF.black_market()
    if G.bm_slot_areas then
        for _, area in ipairs(G.bm_slot_areas) do
            pcall(function() area:remove() end)
        end
        G.bm_slot_areas = nil
    end
    G.bm_slot_areas = {}

    if G.bm_kyra_area then
        pcall(function() G.bm_kyra_area:remove() end)
        G.bm_kyra_area = nil
        G.bm_kyra_card = nil
    end

    -- Kyra Physical Joker Card for Black Market Counter
    local kyra_center = (G.P_CENTERS and G.P_CENTERS['j_reality_warp_kyra'])
        or (G.P_CENTERS and G.P_CENTERS['j_Witch brew_kyra'])
        or (G.P_CENTERS and G.P_CENTERS['j_kyra'])
        or (G.P_CENTERS and G.P_CENTERS['kyra'])
    if not kyra_center and G.P_CENTERS then
        for k, v in pairs(G.P_CENTERS) do
            if string.find(string.lower(k), 'kyra', 1, true) then
                kyra_center = v
                break
            end
        end
    end

    local kyra_scale = 0.65
    local kyra_w = G.CARD_W * kyra_scale
    local kyra_h = G.CARD_H * kyra_scale

    G.bm_kyra_area = CardArea(0, 0, kyra_w, kyra_h, { card_limit = 1, type = 'title', highlight_limit = 0, card_w = kyra_w })
    local kyra_card = Card(0, 0, kyra_w, kyra_h, G.P_CARDS.empty, kyra_center or (G.P_CENTERS and G.P_CENTERS.j_joker))
    kyra_card.facing = 'front'
    if kyra_center then
        kyra_card:set_ability(kyra_center)
    end
    G.bm_kyra_area:emplace(kyra_card)
    G.bm_kyra_card = kyra_card

    -- 4 Designated Slot Boxes (Alchemical Rack Structure like Pouch)
    local slot_scale = 0.65
    local slot_w = G.CARD_W * slot_scale
    local slot_h = G.CARD_H * slot_scale
    local slot_nodes = {}

    for slot_idx = 1, 4 do
        local item = G.GAME.black_market_stock and G.GAME.black_market_stock[slot_idx]
        if item then
            local center = item.key and G.P_CENTERS[item.key]
            local item_area = CardArea(0, 0, slot_w, slot_h, { card_limit = 1, type = 'title', highlight_limit = 0, card_w = slot_w })
            table.insert(G.bm_slot_areas, item_area)

            local item_card = Card(0, 0, slot_w, slot_h, G.P_CARDS.empty, center or (G.P_CENTERS and G.P_CENTERS.c_base))
            item_card.facing = 'front'
            if center then
                item_card:set_ability(center)
            end
            item_area:emplace(item_card)

            local can_afford = (G.GAME.dark_coins or 0) >= (item.cost or 1)

            table.insert(slot_nodes, {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.05,
                    r = 0.10,
                    minw = 2.2,
                    colour = HEX('140728'),
                    outline = 0.02,
                    outline_colour = item.sold and HEX('3f3f46') or HEX('c084fc'),
                    emboss = 0.03
                },
                nodes = {
                    -- Dedicated Price Box / Pill at the top (shifted 10px higher)
                    {
                        n = G.UIT.R,
                        config = {
                            align = "cm",
                            padding = 0.02,
                            r = 0.08,
                            minw = 1.6,
                            minh = 0.36,
                            colour = item.sold and HEX('27272a') or HEX('261047'),
                            outline = 0.02,
                            outline_colour = item.sold and HEX('52525b') or HEX('e9d5ff'),
                            shadow = true
                        },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = item.sold and "SOLD" or ("$" .. tostring(item.cost or 1)),
                                    scale = 0.36,
                                    colour = item.sold and G.C.UI.TEXT_INACTIVE or HEX('f3e8ff'),
                                    shadow = true
                                }
                            }
                        }
                    },
                    -- 10px spacing buffer to lift the price box
                    { n = G.UIT.R, config = { minh = 0.14 }, nodes = {} },
                    -- Card in its own area
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = {
                            { n = G.UIT.O, config = { object = item_area } }
                        }
                    },
                    -- Card Name label
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02, maxw = 2.1 },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = item.name or "Item",
                                    scale = 0.25,
                                    colour = item.sold and G.C.UI.TEXT_INACTIVE or G.C.WHITE,
                                    shadow = true
                                }
                            }
                        }
                    },
                    -- Buy Button / Sold badge
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.02 },
                        nodes = {
                            item.sold and {
                                n = G.UIT.C,
                                config = {
                                    align = "cm",
                                    padding = 0.05,
                                    minw = 1.6,
                                    minh = 0.42,
                                    r = 0.08,
                                    colour = HEX('27272a')
                                },
                                nodes = {
                                    { n = G.UIT.T, config = { text = "SOLD", scale = 0.28, colour = G.C.UI.TEXT_INACTIVE } }
                                }
                            } or {
                                n = G.UIT.C,
                                config = {
                                    id = 'bm_buy_slot_' .. slot_idx,
                                    align = "cm",
                                    padding = 0.05,
                                    minw = 1.6,
                                    minh = 0.42,
                                    r = 0.08,
                                    hover = can_afford,
                                    shadow = true,
                                    colour = can_afford and HEX('6b21a8') or G.C.UI.BACKGROUND_INACTIVE,
                                    button = can_afford and 'buy_black_market_slot' or nil,
                                    ref_table = { slot = slot_idx }
                                },
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            text = "Buy",
                                            scale = 0.30,
                                            colour = can_afford and G.C.WHITE or G.C.UI.TEXT_INACTIVE,
                                            shadow = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
        end
    end

    local t = {
        n = G.UIT.ROOT,
        config = { align = 'cm', colour = G.C.CLEAR },
        nodes = {
            {
                n = G.UIT.C,
                config = {
                    align = "cm",
                    padding = 0.08,
                    emboss = 0.05,
                    r = 0.14,
                    colour = HEX('1a0b33'),
                    outline = 0.03,
                    outline_colour = HEX('ffffff')
                },
                nodes = {
                    -- 1. Kyra Header Banner
                    {
                        n = G.UIT.R,
                        config = {
                            align = "cm",
                            padding = 0.06,
                            minw = 11.5,
                            r = 0.12,
                            colour = HEX('27114c'),
                            outline = 0.03,
                            outline_colour = HEX('ffffff'),
                            emboss = 0.05
                        },
                        nodes = {
                            -- Kyra Card Slot
                            {
                                n = G.UIT.C,
                                config = { align = "cm", padding = 0.03, minw = 1.6, r = 0.1, colour = HEX('1e0f38') },
                                nodes = {
                                    { n = G.UIT.O, config = { object = G.bm_kyra_area } },
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cm", padding = 0.02 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = "Kyra", scale = 0.30, colour = HEX('ffffff'), shadow = true } }
                                        }
                                    }
                                }
                            },
                            { n = G.UIT.C, config = { minw = 0.10 }, nodes = {} },
                            -- Kyra Dialogue Speech Box
                            {
                                n = G.UIT.C,
                                config = { align = "cl", padding = 0.08, minw = 9.4, maxw = 9.4, minh = 1.25, r = 0.10, colour = HEX('15082b'), outline = 0.02, outline_colour = HEX('ede9fe') },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cl", padding = 0.02 },
                                        nodes = {
                                            { n = G.UIT.T, config = { text = "KYRA (Black Market)", scale = 0.32, colour = HEX('e9d5ff'), shadow = true } }
                                        }
                                    },
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cl", maxw = 9.2 },
                                        nodes = {
                                            {
                                                n = G.UIT.O,
                                                config = {
                                                    object = DynaText({
                                                        string = {{ ref_table = G.GAME, ref_value = 'kyra_current_quote' }},
                                                        colours = { HEX('ffffff') },
                                                        scale = 0.44,
                                                        shadow = true,
                                                        maxw = 9.2,
                                                        pop_in = 0.2
                                                    }),
                                                    id = 'kyra_dialogue_dynatext'
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    },
                    { n = G.UIT.R, config = { minh = 0.10 }, nodes = {} },
                    -- 2. Main Controls & Wares Row
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.03 },
                        nodes = {
                            -- Left Controls Column
                            {
                                n = G.UIT.C,
                                config = { align = "cm", padding = 0.04 },
                                nodes = {
                                    -- Dark Money Balance Readout
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            align = "cm",
                                            padding = 0.05,
                                            r = 0.10,
                                            colour = HEX('1a0933'),
                                            outline = 0.025,
                                            outline_colour = HEX('c084fc'),
                                            minw = 1.95,
                                            minh = 0.62,
                                            shadow = true,
                                            emboss = 0.03
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.C,
                                                config = { align = "cm" },
                                                nodes = {
                                                    {
                                                        n = G.UIT.R,
                                                        config = { align = "cm" },
                                                        nodes = {
                                                            { n = G.UIT.T, config = { text = "DARK MONEY", scale = 0.22, colour = HEX('d8b4fe'), shadow = true } }
                                                        }
                                                    },
                                                    {
                                                        n = G.UIT.R,
                                                        config = { align = "cm" },
                                                        nodes = {
                                                            { n = G.UIT.T, config = { text = "$", scale = 0.44, colour = HEX('c084fc'), shadow = true } },
                                                            { n = G.UIT.T, config = { text = " ", scale = 0.20 } },
                                                            { n = G.UIT.T, config = { ref_table = G.GAME, ref_value = 'dark_coins', scale = 0.44, colour = G.C.WHITE, shadow = true } }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    { n = G.UIT.R, config = { minh = 0.05 }, nodes = {} },
                                    -- Return to normal shop button
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            id = 'exit_black_market_button',
                                            align = "cm",
                                            minw = 1.9,
                                            minh = 0.85,
                                            r = 0.10,
                                            colour = HEX('3f3f46'),
                                            outline = 0.02,
                                            outline_colour = HEX('ffffff'),
                                            button = 'exit_black_market',
                                            hover = true,
                                            shadow = true
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm" },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = "Return To", scale = 0.30, colour = G.C.WHITE, shadow = true } }
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm" },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = "Shop", scale = 0.34, colour = G.C.GOLD, shadow = true } }
                                                }
                                            }
                                        }
                                    },
                                    { n = G.UIT.R, config = { minh = 0.05 }, nodes = {} },
                                    -- Reroll stock button (Dark Coins)
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            id = 'reroll_black_market_button',
                                            align = "cm",
                                            minw = 1.9,
                                            minh = 0.85,
                                            r = 0.10,
                                            colour = HEX('7e22ce'),
                                            outline = 0.02,
                                            outline_colour = HEX('ffffff'),
                                            button = 'reroll_black_market',
                                            func = 'can_reroll_black_market',
                                            hover = true,
                                            shadow = true
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm" },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = "Reroll Stock", scale = 0.30, colour = G.C.WHITE, shadow = true } }
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm" },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = "$1", scale = 0.38, colour = HEX('ffffff'), shadow = true } }
                                                }
                                            }
                                        }
                                    },
                                    { n = G.UIT.R, config = { minh = 0.05 }, nodes = {} },
                                    -- Next Round Button
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            id = 'bm_next_round_button',
                                            align = "cm",
                                            minw = 1.9,
                                            minh = 0.80,
                                            r = 0.10,
                                            colour = G.C.RED,
                                            outline = 0.02,
                                            outline_colour = HEX('ffffff'),
                                            one_press = true,
                                            button = 'toggle_shop',
                                            hover = true,
                                            shadow = true
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm" },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = localize('b_next_round_1'), scale = 0.30, colour = G.C.WHITE, shadow = true } }
                                                }
                                            },
                                            {
                                                n = G.UIT.R,
                                                config = { align = "cm" },
                                                nodes = {
                                                    { n = G.UIT.T, config = { text = localize('b_next_round_2'), scale = 0.30, colour = G.C.WHITE, shadow = true } }
                                                }
                                            }
                                        }
                                    }
                                }
                            },
                            -- Right Wares Container (Alchemical Rack of 4 Textured Slots)
                            {
                                n = G.UIT.C,
                                config = {
                                    align = "cm",
                                    padding = 0.08,
                                    r = 0.14,
                                    colour = HEX('180830'),
                                    outline = 0.03,
                                    outline_colour = HEX('ffffff'),
                                    emboss = 0.05,
                                    minw = 9.4
                                },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = { align = "cm", padding = 0.04 },
                                        nodes = slot_nodes
                                    }
                                }
                            }
                        }
                    },
                    -- 3. Subtitle footer
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.05 },
                        nodes = {
                            {
                                n = G.UIT.T,
                                config = {
                                    text = "Contraband Potions  |  Forbidden Spectrals  |  Borrowed Jokers  |  Contraband Goods",
                                    scale = 0.28,
                                    colour = HEX('ffffff'),
                                    shadow = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return t
end

-- Helper to inject Scaled Black Market Button to the right of G.shop_jokers
local function inject_black_market_shop_button(tree)
    if not tree or type(tree) ~= 'table' then return false end
    if tree.nodes then
        for _, child in ipairs(tree.nodes) do
            if child and child.nodes then
                for _, grandchild in ipairs(child.nodes) do
                    if grandchild and grandchild.config and grandchild.config.object == G.shop_jokers then
                        local already_has = false
                        for _, sibling in ipairs(tree.nodes) do
                            if sibling.config and sibling.config.id == 'black_market_col' then
                                already_has = true
                                break
                            end
                        end
                        if not already_has then
                            table.insert(tree.nodes, {
                                n = G.UIT.C,
                                config = { id = 'black_market_col', align = "cm", padding = 0.03 },
                                nodes = {
                                    {
                                        n = G.UIT.R,
                                        config = {
                                            id = 'black_market_entrance_button',
                                            align = "cm",
                                            minw = 1.35,
                                            minh = 2.0,
                                            r = 0.10,
                                            colour = HEX('2a1050'),
                                            outline = 0.02,
                                            outline_colour = HEX('ffffff'),
                                            hover = true,
                                            shadow = true,
                                            button = 'enter_black_market'
                                        },
                                        nodes = {
                                            {
                                                n = G.UIT.C,
                                                config = { align = "cm", padding = 0.03 },
                                                nodes = {
                                                    { n = G.UIT.R, config = { align = "cm" }, nodes = { { n = G.UIT.T, config = { text = "BLACK", scale = 0.28, colour = HEX('ffffff'), shadow = true } } } },
                                                    { n = G.UIT.R, config = { align = "cm" }, nodes = { { n = G.UIT.T, config = { text = "MARKET", scale = 0.28, colour = HEX('c084fc'), shadow = true } } } },
                                                    { n = G.UIT.R, config = { align = "cm", minh = 0.06 }, nodes = {} },
                                                    { n = G.UIT.R, config = { align = "cm", r = 0.06, colour = HEX('4c1d95'), padding = 0.04, minw = 1.15 }, nodes = { { n = G.UIT.T, config = { text = "$ Enter", scale = 0.30, colour = G.C.WHITE, shadow = true } } } }
                                                }
                                            }
                                        }
                                    }
                                }
                            })
                        end
                        return true
                    end
                end
            end
            if inject_black_market_shop_button(child) then
                return true
            end
        end
    end
    return false
end

-- Shop UI Hook (1 in 2 chance per shop visit, guaranteed for Dark Merchant Deck)
if G and G.UIDEF and G.UIDEF.shop then
    local orig_uidef_shop = G.UIDEF.shop
    G.UIDEF.shop = function()
        if G.GAME and G.GAME.black_market_last_shop_round ~= (G.GAME.round or 0) then
            G.GAME.black_market_last_shop_round = (G.GAME.round or 0)
            local roll = pseudorandom('black_market_avail_' .. tostring(G.GAME.round or 0) .. '_' .. tostring((G.GAME.round_resets and G.GAME.round_resets.ante) or 1))
            G.GAME.black_market_available = (roll < 0.5)
        end

        if G.GAME and G.GAME.dark_merchant_deck then
            G.GAME.black_market_available = true
        end

        local res = orig_uidef_shop()

        if G.GAME and G.GAME.black_market_available then
            inject_black_market_shop_button(res)
        end

        return res
    end
end

-- Enter & Exit Black Market View Transitions (Purple & White Theme)
G.FUNCS.enter_black_market = function(e)
    stop_use()
    G.GAME.in_black_market = true

    -- Purple & White background theme
    ease_background_colour{
        new_colour = HEX('230d42'),
        special_colour = HEX('ffffff'),
        contrast = 2.0
    }

    if G.SHOP_SIGN then
        G.SHOP_SIGN.alignment.offset.y = -15
    end

    -- Shift normal shop downwards off-screen to preserve its state
    if G.shop then
        G.shop.alignment.offset.y = G.ROOM.T.y + 29
    end

    play_sound('tarot1', 0.8, 0.8)

    G.GAME.kyra_current_quote = get_random_kyra_quote('enter')

    if not G.GAME.black_market_stock or G.GAME.black_market_stock_round ~= G.GAME.round then
        G.GAME.black_market_stock_round = G.GAME.round
        generate_black_market_stock()
    end

    if G.black_market then
        pcall(function() G.black_market:remove() end)
        G.black_market = nil
    end

    G.black_market = UIBox{
        definition = G.UIDEF.black_market(),
        config = { align = 'tmi', offset = { x = 0, y = -5.3 }, major = G.hand, bond = 'Weak' }
    }
end

G.FUNCS.exit_black_market = function(e)
    stop_use()
    G.GAME.in_black_market = false

    ease_background_colour_blind(G.STATES.SHOP)

    if G.SHOP_SIGN then
        G.SHOP_SIGN.alignment.offset.y = 0
    end

    play_sound('whoosh1', 1.1, 0.6)

    -- Remove Black Market UIBox and temporary slot CardAreas cleanly
    if G.black_market then
        pcall(function() G.black_market:remove() end)
        G.black_market = nil
    end

    if G.bm_slot_areas then
        for _, area in ipairs(G.bm_slot_areas) do
            pcall(function() area:remove() end)
        end
        G.bm_slot_areas = nil
    end

    if G.bm_kyra_area then
        pcall(function() G.bm_kyra_area:remove() end)
        G.bm_kyra_area = nil
        G.bm_kyra_card = nil
    end

    -- Slide the untouched normal shop back into place
    if G.shop then
        G.shop.alignment.offset.y = -5.3
        G.shop.alignment.offset.x = 0
    end
end

-- Shop Exit Cleanup Hook
if G and G.FUNCS and G.FUNCS.toggle_shop then
    local orig_toggle_shop = G.FUNCS.toggle_shop
    G.FUNCS.toggle_shop = function(e)
        if G.GAME then
            G.GAME.in_black_market = false
            G.GAME.black_market_stock_round = nil
            G.GAME.black_market_stock = nil
        end
        if G.black_market then
            pcall(function() G.black_market:remove() end)
            G.black_market = nil
        end
        if G.bm_kyra_area then
            pcall(function() G.bm_kyra_area:remove() end)
            G.bm_kyra_area = nil
            G.bm_kyra_card = nil
        end
        if G.bm_slot_areas then
            for _, area in ipairs(G.bm_slot_areas) do
                pcall(function() area:remove() end)
            end
            G.bm_slot_areas = nil
        end
        orig_toggle_shop(e)
    end
end
