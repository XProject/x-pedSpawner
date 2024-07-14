---@class CRegistry
---@field private storage any[]
---@field private storageCount number
---@field getCount fun(this: CRegistry): storageCount: number
---@field getAll fun(this: CRegistry): storage: any[]
---@field getElementByIndex fun(this: CRegistry, index: number): any?
---@field getIndexByElement fun(this: CRegistry, attribute: any, attributeValue: any): number?
---@field addElement fun(this: CRegistry, element: any)
---@field removeElement fun(this: CRegistry, element: any)
---@field addElementByIndex fun(this: CRegistry, element: any, index: number)
---@field removeElementByIndex fun(this: CRegistry, index: number)

local class    = lib.require("modules.class.shared") --[[@as class]]

---@class Registry: CRegistry
local Registry = class("Registry", nil, {
    members = {
        --[[ private attributes ]]

        storage      = { private = true, value = {} },
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
            method = function(this, element)
                this.storageCount += 1
                this.storage[this.storageCount] = element
            end
        },

        removeElement = {
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
            method = function(this, element, index)
                this.storageCount += 1
                table.insert(this.storage, index, element)
            end
        },

        removeElementByIndex = {
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
