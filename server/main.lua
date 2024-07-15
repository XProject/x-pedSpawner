local handler       = {}

---@class Ped
local CPed          = lib.load("modules.ped")
local class         = lib.require("modules.class") --[[@as class]]
local loadedPlayers = class.new(lib.load("modules.registry")) --[[@as Registry]]
local pedRegistry   = class.new(lib.load("modules.pedRegistry")) --[[@as PedRegistry]]

---creates an instance of the Ped class, stores it in an storage, and returns the object
---@param pedModel  number | string
---@param pedCoords vector4
---@param pedRadius number
---@param pedBucket? number
---@return Ped
function handler.create(pedModel, pedCoords, pedRadius, pedBucket)
    if type(pedModel) == "string" then
        pedModel = joaat(pedModel)
    end

    ---@type Ped
    local ped = class.new(CPed, pedModel, pedCoords, pedRadius, pedBucket)

    pedRegistry:addElement(ped)

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

    return true
end

local utility = lib.require("modules.utility") --[[@as svUtility]]

---spawns ped while a player enters its zone
---@param playerId number
---@param pedKey string
local function onEnterPedRadius(playerId, pedKey)
    local ped = pedRegistry:getElementByKey(pedKey)

    if not ped or not ped:isPlayerNearby(playerId, 5) then return utility.cheatDetected(playerId) end

    local pedCoords = ped:getCoords()

    local pedEntity = CreatePed(0, ped:getModel(), pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, true, true)

    if not pedEntity then
        ped:setLoadState(false)
        return utility.error("The ped entity requested by the Player (^5%s^7) for the key of (^1%s^7) could not be spawned!")
    end

    ped:setEntityId(pedEntity)

    FreezeEntityPosition(pedEntity, true)

    TriggerEvent("x-pedSpawner:enteredPedRadius", playerId, pedKey)
end

---removes ped while a player exits its zone
---@param playerId number
---@param pedKey string
local function onExitPedRadius(playerId, pedKey)
    local ped = pedRegistry:getElementByKey(pedKey)

    if not ped or ped:isPlayerNearby(playerId, -5) then return utility.cheatDetected(playerId) end

    ped:deleteEntity()

    TriggerEvent("x-pedSpawner:exitedPedRadius", playerId, pedKey)
end

utility.registerNetEvent("enterPedRadius", function(pedKey)
    utility.queue(onEnterPedRadius, source, pedKey)
end)

utility.registerNetEvent("exitPedRadius", function(pedKey)
    utility.queue(onExitPedRadius, source, pedKey)
end)

do
    handler.create(joaat("a_m_m_eastsa_01"), vector4(-788.3876, -2335.1282, 14.8174, 220.5283), 10.0)
    handler.create(joaat("a_m_m_eastsa_01"), vector4(-789.4866, -2334.0007, 14.8078, 218.6251), 10.0)
    handler.create(joaat("a_m_m_eastsa_01"), vector4(-789.4866, -2334.0007, 14.8078, 218.6251), 10.0, 2)

    RegisterCommand("bucket", function(source, args)
        SetPlayerRoutingBucket(source, tonumber(args[1]) --[[@as integer]])
    end, false)
end

---@param playerId? number if omitted it will sync with all players
local function syncAllPedsWithPlayer(playerId)
    utility.triggerLatentClientEvent("syncAllPeds", playerId or -1, pedRegistry:getAllEntriesForClient())
end

utility.registerNetEvent("playerLoaded", function()
    local playerId = source

    if loadedPlayers:getIndexByElement(playerId) then
        return utility.cheatDetected(playerId)
    end

    loadedPlayers:addElement(playerId)

    syncAllPedsWithPlayer(playerId)
end)

AddEventHandler("playerDropped", function()
    local playerId = source

    if loadedPlayers:getIndexByElement(playerId) then
        return loadedPlayers:removeElement(playerId)
    end
end)

AddEventHandler("onResourceStop", function(resource)
    if resource ~= cache.resource then return end

    for i = 1, pedRegistry:getCount() do
        pedRegistry:getElementByIndex(i):deleteEntity()
    end
end)

collectgarbage("generational")

return handler
