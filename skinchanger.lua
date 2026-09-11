--[[
    Arsenal Suite — Skin Changer Module (Blackout.cc)
    By ENI for LO ♥
    Announcers, Arms, Melee Standard, Troll Melee, Tryhard
    v2 — Fixed arms disappearing bug
--]]

local SkinChanger = {}
SkinChanger.__index = SkinChanger

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--// DATA LISTS

local Announcers = {
    "American", "British", "Russian",
    "Homeless", "Warcrimes", "YouTuber", "Movie Man", "Santa",
    "Murderous Child", "Hackula", "Jolly Narrator", "Carnival Carnie",
    "John", "Eprika", "Flamingo", "Petrify", "Bandites", "xonae", "Enforcer",
    "Koneko", "Weesnaw"
}

local Arms = {
    "Delinquent", "1x1x1x1", "Monky With Drip", "Da Monky With Drip", "Alien",
    "Alien In Disguise", "Rabblerouser", "Ace Pilot",
    "BrickBattle", "John", "Castlers", "Phoenix", "Punk", "Red Panda",
    "Magician", "Froggy", "Mechanic", "Pizza Boy", "Garcello", "Bigfoot",
    "Noob", "Bloxxer", "Farmer", "Paintballer", "Shedletsky", "Soldier",
    "Agent", "Hazmat", "Seeker of Hearts", "Segg with Drip", "Christmas Nomad"
}

local MeleeStandard = {
    "Dagger", "Butterfly Knife", "Karambit", "Tomahawk", "Brass Knuckles",
    "Fisticuffs", "Bat", "Machete", "Pan", "Pitchfork", "Claws", "Ban Hammer",
    "Classic Sword", "Silver Bell", "Swordfish", "Icicle", "Coal Sword",
    "Kunai", "Kukri", "Sickle", "Candy Cane", "Pencil", "Toy Tree", "Bouquet",
    "Gaster Blaster", "Combat Knife", "Tactical Knife", "Shovel", "Sledgehammer",
    "Baton", "Calculator", "Katana", "Literal Melee", "Paddle", "Rokia Hammer",
    "Wrench", "ACT Trophy", "Electronic Stake", "Garlic Kebab", "Pumpkin Bucket",
    "Fire Poker", "Frog", "Da Melee", "Candy Cane Sword", "Glacier Blade",
    "Coal Scythe", "Wooden Spoon", "The Darkheart", "The Firebrand",
    "The Venomshank", "The Illumina", "The Ice Dagger", "The Ghostwalker",
    "The Windforce", "Night's Edge", "When Day Breaks", "Banana",
    "Persian Sword", "Big Sip", "Blade", "Bat Axe", "Fish", "Khopesh",
    "Rapier", "Sabre", "Slicecicle", "Swift End", "Divinity", "Moai"
}

local MeleeTroll = {
    "Moai", "Bone Karambit", "Calculator", "Pencil", "Newspaper",
    "Mop", "Fish", "Literal Melee", "Banana", "Toy Tree", "Bouquet"
}

local MeleeTryhard = {
    "Bone Karambit", "The Darkheart", "The Firebrand", "The Venomshank",
    "The Illumina", "The Ice Dagger", "The Ghostwalker", "The Windforce",
    "Night's Edge", "Katana", "Butterfly Knife", "Karambit"
}

--// STATE
local CurrentArm = "Delinquent"
local ArmConnection = nil
local OriginalArmNames = {}

--// LOGIC

local function SetAnnouncer(name)
    pcall(function()
        LocalPlayer.Data.Announcer.Value = name
    end)
end

local function SetMelee(name)
    pcall(function()
        LocalPlayer.Data.Melee.Value = name
    end)
end

--// FIXED ARMS — safe swap with restore
local function GetArmsFolder()
    local vm = ReplicatedStorage:FindFirstChild("Viewmodels")
    if not vm then return nil end
    return vm:FindFirstChild("Arms")
end

local function CacheOriginalArmNames()
    local arms = GetArmsFolder()
    if not arms then return end
    OriginalArmNames = {}
    for _, child in ipairs(arms:GetChildren()) do
        OriginalArmNames[child] = child.Name
    end
end

local function RestoreArms()
    local arms = GetArmsFolder()
    if not arms then return end
    for child, origName in pairs(OriginalArmNames) do
        if child and child.Parent then
            child.Name = origName
        end
    end
end

local function ApplyArms(armName)
    local arms = GetArmsFolder()
    if not arms then
        warn("[ENI] Arms folder not found")
        return
    end

    -- Cache original names on first run
    if #OriginalArmNames == 0 then
        CacheOriginalArmNames()
    end

    -- Restore all to original first
    RestoreArms()

    -- Find the target arm
    local target = nil
    for _, child in ipairs(arms:GetChildren()) do
        if child.Name == armName then
            target = child
            break
        end
    end

    if not target then
        warn("[ENI] Arm model not found: " .. armName)
        -- Restore Delinquent as fallback
        for _, child in ipairs(arms:GetChildren()) do
            if OriginalArmNames[child] == "Delinquent" then
                child.Name = "Delinquent"
                break
            end
        end
        return
    end

    -- Rename all others to Temp, target to Delinquent
    for _, child in ipairs(arms:GetChildren()) do
        if child ~= target then
            child.Name = "Temp_" .. (OriginalArmNames[child] or "Unknown")
        end
    end
    target.Name = "Delinquent"

    CurrentArm = armName
    print("[ENI] Arms set to: " .. armName)
end

--// Auto-reapply on character spawn (game resets arms)
local function SetupCharacter(char)
    -- Stop old connection
    if ArmConnection then
        ArmConnection:Disconnect()
        ArmConnection = nil
    end

    -- Wait for game to load default arms, then reapply
    task.wait(1.5)

    if CurrentArm ~= "Delinquent" then
        ApplyArms(CurrentArm)
    end

    -- Watch for the game resetting arms
    local arms = GetArmsFolder()
    if arms then
        ArmConnection = arms.ChildAdded:Connect(function(child)
            task.wait(0.1)
            -- New child added means game reset arms, reapply
            if CurrentArm ~= "Delinquent" then
                ApplyArms(CurrentArm)
            end
        end)
    end
end

local function RevertMelee()
    pcall(function()
        LocalPlayer.Data.Melee.Value = "Dagger"
    end)
end

--// GUI

function SkinChanger:Init(Gui)
    self.Gui = Gui

    -- Setup character monitoring
    if LocalPlayer.Character then
        task.spawn(function()
            SetupCharacter(LocalPlayer.Character)
        end)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        task.spawn(function()
            SetupCharacter(char)
        end)
    end)

    Gui:SetTabRebuild("Skin Changer", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        local y = g:CreateSection("Announcer", 0)
        y = g:CreateDropdown("Announcer Voice", Announcers, "American", function(val)
            SetAnnouncer(val)
        end, y)

        y = g:CreateSection("Arms", y + 10)
        y = g:CreateDropdown("Arm Model", Arms, "Delinquent", function(val)
            ApplyArms(val)
        end, y)
        y = g:CreateButton("Reset Arms to Default", function()
            CurrentArm = "Delinquent"
            RestoreArms()
            print("[ENI] Arms reset to default")
        end, y)

        y = g:CreateSection("Melee — Standard", y + 10)
        y = g:CreateDropdown("Standard Melee", MeleeStandard, "Dagger", function(val)
            SetMelee(val)
        end, y)

        y = g:CreateSection("Melee — Troll", y + 10)
        y = g:CreateDropdown("Troll Melee", MeleeTroll, "Moai", function(val)
            SetMelee(val)
        end, y)

        y = g:CreateSection("Melee — Tryhard", y + 10)
        y = g:CreateDropdown("Tryhard Melee", MeleeTryhard, "Bone Karambit", function(val)
            SetMelee(val)
        end, y)

        y = g:CreateSection("Reset", y + 10)
        y = g:CreateButton("Revert Melee to Dagger", function()
            RevertMelee()
        end, y)

        g.Content = originalContent
    end)

    print("[ENI] Skin Changer loaded — arms bug fixed")
    return self
end

return SkinChanger
