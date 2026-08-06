HG.Lobby = HG.Lobby or {}

----------------------------------------------------------
-- Open Lobby
----------------------------------------------------------

function HG.Lobby.Open()

    if HG.Game.State ~= "IDLE" then
        return false
    end

    HG.Game.State = "JOINING"
    HG.Game.Joining = true

    HG.Lobby.Players = {}
    HG.Lobby.EndsAt = os.time() + Config.Game.JoinTime

    HG.Broadcast("hg:lobbyOpened", {
        endTime = HG.Lobby.EndsAt,
        joinTime = Config.Game.JoinTime,
        minPlayers = Config.Game.MinPlayers
    })

    print("^2[HG]^7 Lobby opened.")

    return true

end

----------------------------------------------------------
-- Close Lobby
----------------------------------------------------------

function HG.Lobby.Close()

    HG.Game.Joining = false
    HG.Lobby.EndsAt = 0

    HG.Broadcast("hg:lobbyClosed")

    print("^2[HG]^7 Lobby closed.")

end

----------------------------------------------------------
-- Player Join
----------------------------------------------------------

function HG.Lobby.AddPlayer(source)

    local player = HG.GetPlayer(source)

    if not player then
        return false, "Player not found."
    end

    if not HG.Game.Joining then
        return false, "Lobby is closed."
    end

    if player.Joined then
        return false, "Already joined."
    end

    player.Joined = true
    player.Alive = true

    HG.Lobby.Players[source] = true

    HG.Broadcast(
        "hg:lobbyPlayerList",
        HG.Utils.TableCount(HG.Lobby.Players)
    )

    HG.Notify(source, "~g~Sikeresen csatlakoztál a Hunger Gameshez!")

    print(("[HG] %s joined lobby."):format(GetPlayerName(source)))

    return true

end

----------------------------------------------------------
-- Player Leave
----------------------------------------------------------

function HG.Lobby.RemovePlayer(source)

    local player = HG.GetPlayer(source)

    if not player then
        return
    end

    player.Joined = false
    player.Alive = false

    HG.Lobby.Players[source] = nil

    HG.Broadcast(
        "hg:lobbyPlayerList",
        HG.Utils.TableCount(HG.Lobby.Players)
    )

end

----------------------------------------------------------
-- Joined Players
----------------------------------------------------------

function HG.Lobby.Count()

    return HG.Utils.TableCount(HG.Lobby.Players)

end

----------------------------------------------------------
-- Is Joined
----------------------------------------------------------

function HG.Lobby.IsJoined(source)

    return HG.Lobby.Players[source] == true

end

----------------------------------------------------------
-- Start Command
----------------------------------------------------------

RegisterCommand(Config.Commands.Start, function(source)

    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        return
    end

    if HG.Game.State ~= "IDLE" then

        if source ~= 0 then
            HG.Notify(source, "~r~Már fut egy Hunger Games esemény!")
        end

        return
    end

    HG.Lobby.Open()

end)

----------------------------------------------------------
-- Stop Command
----------------------------------------------------------

RegisterCommand(Config.Commands.Stop, function(source)

    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        return
    end

    HG.Reset()

    HG.Broadcast("hg:eventStopped")

    print("^1[HG]^7 Event stopped.")

end)

----------------------------------------------------------
-- Join Command
----------------------------------------------------------

RegisterCommand(Config.Commands.Join, function(source)

    if source == 0 then
        return
    end

    local ok, reason = HG.Lobby.AddPlayer(source)

    if not ok then
        HG.Notify(source, "~r~"..reason)
    end

end)

----------------------------------------------------------
-- Leave Command
----------------------------------------------------------

RegisterCommand("hgleave", function(source)

    if source == 0 then
        return
    end

    HG.Lobby.RemovePlayer(source)

    HG.Notify(source, "~y~Kiléptél a Hunger Games lobbyból.")

end)

----------------------------------------------------------
-- Disconnect
----------------------------------------------------------

AddEventHandler("playerDropped", function()

    HG.Lobby.RemovePlayer(source)

end)

----------------------------------------------------------
-- Lobby Thread
----------------------------------------------------------

CreateThread(function()

    while true do

        Wait(1000)

        if HG.Game.State ~= "JOINING" then
            goto continue
        end

        local remaining = HG.Lobby.EndsAt - os.time()

        if remaining < 0 then
            remaining = 0
        end

        HG.Broadcast(
            "hg:lobbyCountdown",
            remaining,
            HG.Lobby.Count(),
            Config.Game.MinPlayers
        )

        if remaining == 0 then

            if HG.Lobby.Count() < Config.Game.MinPlayers then

                HG.Broadcast("hg:lobbyNotEnoughPlayers")

                HG.Lobby.Close()

                HG.Game.State = "IDLE"

            else

                HG.Game.State = "STARTING"

                print("^2[HG]^7 Lobby finished.")

                if HG.Event and HG.Event.Start then
                    HG.Event.Start()
                end

            end

        end

        ::continue::

    end

end)