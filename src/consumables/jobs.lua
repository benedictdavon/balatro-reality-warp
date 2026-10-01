-- Job Cards & Booster Packs

-- Consumable Type: Jobs
SMODS.ConsumableType {
    key = 'Job',
    primary_colour = HEX('ffffff'),
    secondary_colour = HEX('52525c'),
    loc_txt = {
        name = 'Job',
        collection = 'Job Cards',
        underscores_single = 'Job Card',
        underscores_plural = 'Job Cards'
    },
    shop_rate = 0.0,
    collection_rows = { 2, 7 },
    default = 'c_Witch_brew_miner_job'
}

local JOB_CARD_KEYS = {
    'c_Witch_brew_miner_job',
    'c_Witch_brew_gardener_job',
    'c_Witch_brew_banker_job',
    'c_Witch_brew_surgeon_job',
    'c_Witch_brew_alchemist_job',
    'c_Witch_brew_butcher_job',
    'c_Witch_brew_detective_job',
    'c_Witch_brew_chef_job',
    'c_Witch_brew_archaeologist_job',
    'c_Witch_brew_jeweler_job',
    'c_Witch_brew_apothecary_job',
    'c_Witch_brew_bounty_hunter_job',
    'c_Witch_brew_croupier_job'
}

local function create_job_card_for_pack(key_append)
    local card_obj = nil
    if create_card then
        card_obj = create_card('Job', G.pack_cards, nil, nil, true, false, nil, key_append or 'job_pack')
    end
    if (not card_obj or not card_obj.config) and SMODS and SMODS.create_card then
        card_obj = SMODS.create_card({ set = 'Job', area = G.pack_cards, skip_materialize = true, key_append = key_append or 'job_pack' })
    end
    if not card_obj or not card_obj.config then
        local valid_keys = {}
        for _, k in ipairs(JOB_CARD_KEYS) do
            if G.P_CENTERS and G.P_CENTERS[k] then
                table.insert(valid_keys, k)
            end
        end
        local chosen_key = (#valid_keys > 0) and pseudorandom_element(valid_keys, pseudoseed(key_append or 'job_pack_valid')) or pseudorandom_element(JOB_CARD_KEYS, pseudoseed(key_append or 'job_pack_fallback'))
        local center = (G.P_CENTERS and G.P_CENTERS[chosen_key]) or (G.P_CENTERS and G.P_CENTERS[string.gsub(chosen_key, 'c_Witch_brew_', 'c_')])
        if center then
            card_obj = Card(G.pack_cards.T.x + G.pack_cards.T.w/2, G.pack_cards.T.y, G.CARD_W, G.CARD_H, G.P_CARDS.empty, center, {bypass_discovery_center = true, bypass_discovery_ui = true})
        end
    end
    return card_obj
end

-- Job Stickers Atlas & SMODS.Sticker Definitions
SMODS.Atlas {
    key = "job_stickers",
    path = "job_stickers.png",
    px = 71,
    py = 95
}

local ALL_JOB_STICKERS = {
    'gardener_job',
    'detective_job',
    'chef_job',
    'archaeologist_job',
    'miner_job',
    'jeweler_job',
    'apothecary_job',
    'bounty_hunter_job',
    'croupier_job'
}

local function clear_card_jobs(card)
    if card and card.ability then
        for _, k in ipairs(ALL_JOB_STICKERS) do
            if card.ability[k] and SMODS.Stickers and SMODS.Stickers[k] then
                SMODS.Stickers[k]:apply(card, false)
            end
            card.ability[k] = nil
        end
    end
end



SMODS.Sticker {
    key = "gardener_job",
    atlas = "job_stickers",
    pos = { x = 0, y = 0 },
    badge_colour = HEX('27ae60'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Gardener',
        label = 'Gardener',
        text = {
            "When discarding this card, permanently adds",
            "{C:chips}+2{} base Chips to all cards",
            "of the same suit in full deck"
        }
    },
    calculate = function(self, card, context)
        if context.discard and context.other_card == card then
            local suit = card.base and card.base.suit
            if suit and G.playing_cards then
                for _, c in ipairs(G.playing_cards) do
                    if c:is_suit(suit) or (c.base and c.base.suit == suit) then
                        c.ability = c.ability or {}
                        c.ability.perma_bonus = (c.ability.perma_bonus or 0) + 2
                    end
                end
                if G.hand and G.hand.cards then
                    for _, c in ipairs(G.hand.cards) do
                        if c ~= card and (c:is_suit(suit) or (c.base and c.base.suit == suit)) then
                            c:juice_up(0.3, 0.3)
                        end
                    end
                end
                play_sound('chips1')
                local suit_name = (localize and localize(suit, 'suits_plural')) or suit
                local chip_msg = '+2 Chips (' .. suit_name .. ')!'
                return {
                    message = chip_msg,
                    colour = G.C.CHIPS,
                    card = card
                }
            end
        end
    end
}

SMODS.Sticker {
    key = "detective_job",
    atlas = "job_stickers",
    pos = { x = 1, y = 0 },
    badge_colour = HEX('2980b9'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Detective',
        label = 'Detective',
        text = {
            "On opening hand of the round,",
            "reveals the next 3 drawn cards and",
            "gives them {C:gold}Gold Seal{} or {C:blue}Blue Seal{}"
        }
    },
    calculate = function(self, card, context)
        if context.first_hand_drawn and card.area == G.hand then
            if G.deck and G.deck.cards and #G.deck.cards > 0 then
                local count = math.min(3, #G.deck.cards)
                local seals = { 'Gold', 'Blue' }
                local start_msg = 'Investigating Deck!'
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = start_msg, colour = HEX('2980b9') })
                for i = 1, count do
                    local top_c = G.deck.cards[#G.deck.cards - (i - 1)]
                    if top_c then
                        local chosen_seal = pseudorandom_element(seals, pseudoseed('detective_seal'))
                        top_c:set_seal(chosen_seal, true)
                        top_c:juice_up(0.4, 0.4)
                        local rank_str = (top_c.base and top_c.base.value) or 'Card'
                        local suit_str = (top_c.base and top_c.base.suit) or ''
                        local seal_name = chosen_seal == 'Gold' and 'Gold' or 'Blue'
                        local of_str = ' of '
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            func = function()
                                play_sound('tarot1', 1 + 0.1 * i)
                                card_eval_status_text(card, 'extra', nil, nil, nil, {
                                    message = rank_str .. of_str .. suit_str .. ' (' .. seal_name .. ')',
                                    colour = chosen_seal == 'Gold' and G.C.GOLD or G.C.BLUE
                                })
                                return true
                            end
                        }))
                    end
                end
                return {
                    message = 'Clues Discovered!',
                    colour = HEX('2980b9'),
                    card = card
                }
            end
        end
    end
}

SMODS.Sticker {
    key = "chef_job",
    atlas = "job_stickers",
    pos = { x = 2, y = 0 },
    badge_colour = HEX('e67e22'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Chef',
        label = 'Chef',
        text = {
            "When scoring face cards (J, Q, K),",
            "converts all other scored cards",
            "into {C:mult}Mult Cards{}"
        }
    },
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play and card:is_face() then
            local converted = 0
            if context.scoring_hand then
                for _, other_c in ipairs(context.scoring_hand) do
                    if other_c ~= card and other_c.config and other_c.config.center ~= G.P_CENTERS.m_mult then
                        other_c:set_ability(G.P_CENTERS.m_mult)
                        other_c:juice_up(0.5, 0.5)
                        converted = converted + 1
                    end
                end
            end
            if converted > 0 then
                play_sound('tarot1')
                return {
                    message = 'Seasoned!',
                    colour = HEX('e67e22'),
                    card = card
                }
            end
        end
    end
}

SMODS.Sticker {
    key = "archaeologist_job",
    atlas = "job_stickers",
    pos = { x = 3, y = 0 },
    badge_colour = HEX('d35400'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Archaeologist',
        label = 'Archaeologist',
        text = {
            "When scoring on final hand of round,",
            "recovers 1 discarded card with",
            "an edition ({C:dark_edition}Foil{}, {C:dark_edition}Holo{}, {C:dark_edition}Poly{})"
        }
    },
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            if G.GAME and G.GAME.current_round and G.GAME.current_round.hands_left == 0 and not card.ability.archaeologist_triggered_this_hand then
                card.ability.archaeologist_triggered_this_hand = true
                if G.discard and G.discard.cards and #G.discard.cards > 0 then
                    local rescued = pseudorandom_element(G.discard.cards, pseudoseed('archaeologist_rescue'))
                    if rescued and G.hand then
                        draw_card(G.discard, G.hand, 100, 'up', nil, rescued)
                        local edition_choices = {
                            { foil = true },
                            { holo = true },
                            { polychrome = true }
                        }
                        local chosen_ed = pseudorandom_element(edition_choices, pseudoseed('archaeologist_ed'))
                        rescued:set_edition(chosen_ed, true)
                        return {
                            message = 'Excavated!',
                            colour = G.C.GOLD,
                            card = card
                        }
                    end
                end
            end
        end
        if context.after or context.end_of_round then
            card.ability.archaeologist_triggered_this_hand = nil
        end
    end
}

-- Miner Sticker
SMODS.Sticker {
    key = "miner_job",
    atlas = "job_stickers",
    pos = { x = 4, y = 0 },
    badge_colour = HEX('d35400'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Miner',
        label = 'Miner',
        text = {
            "When scored, digs deep:",
            "Grants {C:money}+$1{} to {C:money}+$3{} instantly.",
            "{C:green}1 in 8{} chance to find a Gem ({C:chips}+50 Chips{})",
            "or unearth a random consumable directly into inventory"
        }
    },
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            local cash = pseudorandom('miner_cash', 1, 3)
            ease_dollars(cash)

            local roll = pseudorandom('miner_gem', 1, 8)
            if roll == 1 then
                if G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
                    SMODS.add_card { set = 'Tarot', key_append = 'miner_dig' }
                    play_sound('tarot2')
                    return {
                        message = 'Unearthed Consumable! (+$' .. cash .. ')',
                        colour = G.C.GOLD,
                        card = card
                    }
                else
                    return {
                        chips = 50,
                        message = 'Gem Unearthed! +50 Chips (+$' .. cash .. ')',
                        colour = HEX('d35400'),
                        card = card
                    }
                end
            end

            return {
                message = '+$' .. cash .. ' Mined',
                colour = G.C.GOLD,
                card = card
            }
        end
    end
}

-- Jeweler Sticker
SMODS.Sticker {
    key = "jeweler_job",
    atlas = "job_stickers",
    pos = { x = 0, y = 1 },
    badge_colour = HEX('1abc9c'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Jeweler',
        label = 'Jeweler',
        text = {
            "When scored in a hand with an {C:attention}Enhanced{} card,",
            "polishes that card: permanently grants it",
            "an edition ({C:dark_edition}Foil{}, {C:dark_edition}Holo{}, or {C:dark_edition}Poly{})"
        }
    },
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            if context.scoring_hand then
                local candidates = {}
                for _, sc in ipairs(context.scoring_hand) do
                    if sc ~= card and sc.config and sc.config.center and sc.config.center ~= G.P_CENTERS.c_base and not sc.edition then
                        candidates[#candidates + 1] = sc
                    end
                end

                if #candidates > 0 then
                    local chosen = pseudorandom_element(candidates, pseudoseed('jeweler_polish'))
                    local editions = { { foil = true }, { holo = true }, { polychrome = true } }
                    local ed = pseudorandom_element(editions, pseudoseed('jeweler_edition'))
                    chosen:set_edition(ed, true)
                    play_sound('gold_seal')
                    return {
                        message = 'Polished Edition!',
                        colour = HEX('1abc9c'),
                        card = chosen
                    }
                end
            end
        end
    end
}

-- Apothecary Sticker
SMODS.Sticker {
    key = "apothecary_job",
    atlas = "job_stickers",
    pos = { x = 1, y = 1 },
    badge_colour = HEX('27ae60'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Apothecary',
        label = 'Apothecary',
        text = {
            "When discarded, {C:green}cleanses debuffs{}",
            "from all cards currently in hand and reduces",
            "Blind requirement by {C:attention}4%{} {C:inactive}(Max 20%/rnd){}"
        }
    },
    calculate = function(self, card, context)
        if context.discard and context.other_card == card then
            G.GAME.apothecary_reduc_round = G.GAME.apothecary_reduc_round or 0
            local cleansed = 0
            if G.hand and G.hand.cards then
                for _, c in ipairs(G.hand.cards) do
                    if c.debuff then
                        c.debuff = false
                        c:juice_up(0.3, 0.3)
                        cleansed = cleansed + 1
                    end
                end
            end

            local blind_msg = nil
            if G.GAME.apothecary_reduc_round < 0.20 and G.GAME.blind and G.GAME.blind.chips then
                local reduction = math.floor(G.GAME.blind.chips * 0.04)
                if reduction > 0 then
                    G.GAME.blind.chips = math.max(1, G.GAME.blind.chips - reduction)
                    G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
                    G.GAME.apothecary_reduc_round = G.GAME.apothecary_reduc_round + 0.04
                    blind_msg = "-4% Blind!"
                end
            end

            play_sound('tarot1')
            return {
                message = blind_msg or (cleansed > 0 and 'Cleansed!' or 'Medicinal Brew!'),
                colour = HEX('27ae60'),
                card = card
            }
        end
    end
}

-- Bounty Hunter Sticker
SMODS.Sticker {
    key = "bounty_hunter_job",
    atlas = "job_stickers",
    pos = { x = 2, y = 1 },
    badge_colour = HEX('c0392b'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Bounty Hunter',
        label = 'Bounty Hunter',
        text = {
            "Each round, a random rank becomes the {C:red}Wanted Target{}.",
            "Scoring this card alongside the target",
            "awards {C:money}+$7{} and {X:mult,C:white}X1.5{} Mult"
        }
    },
    calculate = function(self, card, context)
        if context.first_hand_drawn and card.area == G.hand then
            local ranks = { '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace' }
            G.GAME.wanted_target_rank = pseudorandom_element(ranks, pseudoseed('bounty_target'))
            card_eval_status_text(card, 'extra', nil, nil, nil, {
                message = 'Wanted: ' .. tostring(G.GAME.wanted_target_rank) .. '!',
                colour = HEX('c0392b')
            })
        end

        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            local target_rank = G.GAME.wanted_target_rank
            if target_rank and context.scoring_hand then
                local has_target = false
                for _, sc in ipairs(context.scoring_hand) do
                    local val = sc.base and sc.base.value
                    if val == target_rank or (sc.get_id and sc:get_id() == target_rank) then
                        has_target = true
                        break
                    end
                end

                if has_target then
                    ease_dollars(7)
                    return {
                        x_mult = 1.5,
                        message = 'Bounty Claimed! +$7',
                        colour = G.C.GOLD,
                        card = card
                    }
                end
            end
        end
    end
}

-- Croupier Sticker
SMODS.Sticker {
    key = "croupier_job",
    atlas = "job_stickers",
    pos = { x = 3, y = 1 },
    badge_colour = HEX('8e44ad'),
    prefix_config = { key = false },
    sets = { Default = true, Enhanced = true },
    rate = 0,
    needs_enable_flag = false,
    loc_txt = {
        name = 'Dice / Croupier',
        label = 'Dice',
        text = {
            "When scored, rolls a 6-sided die:",
            "{C:attention}1 or 3{}: {C:mult}+8 Mult{} per pip",
            "{C:attention}2 or 4{}: {C:chips}+30 Chips{} per pip",
            "{C:attention}5 or 6{}: {X:mult,C:white}X2.0{} Mult and retriggers card"
        }
    },
    calculate = function(self, card, context)
        if (context.main_scoring or context.individual) and context.cardarea == G.play then
            local roll = pseudorandom('dice_job', 1, 6)
            play_sound('dice', 1.0 + roll * 0.05)

            if roll == 1 or roll == 3 then
                local mult_val = roll * 8
                return {
                    mult = mult_val,
                    message = 'Die: ' .. roll .. ' (+' .. mult_val .. ' Mult)',
                    colour = G.C.MULT,
                    card = card
                }
            elseif roll == 2 or roll == 4 then
                local chip_val = roll * 30
                return {
                    chips = chip_val,
                    message = 'Die: ' .. roll .. ' (+' .. chip_val .. ' Chips)',
                    colour = G.C.CHIPS,
                    card = card
                }
            else
                return {
                    x_mult = 2.0,
                    message = 'Jackpot Die: ' .. roll .. '! X2 Mult',
                    colour = HEX('8e44ad'),
                    card = card
                }
            end
        end

        if context.repetition and context.cardarea == G.play and context.other_card == card then
            if card.ability and card.ability.croupier_rolled_high then
                card.ability.croupier_rolled_high = nil
                return {
                    message = 'Retrigger!',
                    repetitions = 1,
                    card = card
                }
            end
        end
    end
}

-- Job Cards Atlas

SMODS.Atlas {
    key = "c_jobs",
    path = "c_jobs.png",
    px = 71,
    py = 95
}

-- Job Consumable 1: The Miner
SMODS.Consumable {
    key = 'miner_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 0, y = 0 },
    loc_txt = {
        name = 'The Miner',
        text = {
            "Assigns Miner job sticker to {C:attention}1 selected card{}.",
            "Each time it scores: awards {C:money}+$1{} to {C:money}+$3{},",
            "with a {C:green}1 in 8{} chance to unearth a Gem ({C:chips}+50 Chips{})",
            "or a random consumable directly into inventory"
        }
    },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                clear_card_jobs(target)
                if SMODS.Stickers and SMODS.Stickers['miner_job'] then
                    SMODS.Stickers['miner_job']:apply(target, true)
                else
                    target.ability = target.ability or {}
                    target.ability.miner_job = true
                end
                play_sound('tarot1')
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Miner Hired!', colour = HEX('d35400') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 2: The Gardener
SMODS.Consumable {
    key = 'gardener_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 1, y = 0 },
    loc_txt = {
        name = 'The Gardener',
        text = {
            "Assigns Gardener job to {C:attention}1 selected card{}.",
            "When discarded, permanently adds {C:chips}+2{} extra",
            "Chips to all cards of its suit in your full deck"
        }
    },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                clear_card_jobs(target)
                if SMODS.Stickers and SMODS.Stickers['gardener_job'] then
                    SMODS.Stickers['gardener_job']:apply(target, true)
                else
                    target.ability = target.ability or {}
                    target.ability.gardener_job = true
                end
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Gardener Hired!', colour = HEX('27ae60') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 3: The Banker
SMODS.Consumable {
    key = 'banker_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 2, y = 0 },
    loc_txt = {
        name = 'The Banker',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into an {C:attention}Investment Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_investment_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('gold_seal')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                local center = get_investment_enhancement_center()
                target:set_ability(center)
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Investment Card!', colour = G.C.MONEY })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 4: The Surgeon
SMODS.Consumable {
    key = 'surgeon_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 3, y = 0 },
    loc_txt = {
        name = 'The Surgeon',
        text = {
            "Destroys the {C:attention}1st selected card{} and",
            "transfers all its bonus Chips, Enhancement,",
            "Seal, and Edition to the {C:attention}2nd selected card{}"
        }
    },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 2
    end,
    use = function(self, card, area, copier)
        local donor = G.hand.highlighted[1]
        local recipient = G.hand.highlighted[2]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot2')
                card:juice_up(0.4, 0.6)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.3,
            func = function()
                local donor_bonus = (donor.ability and donor.ability.perma_bonus) or 0
                recipient.ability = recipient.ability or {}
                recipient.ability.perma_bonus = (recipient.ability.perma_bonus or 0) + donor_bonus

                if donor.config and donor.config.center and donor.config.center ~= G.P_CENTERS.c_base then
                    recipient:set_ability(donor.config.center)
                end

                if donor.seal then
                    recipient:set_seal(donor.seal, nil, true)
                end

                if donor.edition then
                    recipient:set_edition(donor.edition, true)
                end

                for _, jk in ipairs({'gardener_job', 'detective_job', 'chef_job', 'archaeologist_job'}) do
                    if donor.ability and donor.ability[jk] then
                        clear_card_jobs(recipient)
                        if SMODS.Stickers and SMODS.Stickers[jk] then
                            SMODS.Stickers[jk]:apply(recipient, true)
                        else
                            recipient.ability = recipient.ability or {}
                            recipient.ability[jk] = true
                        end
                    end
                end

                play_sound('tarot1')
                donor:start_dissolve()
                recipient:juice_up(0.6, 0.6)
                card_eval_status_text(recipient, 'extra', nil, nil, nil, { message = 'Transplanted!', colour = G.C.RED })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 5: The Alchemist
SMODS.Consumable {
    key = 'alchemist_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 4, y = 0 },
    loc_txt = {
        name = 'The Alchemist',
        text = {
            "Enhances {C:attention}1 selected card{}",
            "into a {C:attention}Lead Card{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = get_lead_enhancement_center()
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                local center = get_lead_enhancement_center()
                target:set_ability(center)
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Lead Card!', colour = G.C.GREY })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 6: The Butcher
SMODS.Consumable {
    key = 'butcher_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 0, y = 1 },
    loc_txt = {
        name = 'The Butcher',
        text = {
            "Destroys {C:attention}1 selected card{} (Rank 3+)",
            "and creates {C:attention}2 cards{} dividing its rank",
            "{C:inactive}(if odd, one card has {C:attention}+1{C:inactive} rank){}",
            "with random {C:attention}Steel{}, {C:attention}Glass{}, {C:attention}Wild{}, or {C:attention}Lucky{} enhancements"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
            info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
            info_queue[#info_queue + 1] = G.P_CENTERS.m_wild
            info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        if G.hand and G.hand.highlighted and #G.hand.highlighted == 1 then
            local id = G.hand.highlighted[1]:get_id()
            return id and id >= 3
        end
        return false
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        local original_suit = target.base and target.base.suit or 'Spades'
        local suit_prefix = string.sub(original_suit, 1, 1)
        local id = target:get_id() or 4
        local rank_strings = { [2]='2', [3]='3', [4]='4', [5]='5', [6]='6', [7]='7', [8]='8', [9]='9', [10]='10', [11]='J', [12]='Q', [13]='K', [14]='A' }
        local r1_num = math.max(2, math.floor(id / 2))
        local r2_num = math.max(2, (id % 2 == 0) and math.floor(id / 2) or (math.floor(id / 2) + 1))
        local rank_1_str = rank_strings[r1_num] or '2'
        local rank_2_str = rank_strings[r2_num] or '3'

        if G.hand then G.hand:unhighlight_all() end

        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot2')
                if card then card:juice_up(0.4, 0.6) end
                target.destroyed = true
                target:start_dissolve(nil, true)
                return true
            end
        }))

        local enhancements = { G.P_CENTERS.m_steel, G.P_CENTERS.m_glass, G.P_CENTERS.m_wild, G.P_CENTERS.m_lucky }
        for i = 1, 2 do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.25,
                func = function()
                    play_sound('tarot1')
                    local chosen_enh = pseudorandom_element(enhancements, pseudoseed('butcher_enh_' .. i))
                    local current_rank_str = (i == 1) and rank_1_str or rank_2_str
                    local new_card = create_playing_card({
                        front = G.P_CARDS[suit_prefix .. '_' .. current_rank_str] or G.P_CARDS['S_2'],
                        center = chosen_enh
                    }, G.hand, nil, i ~= 1, {G.C.SECONDARY_SET.Enhanced})
                    new_card:juice_up(0.4, 0.4)
                    return true
                end
            }))
        end
    end
}

-- Job Consumable 7: The Detective
SMODS.Consumable {
    key = 'detective_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 1, y = 1 },
    loc_txt = {
        name = 'The Detective',
        text = {
            "Assigns Detective job to {C:attention}1 selected card{}.",
            "When in opening hand at start of round,",
            "reveals the next 3 drawn cards and gives each",
            "a {C:gold}Gold Seal{} or {C:blue}Blue Seal{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            if G.P_SEALS and G.P_SEALS.Gold then
                info_queue[#info_queue + 1] = G.P_SEALS.Gold
            else
                info_queue[#info_queue + 1] = { key = 'gold_seal', set = 'Other' }
            end
            if G.P_SEALS and G.P_SEALS.Blue then
                info_queue[#info_queue + 1] = G.P_SEALS.Blue
            else
                info_queue[#info_queue + 1] = { key = 'blue_seal', set = 'Other' }
            end
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                clear_card_jobs(target)
                if SMODS.Stickers and SMODS.Stickers['detective_job'] then
                    SMODS.Stickers['detective_job']:apply(target, true)
                else
                    target.ability = target.ability or {}
                    target.ability.detective_job = true
                end
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Detective Hired!', colour = HEX('2980b9') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 8: The Chef
SMODS.Consumable {
    key = 'chef_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 2, y = 1 },
    loc_txt = {
        name = 'The Chef',
        text = {
            "Assigns Chef job to {C:attention}1 selected face card{} (J, Q, K).",
            "When scored, turns all other scoring cards in the",
            "hand into {C:mult}Mult Cards{}"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = G.P_CENTERS.m_mult
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1 and G.hand.highlighted[1]:is_face()
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                clear_card_jobs(target)
                if SMODS.Stickers and SMODS.Stickers['chef_job'] then
                    SMODS.Stickers['chef_job']:apply(target, true)
                else
                    target.ability = target.ability or {}
                    target.ability.chef_job = true
                end
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Chef Hired!', colour = HEX('e67e22') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 9: The Archaeologist
SMODS.Consumable {
    key = 'archaeologist_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 3, y = 1 },
    loc_txt = {
        name = 'The Archaeologist',
        text = {
            "Assigns Archaeologist job to {C:attention}1 selected card{}.",
            "When scored in your {C:attention}final hand{} of a round,",
            "recovers 1 discarded card and gives it a random",
            "{C:dark_edition}Foil{}, {C:dark_edition}Holographic{}, or {C:dark_edition}Polychrome{} edition"
        }
    },
    loc_vars = function(self, info_queue, card)
        if info_queue then
            info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
            info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
            info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
        end
        return { vars = {} }
    end,
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                clear_card_jobs(target)
                if SMODS.Stickers and SMODS.Stickers['archaeologist_job'] then
                    SMODS.Stickers['archaeologist_job']:apply(target, true)
                else
                    target.ability = target.ability or {}
                    target.ability.archaeologist_job = true
                end
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Archaeologist Hired!', colour = HEX('d35400') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 10: The Jeweler
SMODS.Consumable {
    key = 'jeweler_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 4, y = 1 },
    loc_txt = {
        name = 'The Jeweler',
        text = {
            "Assigns Jeweler job sticker to {C:attention}1 selected card{}.",
            "When scored in a hand with an {C:attention}Enhanced card{},",
            "polishes it, permanently granting a random",
            "{C:dark_edition}Foil{}, {C:dark_edition}Holographic{}, or {C:dark_edition}Polychrome{} edition"
        }
    },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                clear_card_jobs(target)
                if SMODS.Stickers and SMODS.Stickers['jeweler_job'] then
                    SMODS.Stickers['jeweler_job']:apply(target, true)
                else
                    target.ability = target.ability or {}
                    target.ability.jeweler_job = true
                end
                play_sound('tarot1')
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Jeweler Hired!', colour = HEX('1abc9c') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 11: The Apothecary
SMODS.Consumable {
    key = 'apothecary_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 0, y = 2 },
    loc_txt = {
        name = 'The Apothecary',
        text = {
            "Assigns Apothecary job to {C:attention}1 selected card{}.",
            "When discarded, {C:green}cleanses debuffs{} from all",
            "cards in hand and reduces Blind requirement",
            "by {C:attention}4%{} {C:inactive}(Capped at 20% per round){}"
        }
    },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                clear_card_jobs(target)
                if SMODS.Stickers and SMODS.Stickers['apothecary_job'] then
                    SMODS.Stickers['apothecary_job']:apply(target, true)
                else
                    target.ability = target.ability or {}
                    target.ability.apothecary_job = true
                end
                play_sound('tarot1')
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Apothecary Hired!', colour = HEX('27ae60') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 12: The Bounty Hunter
SMODS.Consumable {
    key = 'bounty_hunter_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 1, y = 2 },
    loc_txt = {
        name = 'The Bounty Hunter',
        text = {
            "Assigns Bounty Hunter job to {C:attention}1 selected card{}.",
            "Designates a random {C:red}Wanted Target{} rank each round.",
            "Scoring with the target awards {C:money}+$7{} and {X:mult,C:white}X1.5{} Mult"
        }
    },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                clear_card_jobs(target)
                if SMODS.Stickers and SMODS.Stickers['bounty_hunter_job'] then
                    SMODS.Stickers['bounty_hunter_job']:apply(target, true)
                else
                    target.ability = target.ability or {}
                    target.ability.bounty_hunter_job = true
                end
                play_sound('tarot1')
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Bounty Hunter Hired!', colour = HEX('c0392b') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}

-- Job Consumable 13: The Croupier
SMODS.Consumable {
    key = 'croupier_job',
    set = 'Job',
    atlas = 'c_jobs',
    pos = { x = 2, y = 2 },
    loc_txt = {
        name = 'The Croupier',
        text = {
            "Assigns Dice sticker to {C:attention}1 selected card{}.",
            "Rolls a 6-sided die upon scoring:",
            "{C:attention}1 or 3{}: {C:mult}+8 Mult{} per pip | {C:attention}2 or 4{}: {C:chips}+30 Chips{} per pip",
            "{C:attention}5 or 6{}: {X:mult,C:white}X2.0{} Mult and retriggers this card"
        }
    },
    in_pool = function(self, args)
        return is_witch_brew_spectrals_jobs_enabled()
    end,
    can_use = function(self, card)
        return G.hand and G.hand.highlighted and #G.hand.highlighted == 1
    end,
    use = function(self, card, area, copier)
        local target = G.hand.highlighted[1]
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                clear_card_jobs(target)
                if SMODS.Stickers and SMODS.Stickers['croupier_job'] then
                    SMODS.Stickers['croupier_job']:apply(target, true)
                else
                    target.ability = target.ability or {}
                    target.ability.croupier_job = true
                end
                play_sound('tarot1')
                target:juice_up(0.5, 0.5)
                card_eval_status_text(target, 'extra', nil, nil, nil, { message = 'Dice Sticker Applied!', colour = HEX('8e44ad') })
                if G.hand then G.hand:unhighlight_all() end
                return true
            end
        }))
    end
}


-- Job Packs Atlas
SMODS.Atlas {
    key = "c_packs",
    path = "packs.png",
    px = 71,
    py = 95
}
-- Booster Packs: Job Applications
SMODS.Booster {
    key = 'job_pack_1',
    atlas = 'c_packs',
    pos = { x = 0, y = 0 },
    config = { extra = 3, choose = 1 },
    cost = 4,
    weight = 1.0,
    kind = 'Job',
    group_key = 'k_job_pack',
    draw_hand = true,
    in_pool = function(self, args) return is_witch_brew_spectrals_jobs_enabled() end,
    loc_txt = {
        name = 'Job Application',
        group_name = 'Job Application',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2# Job cards{} to give",
            "a job to a card"
        }
    },
    loc_vars = function(self, info_queue, card)
        local choose = (card and card.ability and card.ability.choose) or (card and card.config and card.config.choose) or (self.config and self.config.choose) or 1
        local extra = (card and card.ability and card.ability.extra) or (card and card.config and card.config.extra) or (self.config and self.config.extra) or 3
        return { vars = { choose, extra } }
    end,
    create_card = function(self, card, i) return create_job_card_for_pack('job_pack') end,
    ease_background_colour = function(self) ease_job_pack_background() end
}

SMODS.Booster {
    key = 'job_pack_2',
    atlas = 'c_packs',
    pos = { x = 1, y = 0 },
    config = { extra = 3, choose = 1 },
    cost = 4,
    weight = 1.0,
    kind = 'Job',
    group_key = 'k_job_pack',
    draw_hand = true,
    in_pool = function(self, args) return is_witch_brew_spectrals_jobs_enabled() end,
    loc_txt = {
        name = 'Job Application',
        group_name = 'Job Application',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2# Job cards{} to give",
            "a job to a card"
        }
    },
    loc_vars = function(self, info_queue, card)
        local choose = (card and card.ability and card.ability.choose) or (card and card.config and card.config.choose) or (self.config and self.config.choose) or 1
        local extra = (card and card.ability and card.ability.extra) or (card and card.config and card.config.extra) or (self.config and self.config.extra) or 3
        return { vars = { choose, extra } }
    end,
    create_card = function(self, card, i) return create_job_card_for_pack('job_pack') end,
    ease_background_colour = function(self) ease_job_pack_background() end
}

SMODS.Booster {
    key = 'job_pack_3',
    atlas = 'c_packs',
    pos = { x = 2, y = 0 },
    config = { extra = 5, choose = 1 },
    cost = 6,
    weight = 0.5,
    kind = 'Job',
    group_key = 'k_job_pack',
    draw_hand = true,
    in_pool = function(self, args) return is_witch_brew_spectrals_jobs_enabled() end,
    loc_txt = {
        name = 'Jumbo Job Application',
        group_name = 'Job Application',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2# Job cards{} to give",
            "a job to a card"
        }
    },
    loc_vars = function(self, info_queue, card)
        local choose = (card and card.ability and card.ability.choose) or (card and card.config and card.config.choose) or (self.config and self.config.choose) or 1
        local extra = (card and card.ability and card.ability.extra) or (card and card.config and card.config.extra) or (self.config and self.config.extra) or 5
        return { vars = { choose, extra } }
    end,
    create_card = function(self, card, i) return create_job_card_for_pack('jumbo_job_pack') end,
    ease_background_colour = function(self) ease_job_pack_background() end
}

SMODS.Booster {
    key = 'job_pack_4',
    atlas = 'c_packs',
    pos = { x = 3, y = 0 },
    config = { extra = 5, choose = 2 },
    cost = 8,
    weight = 0.25,
    kind = 'Job',
    group_key = 'k_job_pack',
    draw_hand = true,
    in_pool = function(self, args) return is_witch_brew_spectrals_jobs_enabled() end,
    loc_txt = {
        name = 'Mega Job Application',
        group_name = 'Job Application',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2# Job cards{} to give",
            "a job to a card"
        }
    },
    loc_vars = function(self, info_queue, card)
        local choose = (card and card.ability and card.ability.choose) or (card and card.config and card.config.choose) or (self.config and self.config.choose) or 2
        local extra = (card and card.ability and card.ability.extra) or (card and card.config and card.config.extra) or (self.config and self.config.extra) or 5
        return { vars = { choose, extra } }
    end,
    create_card = function(self, card, i) return create_job_card_for_pack('mega_job_pack') end,
    ease_background_colour = function(self) ease_job_pack_background() end
}


