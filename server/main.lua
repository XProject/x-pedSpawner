---@class Ped
local CPed              = lib.load("modules.ped")
local shared            = lib.require("shared") --[[@as shared]]
local class             = lib.require("modules.class") --[[@as class]]
local utility           = lib.require("modules.utility") --[[@as svUtility]]
local pedRegistry       = class.new(lib.load("modules.pedRegistry")) --[[@as PedRegistry]]
local loadedPlayers     = class.new(lib.load("modules.registry")) --[[@as Registry]]
local pedPlayerRegistry = {} --[[@type table<string, Registry>]]


---spawns ped while a player enters its zone
---@param playerId number
---@param pedKey string
local function onEnterPedRadius(playerId, pedKey)
    local ped = pedRegistry:getElementByKey(pedKey)

    if not ped then
        return utility.error(("Player (^5%s^7) tried entering the radius of a ped with the key of %s which does not exist"):format(playerId, pedKey))
    elseif not ped:isPlayerInRadius(playerId, 5) then
        return utility.cheatDetected(playerId, ("Player (^5%s^7) is not close to the radius of ped with key of %s"):format(playerId, pedKey))
    end

    local pedPlayerStorage = pedPlayerRegistry[pedKey]

    if not pedPlayerStorage then
        return utility.error(("Player (^5%s^7) cannot be assigned in pedPlayerRegistry of ped with the key of %s"):format(playerId, pedKey))
    elseif pedPlayerStorage:getIndexByElement(playerId) then
        return utility.cheatDetected(playerId, ("Player (^5%s^7) already is in the radius of ped with the key of %s"):format(playerId, pedKey))
    end

    pedPlayerStorage:addElement(playerId)

    if not ped:getEntityId() then -- if the entity is not already spawned
        local pedCoords = ped:getCoords()

        local pedEntity = CreatePed(0, ped:getModel(), pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, true, true)

        if not pedEntity then
            return utility.error("The ped entity requested by the Player (^5%s^7) for the key of (^1%s^7) could not be spawned!")
        end

        ped:setEntityId(pedEntity)

        FreezeEntityPosition(pedEntity, true)

        Entity(pedEntity).state:set(shared.stateBagName, ped:getClientOnEnterScript(), true)
    end

    TriggerEvent(("%s:enteredPedRadius"):format(cache.resource), playerId, pedKey)
end

---removes ped while a player exits its zone
---@param playerId number
---@param pedKey string
---@param loggingOut? boolean
local function onExitPedRadius(playerId, pedKey, loggingOut)
    loggingOut = type(loggingOut) == "boolean" and loggingOut
    local ped = pedRegistry:getElementByKey(pedKey)
    local pedPlayerStorage = pedPlayerRegistry[pedKey]

    if not loggingOut then -- skips the below checks if onExitPedRadius is forced call by the server while player is dropped
        if not ped then
            return utility.error(("Player (^5%s^7) tried exiting the radius of a ped with the key of %s which does not exist"):format(playerId, pedKey))
        elseif ped:isPlayerInRadius(playerId, -5) then
            return utility.cheatDetected(playerId, ("Player (^5%s^7) is still inside the radius of ped with key of %s"):format(playerId, pedKey))
        end

        if not pedPlayerStorage then
            return utility.error(("Player (^5%s^7) cannot be removed from pedPlayerRegistry of ped with the key of %s"):format(playerId, pedKey))
        elseif not pedPlayerStorage:getIndexByElement(playerId) then
            return utility.cheatDetected(playerId, ("Player (^5%s^7) is not even in the radius of ped with the key of %s"):format(playerId, pedKey))
        end
    end

    ---@cast ped -?

    pedPlayerStorage:removeElement(playerId)

    if pedPlayerStorage:getCount() > 0 then return end -- there are other players in the ped radius, so it shouldn't get deleted yet

    ped:deleteEntity()

    TriggerEvent(("%s:exitedPedRadius"):format(cache.resource), playerId, pedKey)
end

utility.registerNetEvent("enterPedRadius", function(pedKey)
    utility.queue(onEnterPedRadius, source, pedKey)
end)

utility.registerNetEvent("exitPedRadius", function(pedKey)
    utility.queue(onExitPedRadius, source, pedKey)
end)

---@param playerId? number if omitted it will sync with all players
local function syncAllPedsWithPlayer(playerId)
    utility.triggerLatentClientEvent("syncAllPeds", playerId or -1, pedRegistry:getAllEntriesForClient())
end

utility.registerNetEvent("playerLoaded", function()
    local playerId = source

    if loadedPlayers:getIndexByElement(playerId) then
        return utility.cheatDetected(playerId, ("Player (^5%s^7) is already loaded"):format(playerId))
    end

    loadedPlayers:addElement(playerId)

    utility.queue(syncAllPedsWithPlayer, playerId)
end)

AddEventHandler("playerDropped", function()
    local playerId = source

    if loadedPlayers:getIndexByElement(playerId) then
        loadedPlayers:removeElement(playerId)
    end

    for pedKey, registry in pairs(pedPlayerRegistry) do
        if registry:getIndexByElement(playerId) then
            utility.queue(onExitPedRadius, playerId, pedKey, true)
        end
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource == cache.resource then
        for i = 1, pedRegistry:getCount() do
            pedRegistry:getElementByIndex(i):deleteEntity()
        end
    else
        local indicesToRemove, count = {}, 0

        for i = 1, pedRegistry:getCount() do
            local ped = pedRegistry:getElementByIndex(i)

            ---@cast ped -?

            if ped:getResource() == resource then
                count += 1
                indicesToRemove[count] = i

                ped:deleteEntity()

                local pedKey = ped:getKey()
                local registry = pedPlayerRegistry[pedKey]

                for k = registry:getCount(), 1, -1 do
                    registry:removeElementByIndex(k)
                end

                table.wipe(registry)
                table.wipe(pedPlayerRegistry[pedKey])
                pedPlayerRegistry[pedKey], registry = nil, nil ---@diagnostic disable-line: cast-local-type
            end
        end

        for i = count, 1, -1 do
            pedRegistry:removeElementByIndex(indicesToRemove[i])
        end

        -- sync the changes with client
        if count > 0 then
            utility.queue(syncAllPedsWithPlayer)
        end
    end
end)

collectgarbage("generational")


--[[ -------------------- API -------------------- ]]
local api = setmetatable({}, {
    __newindex = function(self, index, value)
        exports(index, value)
        rawset(self, index, value)
    end
})

---creates an instance of the Ped class, stores it in an storage, and returns the ped's unique key
---@param pedModel  number | string
---@param pedCoords vector4
---@param pedRadius number
---@param pedBucket? number
---@param clientOnEnterScript? string
---@return string
function api.create(pedModel, pedCoords, pedRadius, pedBucket, clientOnEnterScript)
    if type(pedModel) == "string" then
        pedModel = joaat(pedModel)
    end

    ---@type Ped
    local ped = class.new(CPed, pedModel, pedCoords, pedRadius, pedBucket, clientOnEnterScript)
    local pedKey = ped:getKey()

    pedRegistry:addElement(ped)

    pedPlayerRegistry[pedKey] = class.new(lib.load("modules.registry"))

    utility.queue(syncAllPedsWithPlayer)

    return pedKey
end

---removes the specified instance of the Ped class from the storage, returns if the process was succesful or not
---@param ped Ped | string
---@return boolean
function api.remove(ped)
    if type(ped) == "string" then
        ped = pedRegistry:getElementByKey(ped) ---@diagnostic disable-line: cast-local-type
    end

    if not class.is_object(ped, CPed) then return false end

    ---@cast ped -?

    ped:deleteEntity()
    pedRegistry:removeElement(ped)

    local pedKey = ped:getKey()
    local registry = pedPlayerRegistry[pedKey]

    for i = registry:getCount(), 1, -1 do
        registry:removeElementByIndex(i)
    end

    table.wipe(registry)
    table.wipe(pedPlayerRegistry[pedKey])
    pedPlayerRegistry[pedKey], registry = nil, nil ---@diagnostic disable-line: cast-local-type

    utility.queue(syncAllPedsWithPlayer)

    return true
end

-- local clientScript = [[
-- SetEntityInvincible(%entity, true)
-- FreezeEntityPosition(%entity, true)
-- SetEntityProofs(%entity, true, true, true, false, true, true, true, true)
-- SetPedDiesWhenInjured(%entity, false)
-- SetPedFleeAttributes(%entity, 2, true)
-- SetPedCanPlayAmbientAnims(%entity, false)
-- SetPedCanLosePropsOnDamage(%entity, false, 0)
-- SetPedRelationshipGroupHash(%entity, `PLAYER`)
-- SetBlockingOfNonTemporaryEvents(%entity, true)
-- SetPedCanRagdollFromPlayerImpact(%entity, false)
-- ]]

-- api.create(joaat("a_m_m_eastsa_01"), vector4(-788.3876, -2335.1282, 14.8174, 220.5283), 10.0, 0, clientScript)
-- api.create(joaat("a_m_m_eastsa_01"), vector4(-789.4866, -2334.0007, 14.8078, 218.6251), 10.0)
-- api.create(joaat("a_m_m_eastsa_01"), vector4(-789.4866, -2334.0007, 14.8078, 218.6251), 10.0, 2, clientScript)

-- RegisterCommand("bucket", function(source, args)
--     SetPlayerRoutingBucket(source, tonumber(args[1]) --[[@as integer]])
-- end, false)

-- RegisterCommand("addPed", function(source, args)
--     local playerPed = GetPlayerPed(source)
--     local playerCoords = GetEntityCoords(playerPed)
--     local playerHeading = GetEntityHeading(playerPed)

--     local ped = api.create(joaat("a_m_m_eastsa_01"), vector4(playerCoords.x, playerCoords.y, playerCoords.z, playerHeading), 10.0, GetPlayerRoutingBucket(source), clientScript)

--     utility.trace(ped)
-- end, false)

-- RegisterCommand("removePed", function(source, args)
--     local pedKey = args[1]
--     local result = api.remove(pedKey)

--     utility.trace(pedKey, result and "removed" or "not removed")
-- end, false)

return api
