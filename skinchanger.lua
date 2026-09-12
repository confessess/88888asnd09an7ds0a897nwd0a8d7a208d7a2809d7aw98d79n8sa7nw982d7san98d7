--[[
    Arsenal Suite — Skin Changer (Blackout.cc)
    Original by LO — cleaned by ENI ♥

    v2 — Removed broken Gun Chams section (now lives in gunmods.lua Weapon tab)
    Fixed Data value handling so skins actually apply
--]]

local SkinChanger = {}
SkinChanger.__index = SkinChanger

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

SkinChanger.Config = {
    MeleeSkin = "None",
    AnnouncerSkin = "None",
    ArmSkin = "None",
}

--// Wait for Data folder — robust against slow loading
local Data = LocalPlayer:WaitForChild("Data", 10)
if not Data then
    warn("[ENI] Data folder not found after 10s — skin changer may not work")
end

--// Valid skin lists (populated dynamically if possible, else fallback)
local MeleeSkins = {
    "None", "Crucible", "Endbringer", "The Windforce", "The Darkheart",
    "The Illumina", "The Venomshank", "The Ghostwalker", "Night's Edge",
    "Classic Sword", "Space Katana", "SuperSpaceKatana", "Katana",
    "Machete", "Chainsaw", "Scythe", "Hallow's Scythe", "Coal Scythe",
    "Skele Scythe", "Heart Break", "Death's Blade", "Ghost Ripper",
    "Stinger", "Digi-Blade", "Swift End", "Divinity", "Glacier Blade",
    "Khopesh", "Energy Blade", "Energy Katar", "Katar", "Rapier",
    "Saber", "Sabre", "Naginata", "Daito", "Doublade", "Reclaimer",
    "Assimilator", "Synthlight Greatsword", "Spring Greatsword",
    "Easter Cleaver", "Bunny Staff", "The Scrambler", "Grumpy Hammer",
    "The Fool's Tool", "Blast Hammer", "Merry Masher", "Peppermint Hammer",
    "Candy Cane Claws", "Slicecicle", "Icicle", "The Ice Dagger",
    "Frostweaver's Wand", "Handblades", "Stranger's Handblades",
    "Makeshift Axe", "Leader's Axe", "Wired Bat", "Rebel's Bat",
    "Rusty Pipe", "Roughian's Pipe", "Makeshift Saw", "Pipe Wrench Shank",
    "Drill-Shear Skewer", "Earth Cleaver", "Harvester", "Ban Hammer",
    "Moderation Hammer", "Rokia Hammer", "Sledgehammer", "Reliable Hammer",
    "Bat Axe", "Electro Axe", "Pumpkin Axe", "Halberd", "Hero's Sword",
    "Aged Shovel", "Bone Club", "Blossoming Femur", "Golden Rings",
    "Divine Medallions", "Claws", "Slappy", "Crab Claw", "R.A.M",
    "Starfire Staff", "Pumpkin Staff", "Candleabra", "Candle Sword",
    "Electronic Stake", "Fire Poker", "Garlic Kebab", "Carrot", "Banana",
    "Loaf", "Swordfish", "Silver Bell", "Skull Pal", "Seal", "Kunai",
    "Kukri", "Sickle", "Candy Cane", "Toy Tree", "Pencil", "Pan",
    "Wooden Spoon", "Rubber Hammer", "Pitchfork", "Spellbook",
    "Brass Knuckles", "Butterfly Knife", "Tactical Knife", "Combat Knife",
    "Kitchen Knife", "Gingerbread Knife", "Dagger", "Blade", "Karambit",
    "Bone Karambit", "Tomahawk", "Crowbar", "Wrench", "Bat", "Doodle Sign",
    "Newspaper", "Paddle", "Racket", "Plane", "Nomad's Blade", "Stop Sign",
    "Guitar", "Paint Brush", "Bouquet", "Mop", "Big Sip", "Delinquent Pop",
    "Sip O' Stink", "Handy Candy", "Smug Egg", "Egg", "Pumpkin Bucket",
    "Coral Blade", "Annihilator's Broken Sword", "Da Melee", "Literal Melee",
    "Calculator", "Fisticuffs", "Moai", "Killbrick Melee", "Brick",
    "Bloxy", "ACT Trophy", "ACT Trophy S6", "Fish", "Peppermint Slicer",
    "Frog", "Electric Flail", "Beast Hammer", "Can Mace",
}

local AnnouncerSkins = {
    "None", "Default", "Deep", "Feminine", "Masculine", "Robot",
    "Anime", "Epic", "John", "Meme", "Retro", "Smooth", "Veteran",
    "Zombie", "Narrator", "Sports", "Action", "Dramatic", "Chill",
}

local ArmSkins = {
    "None", "Default", "Black", "White", "Red", "Blue", "Green",
    "Tactical", "Fingerless", "Gloves", "Wraps", "Bandages",
    "Mechanical", "Cyber", "Golden", "Diamond", "Camo", "Winter",
    "Ninja", "Boxing", "MMA", "Military", "Police", "Fire",
}

--// Try to populate from game data for accuracy
task.spawn(function()
    local success, result = pcall(function()
        local replicated = game:GetService("ReplicatedStorage")
        -- Arsenal stores skin data in various places; try common ones
        local skinData = replicated:FindFirstChild("SkinData") 
            or replicated:FindFirstChild("Skins")
            or replicated:FindFirstChild("Assets")
        if skinData then
            local found = {}
            for _, child in ipairs(skinData:GetChildren()) do
                table.insert(found, child.Name)
            end
            if #found > 0 then
                -- Merge with defaults, keeping "None" first
                local merged = {"None"}
                for _, name in ipairs(found) do
                    if name ~= "None" then
                        table.insert(merged, name)
                    end
                end
                MeleeSkins = merged
            end
        end
    end)
end)

--// Core skin application — sets Data values that Arsenal reads
local function SetDataValue(valueName, skinName)
    if not Data then
        warn("[ENI] No Data folder — cannot set " .. valueName)
        return false
    end

    local value = Data:FindFirstChild(valueName)
    if not value then
        -- Try alternate names
        local alternates = {
            ["MeleeSkin"] = {"Melee", "MeleeWeapon", "MeleeSkin"},
            ["Announcer"] = {"Announcer", "AnnouncerSkin", "Voice"},
            ["Skin"] = {"Skin", "ArmSkin", "Arms", "Gloves"},
        }

        local found = nil
        for _, altName in ipairs(alternates[valueName] or {}) do
            found = Data:FindFirstChild(altName)
            if found then break end
        end

        if not found then
            warn("[ENI] Data value '" .. valueName .. "' not found")
            return false
        end
        value = found
    end

    local success, err = pcall(function()
        value.Value = skinName
    end)

    if success then
        print("[ENI] Set " .. valueName .. " = " .. skinName)
        return true
    else
        warn("[ENI] Failed to set " .. valueName .. ": " .. tostring(err))
        return false
    end
end

--// Apply all configured skins (called on spawn and manually)
local function ApplyAllSkins()
    if SkinChanger.Config.MeleeSkin ~= "None" then
        SetDataValue("MeleeSkin", SkinChanger.Config.MeleeSkin)
    end
    if SkinChanger.Config.AnnouncerSkin ~= "None" then
        SetDataValue("Announcer", SkinChanger.Config.AnnouncerSkin)
    end
    if SkinChanger.Config.ArmSkin ~= "None" then
        SetDataValue("Skin", SkinChanger.Config.ArmSkin)
    end
end

--// Re-apply on respawn (Data values sometimes reset)
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1) -- Let character fully load
    ApplyAllSkins()
end)

-- ═══════════════════════════════════════════════════════════════
-- GUI — Uses Blackout.cc framework API
-- Gun Chams section REMOVED — now lives in gunmods.lua Weapon tab
-- ═══════════════════════════════════════════════════════════════

function SkinChanger:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Skin Changer", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        --// ═══ MELEE SKIN CHANGER ═══
        local y = g:CreateSection("Melee Skin Changer", 0)

        y = g:CreateDropdown("Melee Skin", MeleeSkins, SkinChanger.Config.MeleeSkin, function(val)
            SkinChanger.Config.MeleeSkin = val
            if val ~= "None" then
                SetDataValue("MeleeSkin", val)
            end
        end, y)

        y = g:CreateButton("Apply Melee Skin", function()
            if SkinChanger.Config.MeleeSkin ~= "None" then
                SetDataValue("MeleeSkin", SkinChanger.Config.MeleeSkin)
            end
        end, y)

        --// ═══ ANNOUNCER CHANGER ═══
        y = g:CreateSection("Announcer Changer", y + 10)

        y = g:CreateDropdown("Announcer", AnnouncerSkins, SkinChanger.Config.AnnouncerSkin, function(val)
            SkinChanger.Config.AnnouncerSkin = val
            if val ~= "None" then
                SetDataValue("Announcer", val)
            end
        end, y)

        y = g:CreateButton("Apply Announcer", function()
            if SkinChanger.Config.AnnouncerSkin ~= "None" then
                SetDataValue("Announcer", SkinChanger.Config.AnnouncerSkin)
            end
        end, y)

        --// ═══ ARM / GLOVE SKIN CHANGER ═══
        y = g:CreateSection("Arm Skin Changer", y + 10)

        y = g:CreateDropdown("Arm Skin", ArmSkins, SkinChanger.Config.ArmSkin, function(val)
            SkinChanger.Config.ArmSkin = val
            if val ~= "None" then
                SetDataValue("Skin", val)
            end
        end, y)

        y = g:CreateButton("Apply Arm Skin", function()
            if SkinChanger.Config.ArmSkin ~= "None" then
                SetDataValue("Skin", SkinChanger.Config.ArmSkin)
            end
        end, y)

        --// ═══ APPLY ALL ═══
        y = g:CreateSection("Bulk Actions", y + 10)

        y = g:CreateButton("Apply All Skins", function()
            ApplyAllSkins()
        end, y)

        y = g:CreateButton("Reset to Default", function()
            SkinChanger.Config.MeleeSkin = "None"
            SkinChanger.Config.AnnouncerSkin = "None"
            SkinChanger.Config.ArmSkin = "None"
            SetDataValue("MeleeSkin", "Default")
            SetDataValue("Announcer", "Default")
            SetDataValue("Skin", "Default")
            print("[ENI] All skins reset to default")
        end, y)

        g.Content = originalContent
    end)

    --// Apply saved config on load
    task.spawn(function()
        task.wait(2)
        ApplyAllSkins()
    end)

    print("[ENI] Skin Changer loaded — gun chams removed, skins fixed")
    return self
end

return SkinChanger