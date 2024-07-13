---@class CRegistry
---@field private storage any[]

local safeCall = pcall
local class    = lib.require("modules.class.shared") --[[@as class]]

local Registry = class("Registry", nil, {
    members = {
        --[[ private attributes ]]
        storage = { private = true, value = {} },
        storageCount = { private = true, value = 0 },

        --[[ getters and setters ]]

        getCount = {
            method = function(this)
                return this.storageCount
            end
        },

        getAll = {
            method = function(this)
                return this.storage
            end
        },

        getByIndex = {
            method = function(this, index)
                return this.storage[index]
            end
        },

        getIndexByAttribute = { -- needs extensive testing
            method = function(this, attribute, attributeValue)
                for i = 1, storageCount do
                    local element = this.storage[i]
                    local response = safeCall(element:attribute()) or safeCall(element[attribute]) or rawget(element[attribute])

                    if response and response == attributeValue then return i end
                end
            end
        },

        --[[ other methods ]]

        add = {
            method = function(this, element)
                storageCount += 1
                this.storage[storageCount] = element
            end
        },

        removeByIndex = {
            method = function(this, index)
                if not this:getByIndex(index) then
                    return error(("removeByIndex received %s which does not exist as an index"):format(index))
                end

                storageCount -= 1
                table.remove(this.storage, index)
            end
        },

        -- overloads tostring
        -- __tostring = {
        --     method = function(this)
        --         return string.format()
        --     end
        -- },
    },
})

return Registry
