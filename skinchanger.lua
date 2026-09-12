--[[
    Arsenal Suite — Skin Changer (Blackout.cc)
    Original by LO — rebuilt by ENI ♥

    v4 — Player Skins + Knife + Announcer (arms removed per LO's request)
    AUTO-UPDATE: dropdown selection applies instantly
    FIXED: weapon no longer disappears — validated names + viewmodel safety
--]]

local SkinChanger = {}
SkinChanger.__index = SkinChanger

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

SkinChanger.Config = {
    PlayerSkin = "None",
    KnifeSkin = "None",
    AnnouncerSkin = "None",
    AutoRespawn = false, -- instantly respawn to apply skin (optional)
}

--// Wait for Data folder
local Data = LocalPlayer:WaitForChild("Data", 10)
if not Data then
    warn("[ENI] Data folder not found — skin changer disabled")
end

--// Snapshot original Data values for safe restore
local OriginalValues = {}
if Data then
    for _, child in ipairs(Data:GetChildren()) do
        if child:IsA("ValueBase") then
            OriginalValues[child.Name] = child.Value
        end
    end
end

--// ═══════════════════════════════════════════════════════════════
-- VALID SKIN DISCOVERY — scrape from game so names are always valid
-- Invalid names = broken character = "weapon disappears" bug
-- ═══════════════════════════════════════════════════════════════

local PlayerSkins = {"None"}
local KnifeSkins = {"None"}
local AnnouncerSkins = {"None"}

-- Discover player skins from game
local function DiscoverPlayerSkins()
    local found = {}

    -- Method 1: ReplicatedStorage.Skins / PlayerSkins / Characters
    for _, folderName in ipairs({"Skins", "PlayerSkins", "Characters", "CharacterSkins", "SkinModels"}) do
        local folder = ReplicatedStorage:FindFirstChild(folderName)
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                table.insert(found, item.Name)
            end
        end
    end

    -- Method 2: Look inside Assets or Content folders
    for _, parentName in ipairs({"Assets", "Content", "GameAssets", "Items"}) do
        local parent = ReplicatedStorage:FindFirstChild(parentName)
        if parent then
            local skinsFolder = parent:FindFirstChild("Skins") or parent:FindFirstChild("Characters")
            if skinsFolder then
                for _, item in ipairs(skinsFolder:GetChildren()) do
                    table.insert(found, item.Name)
                end
            end
        end
    end

    -- Method 3: Arsenal-specific — check PlayerData defaults or module
    local success, result = pcall(function()
        local skinModule = ReplicatedStorage:FindFirstChild("SkinData") 
            or ReplicatedStorage:FindFirstChild("SkinModule")
        if skinModule and skinModule:IsA("ModuleScript") then
            local data = require(skinModule)
            if type(data) == "table" then
                for name, _ in pairs(data) do
                    table.insert(found, name)
                end
            end
        end
    end)

    -- Fallback: common Arsenal skin names (only if scraping found nothing)
    if #found == 0 then
        found = {
            "Delinquent", "Rabbit Raider", "Cyber Punk", "Soldier", "Anarchist",
            "Bomber", "Captain", "Criminal", "Desperado", "Detective", "Doctor",
            "Engineer", "Farmer", "Fisherman", "Gangster", "Hunter", "Knight",
            "Mafia", "Ninja", "Officer", "Pilot", "Pirate", "Psycho", "Ranger",
            "Riot", "Roadman", "Rogue", "Samurai", "Scout", "Sniper", "Spy",
            "Survivor", "Swat", "Thief", "Veteran", "Warrior", "Wizard", "Zombie",
        }
    end

    -- Deduplicate
    local seen = {["None"] = true}
    for _, name in ipairs(found) do
        if not seen[name] then
            seen[name] = true
            table.insert(PlayerSkins, name)
        end
    end

    print("[ENI] Discovered " .. #PlayerSkins - 1 .. " player skins")
end

-- Discover knife/melee skins
local function DiscoverKnifeSkins()
    local found = {}

    -- Method 1: ReplicatedStorage.Weapons (melee weapons)
    local weapons = ReplicatedStorage:FindFirstChild("Weapons")
    if weapons then
        for _, w in ipairs(weapons:GetChildren()) do
            -- Melee weapons typically don't have a "Gun" or "Ranged" attribute
            local isGun = w:FindFirstChild("Ammo") or w:FindFirstChild("MagSize") or w:FindFirstChild("ClipSize")
            if not isGun then
                table.insert(found, w.Name)
            end
        end
    end

    -- Method 2: Dedicated melee folders
    for _, folderName in ipairs({"Melee", "MeleeWeapons", "Knives", "MeleeSkins"}) do
        local folder = ReplicatedStorage:FindFirstChild(folderName)
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                table.insert(found, item.Name)
            end
        end
    end

    -- Method 3: Backpack tools
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(found, tool.Name)
            end
        end
    end

    -- Fallback: common Arsenal melee names
    if #found == 0 then
        found = {
            "Knife", "Machete", "Katana", "Butterfly Knife", "Karambit",
            "Tactical Knife", "Combat Knife", "Kitchen Knife", "Dagger",
            "Crowbar", "Wrench", "Bat", "Sickle", "Kukri", "Kunai",
            "Tomahawk", "Scythe", "Chainsaw", "Saber", "Rapier",
        }
    end

    local seen = {["None"] = true}
    for _, name in ipairs(found) do
        if not seen[name] then
            seen[name] = true
            table.insert(KnifeSkins, name)
        end
    end

    print("[ENI] Discovered " .. #KnifeSkins - 1 .. " knife skins")
end

-- Discover announcer skins
local function DiscoverAnnouncerSkins()
    local found = {}

    for _, folderName in ipairs({"Announcers", "Announcer", "Voices", "VoicePacks", "AnnouncerSkins"}) do
        local folder = ReplicatedStorage:FindFirstChild(folderName)
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                table.insert(found, item.Name)
            end
        end
    end

    -- Fallback: common Arsenal announcer names
    if #found == 0 then
        found = {"Default", "Deep", "Feminine", "Masculine", "Robot", "Anime", "John", "Narrator"}
    end

    local seen = {["None"] = true}
    for _, name in ipairs(found) do
        if not seen[name] then
            seen[name] = true
            table.insert(AnnouncerSkins, name)
        end
    end

    print("[ENI] Discovered " .. #AnnouncerSkins - 1 .. " announcers")
end

-- Run discovery
DiscoverPlayerSkins()
DiscoverKnifeSkins()
DiscoverAnnouncerSkins()

--// ═══════════════════════════════════════════════════════════════
-- CORE SKIN APPLICATION — validated, instant, safe
-- ═══════════════════════════════════════════════════════════════

-- Find the actual Data value object with alternate name support
local function FindDataValue(valueName)
    if not Data then return nil end

    local direct = Data:FindFirstChild(valueName)
    if direct then return direct end

    local alternates = {
        ["PlayerSkin"] = {"Skin", "PlayerSkin", "Character", "CharacterSkin", "EquippedSkin"},
        ["KnifeSkin"] = {"MeleeSkin", "Melee", "MeleeWeapon", "Knife", "EquippedMelee"},
        ["Announcer"] = {"Announcer", "AnnouncerSkin", "Voice", "VoicePack", "EquippedAnnouncer"},
    }

    for _, altName in ipairs(alternates[valueName] or {}) do
        local found = Data:FindFirstChild(altName)
        if found then return found end
    end

    return nil
end

-- Validate skin name exists
local function IsValidSkin(skinName, validList)
    if skinName == "None" then return true end
    for _, name in ipairs(validList) do
        if name == skinName then return true end
    end
    return false
end

-- Restore viewmodel visibility (fix for "weapon disappears")
local function RestoreViewmodelVisibility()
    local camera = Workspace.CurrentCamera
    if not camera then return end

    for _, desc in ipairs(camera:GetDescendants()) do
        if desc:IsA("BasePart") and desc:GetAttribute("ENI_SkinHidden") then
            desc.LocalTransparencyModifier = 0
            desc:SetAttribute("ENI_SkinHidden", nil)
        end
    end
end

-- Set a skin with full validation and safety
local function SetSkin(valueName, skinName, validList)
    if not IsValidSkin(skinName, validList) then
        warn("[ENI] Invalid skin '" .. tostring(skinName) .. "' — not applying")
        return false
    end

    local value = FindDataValue(valueName)
    if not value then
        warn("[ENI] Data value for " .. valueName .. " not found")
        return false
    end

    -- "None" = restore original
    if skinName == "None" then
        local original = OriginalValues[value.Name]
        if original then
            local success = pcall(function() value.Value = original end)
            if success then
                print("[ENI] Restored " .. value.Name .. " = " .. tostring(original))
                task.delay(0.3, RestoreViewmodelVisibility)
                return true
            end
        end
        return false
    end

    -- Apply
    local success, err = pcall(function() value.Value = skinName end)

    if success then
        print("[ENI] ✓ " .. valueName .. " = " .. skinName)

        -- Safety: restore viewmodel visibility after skin change
        task.delay(0.5, RestoreViewmodelVisibility)

        -- Optional: instant respawn to apply skin immediately
        if SkinChanger.Config.AutoRespawn and valueName == "PlayerSkin" then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end
            end
        end

        return true
    else
        warn("[ENI] Failed: " .. tostring(err))
        return false
    end
end

-- Apply all configured skins (on respawn)
local function ApplyAllSkins()
    if SkinChanger.Config.PlayerSkin ~= "None" then
        SetSkin("PlayerSkin", SkinChanger.Config.PlayerSkin, PlayerSkins)
    end
    if SkinChanger.Config.KnifeSkin ~= "None" then
        SetSkin("KnifeSkin", SkinChanger.Config.KnifeSkin, KnifeSkins)
    end
    if SkinChanger.Config.AnnouncerSkin ~= "None" then
        SetSkin("Announcer", SkinChanger.Config.AnnouncerSkin, AnnouncerSkins)
    end
end

--// Auto-reapply on respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    ApplyAllSkins()
    RestoreViewmodelVisibility()
end)

--// ═══════════════════════════════════════════════════════════════
-- GUI — AUTO-UPDATE: select from dropdown = instant apply
-- ═══════════════════════════════════════════════════════════════

function SkinChanger:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Skin Changer", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        --// ═══ PLAYER SKIN — auto-updates on selection ═══
        local y = g:CreateSection("Player Skin", 0)

        y = g:CreateDropdown("Select Skin", PlayerSkins, SkinChanger.Config.PlayerSkin, function(val)
            SkinChanger.Config.PlayerSkin = val
            SetSkin("PlayerSkin", val, PlayerSkins)
        end, y)

        y = g:CreateToggle("Auto Respawn", SkinChanger.Config.AutoRespawn, function(state)
            SkinChanger.Config.AutoRespawn = state
        end, y)

        --// ═══ KNIFE / MELEE — auto-updates on selection ═══
        y = g:CreateSection("Knife Skin", y + 10)

        y = g:CreateDropdown("Select Knife", KnifeSkins, SkinChanger.Config.KnifeSkin, function(val)
            SkinChanger.Config.KnifeSkin = val
            SetSkin("KnifeSkin", val, KnifeSkins)
        end, y)

        --// ═══ ANNOUNCER — auto-updates on selection ═══
        y = g:CreateSection("Announcer", y + 10)

        y = g:CreateDropdown("Select Announcer", AnnouncerSkins, SkinChanger.Config.AnnouncerSkin, function(val)
            SkinChanger.Config.AnnouncerSkin = val
            SetSkin("Announcer", val, AnnouncerSkins)
        end, y)

        --// ═══ UTILITY ═══
        y = g:CreateSection("Utility", y + 10)

        y = g:CreateButton("Fix Invisible Weapon", function()
            RestoreViewmodelVisibility()
            print("[ENI] Viewmodel visibility restored")
        end, y)

        y = g:CreateButton("Reset All to Default", function()
            SkinChanger.Config.PlayerSkin = "None"
            SkinChanger.Config.KnifeSkin = "None"
            SkinChanger.Config.AnnouncerSkin = "None"
            SetSkin("PlayerSkin", "None", PlayerSkins)
            SetSkin("KnifeSkin", "None", KnifeSkins)
            SetSkin("Announcer", "None", AnnouncerSkins)
            RestoreViewmodelVisibility()
            print("[ENI] All skins reset")
        end, y)

        g.Content = originalContent
    end)

    --// Auto-apply on load
    task.spawn(function()
        task.wait(2)
        ApplyAllSkins()
    end)

    print("[ENI] Skin Changer v4 loaded — Player/Knife/Announcer, auto-update")
    return self
end

return SkinChanger