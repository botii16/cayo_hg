HG = HG or {}

----------------------------------------------------------
-- Resource Info
----------------------------------------------------------

HG.Version = "2.6.0"

HG.Name = "Droxen Hunger Games"

----------------------------------------------------------
-- Game State
----------------------------------------------------------

HG.Game = {

    State = "IDLE",

    Active = false,

    Joining = false,

    Starting = false,

    Ending = false,

    Timer = 0,

    Winner = nil,

    StartedAt = 0

}

----------------------------------------------------------
-- Lobby State
----------------------------------------------------------

HG.Lobby = {

    Players = {},

    ReadyPlayers = {},

    EndsAt = 0

}

----------------------------------------------------------
-- Circle State
----------------------------------------------------------

HG.Circle = {

    Stage = 0,

    Waiting = true,

    Shrinking = false,

    StartedShrink = 0,

    EndsShrink = 0,

    Center = Config.PlayArea.Center,

    Radius = Config.Circle.StartRadius,

    TargetCenter = Config.PlayArea.Center,

    TargetRadius = Config.Circle.StartRadius

}

----------------------------------------------------------
-- Loot State
----------------------------------------------------------

HG.Loot = {

    Tier = 1,

    LastUpgrade = 0,

    LastEpicDrop = 0

}

----------------------------------------------------------
-- Player State
----------------------------------------------------------

HG.Players = {}

----------------------------------------------------------
-- Helper
----------------------------------------------------------

function HG.GetPlayer(source)

    return HG.Players[source]

end

----------------------------------------------------------

function HG.IsPlayerAlive(source)

    local player = HG.Players[source]

    if not player then

        return false

    end

    return player.Alive

end

----------------------------------------------------------

function HG.GetAlivePlayers()

    local count = 0

    for _, player in pairs(HG.Players) do

        if player.Alive then

            count = count + 1

        end

    end

    return count

end

----------------------------------------------------------

function HG.ForEachAlive(cb)

    for src, player in pairs(HG.Players) do

        if player.Alive then

            cb(src, player)

        end

    end

end

----------------------------------------------------------

function HG.Broadcast(eventName, ...)

    TriggerClientEvent(eventName, -1, ...)

end

----------------------------------------------------------

function HG.Notify(source, msg)

    -- Később saját NUI notify lesz.

end

----------------------------------------------------------
-- Reset
----------------------------------------------------------

function HG.Reset()

    HG.Game.Active = false
    HG.Game.Joining = false
    HG.Game.Starting = false
    HG.Game.Ending = false

    HG.Game.Timer = 0

    HG.Game.Winner = nil

    HG.Circle.Stage = 0

    HG.Circle.Waiting = true
    HG.Circle.Shrinking = false

    HG.Circle.Center = Config.PlayArea.Center
    HG.Circle.TargetCenter = Config.PlayArea.Center

    HG.Circle.Radius = Config.Circle.StartRadius
    HG.Circle.TargetRadius = Config.Circle.StartRadius

    HG.Lobby.Players = {}

    HG.Loot.Tier = 1

    HG.Loot.LastUpgrade = 0
    HG.Loot.LastEpicDrop = 0

    HG.Players = {}

end

----------------------------------------------------------
-- Resource
----------------------------------------------------------

AddEventHandler("onResourceStart", function(resource)

    if resource ~= GetCurrentResourceName() then

        return

    end

    HG.Reset()

    for _, playerId in ipairs(GetPlayers()) do

    local src = tonumber(playerId)

    HG.Players[src] = {

        Source = src,

        Name = GetPlayerName(src),

        Alive = false,

        Joined = false,

        Spawned = false,

        Protected = false,

        ConfirmedSpawn = false,

        SpawnPosition = nil,

        LastPosition = nil,

        Kills = 0,

        Deaths = 0,

        Placement = 0

    }

end

    print(("^2[%s]^7 loaded."):format(HG.Name))

end)

----------------------------------------------------------

AddEventHandler("onResourceStop", function(resource)

    if resource ~= GetCurrentResourceName() then

        return

    end

    HG.Reset()

end)

----------------------------------------------------------
-- Player Join
----------------------------------------------------------

AddEventHandler("playerJoining", function()

    local src = source

    HG.Players[src] = {

    Source = src,

    Alive = false,

    Joined = false,

    Spawned = false,

    Protected = false,

    ConfirmedSpawn = false,

    SpawnPosition = nil,

    LastPosition = nil,

    Kills = 0,

    Deaths = 0,

    Placement = 0

}

end)

----------------------------------------------------------
-- Player Leave
----------------------------------------------------------

AddEventHandler("playerDropped", function()

    local src = source

    HG.Players[src] = nil

end)

----------------------------------------------------------
-- Thread
----------------------------------------------------------

CreateThread(function()

    while true do

        Wait(1000)

        if HG.Game.Active then

            HG.Game.Timer = HG.Game.Timer + 1

        end

    end

end)