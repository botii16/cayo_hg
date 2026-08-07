HG = HG or {}

HG.HUD = {}

----------------------------------------------------------
-- HUD State
----------------------------------------------------------

HG.HUD.Visible = false

HG.HUD.Alive = 0
HG.HUD.Kills = 0

----------------------------------------------------------
-- Show HUD
----------------------------------------------------------

function HG.HUD.Show()

    if HG.HUD.Visible then
        return
    end

    HG.HUD.Visible = true

    SendNUIMessage({

        action = "showHUD"

    })

end

----------------------------------------------------------
-- Hide HUD
----------------------------------------------------------

function HG.HUD.Hide()

    if not HG.HUD.Visible then
        return
    end

    HG.HUD.Visible = false

    SendNUIMessage({

        action = "hideHUD"

    })

end

----------------------------------------------------------
-- Update HUD
----------------------------------------------------------

function HG.HUD.Update()

    SendNUIMessage({

        action = "updateHUD",

        alive = HG.HUD.Alive,

        kills = HG.HUD.Kills

    })

end

----------------------------------------------------------
-- Match Started
----------------------------------------------------------

RegisterNetEvent("hg:startMatch", function()

    HG.HUD.Alive = 1
    HG.HUD.Kills = 0

    HG.HUD.Show()
    HG.HUD.Update()

end)

----------------------------------------------------------
-- Match Finished
----------------------------------------------------------

RegisterNetEvent("hg:eventFinished", function()

    HG.HUD.Hide()

end)

----------------------------------------------------------
-- Update Alive
----------------------------------------------------------

RegisterNetEvent("hg:updateAlive", function(alive)

    HG.HUD.Alive = alive

    HG.HUD.Update()

end)

----------------------------------------------------------
-- Update Kills
----------------------------------------------------------

RegisterNetEvent("hg:updateKills", function(kills)

    HG.HUD.Kills = kills

    HG.HUD.Update()

end)

----------------------------------------------------------
-- Match Countdown
----------------------------------------------------------

RegisterNetEvent("hg:countdown", function(value)

    if value == "GO!" then

        SendNUIMessage({

            action = "fight"

        })

        CreateThread(function()

            Wait(1000)

            SendNUIMessage({

                action = "hideCountdown"

            })

        end)

        return

    end

    SendNUIMessage({

        action = "showCountdown",

        value = value

    })

end)

CreateThread(function()

    while true do

        Wait(200)

        if not HG.Circle.Data then
            goto continue
        end

        local remaining = 0

        if HG.Circle.State == "WAIT" then

            remaining = math.max(
                0,
                HG.Circle.WaitDuration - (GetGameTimer() - HG.Circle.WaitStart)
            )

        elseif HG.Circle.State == "SHRINK" then

            remaining = math.max(
                0,
                HG.Circle.Duration - (GetGameTimer() - HG.Circle.StartTime)
            )

        end

        local minutes = math.floor(remaining / 1000 / 60)
        local seconds = math.floor((remaining / 1000) % 60)

        SendNUIMessage({

            action = "updateHUD",

            zoneTimer = string.format("%02d:%02d", minutes, seconds),

            phase = string.format(
                "%d / %d",
                HG.Circle.Data.phase,
                #Config.Circle.Stages
            )

        })

        ::continue::

    end

end)