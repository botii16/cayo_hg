HG = HG or {}

HG.Client = {}

----------------------------------------------------------
-- Player State
----------------------------------------------------------

HG.Client.InEvent = false
HG.Client.InLobby = false
HG.Client.SpawnOpen = false

----------------------------------------------------------
-- Helpers
----------------------------------------------------------

local function OpenLobby(data)

    SetNuiFocus(true, true)

    SendNUIMessage({

        action = "showLobby",

        players = data.players or {},

        joined = data.joined or false,

        minPlayers = data.minPlayers,

        onlinePlayers = data.onlinePlayers

    })

    HG.Client.InLobby = true

end

----------------------------------------------------------

local function CloseLobby()

    SetNuiFocus(false, false)

    SendNUIMessage({

        action = "hideLobby"

    })

    HG.Client.InLobby = false

end

----------------------------------------------------------

local function OpenSpawnSelection()

    SetNuiFocus(true, true)

    HG.Client.SpawnOpen = true

end

----------------------------------------------------------

local function CloseSpawnSelection()

    SetNuiFocus(false, false)

    HG.Client.SpawnOpen = false

end

----------------------------------------------------------
-- Lobby Open
----------------------------------------------------------

RegisterNetEvent("hg:lobbyOpened", function(data)

    HG.Client.InEvent = true
    OpenLobby(data)

end)

----------------------------------------------------------
-- Lobby Close
----------------------------------------------------------

RegisterNetEvent("hg:lobbyClosed", function()

    CloseLobby()

end)

----------------------------------------------------------
-- Lobby Countdown
----------------------------------------------------------

RegisterNetEvent("hg:lobbyCountdown", function(timeLeft, players, minPlayers)

    SendNUIMessage({

        action = "lobbyTimer",

        timeLeft = timeLeft

    })

end)

----------------------------------------------------------
-- Lobby Player List
----------------------------------------------------------

RegisterNetEvent("hg:lobbyPlayers", function(players, onlinePlayers, minPlayers)

    SendNUIMessage({

        action = "lobbyPlayers",

        players = players,

        onlinePlayers = onlinePlayers,

        joined = HG.Client.InEvent,

        minPlayers = minPlayers

    })

end)

----------------------------------------------------------
-- Spawn Selection
----------------------------------------------------------

RegisterNetEvent("hg:showSpawnLoading", function()

    OpenSpawnSelection()

    SendNUIMessage({

        action = "showSpawnLoading",

        text = "Töltés..."

    })

end)
----------------------------------------------------------

RegisterNetEvent("hg:startMatch", function()

    CloseSpawnSelection()

    SendNUIMessage({

        action = "hideSpawnMap"

    })

end)

----------------------------------------------------------

RegisterNetEvent("hg:eventFinished", function()

    CloseLobby()

    CloseSpawnSelection()

    HG.Client.InEvent = false

end)

----------------------------------------------------------
-- NUI Callbacks
----------------------------------------------------------

RegisterNUICallback("joinEvent", function(data, cb)

    TriggerServerEvent("hg:lobbyJoin")

    cb({
        ok = true
    })

end)

---------------------------------------------------------

RegisterNetEvent("hg:lobbyJoined", function()

    HG.Client.InEvent = true

    SendNUIMessage({

        action = "joined"

    })

end)

----------------------------------------------------------

RegisterNUICallback("chooseSpawn", function(data, cb)

    if not HG.Client.SpawnOpen then

        cb({
            ok = false,
            reason = "Spawn kiválasztás nincs megnyitva."
        })

        return

    end

    local worldX, worldY = HG.Utils.PercentToWorld(
        data.x / 100.0,
        data.y / 100.0
    )

    TriggerServerEvent("hg:spawnSelected", {

        x = worldX,

        y = worldY,

        z = Config.PlayArea.Center.z

    })

    cb({
        ok = true
    })

end)

----------------------------------------------------------

RegisterNUICallback("confirmSpawn", function(data, cb)

    TriggerServerEvent("hg:spawnConfirmed")

    cb({
        ok = true
    })

end)

----------------------------------------------------------

RegisterNUICallback("closeLobby", function(data, cb)

    SetNuiFocus(false, false)

    cb({
        ok = true
    })

end)

----------------------------------------------------------
-- Notify
----------------------------------------------------------

RegisterNetEvent("hg:notify", function(message)

    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)

end)

----------------------------------------------------------
-- Resource Start
----------------------------------------------------------

CreateThread(function()

    SetNuiFocus(false, false)

    SendNUIMessage({

        action = "hideLobby"

    })

    SendNUIMessage({

        action = "hideSpawnMap"

    })

end)

----------------------------------------------------------
-- Teleport
----------------------------------------------------------

RegisterNetEvent("hg:teleport", function(coords)

    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    local ped = PlayerPedId()

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)

    SetEntityCoordsNoOffset(
        ped,
        coords.x,
        coords.y,
        coords.z,
        false,
        false,
        false
    )

    Wait(1000)

    DoScreenFadeIn(500)

end)

----------------------------------------------------------
-- Freeze
----------------------------------------------------------

RegisterNetEvent("hg:freeze", function(state)

    local ped = PlayerPedId()

    FreezeEntityPosition(ped, state)

    SetPlayerControl(PlayerId(), not state, 0)

end)

----------------------------------------------------------
-- HG Invite
----------------------------------------------------------

RegisterNetEvent("hg:invite", function(data)

    SetNuiFocus(true, true)

    SendNUIMessage({

        action = "showInvite",

        joinTime = data.joinTime,

        minPlayers = data.minPlayers

    })

end)

----------------------------------------------------------
-- Open Lobby
----------------------------------------------------------

RegisterNetEvent("hg:openLobby", function(data)

    SetNuiFocus(true, true)

    SendNUIMessage({

        action = "showLobby",

        joined = false,

        players = {},

        joinedPlayers = 0,

        onlinePlayers = #GetActivePlayers(),

        minPlayers = data.minPlayers,

        timeLeft = data.joinTime

    })

end)

----------------------------------------------------------
-- Update Lobby
----------------------------------------------------------

RegisterNetEvent("hg:updateLobby", function(data)

    SendNUIMessage({

        action = "updateLobby",

        players = data.players,

        joinedPlayers = data.joinedPlayers,

        onlinePlayers = data.onlinePlayers,

        minPlayers = data.minPlayers,

        timeLeft = data.timeLeft

    })

end)

----------------------------------------------------------
-- Joined
----------------------------------------------------------

RegisterNetEvent("hg:lobbyJoined", function()

    SendNUIMessage({

        action = "joined"

    })

end)

----------------------------------------------------------
-- Close Lobby
----------------------------------------------------------

RegisterNetEvent("hg:lobbyClosed", function()

    SetNuiFocus(false, false)

    SendNUIMessage({

        action = "hideLobby"

    })

end)

----------------------------------------------------------
-- Accept Invite
----------------------------------------------------------

RegisterNUICallback("acceptInvite", function(data, cb)

    TriggerServerEvent("hg:acceptInvite")

    cb({
        ok = true
    })

end)

----------------------------------------------------------
-- Decline Invite
----------------------------------------------------------

RegisterNUICallback("declineInvite", function(data, cb)

    cb({ ok = true })

end)