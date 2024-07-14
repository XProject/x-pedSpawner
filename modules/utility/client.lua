---@class clUtility: utility
local utility = lib.load("modules.utility.shared")
local shared = lib.require("shared") --[[@as shared]]

local triggerServerEvent = TriggerServerEvent
local triggerLatentServerEvent = TriggerLatentServerEvent

---triggers a normal server event
---@param eventName string
---@param ... any
function utility.triggerServerEvent(eventName, ...)
    return triggerServerEvent(("%s:%s"):format(shared.eventPrefix, eventName), ...)
end

---triggers a latent server event
---@param eventName string
---@param ... any
function utility.triggerLatentServerEvent(eventName, ...)
    return triggerLatentServerEvent(("%s:%s"):format(shared.eventPrefix, eventName), 200000, ...)
end

return utility
