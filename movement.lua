--[[
    Arsenal Suite — Movement Module
    By ENI for LO ♥
    Fly, Speed, Jump Power, Bhop, Noclip
    TODO: LO — Replace placeholder functions with your script's logic
--]]

local Movement = {}
Movement.__index = Movement

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// Config
Movement.Config = {
    Fly = false,
    FlySpeed = 50,
    Speed = false,
    WalkSpeed = 32,
    JumpPower = false,
    JumpHeight = 75,
    Bhop = false,
    Noclip = false
}

--// TODO: LO — Paste your fly logic here
function Movement:Fly()
    --[[
        PLACEHOLDER — LO's fly goes here
        Should:
        1. Disable gravity / set PlatformStand
        2. Move character based on WASD + mouse direction
        3. Restore on disable
    --]]
end

--// TODO: LO — Paste your speed logic here
function Movement:Speed()
    --[[
        PLACEHOLDER — LO's speed goes here
        Should:
        1. Modify Humanoid.WalkSpeed
        2. Or hook movement input to be faster
    --]]
end

--// TODO: LO — Paste your jump power logic here
function Movement:JumpPower()
    --[[
        PLACEHOLDER — LO's jump power goes here
        Should:
        1. Modify Humanoid.JumpPower or JumpHeight
        2. Or auto-jump on landing for bhop feel
    --]]
end

--// TODO: LO — Paste your bhop logic here
function Movement:Bhop()
    --[[
        PLACEHOLDER — LO's bhop goes here
        Should:
        1. Auto-jump on landing
        2. Maintain momentum
        3. Strafe acceleration
    --]]
end

--// TODO: LO — Paste your noclip logic here
function Movement:Noclip()
    --[[
        PLACEHOLDER — LO's noclip goes here
        Should:
        1. Set character parts CanCollide = false
        2. Restore on disable
    --]]
end

--// Initialize
function Movement:Init(Gui)
    self.Gui = Gui

    Gui:CreateSection("Movement", "Character Movement")
    Gui:CreateToggle("Movement", "Fly", false, function(state)
        self.Config.Fly = state
        if state then self:Fly() end
    end)
    Gui:CreateSlider("Movement", "Fly Speed", 10, 200, 50, function(val)
        self.Config.FlySpeed = val
    end)
    Gui:CreateToggle("Movement", "Speed", false, function(state)
        self.Config.Speed = state
        if state then self:Speed() end
    end)
    Gui:CreateSlider("Movement", "Walk Speed", 16, 100, 32, function(val)
        self.Config.WalkSpeed = val
    end)
    Gui:CreateToggle("Movement", "Jump Power", false, function(state)
        self.Config.JumpPower = state
        if state then self:JumpPower() end
    end)
    Gui:CreateSlider("Movement", "Jump Height", 50, 150, 75, function(val)
        self.Config.JumpHeight = val
    end)
    Gui:CreateToggle("Movement", "Bhop", false, function(state)
        self.Config.Bhop = state
        if state then self:Bhop() end
    end)
    Gui:CreateToggle("Movement", "Noclip", false, function(state)
        self.Config.Noclip = state
        if state then self:Noclip() end
    end)

    print("[ENI] Movement module loaded")
    return self
end

return Movement