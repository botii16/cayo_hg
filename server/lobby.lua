HG.Lobby = {}

HG.Lobby.Players = {}
HG.Lobby.Invited = false
HG.Lobby.EndTime = 0

----------------------------------------------------------
-- Open Lobby
----------------------------------------------------------

function HG.Lobby.Open()

    if HG.Game.State ~= "IDLE" then
        return false
    end

    HG.Game.State = "JOINING"
    HG.Game.Joining = true

    HG.Lobby.Invited = true
    HG.Lobby.Players = {}
    HG.Lobby.EndTime = os.time() + Config.Game.JoinTime

    TriggerClientEvent("hg:invite", -1, {
        joinTime = Config.Game.JoinTime,
        minPlayers = Config.Game.MinPlayers
    })

    HG.Utils.Debug("Lobby opened.")

    return true

end

----------------------------------------------------------
-- Close Lobby
----------------------------------------------------------

function HG.Lobby.Close()

    HG.Game.Joining = false
    HG.Game.State = "IDLE"

    HG.Lobby.Invited = false
    HG.Lobby.EndTime = 0

    TriggerClientEvent("hg:lobbyClosed", -1)

    HG.Utils.Debug("Lobby closed.")

end

----------------------------------------------------------
-- Accept Invite
----------------------------------------------------------

RegisterNetEvent("hg:acceptInvite", function()

    local src = source

    if not HG.Lobby.Invited then
        return
    end

    local player = HG.GetPlayer(src)

    if not player then
        return
    end

    if player.Joined then
        return
    end

    HG.Player.Join(src)

    TriggerClientEvent("hg:openLobby", src, {
        joinTime = Config.Game.JoinTime,
        minPlayers = Config.Game.MinPlayers
    })

end)

----------------------------------------------------------
-- Join Match
----------------------------------------------------------

RegisterNetEvent("hg:lobbyJoin", function()

    local src = source

    if not HG.Game.Joining then
        return
    end

    local player = HG.GetPlayer(src)

    if not player then
        return
    end

    if player.Joined then
        return
    end

    player.Joined = true
    player.Alive = true

    HG.Lobby.Players[src] = true

    HG.Lobby.Sync()

    TriggerClientEvent("hg:lobbyJoined", src)

end)

----------------------------------------------------------
-- Leave Match
----------------------------------------------------------

RegisterNetEvent("hg:lobbyLeave", function()

    local src = source

    local player = HG.GetPlayer(src)

    if not player then
        return
    end

    player.Joined = false
    player.Alive = false

    HG.Lobby.Players[src] = nil

    HG.Player.Leave(src)

    HG.Lobby.Sync()

    TriggerClientEvent("hg:lobbyClosed", src)

end)

----------------------------------------------------------
-- Lobby Sync
----------------------------------------------------------

function HG.Lobby.Sync()

    local list = {}

    for src in pairs(HG.Lobby.Players) do

        table.insert(list, {
            id = src,
            name = GetPlayerName(src)
        })

    end

    TriggerClientEvent("hg:updateLobby", -1, {

        players = list,

        joinedPlayers = #list,

        onlinePlayers = #GetPlayers(),

        minPlayers = Config.Game.MinPlayers,

        timeLeft = math.max(0, HG.Lobby.EndTime - os.time())

    })

end

----------------------------------------------------------
-- Countdown Thread
----------------------------------------------------------

CreateThread(function()

    while true do

        Wait(1000)

        if not HG.Game.Joining then
            goto continue
        end

        HG.Lobby.Sync()

        if os.time() >= HG.Lobby.EndTime then

            if HG.Utils.TableCount(HG.Lobby.Players) < Config.Game.MinPlayers then

                TriggerClientEvent("hg:notEnoughPlayers", -1)

                HG.Lobby.Close()

            else

                HG.Game.State = "STARTING"

                HG.Game.Joining = false

                HG.Event.Start()

            end

        end

        ::continue::

    end

end)

----------------------------------------------------------
-- Commands
----------------------------------------------------------

RegisterCommand(Config.Commands.Start, function(source)

    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        return
    end

    HG.Lobby.Open()

end)

RegisterCommand(Config.Commands.Stop, function(source)

    if source ~= 0 and not IsPlayerAceAllowed(source, Config.AdminAce) then
        return
    end

    HG.Event.Stop()

end)