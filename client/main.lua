---@class Point
local CPoint  = lib.require("modules.point")
local class   = lib.require("modules.class") --[[@as class]]
local utility = lib.require("modules.utility") --[[@as clUtility]]


do
    CreateThread(function()
        while true do
            if NetworkIsPlayerActive(cache.playerId) then
                utility.triggerServerEvent("requestToSyncAllPeds")
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

collectgarbage("generational")
