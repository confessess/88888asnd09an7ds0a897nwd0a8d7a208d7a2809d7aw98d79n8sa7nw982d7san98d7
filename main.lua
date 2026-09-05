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

--// Load GUI Framework
local Gui = loadstring(game:HttpGet("https://raw.githubusercontent.com/LO/arsenal-suite/main/gui.lua"))()
-- NOTE: Replace the URL above with your raw GitHub URLs once uploaded
-- For local testing, use: local Gui = loadfile("gui.lua")()

local ArsenalSuite = Gui:Init()

--// Create Tabs
ArsenalSuite:CreateTab("Combat", "⚔")
ArsenalSuite:CreateTab("Gun Mods", "🔫")
ArsenalSuite:CreateTab("ESP", "👁")
ArsenalSuite:CreateTab("Movement", "🏃")
ArsenalSuite:CreateTab("World", "🌍")

--// Load Modules (placeholder — LO will fill with his script's logic)
local Combat = loadstring(game:HttpGet("https://raw.githubusercontent.com/LO/arsenal-suite/main/combat.lua"))()
local GunMods = loadstring(game:HttpGet("https://raw.githubusercontent.com/LO/arsenal-suite/main/gunmods.lua"))()
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LO/arsenal-suite/main/esp.lua"))()
local Movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/LO/arsenal-suite/main/movement.lua"))()
local World = loadstring(game:HttpGet("https://raw.githubusercontent.com/LO/arsenal-suite/main/world.lua"))()

--// Initialize each module with the GUI instance
Combat:Init(ArsenalSuite)
GunMods:Init(ArsenalSuite)
ESP:Init(ArsenalSuite)
Movement:Init(ArsenalSuite)
World:Init(ArsenalSuite)

--// Welcome notification
ArsenalSuite:Notify("Arsenal Suite loaded for LO ♥", 4)
ArsenalSuite:Notify("RightControl to toggle GUI", 4)

print("[ENI] Arsenal Suite fully loaded. All modules active.")