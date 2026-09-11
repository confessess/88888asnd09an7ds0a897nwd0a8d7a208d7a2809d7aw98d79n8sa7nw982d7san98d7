--[[
    Arsenal Suite — Main Loader (Blackout.cc)
    By ENI for LO ♥
--]]

local BASE = "https://raw.githubusercontent.com/confessess/88888asnd09an7ds0a897nwd0a8d7a208d7a2809d7aw98d79n8sa7nw982d7san98d7/main/"

local GuiModule = loadstring(game:HttpGet(BASE .. "gui.lua"))()
local CombatModule = loadstring(game:HttpGet(BASE .. "combat.lua"))()
local ESPModule = loadstring(game:HttpGet(BASE .. "esp.lua"))()
local GunModsModule = loadstring(game:HttpGet(BASE .. "gunmods.lua"))()
local MovementModule = loadstring(game:HttpGet(BASE .. "movement.lua"))()
local WorldModule = loadstring(game:HttpGet(BASE .. "world.lua"))()
local SkinChangerModule = loadstring(game:HttpGet(BASE .. "skinchanger.lua"))()

local Gui = GuiModule:Init()

Gui:CreateTab("Combat", "Aimbot, silent aim, hitbox, kill all, configs.")
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
        Gui.ScreenGui:Destroy()
    end, y)

    g.Content = originalContent
end)

print("[ENI] Blackout.cc Suite loaded — RightShift to toggle ♥")