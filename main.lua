--[[
    Arsenal Suite — Main Loader (Blackout.cc)
    By ENI for LO ♥
    Protected — only loads from valid loader chain
--]]

--// SECURITY: Verify loader chain
local chain = getgenv().__BLACKOUT_CHAIN
if not chain or chain.stage ~= 2 or chain.token ~= "b1a9c3e7f2d4a6e8" then
    warn("[Blackout] Access denied — invalid loader chain")
    return
end

--// SECURITY: Singleton lock
if getgenv().__BLACKOUT_LOADED then
    warn("[Blackout] Already loaded")
    return
end
getgenv().__BLACKOUT_LOADED = true

--// SECURITY: Clear chain data after verification
getgenv().__BLACKOUT_CHAIN = nil

local BASE = "https://raw.githubusercontent.com/confessess/88888asnd09an7ds0a897nwd0a8d7a208d7a2809d7aw98d79n8sa7nw982d7san98d7/main/"

local GuiModule = loadstring(game:HttpGet(BASE .. "gui.lua"))()
local CombatModule = loadstring(game:HttpGet(BASE .. "combat.lua"))()
local ESPModule = loadstring(game:HttpGet(BASE .. "esp.lua"))()
local GunModsModule = loadstring(game:HttpGet(BASE .. "gunmods.lua"))()
local MovementModule = loadstring(game:HttpGet(BASE .. "movement.lua"))()
local WorldModule = loadstring(game:HttpGet(BASE .. "world.lua"))()
local SkinChangerModule = loadstring(game:HttpGet(BASE .. "skinchanger.lua"))()

local Gui = GuiModule:Init()

Gui:CreateTab("Combat", "Aimbot, silent aim, and hitbox settings.")
Gui:CreateTab("Visuals", "ESP and world rendering.")
Gui:CreateTab("Gun Mods", "No recoil, no spread, rapid fire, infinite ammo, rainbow guns.")
Gui:CreateTab("Movement", "Speed, jump, and fly settings.")
Gui:CreateTab("Skin Changer", "Announcers, arms, and melee skins.")
Gui:CreateTab("World", "World modifications.")
Gui:CreateTab("Settings", "GUI preferences and keybinds.")

CombatModule:Init(Gui)
ESPModule:Init(Gui)
GunModsModule:Init(Gui)
MovementModule:Init(Gui)
WorldModule:Init(Gui)
SkinChangerModule:Init(Gui)

Gui:SetTabRebuild("Settings", function(g)
    local scroll = g:CreateScrollContent()
    local originalContent = g.Content
    g.Content = scroll

    local y = g:CreateSection("GUI", 0)
    y = g:CreateKeybindSetting(y)
    y = g:CreateButton("Unload GUI", function()
        getgenv().__BLACKOUT_LOADED = false
        Gui.ScreenGui:Destroy()
    end, y)

    g.Content = originalContent
end)

print("[ENI] Blackout.cc Suite loaded — RightShift to toggle ♥")