--[[
    Arsenal Suite — Combat Module
    By ENI for LO ♥
    Aimbot, Hitbox Expander
    Logic extracted from LO's deobfuscated script, cleaned & fixed
--]]

local Combat = {}
Combat.__index = Combat

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

Combat.Config = {
    AimbotEnabled = false,
    HitboxEnabled = false,
    TeamCheck = true,
    FOV = 25,
    HitboxSize = 13,
    HeadHBSize = 20,
    AimKey = Enum.UserInputType.MouseButton2
}

--// Drawing FOV Circle
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Color = Color3.fromRGB(255, 255, 255)
FOV_Circle.Thickness = 1
FOV_Circle.Filled = false
FOV_Circle.NumSides = 100
FOV_Circle.Transparency = 1
FOV_Circle.Radius = 25
FOV_Circle.Visible = true

--// Aimbot: Find closest enemy to mouse within FOV
local function GetClosestEnemy()
    local closestDist = Combat.Config.FOV
    local closestTarget = nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Combat.Config.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local char = plr.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end

        local mousePos = UserInputService:GetMouseLocation()
        local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude

        if dist < closestDist then
            closestDist = dist
            closestTarget = plr
        end
    end

    return closestTarget
end

--// Aimbot state
local IsAiming = false

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Combat.Config.AimKey then
        IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Combat.Config.AimKey then
        IsAiming = false
    end
end)

--// Aimbot render loop
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOV_Circle.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOV_Circle.Radius = Combat.Config.FOV
    FOV_Circle.Visible = Combat.Config.AimbotEnabled

    if Combat.Config.AimbotEnabled and IsAiming then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

--// Hitbox Expander — SAFE version (only Size, no CanCollide/Transparency)
local OriginalSizes = {}

local function ExpandHitboxes()
    if not Combat.Config.HitboxEnabled then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Combat.Config.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local char = plr.Character
        if not char then continue end

        local partsToExpand = {"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}

        for _, partName in ipairs(partsToExpand) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                -- Store original size if not already stored
                if not OriginalSizes[part] then
                    OriginalSizes[part] = part.Size
                end

                local targetSize = (partName == "HeadHB") and
                    Vector3.new(Combat.Config.HeadHBSize, Combat.Config.HeadHBSize, Combat.Config.HeadHBSize) or
                    Vector3.new(Combat.Config.HitboxSize, Combat.Config.HitboxSize, Combat.Config.HitboxSize)

                part.Size = targetSize
            end
        end
    end
end

--// Restore original hitbox sizes
local function RestoreHitboxes()
    for part, originalSize in pairs(OriginalSizes) do
        if part and part.Parent then
            part.Size = originalSize
        end
    end
    OriginalSizes = {}
end

--// Hitbox loop
RunService.RenderStepped:Connect(function()
    if Combat.Config.HitboxEnabled then
        ExpandHitboxes()
    else
        RestoreHitboxes()
    end
end)

--// Cleanup on player leave
Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        for _, part in ipairs(plr.Character:GetDescendants()) do
            if OriginalSizes[part] then
                OriginalSizes[part] = nil
            end
        end
    end
end)

--// Initialize
function Combat:Init(Gui)
    self.Gui = Gui

    Gui:CreateSection("Combat", "Aimbot")
    Gui:CreateToggle("Combat", "Aimbot", false, function(state)
        self.Config.AimbotEnabled = state
    end)
    Gui:CreateToggle("Combat", "Team Check", true, function(state)
        self.Config.TeamCheck = state
    end)
    Gui:CreateSlider("Combat", "FOV Radius", 10, 200, 25, function(val)
        self.Config.FOV = val
    end)

    Gui:CreateSection("Combat", "Hitbox Expander")
    Gui:CreateToggle("Combat", "Hitbox Expander", false, function(state)
        self.Config.HitboxEnabled = state
        if not state then
            RestoreHitboxes()
        end
    end)
    Gui:CreateSlider("Combat", "Body Hitbox Size", 5, 25, 13, function(val)
        self.Config.HitboxSize = val
    end)
    Gui:CreateSlider("Combat", "HeadHB Size", 10, 30, 20, function(val)
        self.Config.HeadHBSize = val
    end)

    print("[ENI] Combat module loaded")
    return self
end

return Combat