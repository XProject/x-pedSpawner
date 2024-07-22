<h1 align="center"><b>X-PED SPAWNER (BETA)</b></h1>
<h3 align="center">Dynamic server-side ped spawner for Onesync Infinity spawns peds when a player enters a defined radius and removes them when no players remain within that radius. It supports bucket functionality and is heavily optimized for performance</h3>
<br>

## 2 **server** exports to utilize in external resources

- create

```lua
---creates an instance of the Ped class, stores it in an storage, and returns the ped's unique key
---@param pedModel  number | string
---@param pedCoords vector4
---@param pedRadius number
---@param pedBucket number
---@param clientOnEnterScript? string
---@return string the unique key of the ped instance that was just created
exports["x-pedSpawner"]:create(pedModel, pedCoords, pedRadius, pedBucket, clientOnEnterScript)
```

- remove

```lua
---removes the specified instance of the Ped with the specified key from the storage, returns if the process was successful or not
---@param pedKey string
---@return boolean
exports["x-pedSpawner"]:remove(pedKey)
```

<hr><br>

## Example

```lua
-- SERVER
-- ** anything that is inside clientScript will be executed 1 time for each player on client once they are inside the ped's radius **
local clientScript = [[
    local entityId = %entity -- the actual id of the entity in client will replace automatically with all instances of the %entity

    SetEntityInvincible(entityId, true)
    FreezeEntityPosition(entityId, true)
    SetEntityProofs(entityId, true, true, true, false, true, true, true, true)
    SetPedDiesWhenInjured(entityId, false)
    SetPedFleeAttributes(entityId, 2, true)
    SetPedCanPlayAmbientAnims(entityId, false)
    SetPedCanLosePropsOnDamage(entityId, false, 0)
    SetPedRelationshipGroupHash(entityId, `PLAYER`)
    SetBlockingOfNonTemporaryEvents(entityId, true)
    SetPedCanRagdollFromPlayerImpact(entityId, false)

    local ox_target = exports.ox_target

    if ox_target then
        ox_target:addLocalEntity(entityId, {
            label = "isn't this nice?"
        })
    end
]]

RegisterCommand("addPed", function(source, args)
    local playerPed = GetPlayerPed(source)
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)

    local pedKey = exports["x-pedSpawner"]:create(joaat(args[1] or "a_m_m_eastsa_01"), vector4(playerCoords.x, playerCoords.y, playerCoords.z, playerHeading), 10.0, GetPlayerRoutingBucket(source), clientScript)
    print(("Created a ped with the unique key of %s"):format(pedKey))
end, false)

RegisterCommand("removePed", function(source, args)
    local pedKey = args[1]
    local result = exports["x-pedSpawner"]:remove(pedKey)

    print(("%s the ped with the unique key of %s"):format(result and "Removed" or "Could not remove", pedKey))
end, false)
```
