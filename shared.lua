---@class shared
local shared        = {}

shared.eventPrefix  = ("__%s__event"):format(cache.resource)

shared.stateBagName = ("__%s__statebag"):format(cache.resource)

return shared
