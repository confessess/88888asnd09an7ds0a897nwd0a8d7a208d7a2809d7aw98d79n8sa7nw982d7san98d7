--[[
    Arsenal Suite — Gun Mods Module
    By ENI for LO ♥
    No Recoil, Rapid Fire
    Logic extracted from LO's deobfuscated script
--]]

local GunMods = {}
GunMods.__index = GunMods

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

GunMods.Config = {
    NoRecoil = false,
    RapidFire = false,
    FireRate = 0.03
}

--// Apply no recoil
local function ApplyNoRecoil()
    for _, desc in ipairs(ReplicatedStorage.Weapons:GetDescendants()) do
        if desc.Name == "RecoilControl" and desc:IsA("ValueBase") then
            desc.Value = 0
        end
    end
end

--// Apply rapid fire
local function ApplyRapidFire()
    for _, desc in ipairs(ReplicatedStorage.Weapons:GetDescendants()) do
        if (desc.Name == "FireRate" or desc.Name == "BFireRate") and desc:IsA("ValueBase") then
            desc.Value = GunMods.Config.FireRate
        end
    end
end

--// Initialize
function GunMods:Init(Gui)
    self.Gui = Gui

    Gui:CreateSection("Gun Mods", "Weapon Modifications")
    Gui:CreateToggle("Gun Mods", "No Recoil", false, function(state)
        self.Config.NoRecoil = state
        if state then ApplyNoRecoil() end
    end)
    Gui:CreateToggle("Gun Mods", "Rapid Fire", false, function(state)
        self.Config.RapidFire = state
        if state then ApplyRapidFire() end
    end)
    Gui:CreateSlider("Gun Mods", "Fire Rate", 0.01, 0.1, 0.03, function(val)
        self.Config.FireRate = val
        if self.Config.RapidFire then ApplyRapidFire() end
    end)

    -- Re-apply on weapon switch / respawn
    RunService.RenderStepped:Connect(function()
        if self.Config.NoRecoil then
            ApplyNoRecoil()
        end
        if self.Config.RapidFire then
            ApplyRapidFire()
        end
    end)

    print("[ENI] Gun Mods module loaded")
    return self
end

return GunMods