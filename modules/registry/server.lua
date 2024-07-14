---@class CRegistry
---@field protected storage              any[]
---@field protected storageCount         number
---@field public    getCount             fun(this: CRegistry): storageCount: number
---@field public    getAll               fun(this: CRegistry): storage: any[]
---@field public    getElementByIndex    fun(this: CRegistry, index: number): any?
---@field public    getIndexByElement    fun(this: CRegistry, attribute: any, attributeValue: any): number?
---@field public    addElement           fun(this: CRegistry, element: any)
---@field public    removeElement        fun(this: CRegistry, element: any)
---@field public    addElementByIndex    fun(this: CRegistry, element: any, index: number)
---@field public    removeElementByIndex fun(this: CRegistry, index: number)

local class    = lib.require("modules.class") --[[@as class]]

---@class Registry: CRegistry
local Registry = class("Registry", nil, {
    members = {
        --[[ attributes ]]

        storage      = { protected = true, value = {} },
        storageCount = { protected = true, value = 0 },

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

        getElementByIndex = {
            method = function(this, index)
                return this.storage[index]
            end
        },

        getIndexByElement = {
            method = function(this, element)
                for i = 1, this.storageCount do
                    local _element = this.storage[i]

                    if _element == element then
                        return i
                    end
                end
            end
        },

        --[[ other methods ]]

        addElement = {
            virtual = true,
            method = function(this, element)
                this.storageCount += 1
                this.storage[this.storageCount] = element
            end
        },

        removeElement = {
            virtual = true,
            method = function(this, element)
                local index = this:getIndexByElement(element)

                if not index then
                    return error(("removeElement received an element (%s) which does not exist in the registry storage"):format(element))
                end

                this.storageCount -= 1
                table.remove(this.storage, index)
            end
        },

        addElementByIndex = {
            virtual = true,
            method = function(this, element, index)
                this.storageCount += 1
                table.insert(this.storage, index, element)
            end
        },

        removeElementByIndex = {
            virtual = true,
            method = function(this, index)
                if not this:getElementByIndex(index) then
                    return error(("removeElementByIndex received %s which does not exist as an index in registry storage"):format(index))
                end

                this.storageCount -= 1
                table.remove(this.storage, index)
            end
        },
    },
})

return Registry
