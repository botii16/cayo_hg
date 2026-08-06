HG = HG or {}

HG.Circle = HG.Circle or {}

HG.Circle.Step = 6

HG.Circle.PillarHeight = 12.0

HG.Circle.PillarSize = 1.2

----------------------------------------------------------
-- Circle State
----------------------------------------------------------

HG.Circle.Data = nil

HG.Circle.Blip = nil

HG.Circle.Enabled = false

HG.Circle.RenderDistance = 180.0

HG.Circle.Step = 8

HG.Circle.PillarHeight = 8.0

HG.Circle.PillarSize = 0.8

----------------------------------------------------------
-- Set Circle
----------------------------------------------------------

function HG.Circle.Set(data)

    HG.Circle.Data = data

    HG.Circle.Enabled = true

end

----------------------------------------------------------
-- Clear Circle
----------------------------------------------------------

function HG.Circle.Clear()

    HG.Circle.Enabled = false

    HG.Circle.Data = nil

    if HG.Circle.Blip then

        RemoveBlip(HG.Circle.Blip)

        HG.Circle.Blip = nil

    end

end

----------------------------------------------------------
-- Draw Pillar
----------------------------------------------------------

function HG.Circle.DrawPillar(x, y, z)

    local alpha = 140 + math.floor(math.sin(GetGameTimer() / 250) * 60)
    local height = HG.Circle.PillarHeight + math.sin(GetGameTimer() / 350) * 3.5

    local red = 255
    local green = 25 + math.floor(math.sin(GetGameTimer() / 450) * 10)
    local blue = 25

    DrawMarker(28, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, HG.Circle.PillarSize, HG.Circle.PillarSize, height, red, green, blue, alpha, false, false, 2, false, nil, nil, false)

end

----------------------------------------------------------
-- Render Circle
----------------------------------------------------------

function HG.Circle.Render()

    if not HG.Circle.Data then
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local dist = #(coords - vector3(
        HG.Circle.Data.x,
        HG.Circle.Data.y,
        coords.z
    ))

    local boundaryDistance = math.abs(
        dist - HG.Circle.Data.radius
    )

    if boundaryDistance > HG.Circle.RenderDistance then
        return
    end

    local center = vector3(

        HG.Circle.Data.x,
        HG.Circle.Data.y,
        30.0

    )

    local radius = HG.Circle.Data.radius

    for angle = 0, 360, HG.Circle.Step do

        local rad = math.rad(angle)

        local x = center.x + math.cos(rad) * radius
        local y = center.y + math.sin(rad) * radius

        HG.Circle.DrawPillar(
            x,
            y,
            center.z
        )
        local x2 = center.x + math.cos(rad) * (radius - 2.5)
        local y2 = center.y + math.sin(rad) * (radius - 2.5)

        HG.Circle.DrawPillar(
            x2,
            y2,
            center.z - 18.0
        )

    end

end

RegisterNetEvent("hg:createCircle", function(data)

    HG.Circle.Set(data)

    if HG.Circle.Blip then
        RemoveBlip(HG.Circle.Blip)
    end

    HG.Circle.Blip = AddBlipForRadius(
        data.x,
        data.y,
        0.0,
        data.radius
    )

    SetBlipColour(HG.Circle.Blip, 2)
    SetBlipAlpha(HG.Circle.Blip, 100)

end)

----------------------------------------------------------
-- Circle Thread
----------------------------------------------------------

CreateThread(function()

    while true do

        local sleep = 500

        if HG.Circle.Enabled then

            sleep = 5

            HG.Circle.Render()

        end

        Wait(sleep)

    end

end)