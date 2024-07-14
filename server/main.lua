local handler     = {}

---@class Ped
local CPed        = lib.load("modules.ped")
local class       = lib.require("modules.class") --[[@as class]]
local pedRegistry = class.new(lib.require("modules.pedRegistry")) --[[@as PedRegistry]]

---creates an instance of the Ped class, stores it in an storage, and returns the object
---@param pedModel  number
---@param pedCoords vector4
---@param pedRadius number
---@param pedBucket? number
---@return Ped
function handler.create(pedModel, pedCoords, pedRadius, pedBucket)
    ---@type Ped
    local ped = class.new(CPed, pedModel, pedCoords, pedRadius, pedBucket)

    pedRegistry:addElement(ped)

    return ped
end

---removes the specified instance of the Ped class from the storage, returns if the process was succesful or not
---@param ped Ped | string
---@return boolean
function handler.remove(ped)
    if type(ped) == "string" then
        ped = pedRegistry:getElementByKey(ped)
    end

    if not class.is_object(ped, CPed) then return false end

    ---@cast ped Ped
    pedRegistry:removeElement(ped)

    return true
end

return handler
