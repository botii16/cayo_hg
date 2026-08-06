HG.Player = {}

----------------------------------------------------------
-- Save Position
----------------------------------------------------------

function HG.Player.SavePosition(source)

    local player = HG.GetPlayer(source)

    if not player then
        return false
    end

    local ped = GetPlayerPed(source)

    if ped == 0 then
        return false
    end

    player.LastPosition = GetEntityCoords(ped)

    return true

end

----------------------------------------------------------
-- Restore Position
----------------------------------------------------------

function HG.Player.RestorePosition(source)

    local player = HG.GetPlayer(source)

    if not player then
        return
    end

    if not player.LastPosition then
        return
    end

    TriggerClientEvent(
        "hg:teleport",
        source,
        player.LastPosition
    )

end

----------------------------------------------------------
-- Teleport Lobby
----------------------------------------------------------

function HG.Player.TeleportLobby(source)

    TriggerClientEvent(
        "hg:teleport",
        source,
        Config.Lobby.Position
    )

end

----------------------------------------------------------
-- Freeze
----------------------------------------------------------

function HG.Player.Freeze(source)

    TriggerClientEvent(
        "hg:freeze",
        source,
        true
    )

end

----------------------------------------------------------
-- Unfreeze
----------------------------------------------------------

function HG.Player.Unfreeze(source)

    TriggerClientEvent(
        "hg:freeze",
        source,
        false
    )

end

----------------------------------------------------------
-- Join HG
----------------------------------------------------------

function HG.Player.Join(source)

    local player = HG.GetPlayer(source)

    if not player then
        return false
    end

    HG.Player.SavePosition(source)

    HG.Player.TeleportLobby(source)

    HG.Player.Freeze(source)

    player.Joined = true

    return true

end

----------------------------------------------------------
-- Leave HG
----------------------------------------------------------

function HG.Player.Leave(source)

    local player = HG.GetPlayer(source)

    if not player then
        return
    end

    player.Joined = false
    player.Alive = false

    HG.Player.Unfreeze(source)

    HG.Player.RestorePosition(source)

end