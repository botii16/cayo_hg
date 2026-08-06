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