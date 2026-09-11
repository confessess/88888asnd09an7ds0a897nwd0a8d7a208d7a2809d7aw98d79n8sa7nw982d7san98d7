--[[
    Arsenal Suite — Weapon Changer Module (Blackout.cc)
    By ENI for LO ♥
    Ported from Lunar X — gun chams with materials and colors
--]]

local WeaponChanger = {}
WeaponChanger.__index = WeaponChanger

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

WeaponChanger.Config = {
    Enabled = false,
    Material = "Neon",
    Color = Color3.fromRGB(255, 0, 0),
    Rainbow = false,
    RainbowSpeed = 2
}

local Materials = {"Neon", "ForceField", "Glass", "SmoothPlastic", "Metal", "Wood", "Granite", "Marble", "Brick", "Pebble", "Sand", "Fabric", "Foil", "Grass", "Ice", "DiamondPlate", "Aluminum", "Gold", "Silver", "WoodPlanks", "Cobblestone", "Concrete", "CorrodedMetal", "Granite", "Marble", "Pebble", "Sand", "Fabric", "Foil", "Grass", "Ice", "DiamondPlate", "Aluminum", "Gold", "Silver", "WoodPlanks", "Cobblestone", "Concrete", "CorrodedMetal"}

local ColorPresets = {
    {Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
    {Name = "Blue", Color = Color3.fromRGB(0, 100, 255)},
    {Name = "Green", Color = Color3.fromRGB(0, 255, 0)},
    {Name = "Purple", Color = Color3.fromRGB(150, 0, 255)},
    {Name = "Pink", Color = Color3.fromRGB(255, 100, 200)},
    {Name = "Orange", Color = Color3.fromRGB(255, 150, 0)},
    {Name = "Yellow", Color = Color3.fromRGB(255, 255, 0)},
    {Name = "Cyan", Color = Color3.fromRGB(0, 255, 255)},
    {Name = "White", Color = Color3.fromRGB(255, 255, 255)},
    {Name = "Black", Color = Color3.fromRGB(20, 20, 20)},
}

local ChamsConnection = nil
local Hue = 0

local function GetEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

local function ApplyChams(tool, color)
    if not tool then return end
    local material = Enum.Material[WeaponChanger.Config.Material] or Enum.Material.Neon

    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("Part") then
            part.Material = material
            part.Color = color
            part.Transparency = 0
        end
    end
end

local function StartChams()
    if ChamsConnection then return end
    print("[ENI] Weapon Chams started")

    ChamsConnection = RunService.Heartbeat:Connect(function(dt)
        if not WeaponChanger.Config.Enabled then
            WeaponChanger:StopChams()
            return
        end

        local color = WeaponChanger.Config.Color
        if WeaponChanger.Config.Rainbow then
            Hue = (Hue + dt * WeaponChanger.Config.RainbowSpeed) % 1
            color = Color3.fromHSV(Hue, 0.9, 1)
        end

        local tool = GetEquippedTool()
        if tool then
            ApplyChams(tool, color)
        end
    end)
end

function WeaponChanger:StopChams()
    if ChamsConnection then
        ChamsConnection:Disconnect()
        ChamsConnection = nil
        print("[ENI] Weapon Chams stopped")
    end
    Hue = 0
end

--// GUI
function WeaponChanger:Init(Gui)
    self.Gui = Gui

    Gui:CreateTab("Weapon Changer", "Gun chams with materials and colors.")

    Gui:SetTabRebuild("Weapon Changer", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        local y = g:CreateSection("Gun Chams", 0)
        y = g:CreateToggle("Enabled", WeaponChanger.Config.Enabled, function(state)
            WeaponChanger.Config.Enabled = state
            if state then StartChams() else WeaponChanger:StopChams() end
        end, y)

        y = g:CreateToggle("Rainbow Mode", WeaponChanger.Config.Rainbow, function(state)
            WeaponChanger.Config.Rainbow = state
        end, y)

        y = g:CreateSlider("Rainbow Speed", 1, 10, WeaponChanger.Config.RainbowSpeed, function(val)
            WeaponChanger.Config.RainbowSpeed = val
        end, y)

        -- Material dropdown
        y = g:CreateSection("Material", y + 10)

        local materialNames = {}
        for _, mat in ipairs(Materials) do
            table.insert(materialNames, mat)
        end

        y = g:CreateDropdown("Material", materialNames, WeaponChanger.Config.Material, function(val)
            WeaponChanger.Config.Material = val
        end, y)

        -- Color presets
        y = g:CreateSection("Color Presets", y + 10)

        for i, preset in ipairs(ColorPresets) do
            y = g:CreateButton(preset.Name, function()
                WeaponChanger.Config.Color = preset.Color
                print("[ENI] Color set to: " .. preset.Name)
            end, y)
        end

        g.Content = originalContent
    end)

    print("[ENI] Weapon Changer loaded")
    return self
end

return WeaponChanger