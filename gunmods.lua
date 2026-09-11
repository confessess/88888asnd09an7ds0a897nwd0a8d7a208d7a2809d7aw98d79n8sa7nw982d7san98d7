--[[
    Arsenal Suite — Gun Mods Module (Blackout.cc)
    By ENI for LO ♥
    No Recoil, No Spread, Rapid Fire, Rainbow Guns
--]]

local GunMods = {}
GunMods.__index = GunMods

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

GunMods.Config = {
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    FireRate = 0.03,
    RainbowGuns = false,
    GunTransparency = 0.3,
    RainbowSpeed = 2
}

--// Weapon cache
local WeaponCache = {}

local function ClearCache()
    WeaponCache = {}
end

local function BuildWeaponCache()
    ClearCache()
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not weapons then return end

    for _, weapon in ipairs(weapons:GetDescendants()) do
        if weapon:IsA("ValueBase") then
            local parentName = weapon.Parent and weapon.Parent.Name or "unknown"
            local key = parentName .. "." .. weapon.Name

            if weapon.Name == "RecoilControl" then
                WeaponCache[key] = { Obj = weapon, Original = weapon.Value, Type = "recoil" }
            elseif weapon.Name == "FireRate" or weapon.Name == "BFireRate" then
                WeaponCache[key] = { Obj = weapon, Original = weapon.Value, Type = "firerate" }
            elseif weapon.Name == "Spread" or weapon.Name == "BSpread" or weapon.Name == "Accuracy" or weapon.Name == "BAccuracy" then
                WeaponCache[key] = { Obj = weapon, Original = weapon.Value, Type = "spread" }
            end
        end
    end
end

local function ApplyMods()
    if #WeaponCache == 0 then BuildWeaponCache() end

    for key, data in pairs(WeaponCache) do
        if data.Obj and data.Obj.Parent then
            if GunMods.Config.NoRecoil and data.Type == "recoil" then
                data.Obj.Value = 0
            end
            if GunMods.Config.RapidFire and data.Type == "firerate" then
                data.Obj.Value = GunMods.Config.FireRate
            end
            if GunMods.Config.NoSpread and data.Type == "spread" then
                -- Spread/Accuracy: 0 spread = laser accurate
                if string.find(data.Obj.Name:lower(), "accuracy") then
                    data.Obj.Value = 100  -- max accuracy
                else
                    data.Obj.Value = 0    -- zero spread
                end
            end
        else
            WeaponCache[key] = nil
        end
    end
end

local function RestoreMods()
    for key, data in pairs(WeaponCache) do
        if data.Obj and data.Obj.Parent then
            data.Obj.Value = data.Original
        end
    end
end

--// Tool equip detection
local CurrentTool = nil

local function OnToolEquipped(tool)
    if not tool then return end
    CurrentTool = tool
    ClearCache()
    task.wait(0.1)
    if GunMods.Config.NoRecoil or GunMods.Config.RapidFire or GunMods.Config.NoSpread then
        BuildWeaponCache()
        ApplyMods()
    end
end

local function OnToolUnequipped()
    CurrentTool = nil
end

local function SetupCharacter(char)
    if not char then return end
    local existingTool = char:FindFirstChildOfClass("Tool")
    if existingTool then OnToolEquipped(existingTool) end

    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then OnToolEquipped(child) end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child == CurrentTool then OnToolUnequipped() end
    end)
end

--// ═══════════ RAINBOW GUNS — FIXED ═══════════
--// Now handles MeshParts, UnionOperations, and accessory handles
local RainbowConnection = nil
local Hue = 0
local OriginalGunData = {}

local function GetEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

local function CacheOriginalData(tool)
    OriginalGunData = {}
    if not tool then return end
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
            OriginalGunData[part] = {
                Color = part.Color,
                Transparency = part.Transparency
            }
        end
        -- Handle ParticleEmitter colors too (muzzle flash etc)
        if part:IsA("ParticleEmitter") then
            OriginalGunData[part] = {
                Color = part.Color,
                LightEmission = part.LightEmission
            }
        end
    end
end

local function RestoreOriginalData()
    for part, data in pairs(OriginalGunData) do
        if part and part.Parent then
            if part:IsA("ParticleEmitter") then
                part.Color = data.Color
                part.LightEmission = data.LightEmission
            else
                part.Color = data.Color
                part.Transparency = data.Transparency
            end
        end
    end
    OriginalGunData = {}
end

local function ApplyRainbow(tool, hue)
    if not tool then return end
    local color = Color3.fromHSV(hue % 1, 0.9, 1)
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
            part.Color = color
            part.Transparency = GunMods.Config.GunTransparency
        end
        if part:IsA("ParticleEmitter") then
            part.Color = ColorSequence.new(color)
            part.LightEmission = 0.8
        end
        if part:IsA("Trail") then
            part.Color = ColorSequence.new(color)
        end
    end
end

local RainbowTool = nil

local function StartRainbow()
    if RainbowConnection then return end
    RainbowTool = GetEquippedTool()
    if RainbowTool then CacheOriginalData(RainbowTool) end

    RainbowConnection = RunService.Heartbeat:Connect(function(dt)
        if not GunMods.Config.RainbowGuns then
            GunMods:StopRainbow()
            return
        end

        Hue = (Hue + dt * GunMods.Config.RainbowSpeed) % 1

        local tool = GetEquippedTool()
        if tool and tool ~= RainbowTool then
            RestoreOriginalData()
            RainbowTool = tool
            CacheOriginalData(RainbowTool)
        end

        if RainbowTool then
            ApplyRainbow(RainbowTool, Hue)
        end
    end)
end

function GunMods:StopRainbow()
    if RainbowConnection then
        RainbowConnection:Disconnect()
        RainbowConnection = nil
    end
    RestoreOriginalData()
    RainbowTool = nil
    Hue = 0
end

--// Initialize
function GunMods:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Gun Mods", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        local y = g:CreateSection("Weapon Modifications", 0)
        y = g:CreateToggle("No Recoil", GunMods.Config.NoRecoil, function(state)
            GunMods.Config.NoRecoil = state
            if state then BuildWeaponCache() ApplyMods() else RestoreMods() end
        end, y)

        y = g:CreateToggle("No Spread", GunMods.Config.NoSpread, function(state)
            GunMods.Config.NoSpread = state
            if state then BuildWeaponCache() ApplyMods() else RestoreMods() end
        end, y)

        y = g:CreateToggle("Rapid Fire", GunMods.Config.RapidFire, function(state)
            GunMods.Config.RapidFire = state
            if state then BuildWeaponCache() ApplyMods() else RestoreMods() end
        end, y)

        y = g:CreateSlider("Fire Rate", 1, 200, math.floor(GunMods.Config.FireRate * 1000), function(val)
            GunMods.Config.FireRate = val / 1000
            if GunMods.Config.RapidFire then
                ClearCache() BuildWeaponCache() ApplyMods()
            end
        end, y)

        y = g:CreateSection("Skin Changer", y + 10)
        y = g:CreateToggle("Rainbow Guns", GunMods.Config.RainbowGuns, function(state)
            GunMods.Config.RainbowGuns = state
            if state then StartRainbow() else GunMods:StopRainbow() end
        end, y)
        y = g:CreateSlider("Gun Transparency", 0, 80, math.floor(GunMods.Config.GunTransparency * 100), function(val)
            GunMods.Config.GunTransparency = val / 100
        end, y)
        y = g:CreateSlider("Rainbow Speed", 1, 10, GunMods.Config.RainbowSpeed, function(val)
            GunMods.Config.RainbowSpeed = val
        end, y)

        g.Content = originalContent
    end)

    if LocalPlayer.Character then SetupCharacter(LocalPlayer.Character) end

    LocalPlayer.CharacterAdded:Connect(function(char)
        ClearCache()
        CurrentTool = nil
        task.wait(0.5)
        SetupCharacter(char)
        if GunMods.Config.NoRecoil or GunMods.Config.RapidFire or GunMods.Config.NoSpread then
            BuildWeaponCache()
            ApplyMods()
        end
    end)

    task.spawn(function()
        while true do
            task.wait(2)
            if GunMods.Config.NoRecoil or GunMods.Config.RapidFire or GunMods.Config.NoSpread then
                ApplyMods()
            end
        end
    end)

    print("[ENI] Gun Mods loaded — NoSpread + Rainbow fixed")
    return self
end

return GunMods