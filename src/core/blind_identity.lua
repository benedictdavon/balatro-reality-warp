-- Progression uses slots; gameplay identity and category use registered definitions.
function reality_warp_blind_definition(blind)
    blind = blind or (G and G.GAME and G.GAME.blind)
    return blind and ((blind.config and blind.config.blind) or blind)
end

function reality_warp_blind_key(blind)
    local definition = reality_warp_blind_definition(blind)
    return definition and definition.key
end

function reality_warp_blind_is(blind, suffix)
    return reality_warp_blind_key(blind) == 'bl_reality_warp_' .. suffix
end

function reality_warp_blind_is_boss(blind)
    local definition = reality_warp_blind_definition(blind)
    return not not (definition and definition.boss)
end

function reality_warp_blind_is_showdown(blind)
    local definition = reality_warp_blind_definition(blind)
    return not not (definition and (definition.showdown or
        (type(definition.boss) == 'table' and definition.boss.showdown)))
end

function reality_warp_current_slot()
    return G and G.GAME and G.GAME.blind_on_deck
end

function reality_warp_selected_blind_key(slot)
    local resets = G and G.GAME and G.GAME.round_resets
    return resets and resets.blind_choices and resets.blind_choices[slot or reality_warp_current_slot()]
end

-- Recalculate after unlocking so other debuff sources and Perishable expiry survive.
function reality_warp_pincer_card_destroyed()
    local blind = G and G.GAME and G.GAME.blind
    if not reality_warp_blind_is(blind, 'pinza') or blind.disabled or G.GAME.pinza_card_destroyed then return end
    G.GAME.pinza_card_destroyed = true
    for _, joker in ipairs((G.jokers and G.jokers.cards) or {}) do
        SMODS.recalc_debuff(joker)
    end
    play_sound('tarot2')
end
