--[[
    Arsenal Suite — Gun Mods Module (Blackout.cc)
    By ENI for LO ♥
    No Recoil, No Spread, Rapid Fire, Infinite Ammo, Rainbow Guns
    v2 — Fixed rainbow guns
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
    InfiniteAmmo = false,
    FastReload = false,
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
            elseif weapon.Name == "Auto" then
                WeaponCache[key] = { Obj = weapon, Original = weapon.Value, Type = "auto" }
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
            if GunMods.Config.RapidFire and data.Type == "auto" then
                data.Obj.Value = true
            end
            if GunMods.Config.NoSpread and data.Type == "spread" then
                if string.find(data.Obj.Name:lower(), "accuracy") then
                    data.Obj.Value = 100
                else
                    data.Obj.Value = 0
                end
            end
        else
            WeaponCache[key] = nil
        end
    end
end

local function ApplyInfiniteAmmo()
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not weapons then return end

    for _, w in ipairs(weapons:GetChildren()) do
        if w:FindFirstChild("FireRate") then
            if GunMods.Config.InfiniteAmmo then
                if w:FindFirstChild("Infinite") == nil then
                    pcall(function()
                        local f = Instance.new("Folder")
                        f.Name = "Infinite"
                        f.Parent = w
                    end)
                end
            else
                local inf = w:FindFirstChild("Infinite")
                if inf then
                    pcall(function() inf:Destroy() end)
                end
            end
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
    if GunMods.Config.InfiniteAmmo then
        pcall(function()
            if tool:FindFirstChild("Infinite") == nil then
                local f = Instance.new("Folder")
                f.Name = "Infinite"
                f.Parent = tool
            end
        end)
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


--// FAST RELOAD — from Lunar X
local function ApplyFastReload()
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not weapons then return end

    for _, w in ipairs(weapons:GetChildren()) do
        if w:FindFirstChild("FireRate") then
            if GunMods.Config.FastReload then
                -- Set reload time to near-zero
                local reload = w:FindFirstChild("ReloadTime") or w:FindFirstChild("Reload")
                if reload and reload:IsA("NumberValue") then
                    if not reload:GetAttribute("OriginalValue") then
                        reload:SetAttribute("OriginalValue", reload.Value)
                    end
                    reload.Value = 0.01
                end
                -- Also try TacticalReload
                local tactical = w:FindFirstChild("TacticalReload")
                if tactical and tactical:IsA("NumberValue") then
                    if not tactical:GetAttribute("OriginalValue") then
                        tactical:SetAttribute("OriginalValue", tactical.Value)
                    end
                    tactical.Value = 0.01
                end
            else
                -- Restore original
                local reload = w:FindFirstChild("ReloadTime") or w:FindFirstChild("Reload")
                if reload and reload:IsA("NumberValue") then
                    local orig = reload:GetAttribute("OriginalValue")
                    if orig then reload.Value = orig end
                end
                local tactical = w:FindFirstChild("TacticalReload")
                if tactical and tactical:IsA("NumberValue") then
                    local orig = tactical:GetAttribute("OriginalValue")
                    if orig then tactical.Value = orig end
                end
            end
        end
    end
end

--// RAINBOW GUNS — FIXED: uses Heartbeat, better part detection
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
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("Part") then
            OriginalGunData[part] = {
                Color = part.Color,
                Transparency = part.Transparency,
                Material = part.Material
            }
        end
        if part:IsA("ParticleEmitter") then
            OriginalGunData[part] = {
                Color = part.Color,
                LightEmission = part.LightEmission
            }
        end
        if part:IsA("Trail") then
            OriginalGunData[part] = {
                Color = part.Color
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
            elseif part:IsA("Trail") then
                part.Color = data.Color
            else
                part.Color = data.Color
                part.Transparency = data.Transparency
                part.Material = data.Material
            end
        end
    end
    OriginalGunData = {}
end

local function ApplyRainbow(tool, hue)
    if not tool then return end
    local color = Color3.fromHSV(hue % 1, 0.9, 1)
    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("Part") then
            part.Color = color
            part.Transparency = GunMods.Config.GunTransparency
            part.Material = Enum.Material.Neon
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
    print("[ENI] Rainbow Guns started")
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
        print("[ENI] Rainbow Guns stopped")
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

        y = g:CreateToggle("Infinite Ammo", GunMods.Config.InfiniteAmmo, function(state)
            GunMods.Config.InfiniteAmmo = state
            ApplyInfiniteAmmo()
        end, y)

        y = g:CreateToggle("Fast Reload", GunMods.Config.FastReload, function(state)
            GunMods.Config.FastReload = state
            ApplyFastReload()
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
        if GunMods.Config.InfiniteAmmo then
            ApplyInfiniteAmmo()
        end
        if GunMods.Config.FastReload then
            ApplyFastReload()
        end
        -- Restart rainbow if it was on
        if GunMods.Config.RainbowGuns then
            task.wait(1)
            StartRainbow()
        end
    end)

    task.spawn(function()
        while true do
            task.wait(2)
            if GunMods.Config.NoRecoil or GunMods.Config.RapidFire or GunMods.Config.NoSpread then
                ApplyMods()
            end
            if GunMods.Config.InfiniteAmmo then
                ApplyInfiniteAmmo()
            end
        end
    end)

    print("[ENI] Gun Mods loaded")
    return self
end

return GunMods