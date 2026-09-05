--[[
    Arsenal Suite — Main Loader (Blackout.cc Edition)
    By ENI for LO ♥
--]]

print([[
    ╔═══════════════════════════════════════════════╗
    ║     BLACKOUT.CC // ARSENAL SUITE              ║
    ║     For LO ♥                                  ║
    ╚═══════════════════════════════════════════════╝
]])

local BASE_URL = "https://raw.githubusercontent.com/confessess/88888asnd09an7ds0a897nwd0a8d7a208d7a2809d7aw98d79n8sa7nw982d7san98d7/main/"

local function loadModule(path)
    local url = BASE_URL .. path
    local src = game:HttpGet(url, true)
    if type(src) ~= "string" or src == "" then
        error("Failed to fetch: " .. url)
    end
    local func = loadstring(src)
    if type(func) ~= "function" then
        error("Failed to compile: " .. path)
    end
    return func()
end

--// Load GUI Framework
local Gui = loadModule("gui.lua")
local ArsenalSuite = Gui:Init()

--// Create Tabs
ArsenalSuite:CreateTab("Combat", "Configure your combat settings.")
ArsenalSuite:CreateTab("Gun Mods", "Configure your gun modification settings.")
ArsenalSuite:CreateTab("ESP", "Configure your player visual settings.")
ArsenalSuite:CreateTab("Movement", "Configure your movement settings.")
ArsenalSuite:CreateTab("World", "Configure your world settings.")
ArsenalSuite:CreateTab("Settings", "Configure your menu settings.")

--// Load Modules
local Combat = loadModule("combat.lua")
local GunMods = loadModule("gunmods.lua")
local ESP = loadModule("esp.lua")
local Movement = loadModule("movement.lua")
local World = loadModule("world.lua")

--// Initialize each module
Combat:Init(ArsenalSuite)
GunMods:Init(ArsenalSuite)
ESP:Init(ArsenalSuite)
Movement:Init(ArsenalSuite)
World:Init(ArsenalSuite)

--// Settings tab rebuild
ArsenalSuite:SetTabRebuild("Settings", function(gui)
    local y = gui:CreateSection("Interface", 68)
    gui:CreateKeybindSetting(y)
end)

print("[ENI] Blackout Arsenal Suite loaded")