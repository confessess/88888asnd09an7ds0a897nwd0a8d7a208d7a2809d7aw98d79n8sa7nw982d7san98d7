--[[
    Arsenal Suite — Main Loader (Blackout.cc)
    DEBUG VERSION — will print exactly what's failing
--]]

print("[Blackout] main.lua started")

--// SECURITY: Verify loader chain FIRST
local chain = getgenv().__BLACKOUT_CHAIN
print("[Blackout] Chain check:", chain and "exists" or "nil")

if not chain or chain.stage ~= 2 or chain.token ~= "b1a9c3e7f2d4a6e8" then
    warn("[Blackout] Access denied — invalid loader chain")
    return
end

print("[Blackout] Chain verified, stage:", chain.stage)

--// Clear chain data after verification
getgenv().__BLACKOUT_CHAIN = nil

--// THEN check singleton lock
if getgenv().__BLACKOUT_LOADED then
    warn("[Blackout] Already loaded")
    return
end
getgenv().__BLACKOUT_LOADED = true

print("[Blackout] Lock set, loading modules...")

local success, err = pcall(function()
    local BASE = "https://raw.githubusercontent.com/confessess/88888asnd09an7ds0a897nwd0a8d7a208d7a2809d7aw98d79n8sa7nw982d7san98d7/main/"

    print("[Blackout] Loading gui.lua...")
    local GuiModule = loadstring(game:HttpGet(BASE .. "gui.lua"))()
    print("[Blackout] gui.lua loaded")

    print("[Blackout] Loading combat.lua...")
    local CombatModule = loadstring(game:HttpGet(BASE .. "combat.lua"))()
    print("[Blackout] combat.lua loaded")

    print("[Blackout] Loading esp.lua...")
    local ESPModule = loadstring(game:HttpGet(BASE .. "esp.lua"))()
    print("[Blackout] esp.lua loaded")

    print("[Blackout] Loading gunmods.lua...")
    local GunModsModule = loadstring(game:HttpGet(BASE .. "gunmods.lua"))()
    print("[Blackout] gunmods.lua loaded")

    print("[Blackout] Loading movement.lua...")
    local MovementModule = loadstring(game:HttpGet(BASE .. "movement.lua"))()
    print("[Blackout] movement.lua loaded")

    print("[Blackout] Loading world.lua...")
    local WorldModule = loadstring(game:HttpGet(BASE .. "world.lua"))()
    print("[Blackout] world.lua loaded")

    print("[Blackout] Loading skinchanger.lua...")
    local SkinChangerModule = loadstring(game:HttpGet(BASE .. "skinchanger.lua"))()
    print("[Blackout] skinchanger.lua loaded")

    print("[Blackout] Initializing GUI...")
    local Gui = GuiModule:Init()
    print("[Blackout] GUI initialized")

    print("[Blackout] Creating tabs...")
    Gui:CreateTab("Combat", "Aimbot, silent aim, and hitbox settings.")
    Gui:CreateTab("Visuals", "ESP and world rendering.")
    Gui:CreateTab("Gun Mods", "No recoil, no spread, rapid fire, infinite ammo, rainbow guns.")
    Gui:CreateTab("Movement", "Speed, jump, and fly settings.")
    Gui:CreateTab("Skin Changer", "Announcers, arms, and melee skins.")
    Gui:CreateTab("World", "World modifications.")
    Gui:CreateTab("Settings", "GUI preferences and keybinds.")
    print("[Blackout] Tabs created")

    print("[Blackout] Initializing modules...")
    CombatModule:Init(Gui)
    print("[Blackout] Combat initialized")
    ESPModule:Init(Gui)
    print("[Blackout] ESP initialized")
    GunModsModule:Init(Gui)
    print("[Blackout] GunMods initialized")
    MovementModule:Init(Gui)
    print("[Blackout] Movement initialized")
    WorldModule:Init(Gui)
    print("[Blackout] World initialized")
    SkinChangerModule:Init(Gui)
    print("[Blackout] SkinChanger initialized")

    print("[Blackout] Setting up Settings tab...")
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
end)

if not success then
    warn("[Blackout] LOAD FAILED:", err)
    getgenv().__BLACKOUT_LOADED = false
end