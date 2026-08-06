HG.Spawn = {}

HG.Spawn.Selected = nil
HG.Spawn.Confirmed = false

RegisterNetEvent("hg:showSpawn", function(data)

    print("^2HG: showSpawn event received^7")

    HG.Spawn.Selected = nil
    HG.Spawn.Confirmed = false

    SetNuiFocus(true, true)

    SendNUIMessage({

        action = "showSpawnMap",

        mapImage = "img/cayo_map.jpg",

        timeLeft = data.timeLeft,

        circle = {

            x = 50,
            y = 50,

            rx = 0,
            ry = 0

        },

        villa = {

            x = 44.6,
            y = 56.5,

            w = 8.3,
            h = 12.2

        }

    })

end)

RegisterNUICallback("chooseSpawn", function(data, cb)

    HG.Spawn.Selected = {

        x = data.x,

        y = data.y

    }

    cb({

        ok = true

    })

end)

RegisterNUICallback("confirmSpawn", function(data, cb)

    print("^2[HG] CLIENT confirmSpawn callback^7")

    if not HG.Spawn.Selected then

        cb({

            ok = false,

            reason = "Nincs kiválasztott pont."

        })

        return

    end

    print("^2[HG] Sending hg:confirmSpawn to server^7")

    TriggerServerEvent(

        "hg:confirmSpawn",

        HG.Spawn.Selected.x,

        HG.Spawn.Selected.y

    )

    HG.Spawn.Confirmed = true

    cb({

        ok = true

    })

end)

RegisterNetEvent("hg:spawnConfirmed", function()

    SetNuiFocus(false,false)

    SendNUIMessage({

        action = "hideSpawnMap"

    })

end)

----------------------------------------------------------
-- Spawn Player
----------------------------------------------------------

RegisterNetEvent("hg:spawnPlayer", function(data)

    DoScreenFadeOut(1000)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    local ped = PlayerPedId()

    SetEntityCoords(
        ped,
        data.x,
        data.y,
        data.z,
        false,
        false,
        false,
        false
    )

    FreezeEntityPosition(ped, false)

    SetEntityInvincible(ped, false)

    Wait(500)

    DoScreenFadeIn(1000)

end)

----------------------------------------------------------
-- Spawn Denied
----------------------------------------------------------

RegisterNetEvent("hg:spawnDenied", function(reason)

    SendNUIMessage({

        action = "spawnError",

        text = reason

    })

end)

----------------------------------------------------------
-- Match Started
----------------------------------------------------------

RegisterNetEvent("hg:startMatch", function()

    SendNUIMessage({

        action = "hideSpawnMap"

    })

    SetNuiFocus(false, false)

end)