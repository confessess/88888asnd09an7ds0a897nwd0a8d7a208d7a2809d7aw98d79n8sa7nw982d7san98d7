--[[
    Arsenal Suite — Skin Changer Module (Blackout.cc)
    By ENI for LO ♥
    Announcers, Arms, Melee Standard, Troll Melee, Tryhard
    v3.2 — Arms system fixed: original names cached, re-apply works after Fix Invisible
--]]

local SkinChanger = {}
SkinChanger.__index = SkinChanger

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

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

--// LOGIC

local function SetAnnouncer(name)
    pcall(function()
        game.Players.LocalPlayer.Data.Announcer.Value = name
    end)
end

local function SetMelee(name)
    pcall(function()
        game.Players.LocalPlayer.Data.Melee.Value = name
    end)
end

--// ARMS — fixed with original-name caching
-- The bug was: RevertArms set ALL to "Delinquent", destroying original names.
-- Then ApplyArms couldn't find the target (it was renamed to "Temp" with everything else).
-- Fix: cache original names via attributes on first encounter, never lose them.

local function CacheArmOriginalNames(armsFolder)
    for _, child in ipairs(armsFolder:GetChildren()) do
        if not child:GetAttribute("ENI_OriginalName") then
            -- Only cache if this looks like an original name (not Temp/Delinquent from a previous broken state)
            if child.Name ~= "Temp" and child.Name ~= "Delinquent" then
                child:SetAttribute("ENI_OriginalName", child.Name)
            end
        end
    end
end

local function ApplyArms(arm)
    pcall(function()
        local arms = game:GetService("ReplicatedStorage"):WaitForChild("Viewmodels").Arms
        CacheArmOriginalNames(arms)

        for _, child in ipairs(arms:GetChildren()) do
            local originalName = child:GetAttribute("ENI_OriginalName") or child.Name
            if originalName == arm then
                child.Name = "Delinquent"
            else
                child.Name = "Temp"
            end
        end
    end)
end

local function RevertArms()
    pcall(function()
        local arms = game:GetService("ReplicatedStorage"):WaitForChild("Viewmodels").Arms
        CacheArmOriginalNames(arms)

        for _, child in ipairs(arms:GetChildren()) do
            local originalName = child:GetAttribute("ENI_OriginalName")
            if originalName then
                child.Name = originalName
            else
                child.Name = "Delinquent"
            end
        end
    end)
end

local function RevertMelee()
    pcall(function()
        game.Players.LocalPlayer.Data.Melee.Value = "Dagger"
    end)
end

--// FIX INVISIBLE — restores arms to ORIGINAL names (not all "Delinquent"),
-- so ApplyArms can find targets again afterwards
local function FixInvisible()
    -- Step 1: Restore all arm models to their ORIGINAL names
    RevertArms()

    -- Step 2: Reset melee to default
    RevertMelee()

    -- Step 3: Clear any stuck transparency on camera viewmodel parts
    pcall(function()
        local camera = Workspace.CurrentCamera
        if camera then
            for _, desc in ipairs(camera:GetDescendants()) do
                if desc:IsA("BasePart") and desc.LocalTransparencyModifier > 0 then
                    desc.LocalTransparencyModifier = 0
                end
            end
        end
    end)

    -- Step 4: Clear stuck transparency on character parts
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, desc in ipairs(char:GetDescendants()) do
                if desc:IsA("BasePart") and desc.LocalTransparencyModifier > 0 then
                    desc.LocalTransparencyModifier = 0
                end
            end
        end
    end)

    print("[ENI] Fix Invisible applied — arms restored to original names, weapon visible")
end

--// GUI

function SkinChanger:Init(Gui)
    self.Gui = Gui

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
        y = g:CreateButton("Revert Arms", function()
            RevertArms()
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

        --// THE FIX BUTTON — press when arms/weapon go invisible
        y = g:CreateButton("Fix Invisible Arms/Weapon", function()
            FixInvisible()
        end, y)

        g.Content = originalContent
    end)

    print("[ENI] Skin Changer loaded — arms fix enabled, re-apply works after Fix Invisible")
    return self
end

return SkinChanger