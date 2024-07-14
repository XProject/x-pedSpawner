local utility = lib.require("modules.utility") --[[@as clUtility]]

do
    CreateThread(function()
        while true do
            Wait(1000)

            if NetworkIsPlayerActive(cache.playerId) then
                utility.triggerServerEvent("requestToSyncAllPeds")
                break
            end
        end
    end)
end

---@type table<string, vector4>
local allPeds = {}
local havePedsBeenSync = false

utility.registerNetEvent("syncAllPeds", function(_allPeds)
    if havePedsBeenSync then return end

    havePedsBeenSync = true

    allPeds = _allPeds
    _allPeds = nil

    for key, value in pairs(allPeds) do
        utility.trace(key, value)
    end
end)
