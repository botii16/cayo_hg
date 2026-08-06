HG = HG or {}
HG.Zones = {}

HG.Zones.PlayArea = {

    Center = Config.PlayArea.Center,

    Radius = Config.PlayArea.Radius

}

----------------------------------------------------------
-- BLACKLIST LISTA
----------------------------------------------------------

HG.Zones.Restricted = {

    {

        Name = "HQ",

        Type = "rectangle",

        Min = Config.HQ.Min,

        Max = Config.HQ.Max,

        PushBack = Config.HQ.PushBack

    }

}

----------------------------------------------------------
-- BLACKLISTEK
----------------------------------------------------------

HG.Zones.NoLoot = {

    "HQ"

}

HG.Zones.NoSupplyDrop = {

    "HQ"

}

HG.Zones.NoSpawn = {

    "HQ"

}


HG.Zones.NoCircle = {

    "HQ"

}