HG.Event = {}

----------------------------------------------------------
-- Start Event
----------------------------------------------------------

function HG.Event.Start()

    if HG.Game.State ~= "STARTING" then
        return
    end

    HG.Game.Active = true
    HG.Game.Joining = false
    HG.Game.Starting = true
    HG.Game.StartedAt = os.time()

    HG.Lobby.Close()

    HG.Utils.Debug("Event started.")

    HG.Circle.Create()

    for source in pairs(HG.Lobby.Players) do

        local player = HG.GetPlayer(source)

        if player then

            player.Alive = true
            player.Spawned = false
            player.ConfirmedSpawn = false
            player.SpawnPosition = nil

            TriggerClientEvent("hg:showSpawn", source, {
                timeLeft = Config.Game.SpawnSelectionTime
            })

        end

    end

end

----------------------------------------------------------
-- Stop Event
----------------------------------------------------------

function HG.Event.Stop()

    if not HG.Game.Active then
        return
    end

    HG.Utils.Debug("Stopping event.")

    for source in pairs(HG.Lobby.Players) do

        local player = HG.GetPlayer(source)

        if player then

            player.Joined = false
            player.Alive = false
            player.Spawned = false
            player.ConfirmedSpawn = false
            player.SpawnPosition = nil

            TriggerClientEvent(
                "hg:eventFinished",
                source
            )

        end

    end

    HG.Reset()

end

----------------------------------------------------------
-- Spawn Selected
----------------------------------------------------------

-- RegisterNetEvent("hg:spawnSelected", function(position)

--     local source = source

--     local player = HG.GetPlayer(source)

--     if not player then
--         return
--     end

--     if not player.Joined then
--         return
--     end

--     if type(position) ~= "table" then
--         return
--     end

--     player.SpawnPosition = vector3(
--         position.x,
--         position.y,
--         position.z
--     )

--     player.ConfirmedSpawn = false

-- end)

-- ----------------------------------------------------------
-- -- Spawn Confirmed
-- ----------------------------------------------------------

-- RegisterNetEvent("hg:spawnConfirmed", function()

--     local source = source

--     local player = HG.GetPlayer(source)

--     if not player then
--         return
--     end

--     if not player.Joined then
--         return
--     end

--     if not player.SpawnPosition then

--         HG.Notify(source, "~r~Először válassz spawn pontot!")

--         return

--     end

--     player.ConfirmedSpawn = true

--     HG.Notify(source, "~g~Spawn pont megerősítve!")

--     HG.Event.CheckReady()

-- end)

----------------------------------------------------------
-- Check Ready
----------------------------------------------------------

function HG.Event.CheckReady()

    local joined = 0
    local ready = 0

    for source in pairs(HG.Lobby.Players) do

        local player = HG.GetPlayer(source)

        if player then

            joined = joined + 1

            if player.ConfirmedSpawn then
                ready = ready + 1
            end

        end

    end


    if joined > 0 and ready == joined then


        HG.Event.StartCountdown()

    end

end

----------------------------------------------------------
-- Start Countdown
----------------------------------------------------------

function HG.Event.StartCountdown()


    if HG.Game.State == "COUNTDOWN" then
        return
    end

    HG.Game.State = "COUNTDOWN"

    CreateThread(function()

        for i = 3, 1, -1 do

            HG.Broadcast(
                "hg:countdown",
                i
            )

            Wait(1000)

        end

        HG.Broadcast("hg:countdown", "GO!")

        Wait(1500)

        HG.Spawn.StartMatch()

    end)

end