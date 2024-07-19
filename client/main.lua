---@class Point
local CPoint  = lib.require("modules.point")
local shared  = lib.require("shared") --[[@as shared]]
local class   = lib.require("modules.class") --[[@as class]]
local utility = lib.require("modules.utility") --[[@as clUtility]]


do
    CreateThread(function()
        while true do
            if NetworkIsPlayerActive(cache.playerId) then
                utility.triggerServerEvent("playerLoaded")
                break
            end

            Wait(1000)
        end
    end)
end

---@type CClientEntry[]
local allPeds = {}
local havePedsBeenSync = false

utility.registerNetEvent("syncAllPeds", function(_allPeds)
    if havePedsBeenSync then return end

    havePedsBeenSync = true

    ---@cast _allPeds CClientEntry[]

    for i = 1, #_allPeds do
        local entry = _allPeds[i]

        class.new(CPoint, entry.key, entry.coords, entry.radius)
    end

    allPeds = _allPeds
    _allPeds = nil
end)

AddStateBagChangeHandler(shared.stateBagName, "", function(bagName, key, value)
    if not value or not key:find(cache.resource) then return end

    local entity = GetEntityFromStateBagName(bagName)

    if not entity or entity == 0 then return end

    value = value:gsub("%%entity", entity)
    local fn, err = load(value)

    if not fn or err then
        return utility.error(("^1Error loading chunk for %s. Error message: %s^0"):format(shared.stateBagName, err))
    end

    fn()
end)

collectgarbage("generational")
