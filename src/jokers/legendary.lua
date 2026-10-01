-- Legendary Jokers, Mod definitions

SMODS.Atlas {
    key = "reality_warp_legendary",
    path = "legendary_jokers.png",
    px = 71,
    py = 95
}

-- World Devourer, Legendary Joker
SMODS.Joker {
    key = 'world_devourer',
    atlas = 'reality_warp_legendary',
    unlocked = false,
    unlock = { "Defeat {C:attention}10 Boss Blinds{}", "in a single run" },
    loc_txt = {
        name = 'World Devourer',
        text = {
            "Gains {X:mult,C:white}X1{} Mult",
            "for each {C:attention}blind{} defeated",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
        }
    },
    config = { extra = {
        xmult_per_blind = 1,
        blinds_defeated = 0,
        xmult = 1
    }},
    rarity = 4,
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    no_particles = true,
    cost = 20,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        return { vars = { ex.xmult or 1 } }
    end,
    check_for_unlock = function(self, args)
        if (args and args.type == 'world_devourer') or (G.GAME and ((G.GAME.reality_warp_bosses_slain or 0) >= 10 or (G.GAME.round_resets and (G.GAME.round_resets.boss_defeats or 0) >= 10))) then
            return true
        end
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local ex = card.ability.extra
            if (ex.xmult or 1) > 1 then
                return {
                    Xmult = ex.xmult,
                    card = card
                }
            end
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local ex = card.ability.extra
            ex.blinds_defeated = (ex.blinds_defeated or 0) + 1
            ex.xmult = 1 + ex.blinds_defeated * (ex.xmult_per_blind or 1)
            return {
                message = 'X'..string.format('%.0f', ex.xmult)..'!',
                colour = G.C.MULT,
                card = card
            }
        end
    end
}

local function get_next_paradox_joker()
    local pool = {}
    if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Joker then
        for _, j in ipairs(G.P_CENTER_POOLS.Joker) do
            if j.key and j.key ~= 'j_reality_warp_living_paradox' then
                table.insert(pool, j.key)
            end
        end
    end
    if #pool > 0 then
        return pseudorandom_element(pool, pseudoseed('paradox_joker_next'))
    end
    return nil
end

-- Living Paradox, Legendary Joker
SMODS.Joker {
    key = 'living_paradox',
    atlas = 'reality_warp_legendary',
    unlocked = false,
    unlock = { "Defeat a {C:attention}Boss Blind{}", "to discover this Joker" },
    loc_txt = {
        name = 'Living Paradox',
        text = {
            "Creates a {C:dark_edition}Negative{} {C:attention}#1#{}",
            "when {C:attention}Boss Blind{} is defeated",
            "{C:inactive}(Changes after each Boss Blind){}"
        }
    },
    config = { extra = { next_joker = nil } },
    rarity = 4,
    pos = { x = 0, y = 1 },
    soul_pos = { x = 1, y = 1 },
    no_particles = true,
    cost = 20,
    blueprint_compat = false,
    check_for_unlock = function(self, args)
        if (args and (args.type == 'defeat_blind' and G.GAME.blind and G.GAME.blind.boss)) or (G.GAME and G.GAME.reality_warp_boss_defeated) then
            return true
        end
    end,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        if not ex.next_joker then
            ex.next_joker = get_next_paradox_joker()
        end
        local next_name = "Random"
        if ex.next_joker and G.P_CENTERS and G.P_CENTERS[ex.next_joker] then
            local center = G.P_CENTERS[ex.next_joker]
            next_name = (localize and localize{type = 'name_text', key = center.key, set = 'Joker'}) or center.name or ex.next_joker
        end
        return { vars = { next_name } }
    end,
    calculate = function(self, card, context)
        if not card.ability.extra.next_joker then
            card.ability.extra.next_joker = get_next_paradox_joker()
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                G.GAME.reality_warp_boss_defeated = true
                local chosen_key = card.ability.extra.next_joker or get_next_paradox_joker()
                G.E_MANAGER:add_event(Event({
                    func = function()
                        local new_j = SMODS.add_card { key = chosen_key, edition = 'e_negative', key_append = 'living_paradox' }
                        card:juice_up(0.5, 0.5)
                        return true
                    end
                }))
                card.ability.extra.next_joker = get_next_paradox_joker()
                return {
                    message = 'Paradox!',
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end
    end
}

-- Star Chronicler, Legendary Joker
SMODS.Joker {
    key = 'star_chronicler',
    atlas = 'reality_warp_legendary',
    unlocked = false,
    unlock = { "Win a complete run", "{C:attention}(Defeat Ante 8+){}" },
    loc_txt = {
        name = 'Star Chronicler',
        text = {
            "Gains {X:mult,C:white}X#1#{} Mult for each",
            "{C:blue}Planet{} card discovered.",
            "{C:spectral}Black Holes{} double its current Mult",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = {
        xmult_per_planet = 0.5,
        black_hole_mult = 1
    }},
    rarity = 4,
    pos = { x = 0, y = 2 },
    soul_pos = { x = 1, y = 2 },
    no_particles = true,
    cost = 20,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability.extra) or self.config.extra
        -- Count discovered planets in collection
        local planet_count = 0
        if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Planet then
            for _, p in ipairs(G.P_CENTER_POOLS.Planet) do
                if p.discovered then
                    planet_count = planet_count + 1
                end
            end
        end
        local base_xm = 1 + planet_count * (ex.xmult_per_planet or 0.5)
        local total_xm = base_xm * (ex.black_hole_mult or 1)
        return { vars = { ex.xmult_per_planet or 0.5, string.format('%.1f', total_xm) } }
    end,
    check_for_unlock = function(self, args)
        if (args and (args.type == 'win_game' or args.type == 'win_custom')) or (G.GAME and (G.GAME.reality_warp_run_won or G.GAME.won)) then
            return true
        end
    end,
    calculate = function(self, card, context)
        -- Double current mult when a Black Hole is used
        if context.using_consumeable and not context.blueprint then
            local c = context.consumeable
            if c and (c.key == 'c_black_hole' or (c.ability and c.ability.name == 'Black Hole')) then
                card.ability.extra.black_hole_mult = (card.ability.extra.black_hole_mult or 1) * 2
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = 'X2 Mult!', colour = G.C.MULT })
            end
        end

        if context.joker_main then
            local ex = card.ability.extra
            local planet_count = 0
            if G.P_CENTER_POOLS and G.P_CENTER_POOLS.Planet then
                for _, p in ipairs(G.P_CENTER_POOLS.Planet) do
                    if p.discovered then
                        planet_count = planet_count + 1
                    end
                end
            end
            local base_xm = 1 + planet_count * (ex.xmult_per_planet or 0.5)
            local total_xm = base_xm * (ex.black_hole_mult or 1)
            if total_xm > 1 then
                return {
                    Xmult = total_xm,
                    card = card
                }
            end
        end
    end
}

-- Joker: creepy_shadow
SMODS.Joker {
    key = 'creepy_shadow',
    atlas = 'reality_warp_legendary',
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Creepy Shadow',
        text = {
            "At end of round, destroys a random {C:attention}Joker{}",
            "in possession (including {C:attention}Eternal{})",
            "and gains {X:mult,C:white}X#1#{} Mult per destroyed Joker.",
            "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult){}"
        }
    },
    config = { extra = { x_mult_gain = 2, x_mult = 1 } },
    rarity = 4,
    pos = { x = 0, y = 3 },
    soul_pos = { x = 1, y = 3 },
    cost = 20,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.x_mult_gain or 2, ex.x_mult or 1 } }
    end,
    calculate = function(self, card, context)
        if context.joker_main and (card.ability.extra.x_mult or 1) > 1 then
            return {
                Xmult = card.ability.extra.x_mult,
                card = card
            }
        end
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            local targets = {}
            if G.jokers and G.jokers.cards then
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card and not j.getting_sliced then
                        targets[#targets + 1] = j
                    end
                end
            end
            if #targets > 0 then
                local chosen = pseudorandom_element(targets, pseudoseed('creepy_shadow'))
                chosen.getting_sliced = true
                card.ability.extra.x_mult = (card.ability.extra.x_mult or 1) + (card.ability.extra.x_mult_gain or 2)
                G.E_MANAGER:add_event(Event({
                    func = function()
                        card:juice_up(0.8, 0.8)
                        chosen:start_dissolve()
                        return true
                    end
                }))
                return {
                    message = 'Consumed! X' .. tostring(card.ability.extra.x_mult),
                    colour = G.C.MULT,
                    card = card
                }
            end
        end
    end
}

-- Joker: ouroboros
SMODS.Joker {
    key = 'ouroboros',
    atlas = 'reality_warp_legendary',
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Ouroboros',
        text = {
            "Each played card retriggers {C:attention}#1#{} times.",
            "Gains {X:mult,C:white}+X#2#{} Mult for every {C:attention}#1#{} retriggers",
            "{C:inactive}(Currently {X:mult,C:white}X#3#{C:inactive} Mult){}"
        }
    },
    config = { extra = { retriggers = 3, x_mult = 1.0, x_mult_gain = 0.5 } },
    rarity = 4,
    pos = { x = 0, y = 4 },
    soul_pos = { x = 1, y = 4 },
    cost = 20,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { ex.retriggers or 3, ex.x_mult_gain or 0.5, string.format('%.1f', ex.x_mult or 1.0) } }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play then
            if not context.blueprint then
                card.ability.extra.x_mult = (card.ability.extra.x_mult or 1.0) + (card.ability.extra.x_mult_gain or 0.5)
            end
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra.retriggers or 3,
                card = card
            }
        end

        if context.joker_main and (card.ability.extra.x_mult or 1.0) > 1.0 then
            return {
                Xmult = card.ability.extra.x_mult,
                card = card
            }
        end
    end
}

-- Joker: chrono_weaver
SMODS.Joker {
    key = 'chrono_weaver',
    atlas = 'reality_warp_legendary',
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Chrono Weaver',
        text = {
            "{C:green}#1# in #2#{} chance to disable {C:attention}Boss Blind{},",
            "{C:green}#1# in #3#{} chance to add {C:chips}+#4#{} Chips,",
            "{C:green}#1# in #5#{} chance to add {C:mult}+#6#{} Mult,",
            "{C:green}#1# in #7#{} chance to add {C:chips}+75%{} of Blind chip requirement"
        }
    },
    config = { extra = {
        boss_odds = 2,
        chip_odds = 3,
        chips = 15000,
        mult_odds = 5,
        mult = 20000,
        req_odds = 10,
        req_percent = 0.75
    }},
    rarity = 4,
    pos = { x = 0, y = 5 },
    soul_pos = { x = 1, y = 5 },
    cost = 20,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        local num, den_boss = SMODS.get_probability_vars(card, 1, ex.boss_odds or 2, 'chrono_boss')
        return { vars = {
            num,
            den_boss,
            ex.chip_odds or 3,
            ex.chips or 15000,
            ex.mult_odds or 5,
            ex.mult or 20000,
            ex.req_odds or 10
        } }
    end,
    calculate = function(self, card, context)
        -- 1 in 2 to disable boss blind at round start
        if (context.setting_blind or context.first_hand_drawn) and not context.blueprint then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                if SMODS.pseudorandom_probability(card, 'chrono_boss', 1, card.ability.extra.boss_odds or 2) then
                    G.GAME.blind:disable()
                    play_sound('timpani')
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = localize('ph_boss_disabled'),
                        colour = G.C.GREEN
                    })
                end
            end
        end

        -- Scoring probabilities
        if context.joker_main then
            local ex = card.ability.extra
            local total_chips = 0
            local total_mult = 0

            if SMODS.pseudorandom_probability(card, 'chrono_chips', 1, ex.chip_odds or 3) then
                total_chips = total_chips + (ex.chips or 15000)
            end

            if SMODS.pseudorandom_probability(card, 'chrono_mult', 1, ex.mult_odds or 5) then
                total_mult = total_mult + (ex.mult or 20000)
            end

            if SMODS.pseudorandom_probability(card, 'chrono_req', 1, ex.req_odds or 10) then
                local blind_req = (G.GAME.blind and G.GAME.blind.chips) or 0
                total_chips = total_chips + math.floor(blind_req * (ex.req_percent or 0.75))
            end

            if total_chips > 0 or total_mult > 0 then
                local ret = { card = card }
                if total_chips > 0 then ret.chips = total_chips end
                if total_mult > 0 then ret.mult = total_mult end
                return ret
            end
        end
    end
}

-- Joker: philosopher
SMODS.Joker {
    key = 'philosopher',
    atlas = 'reality_warp_legendary',
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Philosopher',
        text = {
            "Gains {X:mult,C:white}+X#2#{} Mult whenever a",
            "{C:tarot}Tarot{}, {C:spectral}Spectral{}, or {C:planet}Planet{} card is used",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
        }
    },
    config = { extra = { x_mult = 1.0, x_mult_gain = 0.5 } },
    rarity = 4,
    pos = { x = 0, y = 6 },
    soul_pos = { x = 1, y = 6 },
    cost = 20,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { string.format('%.1f', ex.x_mult or 1.0), ex.x_mult_gain or 0.5 } }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            local c = context.consumeable
            local c_set = (c and c.ability and c.ability.set) or (c and c.config and c.config.center and c.config.center.set)
            if c_set == 'Tarot' or c_set == 'Spectral' or c_set == 'Planet' then
                card.ability.extra.x_mult = (card.ability.extra.x_mult or 1.0) + (card.ability.extra.x_mult_gain or 0.5)
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = 'X' .. string.format('%.1f', card.ability.extra.x_mult) .. ' Mult!',
                    colour = G.C.MULT
                })
            end
        end

        if context.joker_main and (card.ability.extra.x_mult or 1.0) > 1.0 then
            return {
                Xmult = card.ability.extra.x_mult,
                card = card
            }
        end
    end
}

-- Joker: void_monarch
SMODS.Joker {
    key = 'void_monarch',
    atlas = 'reality_warp_legendary',
    unlocked = true,
    discovered = true,
    loc_txt = {
        name = 'Void Monarch',
        text = {
            "Gains {X:mult,C:white}+X#2#{} Mult whenever a {C:purple}Potion{} is used.",
            "Defeating a {C:attention}Boss Blind{} multiplies",
            "current Mult by {X:mult,C:white}X#3#{}",
            "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult){}"
        }
    },
    config = { extra = { x_mult = 1.0, x_mult_potion_gain = 1.0, boss_mult = 1.5 } },
    rarity = 4,
    pos = { x = 0, y = 7 },
    soul_pos = { x = 1, y = 7 },
    cost = 20,
    blueprint_compat = true,
    loc_vars = function(self, info_queue, card)
        local ex = (card and card.ability and card.ability.extra) or self.config.extra
        return { vars = { string.format('%.2f', ex.x_mult or 1.0), ex.x_mult_potion_gain or 1.0, ex.boss_mult or 1.5 } }
    end,
    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint then
            local c = context.consumeable
            local is_potion = (c and c.ability and c.ability.set == 'Potion')
                or (c and c.config and c.config.center and c.config.center.set == 'Potion')
            if is_potion then
                card.ability.extra.x_mult = (card.ability.extra.x_mult or 1.0) + (card.ability.extra.x_mult_potion_gain or 1.0)
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = 'X' .. string.format('%.1f', card.ability.extra.x_mult) .. ' Mult!',
                    colour = G.C.MULT
                })
            end
        end

        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME and G.GAME.blind and G.GAME.blind.boss then
                card.ability.extra.x_mult = (card.ability.extra.x_mult or 1.0) * (card.ability.extra.boss_mult or 1.5)
                return {
                    message = 'X' .. string.format('%.2f', card.ability.extra.x_mult) .. '!',
                    colour = G.C.DARK_EDITION,
                    card = card
                }
            end
        end

        if context.joker_main and (card.ability.extra.x_mult or 1.0) > 1.0 then
            return {
                Xmult = card.ability.extra.x_mult,
                card = card
            }
        end
    end
}


-- Win tracking hook for unlocks
local _old_win = Game.win_run
if _old_win then
    Game.win_run = function(self, ...)
        if G.GAME then G.GAME.reality_warp_run_won = true end
        return _old_win(self, ...)
    end
end
