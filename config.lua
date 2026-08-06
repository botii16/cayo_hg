Config = {}


Config.Debug = false

Config.Commands = {

    Start = "hgstart",
    Stop = "hgstop",
    Join = "hgjoin"

}

Config.AdminAce = "hg"


Config.Game = {

    MinPlayers = 1,
    JoinTime = 10,
    SpawnSelectionTime = 20,
    LootPhase = 300,
    LootUpgradeTime = 120,
    AutoEnd = true

}


Config.Circle = {

    Damage = 5,

    TickRate = 1000,

    RenderDistance = 180.0,

    StartRadius = 1050.0,

    Stages = {

        {
            Wait = 120,
            Shrink = 90,
            Radius = 800.0
        },

        {
            Wait = 90,
            Shrink = 70,
            Radius = 550.0
        },

        {
            Wait = 75,
            Shrink = 60,
            Radius = 350.0
        },

        {
            Wait = 60,
            Shrink = 50,
            Radius = 180.0
        },

        {
            Wait = 45,
            Shrink = 35,
            Radius = 90.0
        },

        {
            Wait = 30,
            Shrink = 25,
            Radius = 35.0
        }

    }

}


Config.Map = {}

Config.Map.Bounds = {

    Min = vector2(3527.4, -4183.9),

    Max = vector2(6112.0, -6121.8)

}


Config.PlayArea = {

    Center = vector3(5011.0, -5118.4, 25.0),

    Radius = 1050.0

}


Config.HQ = {

    Enabled = true,

    Min = vector3(4982.6, -5832.7, 0.0),

    Max = vector3(5001.1, -5601.3, 50.0),

    PushBack = vector3(4984.1157, -5591.8501, 24.1306)

}


Config.Lobby = {}

Config.Lobby.Position = vector3(4470.1831, -4495.8145, 4.1937)

Config.Lobby.Radius = 60.0


Config.Spawn = {}

Config.Spawn.RandomHeight = 1200.0

Config.Spawn.ProtectionTime = 5


Config.Loot = {}

Config.Loot.EpicInterval = 600

Config.Loot.VehicleModels = {

    "blista",

    "issi2",

    "panto",

    "brioso",

    "asterope2"

}


Config.Hud = {}

Config.Hud.ShowAlivePlayers = true

Config.Hud.ShowCircle = true

Config.Hud.ShowLoot = true


Config.Notify = function(msg)

    BeginTextCommandThefeedPost("STRING")

    AddTextComponentSubstringPlayerName(msg)

    EndTextCommandThefeedPostTicker(false, true)

end