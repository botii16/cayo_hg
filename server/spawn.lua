HG.Spawn = {}

HG.Spawn.Selected = {}

----------------------------------------------------------
-- Confirm Spawn
----------------------------------------------------------

RegisterNetEvent("hg:confirmSpawn", function(xPct, yPct)

    local src = source

    local player = HG.GetPlayer(src)

    if not player then
        return
    end

    if not player.Joined then
        return
    end

    if type(xPct) ~= "number" or type(yPct) ~= "number" then
        return
    end

    xPct = math.max(0.0, math.min(100.0, xPct))
    yPct = math.max(0.0, math.min(100.0, yPct))

    HG.Spawn.Selected[src] = {

        x = xPct,
        y = yPct

    }

    if not HG.Spawn.SavePlayerSpawn(src) then
    return
end

player.ConfirmedSpawn = true

TriggerClientEvent("hg:spawnConfirmed", src)

HG.Event.CheckReady()

end)

----------------------------------------------------------
-- Percent -> World
----------------------------------------------------------

function HG.Spawn.PercentToWorld(xPct, yPct)

    local min = Config.Map.Bounds.Min
    local max = Config.Map.Bounds.Max

    local worldX = min.x + ((max.x - min.x) * (xPct / 100.0))
    local worldY = min.y + ((max.y - min.y) * (yPct / 100.0))

    return vector3(worldX, worldY, Config.Spawn.RandomHeight)

end

----------------------------------------------------------
-- HQ Check
----------------------------------------------------------

function HG.Spawn.IsInsideHQ(coords)

    if not Config.HQ.Enabled then
        return false
    end

    local min = Config.HQ.Min
    local max = Config.HQ.Max

    return coords.x >= min.x
        and coords.x <= max.x
        and coords.y >= min.y
        and coords.y <= max.y

end

----------------------------------------------------------
-- Save Spawn
----------------------------------------------------------

function HG.Spawn.SavePlayerSpawn(source)

    local player = HG.GetPlayer(source)

    if not player then
        return false
    end

    local selected = HG.Spawn.Selected[source]

    if not selected then
        return false
    end

    local coords = HG.Spawn.PercentToWorld(

        selected.x,

        selected.y

    )

    if HG.Spawn.IsInsideHQ(coords) then

        TriggerClientEvent("hg:spawnDenied", source,

            "Erre a területre nem lehet ugrani."

        )

        player.ConfirmedSpawn = false

        return false

    end

    player.SpawnPosition = coords

    return true

end

----------------------------------------------------------
-- Spawn All Players
----------------------------------------------------------

function HG.Spawn.StartMatch()

    for source in pairs(HG.Lobby.Players) do

        local player = HG.GetPlayer(source)

        if player and player.SpawnPosition then

            TriggerClientEvent("hg:spawnPlayer", source, {

                x = player.SpawnPosition.x,
                y = player.SpawnPosition.y,
                z = player.SpawnPosition.z

            })

            player.Spawned = true

        end

    end

    HG.Game.State = "RUNNING"

    HG.Broadcast("hg:startMatch")

    HG.Utils.Debug("All players spawned.")

end