---@class svUtility
local utility = {}

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

local generatedStrings = {}
local charset, charsetCount = {}, 0
math.randomseed(math.floor(os.clock() * 100000))
do
    local ranges = { { 48, 57 }, { 65, 90 }, { 97, 122 } } -- 0-9, A-Z, a-z

    for _, range in ipairs(ranges) do
        for c = range[1], range[2] do
            charsetCount += 1
            charset[charsetCount] = string.char(c)
        end
    end

    ranges = nil
end

---generates a random string of the given length
---@param length number
---@return string
function utility.randomString(length)
    local result = ""

    if length > 0 then
        repeat
            for _ = 1, length do
                local randomIndex = math.random(1, charsetCount)
                result = result .. charset[randomIndex]
            end
        until not generatedStrings[result]

        generatedStrings[result] = true
    end

    return result
end

return utility
