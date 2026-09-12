--[[
    Arsenal Suite — Combat Module (Blackout.cc)
    By ENI for LO ♥
    Original Silent Aim + Kill All + Hitsounds
--]]

local Combat = {}
Combat.__index = Combat

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

Combat.Config = {
    SilentAimEnabled = false,
    SilentAimFOV = 100,
    SilentAimHitChance = 100,
    SilentAimTeamCheck = true,
    SilentAimWallCheck = false,
    SilentAimHitpart = "Head",
    AimbotEnabled = false,
    AimbotFOV = 150,
    AimbotSmoothness = 1,
    AimbotTeamCheck = true,
    AimbotWallCheck = false,
    AimbotHitpart = "Head",
    HitboxExpander = false,
    HitboxSize = 5,
    HitsoundsEnabled = false,
    Hitsound = "Skeet.cc",
    HitsoundVolume = 1,
    KillAll = false,
}

--// ORIGINAL SILENT AIM (working code from before)
local function IsVisible(targetPart)
    if not Combat.Config.SilentAimWallCheck then return true end
    local char = LocalPlayer.Character
    if not char then return false end
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = Workspace:Raycast(origin, direction, raycastParams)
    if result and result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end
    return false
end

local function GetClosestPlayerToMouse()
    local closest = nil
    local shortestDistance = Combat.Config.SilentAimFOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Combat.Config.SilentAimTeamCheck and plr.Team == LocalPlayer.Team then
                continue
            end
            local targetPart = plr.Character:FindFirstChild(Combat.Config.SilentAimHitpart)
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen and IsVisible(targetPart) then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        closest = plr
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closest
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if Combat.Config.SilentAimEnabled and method == "FindPartOnRayWithIgnoreList" then
        local target = GetClosestPlayerToMouse()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Combat.Config.SilentAimHitpart)
            if targetPart then
                if math.random(1, 100) <= Combat.Config.SilentAimHitChance then
                    local origin = args[1].Origin
                    local direction = (targetPart.Position - origin).Unit * 1000
                    args[1] = Ray.new(origin, direction)
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end

    return oldNamecall(self, ...)
end)

--// AIMBOT
local function GetAimbotTarget()
    local closest = nil
    local shortestDistance = Combat.Config.AimbotFOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Combat.Config.AimbotTeamCheck and plr.Team == LocalPlayer.Team then
                continue
            end
            local targetPart = plr.Character:FindFirstChild(Combat.Config.AimbotHitpart)
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen and IsVisible(targetPart) then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        closest = plr
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not Combat.Config.AimbotEnabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

    local target = GetAimbotTarget()
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Combat.Config.AimbotHitpart)
        if targetPart then
            local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local moveX = (targetPos.X - mousePos.X) / Combat.Config.AimbotSmoothness
            local moveY = (targetPos.Y - mousePos.Y) / Combat.Config.AimbotSmoothness
            mousemoverel(moveX, moveY)
        end
    end
end)

--// HITBOX EXPANDER
local HitboxConnection = nil

local function ExpandHitbox(size)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Combat.Config.AimbotTeamCheck and plr.Team == LocalPlayer.Team then
                continue
            end
            local head = plr.Character:FindFirstChild("Head")
            if head then
                head.Size = Vector3.new(size, size, size)
                head.Transparency = 0.7
                head.CanCollide = false
            end
        end
    end
end

local function ResetHitbox()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                head.Size = Vector3.new(1.2, 0.6, 1.2)
                head.Transparency = 0
            end
        end
    end
end

function Combat:SetHitboxExpander(state)
    Combat.Config.HitboxExpander = state
    if state then
        HitboxConnection = RunService.Heartbeat:Connect(function()
            ExpandHitbox(Combat.Config.HitboxSize)
        end)
    else
        if HitboxConnection then
            HitboxConnection:Disconnect()
            HitboxConnection = nil
        end
        ResetHitbox()
    end
end

--// HITSOUNDS
local HitsoundList = {
    ["None"] = "",
    ["Skeet.cc"] = "rbxassetid://5447626464",
    ["Neverlose"] = "rbxassetid://6607204501",
    ["Baimware"] = "rbxassetid://6607339542",
    ["Old Fatality"] = "rbxassetid://6607142036",
    ["Rust"] = "rbxassetid://5043539486",
    ["Bell"] = "rbxassetid://6534947240",
    ["TF2"] = "rbxassetid://2868331684",
    ["Among Us"] = "rbxassetid://5700183626",
    ["Fortnite Headshot"] = "rbxassetid://2513174484",
    ["Minecraft"] = "rbxassetid://4018616850",
    ["Osu"] = "rbxassetid://7149255551",
    ["TF2 Critical"] = "rbxassetid://296102734",
    ["Bat"] = "rbxassetid://3333907347",
    ["Call of Duty"] = "rbxassetid://5952120301",
    ["Bruh"] = "rbxassetid://4275842574",
    ["Crowbar"] = "rbxassetid://546410481",
    ["Weeb"] = "rbxassetid://6442965016",
    ["Steve"] = "rbxassetid://4965083997"
}

local function PlayHitsound()
    if not Combat.Config.HitsoundsEnabled then return end
    local soundId = HitsoundList[Combat.Config.Hitsound]
    if not soundId or soundId == "" then return end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = Combat.Config.HitsoundVolume
    sound.Parent = SoundService
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

local function SetupHitsounds()
    local scoreFolder = LocalPlayer:WaitForChild("ScoreFolder")
    local damageValue = scoreFolder:WaitForChild("Damage")
    damageValue:GetPropertyChangedSignal("Value"):Connect(function(newValue)
        if newValue == 0 then return end
        PlayHitsound()
    end)
    LocalPlayer.ChildRemoved:Connect(function(child)
        if child.Name == "ScoreFolder" then
            task.wait(3)
            pcall(SetupHitsounds)
        end
    end)
end

task.spawn(function()
    local success = pcall(SetupHitsounds)
    if not success then
        task.wait(5)
        pcall(SetupHitsounds)
    end
end)

--// KILL ALL
local killAllConnection = nil
local killAllActive = false

local function GetClosestEnemy()
    local closest = nil
    local closestDist = math.huge
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    if not myRoot then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if root and humanoid and humanoid.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = player
                end
            end
        end
    end
    return closest
end

local function KillAllTick()
    if not killAllActive then return end
    local target = GetClosestEnemy()
    if target and target.Character then
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if targetRoot and myRoot then
            myRoot.CFrame = CFrame.new(targetRoot.Position - targetRoot.CFrame.LookVector * 5)
            local camera = Workspace.CurrentCamera
            local direction = (targetRoot.Position - camera.CFrame.Position).unit
            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction)
        end
    end
end

local function SetKillAll(enabled)
    killAllActive = enabled
    Combat.Config.KillAll = enabled
    if enabled then
        if killAllConnection then killAllConnection:Disconnect() end
        killAllConnection = RunService.Heartbeat:Connect(KillAllTick)
    else
        if killAllConnection then
            killAllConnection:Disconnect()
            killAllConnection = nil
        end
    end
end

--// GUI
function Combat:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Combat", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        local y = g:CreateSection("Silent Aim", 0)
        y = g:CreateToggle("Enabled", false, function(state)
            Combat.Config.SilentAimEnabled = state
        end, y)
        y = g:CreateToggle("Team Check", true, function(state)
            Combat.Config.SilentAimTeamCheck = state
        end, y)
        y = g:CreateToggle("Wall Check", false, function(state)
            Combat.Config.SilentAimWallCheck = state
        end, y)
        y = g:CreateSlider("FOV", 10, 500, 100, function(val)
            Combat.Config.SilentAimFOV = val
        end, y)
        y = g:CreateSlider("Hit Chance", 1, 100, 100, function(val)
            Combat.Config.SilentAimHitChance = val
        end, y)
        y = g:CreateDropdown("Hitpart", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(val)
            Combat.Config.SilentAimHitpart = val
        end, y)

        y = g:CreateSection("Aimbot", y + 10)
        y = g:CreateToggle("Enabled", false, function(state)
            Combat.Config.AimbotEnabled = state
        end, y)
        y = g:CreateToggle("Team Check", true, function(state)
            Combat.Config.AimbotTeamCheck = state
        end, y)
        y = g:CreateToggle("Wall Check", false, function(state)
            Combat.Config.AimbotWallCheck = state
        end, y)
        y = g:CreateSlider("FOV", 10, 500, 150, function(val)
            Combat.Config.AimbotFOV = val
        end, y)
        y = g:CreateSlider("Smoothness", 1, 10, 1, function(val)
            Combat.Config.AimbotSmoothness = val
        end, y)
        y = g:CreateDropdown("Hitpart", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(val)
            Combat.Config.AimbotHitpart = val
        end, y)

        y = g:CreateSection("Hitbox Expander", y + 10)
        y = g:CreateToggle("Enabled", false, function(state)
            Combat:SetHitboxExpander(state)
        end, y)
        y = g:CreateSlider("Size", 1, 20, 5, function(val)
            Combat.Config.HitboxSize = val
        end, y)

        y = g:CreateSection("Kill All", y + 10)
        y = g:CreateToggle("Enabled", false, function(state)
            SetKillAll(state)
        end, y)

        y = g:CreateSection("Hitsounds", y + 10)
        y = g:CreateToggle("Enabled", false, function(state)
            Combat.Config.HitsoundsEnabled = state
        end, y)
        local hitsoundNames = {"None", "Skeet.cc", "Neverlose", "Baimware", "Old Fatality", "Rust", "Bell", "TF2", "Among Us", "Fortnite Headshot", "Minecraft", "Osu", "TF2 Critical", "Bat", "Call of Duty", "Bruh", "Crowbar", "Weeb", "Steve"}
        y = g:CreateDropdown("Sound", hitsoundNames, "Skeet.cc", function(val)
            Combat.Config.Hitsound = val
        end, y)
        y = g:CreateSlider("Volume", 0, 10, 1, function(val)
            Combat.Config.HitsoundVolume = val
        end, y)

        g.Content = originalContent
    end)

    print("[ENI] Combat loaded (Silent Aim + Kill All + Hitsounds)")
    return self
end

return Combat