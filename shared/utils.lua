HG = HG or {}
HG.Utils = {}

----------------------------------------------------------
-- Clamp
----------------------------------------------------------

function HG.Utils.Clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end

    if value > maxValue then
        return maxValue
    end

    return value
end

----------------------------------------------------------
-- Linear interpolation
----------------------------------------------------------

function HG.Utils.Lerp(a, b, t)
    return a + (b - a) * t
end

----------------------------------------------------------
-- Random float
----------------------------------------------------------

function HG.Utils.RandomFloat(min, max)
    return min + math.random() * (max - min)
end

----------------------------------------------------------
-- Normalize Vector2 Bounds
----------------------------------------------------------

function HG.Utils.Normalize2D(minVec, maxVec)

    return
        vector2(
            math.min(minVec.x, maxVec.x),
            math.min(minVec.y, maxVec.y)
        ),
        vector2(
            math.max(minVec.x, maxVec.x),
            math.max(minVec.y, maxVec.y)
        )

end

----------------------------------------------------------
-- Normalize Vector3 Bounds
----------------------------------------------------------

function HG.Utils.Normalize3D(minVec, maxVec)

    return
        vector3(
            math.min(minVec.x, maxVec.x),
            math.min(minVec.y, maxVec.y),
            math.min(minVec.z, maxVec.z)
        ),
        vector3(
            math.max(minVec.x, maxVec.x),
            math.max(minVec.y, maxVec.y),
            math.max(minVec.z, maxVec.z)
        )

end

----------------------------------------------------------
-- Distance 2D
----------------------------------------------------------

function HG.Utils.Distance2D(a, b)

    return #(
        vector2(a.x, a.y) -
        vector2(b.x, b.y)
    )

end

----------------------------------------------------------
-- Distance Squared
----------------------------------------------------------

function HG.Utils.Distance2DSquared(a, b)

    local dx = a.x - b.x
    local dy = a.y - b.y

    return (dx * dx) + (dy * dy)

end

----------------------------------------------------------
-- Is point inside radius
----------------------------------------------------------

function HG.Utils.IsInsideRadius(point, center, radius)

    return HG.Utils.Distance2D(point, center) <= radius

end

----------------------------------------------------------
-- Random point inside circle
----------------------------------------------------------

function HG.Utils.RandomPointInCircle(center, radius)

    local angle = HG.Utils.RandomFloat(0.0, math.pi * 2.0)

    local distance = math.sqrt(math.random()) * radius

    return vector3(

        center.x + math.cos(angle) * distance,

        center.y + math.sin(angle) * distance,

        center.z

    )

end

----------------------------------------------------------
-- Map World -> Percent
----------------------------------------------------------

function HG.Utils.WorldToPercent(x, y)

    local tl = Config.Map.Bounds.Min
    local br = Config.Map.Bounds.Max

    local px = (x - tl.x) / (br.x - tl.x)
    local py = (y - tl.y) / (br.y - tl.y)

    return px, py

end

----------------------------------------------------------
-- Percent -> World
----------------------------------------------------------

function HG.Utils.PercentToWorld(px, py)

    local tl = Config.MapBounds.min
    local br = Config.MapBounds.max

    local worldX = tl.x + px * (br.x - tl.x)
    local worldY = tl.y + py * (br.y - tl.y)

    return worldX, worldY

end

----------------------------------------------------------
-- Random Heading
----------------------------------------------------------

function HG.Utils.RandomHeading()

    return HG.Utils.RandomFloat(0.0, 360.0)

end

----------------------------------------------------------
-- Debug
----------------------------------------------------------

function HG.Utils.Debug(...)

    if not Config.Debug then
        return
    end

    print("^3[HG]^7", ...)

end

----------------------------------------------------------
-- Round
----------------------------------------------------------

function HG.Utils.Round(value)

    return math.floor(value + 0.5)

end

----------------------------------------------------------
-- Table Count
----------------------------------------------------------

function HG.Utils.TableCount(tbl)

    local c = 0

    for _ in pairs(tbl) do
        c = c + 1
    end

    return c

end

----------------------------------------------------------
-- Deep Copy
----------------------------------------------------------

function HG.Utils.DeepCopy(tbl)

    local copy = {}

    for k, v in pairs(tbl) do

        if type(v) == "table" then
            copy[k] = HG.Utils.DeepCopy(v)
        else
            copy[k] = v
        end

    end

    return copy

end

----------------------------------------------------------
-- Shuffle
----------------------------------------------------------

function HG.Utils.Shuffle(tbl)

    for i = #tbl, 2, -1 do

        local j = math.random(i)

        tbl[i], tbl[j] = tbl[j], tbl[i]

    end

end

----------------------------------------------------------
-- Random Table Item
----------------------------------------------------------

function HG.Utils.RandomItem(tbl)

    if #tbl == 0 then
        return nil
    end

    return tbl[math.random(#tbl)]

end