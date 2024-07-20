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

    if not pedPlayerRegistry[pedKey] then
        return utility.error(("Player (^5%s^7) cannot be assigned in pedPlayerRegistry of ped with the key of %s"):format(playerId, pedKey))
    elseif pedPlayerRegistry[pedKey]:getIndexByElement(playerId) then
        return utility.cheatDetected(playerId, ("Player (^5%s^7) already is in the radius of ped with the key of %s"):format(playerId, pedKey))
    end

    pedPlayerRegistry[pedKey]:addElement(playerId)

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

    TriggerEvent("x-pedSpawner:enteredPedRadius", playerId, pedKey)
end

---removes ped while a player exits its zone
---@param playerId number
---@param pedKey string
---@param loggingOut? boolean
local function onExitPedRadius(playerId, pedKey, loggingOut)
    loggingOut = type(loggingOut) == "boolean" and loggingOut
    local ped = pedRegistry:getElementByKey(pedKey)

    if not loggingOut then -- skips the below checks if onExitPedRadius is forced call by the server while player is dropped
        if not ped then
            return utility.error(("Player (^5%s^7) tried exiting the radius of a ped with the key of %s which does not exist"):format(playerId, pedKey))
        elseif ped:isPlayerInRadius(playerId, -5) then
            return utility.cheatDetected(playerId, ("Player (^5%s^7) is still inside the radius of ped with key of %s"):format(playerId, pedKey))
        end

        if not pedPlayerRegistry[pedKey] then
            return utility.error(("Player (^5%s^7) cannot be removed from pedPlayerRegistry of ped with the key of %s"):format(playerId, pedKey))
        elseif not pedPlayerRegistry[pedKey]:getIndexByElement(playerId) then
            return utility.cheatDetected(playerId, ("Player (^5%s^7) is not even in the radius of ped with the key of %s"):format(playerId, pedKey))
        end
    end

    ---@cast ped -?

    pedPlayerRegistry[pedKey]:removeElement(playerId)

    if pedPlayerRegistry[pedKey]:getCount() > 0 then return end -- there are other players in the ped radius, so it shouldn't get deleted yet

    ped:deleteEntity()

    TriggerEvent("x-pedSpawner:exitedPedRadius", playerId, pedKey)
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
    if resource ~= cache.resource then return end

    for i = 1, pedRegistry:getCount() do
        pedRegistry:getElementByIndex(i):deleteEntity()
    end
end)

collectgarbage("generational")


--[[ -------------------- API -------------------- ]]
local handler = {}

---creates an instance of the Ped class, stores it in an storage, and returns the object
---@param pedModel  number | string
---@param pedCoords vector4
---@param pedRadius number
---@param pedBucket? number
---@param clientOnEnterScript? string
---@return Ped
function handler.create(pedModel, pedCoords, pedRadius, pedBucket, clientOnEnterScript)
    if type(pedModel) == "string" then
        pedModel = joaat(pedModel)
    end

    ---@type Ped
    local ped = class.new(CPed, pedModel, pedCoords, pedRadius, pedBucket, clientOnEnterScript)

    pedRegistry:addElement(ped)

    pedPlayerRegistry[ped:getKey()] = class.new(lib.load("modules.registry"))

    utility.queue(syncAllPedsWithPlayer)

    return ped
end

---removes the specified instance of the Ped class from the storage, returns if the process was succesful or not
---@param ped Ped | string
---@return boolean
function handler.remove(ped)
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

local clientScript = [[
SetEntityInvincible(%entity, true)
FreezeEntityPosition(%entity, true)
SetEntityProofs(%entity, true, true, true, false, true, true, true, true)
SetPedDiesWhenInjured(%entity, false)
SetPedFleeAttributes(%entity, 2, true)
SetPedCanPlayAmbientAnims(%entity, false)
SetPedCanLosePropsOnDamage(%entity, false, 0)
SetPedRelationshipGroupHash(%entity, `PLAYER`)
SetBlockingOfNonTemporaryEvents(%entity, true)
SetPedCanRagdollFromPlayerImpact(%entity, false)
]]

handler.create(joaat("a_m_m_eastsa_01"), vector4(-788.3876, -2335.1282, 14.8174, 220.5283), 10.0, 0, clientScript)

handler.create(joaat("a_m_m_eastsa_01"), vector4(-789.4866, -2334.0007, 14.8078, 218.6251), 10.0)
handler.create(joaat("a_m_m_eastsa_01"), vector4(-789.4866, -2334.0007, 14.8078, 218.6251), 10.0, 2, clientScript)

RegisterCommand("bucket", function(source, args)
    SetPlayerRoutingBucket(source, tonumber(args[1]) --[[@as integer]])
end, false)

RegisterCommand("add", function(source, args)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)

    handler.create(joaat("a_m_m_eastsa_01"), vector4(playerCoords.x, playerCoords.y, playerCoords.z, playerHeading), 10.0, GetPlayerRoutingBucket(source), clientScript)
end, false)

return handler
