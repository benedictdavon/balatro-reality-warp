-- Fused Boss Blinds for Battle of Gods Mode (Ante 12+)
SMODS.Atlas {
    key = "reality_warp_fused_blinds",
    path = "fused_blinds.png",
    px = 34,
    py = 34
}

G.reality_warp_BLIND_THEMES = G.reality_warp_BLIND_THEMES or {}

local fused_themes = {
    ['obelisk'] = {
        name = 'The Obelisk',
        boss_colour = HEX('6d6a41'),
        new_colour = HEX('2d271c'),
        special_colour = HEX('8e8958'),
        tertiary_colour = HEX('1a160f'),
        contrast = 2
    },
    ['minotaur'] = {
        name = 'The Minotaur',
        boss_colour = HEX('b04d16'),
        new_colour = HEX('441a06'),
        special_colour = HEX('d56a28'),
        tertiary_colour = HEX('200a02'),
        contrast = 2
    },
    ['fortress'] = {
        name = 'The Fortress',
        boss_colour = HEX('b7616a'),
        new_colour = HEX('421b22'),
        special_colour = HEX('dc7d88'),
        tertiary_colour = HEX('220b10'),
        contrast = 2
    },
    ['mind_flayer'] = {
        name = 'The Mind Flayer',
        boss_colour = HEX('ab9297'),
        new_colour = HEX('392552'),
        special_colour = HEX('c8a4df'),
        tertiary_colour = HEX('1c0d2b'),
        contrast = 2
    },
    ['leviathan'] = {
        name = 'The Leviathan',
        boss_colour = HEX('579ec2'),
        new_colour = HEX('173b50'),
        special_colour = HEX('84c5e6'),
        tertiary_colour = HEX('091c28'),
        contrast = 2
    },
    ['iron_maiden'] = {
        name = 'The Iron Maiden',
        boss_colour = HEX('864242'),
        new_colour = HEX('381414'),
        special_colour = HEX('aa5a5a'),
        tertiary_colour = HEX('1c0808'),
        contrast = 2
    },
    ['cyclops'] = {
        name = 'The Cyclops',
        boss_colour = HEX('7c71b9'),
        new_colour = HEX('2b2052'),
        special_colour = HEX('9b8ee2'),
        tertiary_colour = HEX('140d2a'),
        contrast = 2
    },
    ['thorn_crown'] = {
        name = 'The Thorn Crown',
        boss_colour = HEX('6d6565'),
        new_colour = HEX('292424'),
        special_colour = HEX('8d8282'),
        tertiary_colour = HEX('141111'),
        contrast = 2
    },
    ['ouroboros'] = {
        name = 'The Ouroboros',
        boss_colour = HEX('49ac65'),
        new_colour = HEX('174724'),
        special_colour = HEX('6fd38c'),
        tertiary_colour = HEX('0a2411'),
        contrast = 2
    },
    ['nightshade'] = {
        name = 'The Nightshade',
        boss_colour = HEX('85719f'),
        new_colour = HEX('2f2242'),
        special_colour = HEX('a792c3'),
        tertiary_colour = HEX('170e23'),
        contrast = 2
    },
    ['black_diamond'] = {
        name = 'The Black Diamond',
        boss_colour = HEX('b1b693'),
        new_colour = HEX('383b27'),
        special_colour = HEX('cad0ac'),
        tertiary_colour = HEX('1c1e11'),
        contrast = 2
    },
    ['blood_moon'] = {
        name = 'The Blood Moon',
        boss_colour = HEX('b27ca5'),
        new_colour = HEX('44253d'),
        special_colour = HEX('cf9fc4'),
        tertiary_colour = HEX('22101e'),
        contrast = 2
    }
}

for k, v in pairs(fused_themes) do
    G.reality_warp_BLIND_THEMES[k] = v
    G.reality_warp_BLIND_THEMES['bl_reality_warp_' .. k] = v
    if G.C and G.C.BLIND then
        G.C.BLIND['bl_reality_warp_' .. k] = v.boss_colour
    end
end

local function sync_fused_blind_atlases()
    local atlas_obj = (SMODS and SMODS.Atlases and SMODS.Atlases['reality_warp_fused_blinds']) or (G.ASSET_ATLAS and G.ASSET_ATLAS['reality_warp_fused_blinds']) or (G.ANIMATION_ATLAS and G.ANIMATION_ATLAS['reality_warp_fused_blinds'])
    if atlas_obj and atlas_obj.image then
        atlas_obj.frames = 1
        if G.ASSET_ATLAS and not G.ASSET_ATLAS['reality_warp_fused_blinds'] then G.ASSET_ATLAS['reality_warp_fused_blinds'] = atlas_obj end
        if G.ANIMATION_ATLAS and not G.ANIMATION_ATLAS['reality_warp_fused_blinds'] then G.ANIMATION_ATLAS['reality_warp_fused_blinds'] = atlas_obj end
    elseif G.ASSET_ATLAS and G.ASSET_ATLAS['reality_warp_fused_blinds'] and not G.ASSET_ATLAS['reality_warp_fused_blinds'].image then
        G.ASSET_ATLAS['reality_warp_fused_blinds'] = nil
    end
end

sync_fused_blind_atlases()
G.E_MANAGER:add_event(Event({
    func = function()
        sync_fused_blind_atlases()
        return true
    end
}))

-- 1. The Obelisk (Needle + Pillar)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'obelisk',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 0 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('6d6a41'),
    loc_txt = {
        name = 'The Obelisk',
        text = {
            "Play only 1 hand.",
            "Cards played previously",
            "this Ante are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if context.blind_disabled then
            if blind.effect and blind.effect.hands_sub then
                ease_hands_played(blind.effect.hands_sub)
            end
        end

        if blind.disabled then return end

        if context.setting_blind then
            blind.effect = blind.effect or {}
            blind.effect.hands_sub = G.GAME.round_resets.hands - 1
            ease_hands_played(-blind.effect.hands_sub)
        end

        if context.debuff_card and context.debuff_card.area ~= G.jokers and
            context.debuff_card.ability and context.debuff_card.ability.played_this_ante then
            return { debuff = true }
        end
    end
}

-- 2. The Minotaur (Ox + Hook)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'minotaur',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 1 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('b04d16'),
    loc_txt = {
        name = 'The Minotaur',
        text = {
            "Discards 2 random cards per hand.",
            "Sets money to $0 if most",
            "played poker hand is played"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if blind.disabled then return end

        if context.press_play then
            local held_cards = {}; for _, c in ipairs(G.hand.cards) do held_cards[#held_cards + 1] = c end
            reality_warp_queue_blind_event(blind, { func = function()
                local any_selected = nil
                local _cards = {}
                for k, v in ipairs(held_cards) do
                    if not v.removed and v.area == G.hand then _cards[#_cards+1] = v end
                end
                for i = 1, 2 do
                    if #_cards > 0 then
                        local selected_card, card_key = pseudorandom_element(_cards, pseudoseed('hook'))
                        G.hand:add_to_highlighted(selected_card, true)
                        table.remove(_cards, card_key)
                        any_selected = true
                        play_sound('card1', 1)
                    end
                end
                if any_selected then G.FUNCS.discard_cards_from_highlighted(nil, true) end
                return true
            end })
            blind.triggered = true
            delay(0.7)
            SMODS.juice_up_blind()
        end

        if context.debuff_hand then
            blind.triggered = false
            if context.scoring_name == G.GAME.current_round.most_played_poker_hand then
                blind.triggered = true
                if not context.check then
                    return {
                        dollars = -G.GAME.dollars,
                        instant = true,
                        func = function()
                            blind:wiggle()
                        end
                    }
                end
            end
        end
    end
}

-- 3. The Fortress (Wall + Flint)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'fortress',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 2 },
    dollars = 5,
    mult = 3,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('b7616a'),
    loc_txt = {
        name = 'The Fortress',
        text = {
            "Extra large blind.",
            "Base Chips and Mult",
            "are halved"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if blind.disabled then return end

        if context.modify_hand then
            blind.triggered = true
            mult = mod_mult(math.max(math.floor(mult * 0.5 + 0.5), 1))
            hand_chips = mod_chips(math.max(math.floor(hand_chips * 0.5 + 0.5), 0))
            update_hand_text({ sound = 'chips2', modded = true }, { chips = hand_chips, mult = mult })
        end
    end
}

-- 4. The Mind Flayer (Psychic + Arm)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'mind_flayer',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 3 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('ab9297'),
    debuff = { h_size_ge = 5 },
    loc_txt = {
        name = 'The Mind Flayer',
        text = {
            "Must play 5 cards.",
            "Decreases level of",
            "played poker hand"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if blind.disabled then return end

        if context.debuff_hand then
            blind.triggered = false
            if G.GAME.hands[context.scoring_name] and G.GAME.hands[context.scoring_name].level > 1 then
                blind.triggered = true
                if not context.check then
                    return {
                        level_up = -1
                    }
                end
            end
        end
    end
}

-- 5. The Leviathan (Water + Fish)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'leviathan',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 4 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('579ec2'),
    loc_txt = {
        name = 'The Leviathan',
        text = {
            "Start with 0 discards.",
            "Cards drawn face down",
            "after each hand played"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if context.blind_disabled then
            if blind.effect and blind.effect.discards_sub then
                ease_discard(blind.effect.discards_sub)
            end
            if G.hand and G.hand.cards then
                for i = 1, #G.hand.cards do
                    if G.hand.cards[i].facing == 'back' then
                        G.hand.cards[i]:flip()
                    end
                end
            end
        end

        if context.setting_blind or context.hand_drawn then
            blind.prepped = nil
        end

        if blind.disabled then return end

        if context.setting_blind then
            blind.effect = blind.effect or {}
            blind.effect.discards_sub = G.GAME.current_round.discards_left
            ease_discard(-blind.effect.discards_sub)
        end

        if context.press_play then
            blind.prepped = true
        end

        if context.stay_flipped and context.to_area == G.hand and blind.prepped then
            return { stay_flipped = true }
        end
    end
}

-- 6. The Iron Maiden (Manacle + Tooth)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'iron_maiden',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 5 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('864242'),
    loc_txt = {
        name = 'The Iron Maiden',
        text = {
            "-1 Hand Size.",
            "Lose $1 per card played"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if context.blind_disabled then
            if G.hand then
                G.hand:change_size(1)
            end
        end

        if blind.disabled then return end

        if context.setting_blind then
            if G.hand then
                G.hand:change_size(-1)
            end
        end

        if context.press_play then
            local played = {}; local cards = (#(G.hand.highlighted or {}) > 0 and G.hand.highlighted) or G.play.cards or {}
            for _, card in ipairs(cards) do played[#played + 1] = card end
            reality_warp_queue_blind_event(blind, {trigger = 'after', delay = 0.2, func = function()
                for _, card in ipairs(played) do
                    if not card.removed then card:juice_up() end
                    ease_dollars(-1)
                end
                return true
            end})
            blind.triggered = true
            return true
        end
    end
}

-- 7. The Cyclops (Eye + Mouth)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'cyclops',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 6 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('7c71b9'),
    loc_txt = {
        name = 'The Cyclops',
        text = {
            "Only 1 hand type",
            "allowed this round.",
            "Other hands are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if blind.disabled then return end

        if context.setting_blind then
            blind.only_hand = false
        end

        if context.debuff_hand then
            if blind.only_hand and blind.only_hand ~= context.scoring_name then
                blind.triggered = true
                return { debuff = true }
            end
            if not context.check then
                blind.only_hand = context.scoring_name
            end
        end
    end
}

-- 8. The Thorn Crown (Mark + Plant)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'thorn_crown',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 7 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('6d6565'),
    debuff = { is_face = 'face' },
    loc_txt = {
        name = 'The Thorn Crown',
        text = {
            "All Face cards are",
            "drawn face down",
            "and debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if context.blind_disabled then
            if G.hand and G.hand.cards then
                for i = 1, #G.hand.cards do
                    if G.hand.cards[i].facing == 'back' then
                        G.hand.cards[i]:flip()
                    end
                end
            end
        end

        if blind.disabled then return end

        if context.stay_flipped and context.to_area == G.hand and context.other_card and context.other_card:is_face(true) then
            return { stay_flipped = true }
        end
    end
}

-- 9. The Ouroboros (Wheel + Serpent)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'ouroboros',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 8 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('49ac65'),
    loc_txt = {
        name = 'The Ouroboros',
        text = {
            "After Play or Discard,",
            "always draw 3 cards.",
            "#1# in #2# drawn face down"
        }
    },
    loc_vars = function(self, info_queue, card)
        local numerator, denominator = SMODS.get_probability_vars(card or self, 1, 7, 'ouroboros')
        return { vars = { numerator, denominator } }
    end,
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if context.blind_disabled then
            if G.hand and G.hand.cards then
                for i = 1, #G.hand.cards do
                    if G.hand.cards[i].facing == 'back' then
                        G.hand.cards[i]:flip()
                    end
                end
            end
        end

        if blind.disabled then return end

        if context.stay_flipped and context.to_area == G.hand and SMODS.pseudorandom_probability(blind or self, 'ouroboros', 1, 7) then
            return { stay_flipped = true }
        end
    end
}

-- Serpent 3-card draw hook for The Ouroboros
if G.FUNCS and G.FUNCS.draw_from_deck_to_hand then
    local orig_draw_from_deck_to_hand = G.FUNCS.draw_from_deck_to_hand
    G.FUNCS.draw_from_deck_to_hand = function(e)
        if G.GAME and G.GAME.blind and not G.GAME.blind.disabled and
           (G.GAME.blind.name == 'The Ouroboros' or (G.GAME.blind.config and G.GAME.blind.config.blind and G.GAME.blind.config.blind.key == 'bl_reality_warp_ouroboros')) and
           (G.GAME.current_round.hands_played > 0 or G.GAME.current_round.discards_used > 0) and not e then
            return orig_draw_from_deck_to_hand(math.min(#G.deck.cards, 3))
        end
        return orig_draw_from_deck_to_hand(e)
    end
end

-- 10. The Nightshade (House + Goad)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'nightshade',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 9 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('85719f'),
    debuff = { suit = 'Spades' },
    loc_txt = {
        name = 'The Nightshade',
        text = {
            "First hand drawn face down.",
            "All Spades are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if context.blind_disabled then
            if G.hand and G.hand.cards then
                for i = 1, #G.hand.cards do
                    if G.hand.cards[i].facing == 'back' then
                        G.hand.cards[i]:flip()
                    end
                end
            end
        end

        if blind.disabled then return end

        if context.stay_flipped and context.to_area == G.hand and G.GAME.current_round.hands_played == 0 and G.GAME.current_round.discards_used == 0 then
            return { stay_flipped = true }
        end
    end
}

-- 11. The Black Diamond (Window + Club)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'black_diamond',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 10 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('b1b693'),
    loc_txt = {
        name = 'The Black Diamond',
        text = {
            "All Clubs and Diamonds",
            "are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if blind.disabled then return end

        if context.debuff_card and context.debuff_card.area ~= G.jokers and
            (context.debuff_card:is_suit('Clubs', true) or context.debuff_card:is_suit('Diamonds', true)) then
            return { debuff = true }
        end
    end
}

-- 12. The Blood Moon (Head + Goad)
SMODS.Blind {
    reality_warp_fused = true,
    key = 'blood_moon',
    atlas = 'reality_warp_fused_blinds',
    pos = { x = 0, y = 11 },
    dollars = 5,
    mult = 2,
    boss = { min = 12, max = 99 },
    boss_colour = HEX('b27ca5'),
    loc_txt = {
        name = 'The Blood Moon',
        text = {
            "All Hearts and Spades",
            "are debuffed"
        }
    },
    ease_background_colour = function(self)
        ease_custom_blind_background(self)
    end,
    calculate = function(self, blind, context)
        if blind.disabled then return end

        if context.debuff_card and context.debuff_card.area ~= G.jokers and
            (context.debuff_card:is_suit('Hearts', true) or context.debuff_card:is_suit('Spades', true)) then
            return { debuff = true }
        end
    end
}
