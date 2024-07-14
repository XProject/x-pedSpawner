---@class svUtility: utility
local utility = lib.load("modules.utility.shared")

local triggerClientEvent = TriggerClientEvent
local triggerLatentClientEvent = TriggerLatentClientEvent

---triggers a normal client event
---@param eventName string
---@param source number
---@param ... any
function utility.triggerEvent(eventName, source, ...)
    return triggerClientEvent(eventName, source, ...)
end

---triggers a latent client event
---@param eventName string
---@param source number
---@param ... any
function utility.triggerLatentEvent(eventName, source, ...)
    return triggerLatentClientEvent(eventName, source, 200000, ...)
end

---@param source string | number
---@param ... any
function utility.cheatDetected(source, ...)
    print(("[^1CHEATING^7] Player (^5%s^7) with the identifier of (^5%s^7) is detected ^1cheating^7!"):format(source, GetPlayerIdentifierByType(source --[[@as string]], "license")))

    if ... then
        print("[^1CHEATING^7]", ...)
    end
end

return utility
