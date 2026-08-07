HG = HG or {}

HG.Circle = HG.Circle or {}

HG.Circle.Step = 6

HG.Circle.PillarHeight = 12.0

HG.Circle.PillarSize = 1.2

----------------------------------------------------------
-- Circle State
----------------------------------------------------------

HG.Circle.WaitStart = 0
HG.Circle.WaitDuration = 0

HG.Circle.State = "WAIT"

HG.Circle.Data = nil

HG.Circle.FromRadius = 0.0
HG.Circle.ToRadius = 0.0

HG.Circle.StartTime = 0
HG.Circle.Duration = 0

HG.Circle.IsShrinking = false

HG.Circle.Blip = nil

HG.Circle.Enabled = false

HG.Circle.RenderDistance = 180.0

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

    if HG.Circle.IsShrinking then

        local progress = (GetGameTimer() - HG.Circle.StartTime) / HG.Circle.Duration

        progress = math.min(progress, 1.0)

        HG.Circle.Data.radius =
            HG.Circle.FromRadius +
            (HG.Circle.ToRadius - HG.Circle.FromRadius) * progress

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

    HG.Circle.FromRadius = data.radius
    HG.Circle.ToRadius = data.radius

end)

RegisterNetEvent("hg:circleWait", function(data)

    HG.Circle.State = "WAIT"

    HG.Circle.IsShrinking = false

    HG.Circle.WaitStart = GetGameTimer()
    HG.Circle.WaitDuration = data.duration * 1000

    HG.Circle.Data.phase = data.phase

end)

RegisterNetEvent("hg:circleShrink", function(data)

    HG.Circle.State = "SHRINK"

    HG.Circle.IsShrinking = true

    HG.Circle.FromRadius = data.fromRadius
    HG.Circle.ToRadius = data.toRadius

    HG.Circle.StartTime = GetGameTimer()
    HG.Circle.Duration = data.duration * 1000

    HG.Circle.Data.phase = data.phase

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

----------------------------------------------------------
-- Update Radius Blip
----------------------------------------------------------

CreateThread(function()

    while true do

        Wait(250)

        if HG.Circle.Blip and HG.Circle.Data then

            RemoveBlip(HG.Circle.Blip)

            HG.Circle.Blip = AddBlipForRadius(

                HG.Circle.Data.x,
                HG.Circle.Data.y,
                0.0,
                HG.Circle.Data.radius

            )

            SetBlipColour(HG.Circle.Blip, 2)
            SetBlipAlpha(HG.Circle.Blip, 100)

        end

    end

end)