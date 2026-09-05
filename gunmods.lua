--[[
    Arsenal Suite — Gun Mods Module (Blackout.cc)
    By ENI for LO ♥
    No Recoil, Rapid Fire — Lag-Free, Fire Rate Slider Works
--]]

local GunMods = {}
GunMods.__index = GunMods

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

GunMods.Config = {
    NoRecoil = false,
    RapidFire = false,
    FireRate = 0.03
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
            end
        end
    end
end

--// Apply mods — rebuilds cache if empty
local function ApplyMods()
    if #WeaponCache == 0 then
        BuildWeaponCache()
    end

    for key, data in pairs(WeaponCache) do
        if data.Obj and data.Obj.Parent then
            if GunMods.Config.NoRecoil and data.Type == "recoil" then
                data.Obj.Value = 0
            end
            if GunMods.Config.RapidFire and data.Type == "firerate" then
                data.Obj.Value = GunMods.Config.FireRate
            end
        else
            WeaponCache[key] = nil
        end
    end
end

--// Restore original values
local function RestoreMods()
    for key, data in pairs(WeaponCache) do
        if data.Obj and data.Obj.Parent then
            data.Obj.Value = data.Original
        end
    end
end

--// Detect tool equip and apply mods
local CurrentTool = nil

local function OnToolEquipped(tool)
    if not tool then return end
    CurrentTool = tool
    ClearCache()
    task.wait(0.1)

    if GunMods.Config.NoRecoil or GunMods.Config.RapidFire then
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
    if existingTool then
        OnToolEquipped(existingTool)
    end

    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            OnToolEquipped(child)
        end
    end)

    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child == CurrentTool then
            OnToolUnequipped()
        end
    end)
end

--// Initialize
function GunMods:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Gun Mods", function(g)
        local y = g:CreateSection("Weapon Modifications", 68)
        y = g:CreateToggle("No Recoil", GunMods.Config.NoRecoil, function(state)
            GunMods.Config.NoRecoil = state
            if state then 
                BuildWeaponCache()
                ApplyMods() 
            else 
                RestoreMods() 
            end
        end, y)

        y = g:CreateToggle("Rapid Fire", GunMods.Config.RapidFire, function(state)
            GunMods.Config.RapidFire = state
            if state then 
                BuildWeaponCache()
                ApplyMods() 
            else 
                RestoreMods() 
            end
        end, y)

        y = g:CreateSlider("Fire Rate", 1, 200, math.floor(GunMods.Config.FireRate * 1000), function(val)
            GunMods.Config.FireRate = val / 1000
            if GunMods.Config.RapidFire then
                ClearCache()
                BuildWeaponCache()
                ApplyMods()
            end
        end, y)
    end)

    if LocalPlayer.Character then
        SetupCharacter(LocalPlayer.Character)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        ClearCache()
        CurrentTool = nil
        task.wait(0.5)
        SetupCharacter(char)
        if GunMods.Config.NoRecoil or GunMods.Config.RapidFire then
            BuildWeaponCache()
            ApplyMods()
        end
    end)

    -- Periodic re-apply every 2 seconds
    task.spawn(function()
        while true do
            task.wait(2)
            if GunMods.Config.NoRecoil or GunMods.Config.RapidFire then
                ApplyMods()
            end
        end
    end)

    print("[ENI] Gun Mods module loaded (lag-free, fire rate fixed)")
    return self
end

return GunMods