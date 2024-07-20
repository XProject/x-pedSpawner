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

---@param allPeds CClientEntry[]
utility.registerNetEvent("syncAllPeds", function(allPeds)
    -- making sure the event is getting called from the server
    if source == "" or GetInvokingResource() then return end

    -- removing the registered points
    local points = {}
    local registeredPoints = lib.points.getAllPoints()

    for _, point in pairs(registeredPoints) do
        local shouldRemove = true

        for i = 1, #allPeds do
            local entry = allPeds[i]

            if point.key == entry.key then -- means the previously registered point still exists, therefore its data should not get removed
                points[i]    = true
                shouldRemove = false
                break
            end
        end

        if shouldRemove then
            point:remove()
        end
    end

    -- register points
    for i = 1, #allPeds do
        local entry = allPeds[i]

        if not points[i] then
            class.new(CPoint, entry.key, entry.coords, entry.radius)
        end
    end
end)

AddStateBagChangeHandler(shared.stateBagName, "entity", function(bagName, key, chunk)
    if not chunk or not key:find(cache.resource) then return end

    local entity = GetEntityFromStateBagName(bagName)

    if not entity or entity == 0 then return end

    chunk = chunk:gsub("%%entity", entity)
    local fn, err = load(chunk)

    if not fn or err then
        return utility.error(("^1Error loading chunk for %s. Error message: %s^0"):format(shared.stateBagName, err))
    end

    fn()
end)

collectgarbage("generational")
