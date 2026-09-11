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

Gui:CreateTab("Combat", "Aimbot, silent aim, hitbox, kill all.")
Gui:CreateTab("Visuals", "ESP and world rendering.")
Gui:CreateTab("Gun Mods", "No recoil, no spread, rapid fire, infinite ammo, rainbow guns.")
Gui:CreateTab("Movement", "Speed, jump, and fly settings.")
Gui:CreateTab("Skin Changer", "Announcers, arms, and melee skins.")
Gui:CreateTab("World", "World modifications.")
Gui:CreateTab("Settings", "GUI preferences, keybinds, configs.")

CombatModule:Init(Gui)
ESPModule:Init(Gui)
GunModsModule:Init(Gui)
MovementModule:Init(Gui)
WorldModule:Init(Gui)
SkinChangerModule:Init(Gui)

--// CONFIG SAVE/LOAD — collects from all modules
local function SaveAllConfigs()
    local allConfigs = {
        Combat = CombatModule.Config,
        ESP = ESPModule.Config,
        GunMods = GunModsModule.Config,
        Movement = MovementModule.Config,
    }

    local serializable = {}
    for moduleName, config in pairs(allConfigs) do
        serializable[moduleName] = {}
        for k, v in pairs(config) do
            if typeof(v) == "EnumItem" then
                serializable[moduleName][k] = {__enum = true, type = tostring(v.EnumType), name = v.Name}
            elseif typeof(v) == "Color3" then
                serializable[moduleName][k] = {__color = true, r = v.R, g = v.G, b = v.B}
            elseif typeof(v) == "Vector3" then
                serializable[moduleName][k] = {__vector = true, x = v.X, y = v.Y, z = v.Z}
            else
                serializable[moduleName][k] = v
            end
        end
    end

    local json = game:GetService("HttpService"):JSONEncode(serializable)
    print("[ENI] CONFIG (copy this):")
    print(json)
    if setclipboard then
        setclipboard(json)
        print("[ENI] Config copied to clipboard!")
    end
    return json
end

local function LoadAllConfigs(jsonString)
    local success, configs = pcall(function()
        return game:GetService("HttpService"):JSONDecode(jsonString)
    end)

    if not success or type(configs) ~= "table" then
        warn("[ENI] Invalid config string")
        return false
    end

    for moduleName, config in pairs(configs) do
        local module = nil
        if moduleName == "Combat" then module = CombatModule
        elseif moduleName == "ESP" then module = ESPModule
        elseif moduleName == "GunMods" then module = GunModsModule
        elseif moduleName == "Movement" then module = MovementModule
        end

        if module and module.Config then
            for k, v in pairs(config) do
                if type(v) == "table" then
                    if v.__enum then
                        pcall(function() module.Config[k] = Enum[v.type][v.name] end)
                    elseif v.__color then
                        module.Config[k] = Color3.new(v.r, v.g, v.b)
                    elseif v.__vector then
                        module.Config[k] = Vector3.new(v.x, v.y, v.z)
                    else
                        module.Config[k] = v
                    end
                else
                    module.Config[k] = v
                end
            end
        end
    end

    print("[ENI] Config loaded! Rebuild tabs to see changes.")
    return true
end

--// Settings tab rebuild
Gui:SetTabRebuild("Settings", function(g)
    local scroll = g:CreateScrollContent()
    local originalContent = g.Content
    g.Content = scroll

    local y = g:CreateSection("GUI", 0)
    y = g:CreateKeybindSetting(y)
    y = g:CreateButton("Unload GUI", function()
        Gui.ScreenGui:Destroy()
    end, y)

    y = g:CreateSection("Config", y + 10)
    y = g:CreateButton("Save Config", function()
        SaveAllConfigs()
    end, y)
    y = g:CreateButton("Load Config", function()
        print("[ENI] To load config, run this in console:")
        print('LoadAllConfigs([[paste_config_here]])')
    end, y)

    g.Content = originalContent
end)

--// Expose load function globally for console use
getgenv().__BlackoutLoadConfig = LoadAllConfigs

print("[ENI] Blackout.cc Suite loaded — RightShift to toggle ♥")