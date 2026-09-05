--[[
    Arsenal Suite — World Module
    By ENI for LO ♥
    Full Bright, No Fog, Time Control, Atmosphere, X-Ray
    TODO: LO — Replace placeholder functions with your script's logic
--]]

local World = {}
World.__index = World

--// Services
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

--// Config
World.Config = {
    FullBright = false,
    NoFog = false,
    CustomTime = false,
    TimeOfDay = 12,
    NoShadows = false,
    XRay = false
}

--// Store original values
World.Originals = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

--// TODO: LO — Paste your full bright logic here
function World:FullBright()
    --[[
        PLACEHOLDER — LO's full bright goes here
        Should:
        1. Set Lighting.Brightness to max
        2. Set Ambient/OutdoorAmbient to white
        3. Disable shadows
    --]]
end

--// TODO: LO — Paste your no fog logic here
function World:NoFog()
    --[[
        PLACEHOLDER — LO's no fog goes here
        Should:
        1. Set FogStart/FogEnd to extreme values
        2. Or set FogColor to match sky
    --]]
end

--// TODO: LO — Paste your time control logic here
function World:TimeControl()
    --[[
        PLACEHOLDER — LO's time control goes here
        Should:
        1. Lock ClockTime to desired value
        2. Prevent server from overriding
    --]]
end

--// TODO: LO — Paste your x-ray logic here
function World:XRay()
    --[[
        PLACEHOLDER — LO's x-ray goes here
        Should:
        1. Make walls/floors transparent
        2. Or use Highlight to see through walls
    --]]
end

--// Restore original lighting
function World:Restore()
    Lighting.Brightness = self.Originals.Brightness
    Lighting.ClockTime = self.Originals.ClockTime
    Lighting.FogStart = self.Originals.FogStart
    Lighting.FogEnd = self.Originals.FogEnd
    Lighting.FogColor = self.Originals.FogColor
    Lighting.GlobalShadows = self.Originals.GlobalShadows
    Lighting.Ambient = self.Originals.Ambient
    Lighting.OutdoorAmbient = self.Originals.OutdoorAmbient
end

--// Initialize
function World:Init(Gui)
    self.Gui = Gui

    Gui:CreateSection("World", "Environment")
    Gui:CreateToggle("World", "Full Bright", false, function(state)
        self.Config.FullBright = state
        if state then self:FullBright() else self:Restore() end
    end)
    Gui:CreateToggle("World", "No Fog", false, function(state)
        self.Config.NoFog = state
        if state then self:NoFog() else self:Restore() end
    end)
    Gui:CreateToggle("World", "Custom Time", false, function(state)
        self.Config.CustomTime = state
        if state then self:TimeControl() end
    end)
    Gui:CreateSlider("World", "Time of Day", 0, 24, 12, function(val)
        self.Config.TimeOfDay = val
        if self.Config.CustomTime then self:TimeControl() end
    end)
    Gui:CreateToggle("World", "No Shadows", false, function(state)
        self.Config.NoShadows = state
        if state then
            Lighting.GlobalShadows = false
        else
            Lighting.GlobalShadows = self.Originals.GlobalShadows
        end
    end)
    Gui:CreateToggle("World", "X-Ray", false, function(state)
        self.Config.XRay = state
        if state then self:XRay() end
    end)

    print("[ENI] World module loaded")
    return self
end

return World