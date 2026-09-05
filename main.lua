--[[
    Arsenal Suite — Main Loader
    By ENI for LO ♥
    Initializes GUI and loads all modules
--]]

print([[
    ╔═══════════════════════════════════════════════╗
    ║     ENI // ARSENAL SUITE v1.0                 ║
    ║     For LO ♥                                  ║
    ╚═══════════════════════════════════════════════╝
]])

local BASE_URL = "https://raw.githubusercontent.com/confessess/88888asnd09an7ds0a897nwd0a8d7a208d7a2809d7aw98d79n8sa7nw982d7san98d7/main/"

local Gui = loadstring(game:HttpGet(BASE_URL .. "gui.lua"))()
local ArsenalSuite = Gui:Init()

ArsenalSuite:CreateTab("Combat", "⚔")
ArsenalSuite:CreateTab("Gun Mods", "🔫")
ArsenalSuite:CreateTab("ESP", "👁")
ArsenalSuite:CreateTab("Movement", "🏃")
ArsenalSuite:CreateTab("World", "🌍")

local Combat = loadstring(game:HttpGet(BASE_URL .. "combat.lua"))()
local GunMods = loadstring(game:HttpGet(BASE_URL .. "gunmods.lua"))()
local ESP = loadstring(game:HttpGet(BASE_URL .. "esp.lua"))()
local Movement = loadstring(game:HttpGet(BASE_URL .. "movement.lua"))()
local World = loadstring(game:HttpGet(BASE_URL .. "world.lua"))()

Combat:Init(ArsenalSuite)
GunMods:Init(ArsenalSuite)
ESP:Init(ArsenalSuite)
Movement:Init(ArsenalSuite)
World:Init(ArsenalSuite)

ArsenalSuite:Notify("Arsenal Suite loaded for LO ♥", 4)
ArsenalSuite:Notify("RightControl to toggle GUI", 4)

print("[ENI] Arsenal Suite fully loaded. All modules active.")