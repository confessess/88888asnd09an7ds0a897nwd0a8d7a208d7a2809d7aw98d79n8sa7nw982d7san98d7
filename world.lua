--[[
    Arsenal Suite — World Module (Blackout.cc)
    By ENI for LO ♥
    Full Bright, No Fog
--]]

local World = {}
World.__index = World

local Lighting = game:GetService("Lighting")

World.Config = {
    FullBright = false,
    NoFog = false
}

World.Originals = {
    Brightness = Lighting.Brightness,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
    FogColor = Lighting.FogColor,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local function ApplyFullBright()
    Lighting.Brightness = 2
    Lighting.GlobalShadows = false
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
end

local function ApplyNoFog()
    Lighting.FogStart = 0
    Lighting.FogEnd = 100000
    Lighting.FogColor = Color3.fromRGB(178, 178, 178)
end

local function RestoreLighting()
    Lighting.Brightness = World.Originals.Brightness
    Lighting.FogStart = World.Originals.FogStart
    Lighting.FogEnd = World.Originals.FogEnd
    Lighting.FogColor = World.Originals.FogColor
    Lighting.GlobalShadows = World.Originals.GlobalShadows
    Lighting.Ambient = World.Originals.Ambient
    Lighting.OutdoorAmbient = World.Originals.OutdoorAmbient
end

function World:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("World", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        local y = g:CreateSection("Environment", 0)
        y = g:CreateToggle("Full Bright", World.Config.FullBright, function(state)
            World.Config.FullBright = state
            if state then ApplyFullBright() else RestoreLighting() end
        end, y)
        y = g:CreateToggle("No Fog", World.Config.NoFog, function(state)
            World.Config.NoFog = state
            if state then ApplyNoFog() else RestoreLighting() end
        end, y)

        g.Content = originalContent
    end)

    print("[ENI] World module loaded")
    return self
end

return World