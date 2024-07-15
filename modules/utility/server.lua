---@class svUtility: utility
local utility = lib.load("modules.utility.shared")
local shared = lib.require("shared") --[[@as shared]]

local triggerClientEvent = TriggerClientEvent
local triggerLatentClientEvent = TriggerLatentClientEvent

---triggers a normal client event
---@param eventName string
---@param source number
---@param ... any
function utility.triggerClientEvent(eventName, source, ...)
    return triggerClientEvent(("%s:%s"):format(shared.eventPrefix, eventName), source, ...)
end

---triggers a latent client event
---@param eventName string
---@param source number
---@param ... any
function utility.triggerLatentClientEvent(eventName, source, ...)
    return triggerLatentClientEvent(("%s:%s"):format(shared.eventPrefix, eventName), source, 200000, ...)
end

---@param source string | number
---@param ... any
function utility.cheatDetected(source, ...)
    print(("[^1CHEATING^7] Player (^5%s^7) with the identifier of (^5%s^7) is detected ^1cheating^7!"):format(source, GetPlayerIdentifierByType(source --[[@as string]], "license")))

    if ... then
        print(("[^1CHEATING^7] %s"):format(...))
    end
end

return utility
