--[[
    Arsenal Suite — Combat Module (Blackout.cc)
    By ENI for LO ♥
    Silent Aim + Kill All + Hitsounds
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

--// SILENT AIM
local function GetSilentAimTarget()
    local closest, shortestDistance = nil, Combat.Config.SilentAimFOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Combat.Config.SilentAimTeamCheck and plr.Team == LocalPlayer.Team then continue end
            local targetPart = plr.Character:FindFirstChild(Combat.Config.SilentAimHitpart)
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then closest = plr shortestDistance = distance end
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
        local target = GetSilentAimTarget()
        if target and target.Character then
            local targetPart = target.Character:FindFirstChild(Combat.Config.SilentAimHitpart)
            if targetPart and math.random(1, 100) <= Combat.Config.SilentAimHitChance then
                args[1] = Ray.new(args[1].Origin, (targetPart.Position - args[1].Origin).Unit * 1000)
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)

--// AIMBOT
local function GetClosestPlayerToMouse()
    local closest, shortestDistance = nil, Combat.Config.AimbotFOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Combat.Config.AimbotTeamCheck and plr.Team == LocalPlayer.Team then continue end
            local targetPart = plr.Character:FindFirstChild(Combat.Config.AimbotHitpart)
            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then closest = plr shortestDistance = distance end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if not Combat.Config.AimbotEnabled then return end
    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    local target = GetClosestPlayerToMouse()
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Combat.Config.AimbotHitpart)
        if targetPart then
            local targetPos = Camera:WorldToViewportPoint(targetPart.Position)
            local mousePos = UserInputService:GetMouseLocation()
            mousemoverel((targetPos.X - mousePos.X) / Combat.Config.AimbotSmoothness, (targetPos.Y - mousePos.Y) / Combat.Config.AimbotSmoothness)
        end
    end
end)

--// HITBOX EXPANDER
local HitboxConnection = nil
local function ExpandHitbox(size)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Team ~= LocalPlayer.Team then
            local head = plr.Character:FindFirstChild("Head")
            if head then head.Size = Vector3.new(size, size, size) head.Transparency = 0.7 head.CanCollide = false end
        end
    end
end
local function ResetHitbox()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then head.Size = Vector3.new(1.2, 0.6, 1.2) head.Transparency = 0 end
        end
    end
end
function Combat:SetHitboxExpander(state)
    Combat.Config.HitboxExpander = state
    if state then HitboxConnection = RunService.Heartbeat:Connect(function() ExpandHitbox(Combat.Config.HitboxSize) end)
    else if HitboxConnection then HitboxConnection:Disconnect() HitboxConnection = nil end ResetHitbox() end
end

--// HITSOUNDS
local HitsoundList = {["None"]="",["Skeet.cc"]="rbxassetid://5447626464",["Neverlose"]="rbxassetid://6607204501",["Baimware"]="rbxassetid://6607339542",["Old Fatality"]="rbxassetid://6607142036",["Rust"]="rbxassetid://5043539486",["Bell"]="rbxassetid://6534947240",["TF2"]="rbxassetid://2868331684",["Among Us"]="rbxassetid://5700183626",["Fortnite Headshot"]="rbxassetid://2513174484",["Minecraft"]="rbxassetid://4018616850",["Osu"]="rbxassetid://7149255551",["TF2 Critical"]="rbxassetid://296102734",["Bat"]="rbxassetid://3333907347",["Call of Duty"]="rbxassetid://5952120301",["Bruh"]="rbxassetid://4275842574",["Crowbar"]="rbxassetid://546410481",["Weeb"]="rbxassetid://6442965016",["Steve"]="rbxassetid://4965083997"}
local function PlayHitsound()
    if not Combat.Config.HitsoundsEnabled then return end
    local soundId = HitsoundList[Combat.Config.Hitsound]
    if not soundId or soundId == "" then return end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId sound.Volume = Combat.Config.HitsoundVolume sound.Parent = SoundService
    sound:Play() sound.Ended:Connect(function() sound:Destroy() end)
end
local function SetupHitsounds()
    local damageValue = LocalPlayer:WaitForChild("ScoreFolder"):WaitForChild("Damage")
    damageValue:GetPropertyChangedSignal("Value"):Connect(function(v) if v ~= 0 then PlayHitsound() end end)
    LocalPlayer.ChildRemoved:Connect(function(c) if c.Name == "ScoreFolder" then task.wait(3) pcall(SetupHitsounds) end end)
end
task.spawn(function() local s = pcall(SetupHitsounds) if not s then task.wait(5) pcall(SetupHitsounds) end end)

--// KILL ALL
local killAllConnection, killAllActive = nil, false
local function GetClosestEnemy()
    local closest, closestDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                local dist = (root.Position - myRoot.Position).Magnitude
                if dist < closestDist then closestDist = dist closest = player end
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
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot and myRoot then
            myRoot.CFrame = CFrame.new(targetRoot.Position - targetRoot.CFrame.LookVector * 5)
            local camera = Workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + (targetRoot.Position - camera.CFrame.Position).unit)
        end
    end
end
local function SetKillAll(enabled)
    killAllActive = enabled
    if enabled then if killAllConnection then killAllConnection:Disconnect() end killAllConnection = RunService.Heartbeat:Connect(KillAllTick)
    else if killAllConnection then killAllConnection:Disconnect() killAllConnection = nil end end
end

--// GUI
function Combat:Init(Gui)
    self.Gui = Gui
    Gui:SetTabRebuild("Combat", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        local y = g:CreateSection("Silent Aim", 0)
        y = g:CreateToggle("Enabled", false, function(s) Combat.Config.SilentAimEnabled = s end, y)
        y = g:CreateToggle("Team Check", true, function(s) Combat.Config.SilentAimTeamCheck = s end, y)
        y = g:CreateToggle("Wall Check", false, function(s) Combat.Config.SilentAimWallCheck = s end, y)
        y = g:CreateSlider("FOV", 10, 500, 100, function(v) Combat.Config.SilentAimFOV = v end, y)
        y = g:CreateSlider("Hit Chance", 1, 100, 100, function(v) Combat.Config.SilentAimHitChance = v end, y)
        y = g:CreateDropdown("Hitpart", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(v) Combat.Config.SilentAimHitpart = v end, y)

        y = g:CreateSection("Aimbot", y + 10)
        y = g:CreateToggle("Enabled", false, function(s) Combat.Config.AimbotEnabled = s end, y)
        y = g:CreateToggle("Team Check", true, function(s) Combat.Config.AimbotTeamCheck = s end, y)
        y = g:CreateToggle("Wall Check", false, function(s) Combat.Config.AimbotWallCheck = s end, y)
        y = g:CreateSlider("FOV", 10, 500, 150, function(v) Combat.Config.AimbotFOV = v end, y)
        y = g:CreateSlider("Smoothness", 1, 10, 1, function(v) Combat.Config.AimbotSmoothness = v end, y)
        y = g:CreateDropdown("Hitpart", {"Head", "HumanoidRootPart", "Torso"}, "Head", function(v) Combat.Config.AimbotHitpart = v end, y)

        y = g:CreateSection("Hitbox Expander", y + 10)
        y = g:CreateToggle("Enabled", false, function(s) Combat:SetHitboxExpander(s) end, y)
        y = g:CreateSlider("Size", 1, 20, 5, function(v) Combat.Config.HitboxSize = v end, y)

        y = g:CreateSection("Kill All", y + 10)
        y = g:CreateToggle("Enabled", false, SetKillAll, y)

        y = g:CreateSection("Hitsounds", y + 10)
        y = g:CreateToggle("Enabled", false, function(s) Combat.Config.HitsoundsEnabled = s end, y)
        y = g:CreateDropdown("Sound", {"None","Skeet.cc","Neverlose","Baimware","Old Fatality","Rust","Bell","TF2","Among Us","Fortnite Headshot","Minecraft","Osu","TF2 Critical","Bat","Call of Duty","Bruh","Crowbar","Weeb","Steve"}, "Skeet.cc", function(v) Combat.Config.Hitsound = v end, y)
        y = g:CreateSlider("Volume", 0, 10, 1, function(v) Combat.Config.HitsoundVolume = v end, y)

        g.Content = originalContent
    end)
    return self
end

return Combat