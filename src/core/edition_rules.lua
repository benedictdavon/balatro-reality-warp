-- Dark Alchemy owns one native edition poll during a real shop/pack Joker
-- creation. Raw registered weights and RNG remain entirely framework-owned.
local creation_scope, poll_scope
local function pack(...) return {n = select('#', ...), ...} end
local function finish(result)
    if not result[1] then error(result[2], 0) end
    return unpack(result, 2, result.n)
end
local function live(scope)
    return scope and G and G.GAME == scope.game and scope.game.dark_alchemy_tag_active and
        scope.game.round_resets and scope.game.round_resets.ante == scope.ante and
        ((G.shop_jokers and scope.area == G.shop_jokers) or
         (G.pack_cards and scope.area == G.pack_cards))
end
function reality_warp_wrap_alchemy_create(lower)
    return function(...)
        local args = pack(...)
        local kind, area, forced_key, append = args[1], args[2], args[7], args[8]
        local previous = creation_scope
        local game = G and G.GAME
        local center = forced_key and G.P_CENTERS and G.P_CENTERS[forced_key]
        if center and not ((game and game.banned_keys or {})[forced_key]) and center.set ~= 'Default' then
            kind = center.set -- eligibility only; forward the original argument below
        end
        local scope
        if game and game.dark_alchemy_tag_active and kind == 'Joker' and area and
            ((G.shop_jokers and area == G.shop_jokers) or (G.pack_cards and area == G.pack_cards)) then
            local ante = game.round_resets and game.round_resets.ante
            if ante then scope = {game = game, area = area, ante = ante, seed = 'edi' .. (append or '') .. ante} end
        end
        creation_scope = scope -- unowned nested creation must clear parent ownership
        local result = pack(pcall(lower, unpack(args, 1, args.n)))
        creation_scope = previous
        return finish(result)
    end
end

local negative_center, negative_wrapper
local function chain_negative_getter()
    local center = G.P_CENTERS and G.P_CENTERS.e_negative
    if not center or type(center.get_weight) ~= 'function' then return end
    if center == negative_center and center.get_weight == negative_wrapper then return end
    local lower = center.get_weight
    local wrapper = function(self, ...)
        local scope = poll_scope
        if not live(scope) then return lower(self, ...) end
        local depth = scope.depth or 0
        scope.depth = depth + 1
        local result = pack(pcall(lower, self, ...))
        scope.depth = depth
        -- A late external wrapper can call an older RW wrapper: amplify only
        -- the outermost modified getter, after preserving its own modifiers.
        if result[1] and depth == 0 and poll_scope == scope and live(scope) and self == center then
            result[2] = result[2] * 10
        end
        return finish(result)
    end
    center.get_weight = wrapper
    negative_center, negative_wrapper = center, wrapper
end

if poll_edition then
    local lower = poll_edition
    local function invoke(scope, ...)
        if scope then chain_negative_getter() end
        return lower(...)
    end
    function poll_edition(...)
        local args = pack(...)
        local key, no_negative, guaranteed, options = args[1], args[3], args[4], args[5]
        local previous = poll_scope
        local owner = creation_scope
        local scope
        if live(owner) and key == owner.seed and not owner.polled then
            owner.polled = true
            local explicit_weights = false
            for _, option in ipairs(options or {}) do
                if type(option) == 'table' then explicit_weights = true; break end
            end
            if not no_negative and not guaranteed and not explicit_weights then
                scope = {game = owner.game, area = owner.area, ante = owner.ante, depth = 0}
            end
        end
        poll_scope = scope -- every nested/unowned poll gets its own ownership
        local result = pack(pcall(invoke, scope, unpack(args, 1, args.n)))
        poll_scope = previous
        return finish(result)
    end
end
