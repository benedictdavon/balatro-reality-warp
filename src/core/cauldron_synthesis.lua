Witcher_Cauldron = {
    slot_a = nil,
    slot_b = nil,
    recipes = {
        -- Tarot + Tarot -> Random Job Card
        ['Tarot_Tarot'] = function(c1, c2)
            local job_keys = {
                'c_Witch_brew_miner_job', 'c_Witch_brew_gardener_job', 'c_Witch_brew_banker_job',
                'c_Witch_brew_surgeon_job', 'c_Witch_brew_alchemist_job', 'c_Witch_brew_butcher_job',
                'c_Witch_brew_detective_job', 'c_Witch_brew_chef_job', 'c_Witch_brew_archaeologist_job',
                'c_Witch_brew_jeweler_job', 'c_Witch_brew_apothecary_job', 'c_Witch_brew_bounty_hunter_job',
                'c_Witch_brew_croupier_job'
            }
            local chosen = pseudorandom_element(job_keys, pseudoseed('cauldron_job'))
            local card = create_card('Job', G.consumeables, nil, nil, nil, nil, chosen, 'cauldron')
            return card, 'Transmuted into ' .. (card.ability and card.ability.name or 'Job Card') .. '!'
        end,

        -- Job + Job -> Random Spectral Card
        ['Job_Job'] = function(c1, c2)
            local card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'cauldron_spectral')
            return card, 'Elevated to Spectral Power!'
        end,

        -- Spectral + Spectral -> Consumable of Choice / Apex Summons
        ['Spectral_Spectral'] = function(c1, c2)
            -- Guarantees legendary soul or chosen consumable
            local card = create_card('Spectral', G.consumeables, nil, nil, nil, nil, 'c_soul', 'cauldron_apex')
            return card, 'Apex Magic: The Soul Summoned!'
        end,

        -- Planet + Same Planet -> Upgrades poker hand by +4 Levels
        ['Planet_Same'] = function(c1, c2)
            local hand = (c1.ability and c1.ability.hand_type) or (c1.config and c1.config.hand_type)
            if hand and G.GAME.hands and G.GAME.hands[hand] then
                level_up_hand(c1, hand, nil, 4)
                return nil, hand .. ' Upgraded by +4 Levels!'
            end
            return nil, 'Cosmic Expansion: +4 Hand Levels!'
        end
    }
}

function Witcher_Cauldron.can_synthesize(card_a, card_b)
    if not card_a or not card_b then return false end
    local set_a = (card_a.ability and card_a.ability.set) or 'Unknown'
    local set_b = (card_b.ability and card_b.ability.set) or 'Unknown'

    if set_a == 'Tarot' and set_b == 'Tarot' then return true end
    if set_a == 'Job' and set_b == 'Job' then return true end
    if set_a == 'Spectral' and set_b == 'Spectral' then return true end
    if set_a == 'Planet' and set_b == 'Planet' and card_a.config.center.key == card_b.config.center.key then return true end

    return false
end

-- This is kinda funny


function Witcher_Cauldron.synthesize(card_a, card_b)
    if not Witcher_Cauldron.can_synthesize(card_a, card_b) then
        return nil, "Invalid Recipe"
    end

    local set_a = card_a.ability.set
    local set_b = card_b.ability.set
    local recipe_key = nil

    if set_a == 'Tarot' and set_b == 'Tarot' then
        recipe_key = 'Tarot_Tarot'
    elseif set_a == 'Job' and set_b == 'Job' then
        recipe_key = 'Job_Job'
    elseif set_a == 'Spectral' and set_b == 'Spectral' then
        recipe_key = 'Spectral_Spectral'
    elseif set_a == 'Planet' and set_b == 'Planet' then
        recipe_key = 'Planet_Same'
    end

    if recipe_key and Witcher_Cauldron.recipes[recipe_key] then
        play_sound('tarot2', 1.1)
        -- Consume both ingredients
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                card_a:start_dissolve()
                card_b:start_dissolve()
                return true
            end
        }))

        -- Execute recipe
        local result_card, message = Witcher_Cauldron.recipes[recipe_key](card_a, card_b)
        if result_card and G.consumeables then
            result_card:add_to_deck()
            G.consumeables:emplace(result_card)
            result_card:juice_up(0.6, 0.6)
        end

        return result_card, message
    end

    return nil, "Synthesis Failed"
end
