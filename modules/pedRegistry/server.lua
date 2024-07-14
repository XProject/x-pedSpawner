---@class CPedRegistry: Registry
---@field protected storage              Ped[]
---@field protected storageCount         number
---@field public    getCount             fun(this: CPedRegistry): storageCount: number
---@field public    getAll               fun(this: CPedRegistry): storage: Ped[]
---@field public    getElementByIndex    fun(this: CPedRegistry, index: number): Ped?
---@field public    getIndexByElement    fun(this: CPedRegistry, attribute: any, attributeValue: any): number?
---@field public    addElement           fun(this: CPedRegistry, element: any)
---@field public    removeElement        fun(this: CPedRegistry, element: any)
---@field public    addElementByIndex    fun(this: CPedRegistry, element: any, index: number)
---@field public    removeElementByIndex fun(this: CPedRegistry, index: number)
---@field private   stringIndex          table<string, number>
---@field public    getAllStringIndex    fun(this: CPedRegistry): stringIndex: table<string, number>
---@field public    getIndexByKey        fun(this: CPedRegistry, key: string): number?
---@field public    getElementByKey      fun(this: CPedRegistry, key: string): Ped?


local class       = lib.require("modules.class") --[[@as class]]
local CRegistry   = lib.require("modules.registry") --[[@class Registry]]

---@class PedRegistry: CPedRegistry
local PedRegistry = class("PedRegistry", CRegistry, {
    final = true,
    members = {
        --[[ private attributes ]]

        stringIndex = { private = true, value = {} },

        --[[ getters and setters ]]

        getAllStringIndex = {
            method = function(this)
                return this.stringIndex
            end
        },

        getIndexByKey = {
            method = function(this, key)
                return this.stringIndex[key]
            end
        },

        getElementByKey = {
            method = function(this, key)
                return this:getElementByIndex(this.stringIndex[key])
            end
        },

        --[[ other methods ]]

        -- overrides addElement from Registry class
        addElement = {
            method = function(this, element)
                this.storageCount += 1
                this.storage[this.storageCount] = element
                this.stringIndex[element:getKey()] = this.storageCount
            end
        },

        -- overrides removeElement from Registry class
        removeElement = {
            method = function(this, element)
                local index = this:getIndexByElement(element)

                if not index then
                    return error(("removeElement received an element (%s) which does not exist in the ped registry storage"):format(element))
                end

                this.storageCount -= 1
                this.stringIndex[element:getKey()] = nil
                table.remove(this.storage, index)
            end
        },

        -- overrides addElementByIndex from Registry class
        addElementByIndex = {
            method = function(this, element, index)
                this.storageCount += 1
                table.insert(this.storage, index, element)
                this.stringIndex[element:getKey()] = index
            end
        },

        -- overrides removeElementByIndex from Registry class
        removeElementByIndex = {
            method = function(this, index)
                local element = this:getElementByIndex(index)

                if not element then
                    return error(("removeElementByIndex received %s which does not exist as an index in ped registry storage"):format(index))
                end

                this.storageCount -= 1
                this.stringIndex[element:getKey()] = nil
                table.remove(this.storage, index)
            end
        },
    }
})

return PedRegistry
