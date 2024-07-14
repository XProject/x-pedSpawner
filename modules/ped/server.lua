---@class CPed
---@field private key          string
---@field private model        number
---@field private coords       vector4
---@field private radius       number
---@field private entityId     number
---@field private networkId    number
---@field private bucket       number
---@field public  getKey       fun(this: CPed): key: string
---@field public  getModel     fun(this: CPed): model: string
---@field public  getCoords    fun(this: CPed): coords: vector4
---@field public  setCoords    fun(this: CPed, newCoords: vector4)
---@field public  getRadius    fun(this: CPed): radius: number
---@field public  setRadius    fun(this: CPed, newRadius: number)
---@field public  getEntityId  fun(this: CPed): entityId: number
---@field public  setEntityId  fun(this: CPed, newEntityId: number)
---@field public  getNetworkId fun(this: CPed): networkId: number
---@field public  setNetworkId fun(this: CPed, newNetworkId: number)
---@field public  getBucket    fun(this: CPed): bucket: number
---@field public  setBucket    fun(this: CPed, newBucket: number)

local class   = lib.require("modules.class") --[[@as class]]
local utility = lib.require("modules.utility") --[[@as utility]]

local Ped
---@class Ped: CPed
Ped           = class("Ped", nil, {
    members = {
        --[[ private attributes ]]
        key       = { private = true, value = false },
        model     = { private = true, value = false },
        coords    = { private = true, value = false },
        radius    = { private = true, value = false },
        entityId  = { private = true, value = false },
        networkId = { private = true, value = false },
        bucket    = { private = true, value = false },

        --[[ getters and setters ]]

        -- key
        getKey       = {
            method = function(this)
                return this.key
            end
        },

        -- model
        getModel     = {
            method = function(this)
                return this.model
            end
        },

        -- coords
        getCoords    = {
            method = function(this)
                return this.coords
            end
        },
        setCoords    = {
            method = function(this, newCoords)
                local _type = type(newCoords)

                if _type ~= "vector4" then
                    return error(("newCoords must be of type vector4, received %s"):format(_type))
                end

                this.coords = newCoords
            end
        },

        -- radius
        getRadius    = {
            method = function(this)
                return this.radius
            end
        },
        setRadius    = {
            method = function(this, newRadius)
                local _type = type(newRadius)

                if _type ~= "number" then
                    return error(("newRadius must be of type number, received %s"):format(_type))
                end

                if newRadius <= 0.0 then
                    return error(("newRadius must be bigger than 0.0, received %s"):format(newRadius))
                elseif newRadius > 300.0 then
                    newRadius = 300.0 -- because of onesync infinity entity scope
                end

                this.radius = newRadius
            end
        },

        -- entityId
        getEntityId  = {
            method = function(this)
                return this.entityId
            end
        },
        setEntityId  = {
            method = function(this, newEntityId)
                local _type = type(newEntityId)

                if _type ~= "number" then
                    return error(("newEntityId must be of type number, received %s"):format(_type))
                end

                local newNetworkId

                if newEntityId <= 0 then -- means the entity is removed
                    newEntityId = false
                    newNetworkId = false
                elseif not DoesEntityExist(newEntityId) then
                    return error(("newEntityId is not an existing entityId on the server, received %s"):format(newEntityId))
                else
                    newNetworkId = NetworkGetNetworkIdFromEntity(newEntityId)
                end

                this.entityId = newEntityId
                this.networkId = newNetworkId
            end
        },

        -- networkId
        getNetworkId = {
            method = function(this)
                return this.networkId
            end
        },
        setNetworkId = {
            method = function(this, newNetworkId)
                local _type = type(newNetworkId)

                if _type ~= "number" then
                    return error(("newNetworkId must be of type number, received %s"):format(_type))
                end

                local newEntityId

                if newNetworkId <= 0 then -- means the entity is removed
                    newEntityId = false
                    newNetworkId = false
                elseif not DoesEntityExist(NetworkGetEntityFromNetworkId(newNetworkId)) then
                    return error(("newNetworkId is not an existing networkId on the server, received %s"):format(newNetworkId))
                else
                    newEntityId = NetworkGetEntityFromNetworkId(newNetworkId)
                end

                this.entityId = newEntityId
                this.networkId = newNetworkId
            end
        },

        -- bucket
        getBucket    = {
            method = function(this)
                return this.entityId and GetEntityRoutingBucket(this.entityId) or this.bucket
            end
        },
        setBucket    = {
            method = function(this, newBucket)
                local _type = type(newBucket)

                if _type ~= "number" then
                    return error(("newBucket must be of type number, received %s"):format(_type))
                end

                if newBucket < 0 then
                    return error(("newBucket must be 0 or bigger than it, received %s"):format(newBucket))
                elseif this.entityId then
                    SetEntityRoutingBucket(this.entityId, newBucket)
                end

                this.bucket = newBucket
            end
        },

        --[[ other methods ]]

        -- overrides tostring
        __tostring = {
            method = function(this)
                return string.format("[PED] Key: %s, Model: %s, Coords: %s, Radius: %s, EntityId: %s, NetworkId: %s, Bucket: %s", this.key, this.model, this.coords, this.radius, this.entityId, this.networkId, this.bucket)
            end
        },

        -- overrides equal
        __eq = {
            method = function(this, that)
                return that:__is_a(Ped) and this:getKey() == that:getKey()
            end
        }
    },
    ctor    = function(this, _ --[[parent_ctor]], model, coords, radius, bucket)
        this.key    = utility.randomString(5)
        this.model  = model
        this.coords = coords
        this.radius = radius
        this.bucket = bucket or 1 -- defaults to bucket 1
    end
})

return Ped
