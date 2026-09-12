--[[
    Arsenal Suite — Skin Changer Module (Blackout.cc)
    By ENI for LO ♥
    v4 — Z3US Skin Changer integrated (Announcer, Knife Replacer, Camo, Chattags)
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

--// Z3US DATA COLLECTION

local Data = LocalPlayer:WaitForChild("Data")
local AnnouncerValue = Data:WaitForChild("Announcer")
local EquippedValue = LocalPlayer:WaitForChild("Equipped")

-- Collect all announcers from game
local Z3USAnnouncerList = {"None"}
local AnnouncerFolder = ReplicatedStorage:WaitForChild("ItemData"):WaitForChild("Images"):WaitForChild("Announcers")
for _, child in ipairs(AnnouncerFolder:GetChildren()) do
    table.insert(Z3USAnnouncerList, child.Name)
end

-- Collect all melees for knife replacer
local Z3USMeleeList = {"None"}
local MeleeFolder = ReplicatedStorage:WaitForChild("Melees")
for _, child in ipairs(MeleeFolder:GetChildren()) do
    table.insert(Z3USMeleeList, child.Name)
end

-- Collect all camos/skins
local Z3USCamoList = {"None"}
local SkinsFolder = ReplicatedStorage:WaitForChild("Skins")
for _, child in ipairs(SkinsFolder:GetChildren()) do
    table.insert(Z3USCamoList, child.Name)
end

print("[SkinChanger] Loaded " .. #Z3USAnnouncerList .. " announcers, " .. #Z3USMeleeList .. " melees, " .. #Z3USCamoList .. " camos")

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

--// Z3US SKIN CHANGER FUNCTIONS

local function Z3USChangeAnnouncer(announcerName)
    if announcerName == "None" then
        AnnouncerValue.Value = "Default"
    else
        AnnouncerValue.Value = announcerName
    end
    print("[Z3US] Announcer: " .. announcerName)
end

local function Z3USReplaceKnife(knifeName)
    if knifeName == "None" then return end

    local Viewmodels = ReplicatedStorage:WaitForChild("Viewmodels")
    local Images = ReplicatedStorage:WaitForChild("ItemData"):WaitForChild("Images"):WaitForChild("Melees")
    local KillIcons = ReplicatedStorage:WaitForChild("KillIcons")

    if Viewmodels:FindFirstChild("v_" .. knifeName) then
        if Viewmodels:FindFirstChild("v_Dagger") then
            Viewmodels.v_Dagger:Destroy()
        end
        task.wait()

        local newKnife = Viewmodels["v_" .. knifeName]:Clone()
        newKnife.Parent = Viewmodels
        newKnife.Name = "v_Dagger"

        if Images:FindFirstChild("Dagger") and Images:FindFirstChild(knifeName) then
            Images.Dagger.Quality.Value = Images[knifeName].Quality.Value
            Images.Dagger.Value = Images[knifeName].Value
        end

        if KillIcons:FindFirstChild("Dagger") and KillIcons:FindFirstChild(knifeName) then
            KillIcons.Dagger.Value = KillIcons[knifeName].Value
        end

        print("[Z3US] Knife: " .. knifeName)
    else
        warn("[Z3US] Knife not found: " .. knifeName)
    end
end

local function Z3USChangeCamo(camoName)
    if camoName == "None" then
        EquippedValue.Value = ""
    else
        EquippedValue.Value = camoName
    end
    print("[Z3US] Camo: " .. camoName)
end

local function Z3USToggleChatTag(tagName, enabled)
    local player = LocalPlayer
    if enabled then
        if not player:FindFirstChild(tagName) then
            Instance.new("IntValue", player).Name = tagName
        end
    else
        if player:FindFirstChild(tagName) then
            player[tagName]:Destroy()
        end
    end
end

--// ARMS — fixed with original-name caching

local function CacheArmOriginalNames(armsFolder)
    for _, child in ipairs(armsFolder:GetChildren()) do
        if not child:GetAttribute("ENI_OriginalName") then
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

local function FixInvisible()
    RevertArms()
    RevertMelee()

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

    print("[ENI] Fix Invisible applied")
end

--// GUI

function SkinChanger:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Skin Changer", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        --// ORIGINAL SECTIONS
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

        --// Z3US SKIN CHANGER SECTION
        y = g:CreateSection("Z3US Skin Changer", y + 10)

        y = g:CreateDropdown("Z3US Announcer", Z3USAnnouncerList, "None", function(val)
            Z3USChangeAnnouncer(val)
        end, y)

        y = g:CreateDropdown("Replace Knife", Z3USMeleeList, "None", function(val)
            Z3USReplaceKnife(val)
        end, y)

        y = g:CreateDropdown("Weapon Camo", Z3USCamoList, "None", function(val)
            Z3USChangeCamo(val)
        end, y)

        --// Z3US CHAT TAGS
        y = g:CreateSection("Chat Tags (Client-Side)", y + 10)

        y = g:CreateToggle("Chad", false, function(state)
            Z3USToggleChatTag("IsChad", state)
        end, y)

        y = g:CreateToggle("VIP", false, function(state)
            Z3USToggleChatTag("VIP", state)
        end, y)

        y = g:CreateToggle("OldVIP", false, function(state)
            Z3USToggleChatTag("OldVIP", state)
        end, y)

        y = g:CreateToggle("Romin", false, function(state)
            Z3USToggleChatTag("Romin", state)
        end, y)

        y = g:CreateToggle("Admin", false, function(state)
            Z3USToggleChatTag("IsAdmin", state)
        end, y)

        --// RESET SECTION
        y = g:CreateSection("Reset", y + 10)
        y = g:CreateButton("Revert Melee to Dagger", function()
            RevertMelee()
        end, y)

        y = g:CreateButton("Fix Invisible Arms/Weapon", function()
            FixInvisible()
        end, y)

        g.Content = originalContent
    end)

    print("[ENI] Skin Changer loaded with Z3US features")
    return self
end

return SkinChanger
