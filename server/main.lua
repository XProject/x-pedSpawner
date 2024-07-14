local handler       = {}

---@class Ped
local CPed          = lib.load("modules.ped")
local class         = lib.require("modules.class") --[[@as class]]
local loadedPlayers = class.new(lib.load("modules.registry")) --[[@as Registry]]
local pedRegistry   = class.new(lib.load("modules.pedRegistry")) --[[@as PedRegistry]]

---creates an instance of the Ped class, stores it in an storage, and returns the object
---@param pedModel  number
---@param pedCoords vector4
---@param pedRadius number
---@param pedBucket? number
---@return Ped
function handler.create(pedModel, pedCoords, pedRadius, pedBucket)
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

    pedRegistry:removeElement(ped)

    return true
end

local utility = lib.require("modules.utility") --[[@as svUtility]]

utility.registerNetEvent("enteredPedRadius", function(pedKey)
    local playerId = source

    local ped = pedRegistry:getElementByKey(pedKey)

    if not ped or not ped:isPlayerNearby(playerId) then return utility.cheatDetected(playerId) end

    if ped:getLoadState() then return end -- this ped is either loading or loaded

    ped:setLoadState("loading")

    local pedCoords = ped:getCoords()

    local pedEntity = CreatePed(0, ped:getModel(), pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, true, true)

    if not pedEntity then
        ped:setLoadState(false)
        return utility.error("The ped entity requested by the Player (^5%s^7) for the key of (^1%s^7) could not be spawned!")
    end

    ped:setLoadState(true)
    ped:setEntityId(pedEntity)

    FreezeEntityPosition(pedEntity, true)
end)

do
    local ped = handler.create(123456789, vector4(0), 0.0)
    print(ped)
end

---@param playerId? number if omitted it will sync with all players
local function syncAllPedsWithPlayer(playerId)
    utility.triggerLatentClientEvent("syncAllPeds", playerId or -1, pedRegistry:getAllEntriesForClient())
end

utility.registerNetEvent("requestToSyncAllPeds", function()
    local playerId = source

    if loadedPlayers:getIndexByElement(playerId) then return utility.cheatDetected(playerId) end

    loadedPlayers:addElement(playerId)

    syncAllPedsWithPlayer(playerId)
end)

AddEventHandler("playerDropped", function()
    local playerId = source

    if not loadedPlayers:getIndexByElement(playerId) then return end

    loadedPlayers:removeElement(playerId)
end)

return handler
