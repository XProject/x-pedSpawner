---@diagnostic disable: invisible
---@class CPoint
---@field private id     number
---@field private coords vector4
---@field private radius number
---@field public  getId  fun(this: CPoint): id: number

local class = lib.require("modules.class") --[[@as class]]
local utility = lib.require("modules.utility") --[[@as clUtility]]

---@class Point: CPoint
local Point
Point = class("Point", nil, {
    members = {
        --[[ private attributes ]]

        id     = { private = true, value = false },
        coords = { private = true, value = false },
        radius = { private = true, value = false },

        --[[ getters and setters ]]

        getId = {
            ---@param this CPoint
            ---@return number
            method = function(this)
                return this.id
            end
        },

        getCoords = {
            ---@param this CPoint
            ---@return vector4
            method = function(this)
                return this.coords
            end
        },

        getRadius = {
            ---@param this CPoint
            ---@return number
            method = function(this)
                return this.radius
            end
        },

        --[[ other methods ]]

        -- overrides equal
        __eq = {
            ---@param this CPoint
            ---@param that CPoint
            ---@return boolean
            method = function(this, that)
                return that:__is_a(Point) and this:getId() == that:getId()
            end
        }
    },
    ctor    = function(this, _ --[[parent_ctor]], key, coords, radius)
        local p     = lib.points.new({
            coords = coords,
            distance = radius,
            onEnter = function()
                utility.triggerServerEvent("enterPedRadius", key)
            end,
            onExit = function()
                utility.triggerServerEvent("exitPedRadius", key)
            end,
        })

        this.id     = p.id
        this.coords = coords
        this.radius = radius
    end
})

return Point
