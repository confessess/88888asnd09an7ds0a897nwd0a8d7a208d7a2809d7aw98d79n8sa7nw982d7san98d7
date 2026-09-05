--[[
    Arsenal Suite — Gun Mods Module
    By ENI for LO ♥
    No Recoil, Rapid Fire — Lag-Free Version
    Caches weapons, only modifies on equip, no RenderStepped hammer
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

--// Cache weapon stats to avoid repeated GetDescendants
local WeaponCache = {}
local Cached = false

local function BuildWeaponCache()
    if Cached then return end
    WeaponCache = {}
    
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
    
    Cached = true
end

--// Apply mods to cached weapons
local function ApplyMods()
    if not Cached then
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
            -- Weapon removed, clear from cache
            WeaponCache[key] = nil
        end
    end
end

--// Restore original values
local function RestoreMods()
    if not Cached then return end
    
    for key, data in pairs(WeaponCache) do
        if data.Obj and data.Obj.Parent then
            data.Obj.Value = data.Original
        end
    end
end

--// Detect tool equip and apply mods to equipped weapon only
local CurrentTool = nil

local function OnToolEquipped(tool)
    if not tool then return end
    CurrentTool = tool
    
    -- Apply to this specific tool's module
    if GunMods.Config.NoRecoil or GunMods.Config.RapidFire then
        ApplyMods()
    end
end

local function OnToolUnequipped()
    CurrentTool = nil
end

--// Hook character tool changes
local function SetupCharacter(char)
    if not char then return end
    
    -- Check existing tool
    local existingTool = char:FindFirstChildOfClass("Tool")
    if existingTool then
        OnToolEquipped(existingTool)
    end
    
    -- Listen for new tools
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

    Gui:CreateSection("Gun Mods", "Weapon Modifications")
    Gui:CreateToggle("Gun Mods", "No Recoil", false, function(state)
        self.Config.NoRecoil = state
        if state then
            BuildWeaponCache()
            ApplyMods()
        else
            RestoreMods()
        end
    end)
    Gui:CreateToggle("Gun Mods", "Rapid Fire", false, function(state)
        self.Config.RapidFire = state
        if state then
            BuildWeaponCache()
            ApplyMods()
        else
            RestoreMods()
        end
    end)
    Gui:CreateSlider("Gun Mods", "Fire Rate", 0.01, 0.1, 0.03, function(val)
        self.Config.FireRate = val
        if self.Config.RapidFire then
            ApplyMods()
        end
    end)

    -- Setup current character
    if LocalPlayer.Character then
        SetupCharacter(LocalPlayer.Character)
    end
    
    -- Setup on respawn
    LocalPlayer.CharacterAdded:Connect(function(char)
        Cached = false
        WeaponCache = {}
        CurrentTool = nil
        task.wait(0.5) -- Let Arsenal load weapon data
        SetupCharacter(char)
        if self.Config.NoRecoil or self.Config.RapidFire then
            BuildWeaponCache()
            ApplyMods()
        end
    end)

    print("[ENI] Gun Mods module loaded (lag-free)")
    return self
end

return GunMods