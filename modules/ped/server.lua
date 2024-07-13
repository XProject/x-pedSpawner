---@class CPed
---@field model  number
---@field coords vector4
---@field radius number
---@field entity number
---@field netId  number

lib.require("modules.class.shared")

local Ped = class("Ped", nil, {
    members = {
        model = {
            private = true,
            value = false,
            read_only = true
        },
        coords = {
            private = true,
            value = false,
            read_only = true
        },
        radius = {
            private = true,
            value = false,
            read_only = true
        },
        entity = {
            private = true,
            value = false,
            read_only = true
        },
        netId = {
            private = true,
            value = false,
            read_only = true
        },
    },
    ctor = function(this, parent_ctor, model, coords, radius)
        this.model = model
        this.coords = coords
        this.radius = radius
    end,
    dtor = function(this)
        print(string.format("A %s called %s is dead", this.__class.model, this.model))
    end
})
