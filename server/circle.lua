HG.Circle = {}

----------------------------------------------------------
-- Current Circle
----------------------------------------------------------

HG.Circle.Current = {

    x = 0.0,
    y = 0.0,

    radius = 0.0,

    phase = 1

}

----------------------------------------------------------
-- Create First Circle
----------------------------------------------------------

function HG.Circle.Create()

    HG.Circle.Current = {

        x = Config.PlayArea.Center.x,

        y = Config.PlayArea.Center.y,

        radius = Config.Circle.StartRadius,

        phase = 1

    }

    HG.Broadcast("hg:createCircle", HG.Circle.Current)

end