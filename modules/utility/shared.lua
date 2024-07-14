---@class utility
local utility = {}
local shared = lib.require("shared") --[[@as shared]]

---registers a net event
---@param eventName string
---@param ... any
function utility.registerNetEvent(eventName, ...)
    return RegisterNetEvent(("%s:%s"):format(shared.eventPrefix, eventName), ...)
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

---@param ... any
function utility.trace(...)
    print("[^2TRACE^7]", ...)
end

---@param ... any
function utility.warn(...)
    print("[^3WARNING^7]", ...)
end

---@param ... any
function utility.error(...)
    print("[^1ERROR^7]", ...)
end

return utility
