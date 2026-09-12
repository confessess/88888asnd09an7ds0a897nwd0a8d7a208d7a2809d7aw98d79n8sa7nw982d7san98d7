

local GunMods = {}
GunMods.__index = GunMods

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

GunMods.Config = {
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    InfiniteAmmo = false,
    FastReload = false,
    AlwaysAuto = false,
    FireRate = 0.03,

    ChamsEnabled = false,
    ChamsMaterial = "Neon",
    ChamsColor = Color3.fromRGB(255, 0, 0),
    ChamsRainbow = false,
    ChamsRainbowSpeed = 2,
    ChamsTransparency = 0,
    ChamArms = false,
}

-- Gun mods state tracking (same as before)
local ModStates = {
    NoRecoil = { Active = false, Modified = {} },
    NoSpread = { Active = false, Modified = {} },
    RapidFire = { Active = false, Modified = {} },
    FastReload = { Active = false, Modified = {} },
}

local ModsLoopRunning = false
local ModsLoopConnection = nil

local function AnyModActive()
    return GunMods.Config.NoRecoil or GunMods.Config.NoSpread 
        or GunMods.Config.RapidFire or GunMods.Config.FastReload
end

local function SnapshotValue(obj, modName)
    local state = ModStates[modName]
    if not state then return end
    if not state.Modified[obj] then
        state.Modified[obj] = obj.Value
    end
end

local function RestoreMod(modName)
    local state = ModStates[modName]
    if not state then return end
    for obj, originalValue in pairs(state.Modified) do
        if obj and obj.Parent then
            obj.Value = originalValue
        end
    end
    state.Modified = {}
    state.Active = false
end

local function ApplySingleMod(modName)
    local state = ModStates[modName]
    if not state or not state.Active then return end
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if not weapons then return end
    for _, weapon in ipairs(weapons:GetDescendants()) do
        if weapon:IsA("ValueBase") then
            local wname = weapon.Name
            if modName == "NoRecoil" and wname == "RecoilControl" then
                SnapshotValue(weapon, modName)
                weapon.Value = 0
            elseif modName == "NoSpread" then
                if wname == "Spread" or wname == "BSpread" then
                    SnapshotValue(weapon, modName)
                    weapon.Value = 0
                elseif wname == "Accuracy" or wname == "BAccuracy" then
                    SnapshotValue(weapon, modName)
                    weapon.Value = 100
                end
            elseif modName == "RapidFire" then
                if wname == "FireRate" or wname == "BFireRate" then
                    SnapshotValue(weapon, modName)
                    weapon.Value = GunMods.Config.FireRate
                elseif wname == "Auto" then
                    SnapshotValue(weapon, modName)
                    weapon.Value = true
                end
            elseif modName == "FastReload" then
                if wname == "ReloadTime" or wname == "Reload" or wname == "TacticalReload" then
                    SnapshotValue(weapon, modName)
                    weapon.Value = 0.01
                end
            end
        end
    end
end

local function StartModsLoop()
    if ModsLoopRunning then return end
    ModsLoopRunning = true
    ModsLoopConnection = task.spawn(function()
        while AnyModActive() do
            if GunMods.Config.NoRecoil then ApplySingleMod("NoRecoil") end
            if GunMods.Config.NoSpread then ApplySingleMod("NoSpread") end
            if GunMods.Config.RapidFire then ApplySingleMod("RapidFire") end
            if GunMods.Config.FastReload then ApplySingleMod("FastReload") end
            task.wait(2)
        end
        ModsLoopRunning = false
        ModsLoopConnection = nil
    end)
end

local function StopModsLoopIfIdle()
    if not AnyModActive() and ModsLoopConnection then
        -- Loop self-terminates
    end
end

--// Z3US ALWAYS AUTO
local originalAutoValues = {}

local function SetAlwaysAuto(enabled)
    GunMods.Config.AlwaysAuto = enabled
    for _, weapon in ipairs(ReplicatedStorage.Weapons:GetChildren()) do
        if weapon:FindFirstChild("Auto") then
            if enabled then
                if not originalAutoValues[weapon] then
                    originalAutoValues[weapon] = weapon.Auto.Value
                end
                weapon.Auto.Value = true
            else
                if originalAutoValues[weapon] then
                    weapon.Auto.Value = originalAutoValues[weapon]
                end
            end
        end
    end
    print("[Z3US] Always Auto: " .. tostring(enabled))
end

--// Infinite Ammo
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

--// Tool equip detection
local CurrentTool = nil

local function OnToolEquipped(tool)
    CurrentTool = tool
    task.wait(0.1)
    if GunMods.Config.NoRecoil then ApplySingleMod("NoRecoil") end
    if GunMods.Config.NoSpread then ApplySingleMod("NoSpread") end
    if GunMods.Config.RapidFire then ApplySingleMod("RapidFire") end
    if GunMods.Config.FastReload then ApplySingleMod("FastReload") end
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

local function SetupCharacter(char)
    if not char then return end
    local existing = char:FindFirstChildOfClass("Tool")
    if existing then task.spawn(OnToolEquipped, existing) end
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then OnToolEquipped(child) end
    end)
    char.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child == CurrentTool then
            CurrentTool = nil
        end
    end)
end

-- Viewmodel chams (same as before)
local Viewmodel = {
    CurrentModel = nil,
    CurrentWeaponName = nil,
    OriginalParts = {},
    WatchConnection = nil,
    PollConnection = nil,
    ChamConnection = nil,
    RainbowHue = 0,
}

local function IsViewmodelModel(model)
    if not model or not model:IsA("Model") then return false end
    local hasWeaponParts = false
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("MeshPart") then
            hasWeaponParts = true
            break
        end
    end
    return hasWeaponParts
end

local function GetViewmodelWeaponModel(viewmodel)
    if not viewmodel then return nil end
    if viewmodel.Name:match("^v_") then
        return viewmodel
    end
    for _, child in ipairs(viewmodel:GetChildren()) do
        if child:IsA("Model") and child.Name:match("^v_") then
            return child
        end
    end
    if IsViewmodelModel(viewmodel) then
        return viewmodel
    end
    return nil
end

local function RestoreViewmodelParts()
    for part, data in pairs(Viewmodel.OriginalParts) do
        if part and part.Parent then
            part.Color = data.Color
            part.Material = data.Material
            part.Transparency = data.Transparency
        end
    end
    Viewmodel.OriginalParts = {}
end

local function ScrapeViewmodelParts(weaponModel)
    local parts = {}
    for _, desc in ipairs(weaponModel:GetDescendants()) do
        if desc:IsA("BasePart") or desc:IsA("MeshPart") or desc:IsA("UnionOperation") then
            if GunMods.Config.ChamArms or not desc.Name:lower():find("arm") then
                table.insert(parts, desc)
            end
        end
    end
    return parts
end

local function ApplyChamsToViewmodel(weaponModel, color)
    if not weaponModel then return end
    local material = Enum.Material[GunMods.Config.ChamsMaterial] or Enum.Material.Neon
    local parts = ScrapeViewmodelParts(weaponModel)
    for _, part in ipairs(parts) do
        if not Viewmodel.OriginalParts[part] then
            Viewmodel.OriginalParts[part] = {
                Color = part.Color,
                Material = part.Material,
                Transparency = part.Transparency,
            }
        end
        part.Material = material
        part.Color = color
        part.Transparency = GunMods.Config.ChamsTransparency
    end
end

local function OnViewmodelChanged(newModel)
    RestoreViewmodelParts()
    Viewmodel.CurrentModel = nil
    Viewmodel.CurrentWeaponName = nil
    if not GunMods.Config.ChamsEnabled then return end
    if not newModel then return end
    local weaponModel = GetViewmodelWeaponModel(newModel)
    if not weaponModel then return end
    Viewmodel.CurrentModel = weaponModel
    Viewmodel.CurrentWeaponName = weaponModel.Name
    ApplyChamsToViewmodel(weaponModel, GunMods.Config.ChamsColor)
end

local function StartViewmodelWatcher()
    if Viewmodel.WatchConnection then return end
    Viewmodel.WatchConnection = Camera.ChildAdded:Connect(function(child)
        task.wait(0.05)
        if IsViewmodelModel(child) then
            OnViewmodelChanged(child)
        end
    end)
    Viewmodel.PollConnection = task.spawn(function()
        while GunMods.Config.ChamsEnabled do
            task.wait(0.3)
            local found = nil
            for _, child in ipairs(Camera:GetChildren()) do
                if IsViewmodelModel(child) then
                    found = child
                    break
                end
            end
            if found and found ~= Viewmodel.CurrentModel then
                OnViewmodelChanged(found)
            elseif not found and Viewmodel.CurrentModel then
                OnViewmodelChanged(nil)
            end
        end
        Viewmodel.PollConnection = nil
    end)
    Viewmodel.ChamConnection = RunService.Heartbeat:Connect(function(dt)
        if not GunMods.Config.ChamsEnabled then return end
        if not GunMods.Config.ChamsRainbow then return end
        if not Viewmodel.CurrentModel then return end
        Viewmodel.RainbowHue = (Viewmodel.RainbowHue + dt * GunMods.Config.ChamsRainbowSpeed) % 1
        local color = Color3.fromHSV(Viewmodel.RainbowHue, 0.9, 1)
        ApplyChamsToViewmodel(Viewmodel.CurrentModel, color)
    end)
    for _, child in ipairs(Camera:GetChildren()) do
        if IsViewmodelModel(child) then
            OnViewmodelChanged(child)
            break
        end
    end
end

local function StopViewmodelWatcher()
    if Viewmodel.WatchConnection then
        Viewmodel.WatchConnection:Disconnect()
        Viewmodel.WatchConnection = nil
    end
    if Viewmodel.ChamConnection then
        Viewmodel.ChamConnection:Disconnect()
        Viewmodel.ChamConnection = nil
    end
    RestoreViewmodelParts()
    Viewmodel.CurrentModel = nil
    Viewmodel.CurrentWeaponName = nil
    Viewmodel.RainbowHue = 0
end

function GunMods:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Weapon", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        local y = g:CreateSection("Weapon Modifications", 0)

        y = g:CreateToggle("No Recoil", false, function(state)
            GunMods.Config.NoRecoil = state
            if state then
                ModStates.NoRecoil.Active = true
                ApplySingleMod("NoRecoil")
                StartModsLoop()
            else
                RestoreMod("NoRecoil")
                StopModsLoopIfIdle()
            end
        end, y)

        y = g:CreateToggle("No Spread", false, function(state)
            GunMods.Config.NoSpread = state
            if state then
                ModStates.NoSpread.Active = true
                ApplySingleMod("NoSpread")
                StartModsLoop()
            else
                RestoreMod("NoSpread")
                StopModsLoopIfIdle()
            end
        end, y)

        y = g:CreateToggle("Rapid Fire", false, function(state)
            GunMods.Config.RapidFire = state
            if state then
                ModStates.RapidFire.Active = true
                ApplySingleMod("RapidFire")
                StartModsLoop()
            else
                RestoreMod("RapidFire")
                StopModsLoopIfIdle()
            end
        end, y)

        y = g:CreateToggle("Infinite Ammo", false, function(state)
            GunMods.Config.InfiniteAmmo = state
            ApplyInfiniteAmmo()
        end, y)

        y = g:CreateToggle("Fast Reload", false, function(state)
            GunMods.Config.FastReload = state
            if state then
                ModStates.FastReload.Active = true
                ApplySingleMod("FastReload")
                StartModsLoop()
            else
                RestoreMod("FastReload")
                StopModsLoopIfIdle()
            end
        end, y)

        -- Z3US Always Auto
        y = g:CreateToggle("Always Auto", false, function(state)
            SetAlwaysAuto(state)
        end, y)

        y = g:CreateSlider("Fire Rate", 1, 200, math.floor(GunMods.Config.FireRate * 1000), function(val)
            GunMods.Config.FireRate = val / 1000
            if GunMods.Config.RapidFire then
                RestoreMod("RapidFire")
                ModStates.RapidFire.Active = true
                ApplySingleMod("RapidFire")
            end
        end, y)

        -- Viewmodel Chams
        y = g:CreateSection("Viewmodel Chams", y + 10)

        y = g:CreateToggle("Enabled", false, function(state)
            GunMods.Config.ChamsEnabled = state
            if state then
                StartViewmodelWatcher()
            else
                StopViewmodelWatcher()
            end
        end, y)

        y = g:CreateToggle("Rainbow Mode", false, function(state)
            GunMods.Config.ChamsRainbow = state
        end, y)

        y = g:CreateToggle("Cham Arms", false, function(state)
            GunMods.Config.ChamArms = state
            if GunMods.Config.ChamsEnabled and Viewmodel.CurrentModel then
                RestoreViewmodelParts()
                ApplyChamsToViewmodel(Viewmodel.CurrentModel, GunMods.Config.ChamsColor)
            end
        end, y)

        y = g:CreateSlider("Rainbow Speed", 1, 10, GunMods.Config.ChamsRainbowSpeed, function(val)
            GunMods.Config.ChamsRainbowSpeed = val
        end, y)

        y = g:CreateSlider("Transparency", 0, 80, math.floor(GunMods.Config.ChamsTransparency * 100), function(val)
            GunMods.Config.ChamsTransparency = val / 100
            if GunMods.Config.ChamsEnabled and Viewmodel.CurrentModel then
                ApplyChamsToViewmodel(Viewmodel.CurrentModel, GunMods.Config.ChamsColor)
            end
        end, y)

        local Materials = {
            "Neon", "ForceField", "Glass", "SmoothPlastic", "Metal",
            "Wood", "Granite", "Marble", "Brick", "Pebble", "Sand",
            "Fabric", "Foil", "Grass", "Ice", "DiamondPlate",
            "Aluminum", "Gold", "Silver", "WoodPlanks", "Cobblestone",
            "Concrete", "CorrodedMetal"
        }

        y = g:CreateDropdown("Material", Materials, GunMods.Config.ChamsMaterial, function(val)
            GunMods.Config.ChamsMaterial = val
            if GunMods.Config.ChamsEnabled and Viewmodel.CurrentModel then
                ApplyChamsToViewmodel(Viewmodel.CurrentModel, GunMods.Config.ChamsColor)
            end
        end, y)

        y = g:CreateSection("Cham Colors", y + 10)

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

        for _, preset in ipairs(ColorPresets) do
            y = g:CreateButton(preset.Name, function()
                GunMods.Config.ChamsColor = preset.Color
                GunMods.Config.ChamsRainbow = false
                if GunMods.Config.ChamsEnabled and Viewmodel.CurrentModel then
                    ApplyChamsToViewmodel(Viewmodel.CurrentModel, preset.Color)
                end
            end, y)
        end

        g.Content = originalContent
    end)

    if LocalPlayer.Character then SetupCharacter(LocalPlayer.Character) end

    LocalPlayer.CharacterAdded:Connect(function(char)
        CurrentTool = nil
        task.wait(0.5)
        SetupCharacter(char)
        if GunMods.Config.NoRecoil then ModStates.NoRecoil.Active = true ApplySingleMod("NoRecoil") end
        if GunMods.Config.NoSpread then ModStates.NoSpread.Active = true ApplySingleMod("NoSpread") end
        if GunMods.Config.RapidFire then ModStates.RapidFire.Active = true ApplySingleMod("RapidFire") end
        if GunMods.Config.FastReload then ModStates.FastReload.Active = true ApplySingleMod("FastReload") end
        if GunMods.Config.InfiniteAmmo then ApplyInfiniteAmmo() end
        if GunMods.Config.ChamsEnabled then
            task.wait(1)
            for _, child in ipairs(Camera:GetChildren()) do
                if IsViewmodelModel(child) then
                    OnViewmodelChanged(child)
                    break
                end
            end
        end
    end)

    print("[ENI] Gun Mods + Viewmodel Chams + Always Auto loaded")
    return self
end

return GunMods
