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

----------------------------------------------------------
-- Start Stages
----------------------------------------------------------

function HG.Circle.StartStages()

    HG.Circle.Current.phase = 1

    HG.Circle.StartWait()

end

----------------------------------------------------------
-- Wait Phase
----------------------------------------------------------

function HG.Circle.StartWait()

    local stage = Config.Circle.Stages[HG.Circle.Current.phase]

    if not stage then

        HG.Circle.Finish()

        return

    end

    HG.Circle.State = "WAIT"

    HG.Circle.WaitEnds = os.time() + stage.Wait

    HG.Broadcast("hg:circleWait", {

        phase = HG.Circle.Current.phase,

        radius = HG.Circle.Current.radius,

        duration = stage.Wait

    })

    SetTimeout(stage.Wait * 1000, function()

        if not HG.Game.Active then
            return
        end

        HG.Circle.StartShrink()

    end)

end

----------------------------------------------------------
-- Shrink Phase
----------------------------------------------------------

function HG.Circle.StartShrink()

    local stage = Config.Circle.Stages[HG.Circle.Current.phase]

    if not stage then
        return
    end

    HG.Circle.State = "SHRINK"

    HG.Broadcast("hg:circleShrink", {

        phase = HG.Circle.Current.phase,

        fromRadius = HG.Circle.Current.radius,

        toRadius = stage.Radius,

        duration = stage.Shrink

    })

    HG.Circle.Current.radius = stage.Radius

    SetTimeout(stage.Shrink * 1000, function()

        if not HG.Game.Active then
            return
        end

        HG.Circle.Current.phase = HG.Circle.Current.phase + 1

        HG.Circle.StartWait()

    end)

end

----------------------------------------------------------
-- Finish Circle
----------------------------------------------------------

function HG.Circle.Finish()

    HG.Circle.State = "FINISHED"

end