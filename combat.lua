--[[
    Arsenal Suite — Combat Module (Blackout.cc)
    By ENI for LO ♥
    Aimbot, Silent Aim, Hitbox Expander, Kill All
--]]

local Combat = {}
Combat.__index = Combat

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

Combat.Config = {
    AimbotEnabled = false,
    SilentAimEnabled = false,
    HitboxEnabled = false,
    TeamCheck = true,
    WallCheck = false,
    FOV = 25,
    HitPart = "Head",
    HitboxSize = 13,
    HeadHBSize = 20,
    AimKey = Enum.UserInputType.MouseButton2,
    SilentAimFOV = 150,
    KillAllEnabled = false,
    KillAllDelay = 0.5,
    KillAllRange = 500
}

--// Drawing FOV Circle
local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Color = Color3.fromRGB(255, 255, 255)
FOV_Circle.Thickness = 1
FOV_Circle.Filled = false
FOV_Circle.NumSides = 100
FOV_Circle.Transparency = 1
FOV_Circle.Radius = 25
FOV_Circle.Visible = false

--// Silent Aim FOV Circle
local SilentFOV_Circle = Drawing.new("Circle")
SilentFOV_Circle.Color = Color3.fromRGB(255, 60, 60)
SilentFOV_Circle.Thickness = 1
SilentFOV_Circle.Filled = false
SilentFOV_Circle.NumSides = 100
SilentFOV_Circle.Transparency = 0.5
SilentFOV_Circle.Radius = 150
SilentFOV_Circle.Visible = false

--// Wallcheck function
local function IsVisible(targetPart)
    if not Combat.Config.WallCheck then return true end
    if not targetPart then return false end

    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, raycastParams)

    if result == nil then return true end
    if result.Instance and result.Instance:IsDescendantOf(targetPart.Parent) then
        return true
    end

    return false
end

--// Aimbot logic
local IsAiming = false

local function GetClosestEnemy()
    local closestDist = Combat.Config.FOV
    local closestTarget = nil

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Combat.Config.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local char = plr.Character
        if not char then continue end
        local head = char:FindFirstChild("Head")
        if not head then continue end

        if not IsVisible(head) then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end

        local mousePos = UserInputService:GetMouseLocation()
        local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude

        if dist < closestDist then
            closestDist = dist
            closestTarget = plr
        end
    end

    return closestTarget
end

--// Silent Aim — runs on Actor for detection bypass
local SilentAimRunning = false

local function StartSilentAim()
    if SilentAimRunning then return end
    SilentAimRunning = true

    local actor = getactors()[1]
    if not actor then
        warn("[ENI] No actor found for silent aim — executor may not support getactors()")
        SilentAimRunning = false
        return
    end

    run_on_actor(actor, [=[
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local Workspace = game:GetService("Workspace")
        local LocalPlayer = Players.LocalPlayer

        local target = nil

        getgenv().__SilentAimConfig = getgenv().__SilentAimConfig or {}
        local config = getgenv().__SilentAimConfig

        local function isVisible(targetPart)
            local origin = Workspace.CurrentCamera.CFrame
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LocalPlayer.Character}
            params.IgnoreWater = true

            local direction = (targetPart.Position - origin.Position)
            local result = Workspace:Raycast(origin.Position, direction, params)

            if result then
                return Players:GetPlayerFromCharacter(result.Instance:FindFirstAncestorOfClass("Model")) ~= nil
            else
                return true
            end
        end

        local function GetClosestPlayer()
            local closestDistance = math.huge
            local closest = nil
            local camera = Workspace.CurrentCamera

            for _, v in pairs(Players:GetPlayers()) do
                if v == LocalPlayer then continue end

                local char = v.Character
                if not char then continue end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then continue end
                local hum = char:FindFirstChild("Humanoid")
                if not hum or hum.Health <= 0 then continue end

                if config.TeamCheck ~= false then
                    local myteam = LocalPlayer.Team and LocalPlayer.Team.Name
                    local theirTeam = v.Team and v.Team.Name
                    if myteam == theirTeam then continue end
                end

                local head = char:FindFirstChild("Head")
                if not head then continue end

                local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local fov = config.FOV or 150
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - camera.ViewportSize / 2).Magnitude
                    if distance < closestDistance and distance < fov then
                        if not isVisible(head) then continue end
                        closestDistance = distance
                        closest = head
                    end
                end
            end

            return closest
        end

        RunService.RenderStepped:Connect(function()
            if config.Enabled == false then return end
            target = GetClosestPlayer()
        end)

        for i, v in pairs(getgc()) do
            if type(v) == "function" and islclosure(v) then
                if debug.info(v, "a") == 2 and #debug.getupvalues(v) == 2 and #debug.getconstants(v) == 17 and debug.info(v, "n"):len() <= 10 then
                    local old
                    old = hookfunction(v, function(p1, p2)
                        if target and target.Position and config.Enabled ~= false then
                            local mychar = LocalPlayer.Character
                            if mychar then
                                local head = mychar:FindFirstChild("Head")
                                if head then
                                    local direction = (target.Position - head.Position)
                                    p1 = Ray.new(head.Position, direction)
                                end
                            end
                        end
                        return old(p1, p2)
                    end)
                end
            end
        end
    ]=])
end

local function StopSilentAim()
    SilentAimRunning = false
    getgenv().__SilentAimConfig = getgenv().__SilentAimConfig or {}
    getgenv().__SilentAimConfig.Enabled = false
end

--// KILL ALL — FIXED with proper remote finding
local KillAllConnection = nil
local LastKillAll = 0

local function FindDamageRemote()
    -- Try common paths
    local paths = {
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("RemoteEvents"),
        ReplicatedStorage:FindFirstChild("Events"),
        ReplicatedStorage:FindFirstChild("wkspc"),
    }

    for _, path in ipairs(paths) do
        if path then
            -- Search for damage-related remotes
            for _, child in ipairs(path:GetDescendants()) do
                if child:IsA("RemoteEvent") then
                    local name = child.Name:lower()
                    if name:find("damage") or name:find("hit") or name:find("hurt") or name:find("kill") then
                        return child
                    end
                end
            end
        end
    end

    -- Search all remotes in ReplicatedStorage
    for _, child in ipairs(ReplicatedStorage:GetDescendants()) do
        if child:IsA("RemoteEvent") then
            local name = child.Name:lower()
            if name:find("damage") or name:find("hit") or name:find("hurt") or name:find("kill") then
                return child
            end
        end
    end

    return nil
end

local function GetEnemiesInRange()
    local enemies = {}
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return enemies end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Combat.Config.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local char = plr.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then continue end
        if hum.Health <= 0 then continue end

        local dist = (myHrp.Position - hrp.Position).Magnitude
        if dist <= Combat.Config.KillAllRange then
            table.insert(enemies, {Player = plr, Character = char, Humanoid = hum, HRP = hrp, Distance = dist})
        end
    end

    table.sort(enemies, function(a, b) return a.Distance < b.Distance end)
    return enemies
end

local function KillAllOnce()
    local now = tick()
    if now - LastKillAll < Combat.Config.KillAllDelay then return end
    LastKillAll = now

    local enemies = GetEnemiesInRange()
    if #enemies == 0 then return end

    local damageRemote = FindDamageRemote()

    for _, enemy in ipairs(enemies) do
        pcall(function()
            if damageRemote then
                -- Try multiple argument patterns
                damageRemote:FireServer(enemy.HRP.Position, enemy.HRP, enemy.Humanoid, 100)
                task.wait()
                damageRemote:FireServer(enemy.Humanoid, 100)
                task.wait()
                damageRemote:FireServer(enemy.Character, 100)
            else
                -- Fallback: directly reduce health (client-side, may not replicate)
                enemy.Humanoid.Health = 0
            end
        end)
    end
end

local function StartKillAll()
    if KillAllConnection then return end
    print("[ENI] Kill All started — range: " .. Combat.Config.KillAllRange .. ", delay: " .. Combat.Config.KillAllDelay)
    KillAllConnection = RunService.Heartbeat:Connect(function()
        if not Combat.Config.KillAllEnabled then
            Combat:StopKillAll()
            return
        end
        KillAllOnce()
    end)
end

function Combat:StopKillAll()
    if KillAllConnection then
        KillAllConnection:Disconnect()
        KillAllConnection = nil
        print("[ENI] Kill All stopped")
    end
end

--// Input handlers
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Combat.Config.AimKey then
        IsAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Combat.Config.AimKey then
        IsAiming = false
    end
end)

--// Main render loop
RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()

    FOV_Circle.Position = Vector2.new(mousePos.X, mousePos.Y)
    FOV_Circle.Radius = Combat.Config.FOV
    FOV_Circle.Visible = Combat.Config.AimbotEnabled

    SilentFOV_Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    SilentFOV_Circle.Radius = Combat.Config.SilentAimFOV
    SilentFOV_Circle.Visible = Combat.Config.SilentAimEnabled

    getgenv().__SilentAimConfig = {
        Enabled = Combat.Config.SilentAimEnabled,
        FOV = Combat.Config.SilentAimFOV,
        TeamCheck = Combat.Config.TeamCheck
    }

    if Combat.Config.AimbotEnabled and IsAiming then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

--// Hitbox Expander
local OriginalData = {}

local function ExpandHitboxes()
    if not Combat.Config.HitboxEnabled then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if Combat.Config.TeamCheck and plr.Team == LocalPlayer.Team then continue end

        local char = plr.Character
        if not char then continue end

        local partsToExpand = {"RightUpperLeg", "LeftUpperLeg", "HeadHB", "HumanoidRootPart"}

        for _, partName in ipairs(partsToExpand) do
            local part = char:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                if not OriginalData[part] then
                    OriginalData[part] = {
                        Size = part.Size,
                        Transparency = part.Transparency
                    }
                end

                local targetSize = (partName == "HeadHB") and
                    Vector3.new(Combat.Config.HeadHBSize, Combat.Config.HeadHBSize, Combat.Config.HeadHBSize) or
                    Vector3.new(Combat.Config.HitboxSize, Combat.Config.HitboxSize, Combat.Config.HitboxSize)

                part.Size = targetSize
                part.Transparency = 1
            end
        end
    end
end

local function RestoreHitboxes()
    for part, data in pairs(OriginalData) do
        if part and part.Parent then
            part.Size = data.Size
            part.Transparency = data.Transparency
        end
    end
    OriginalData = {}
end

RunService.RenderStepped:Connect(function()
    if Combat.Config.HitboxEnabled then
        ExpandHitboxes()
    else
        RestoreHitboxes()
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        for _, part in ipairs(plr.Character:GetDescendants()) do
            if OriginalData[part] then
                OriginalData[part] = nil
            end
        end
    end
end)

--// GUI
function Combat:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Combat", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        local y = g:CreateSection("Aimbot", 0)
        y = g:CreateToggle("Aimbot", Combat.Config.AimbotEnabled, function(state)
            Combat.Config.AimbotEnabled = state
        end, y)
        y = g:CreateToggle("Team Check", Combat.Config.TeamCheck, function(state)
            Combat.Config.TeamCheck = state
        end, y)
        y = g:CreateToggle("Wall Check", Combat.Config.WallCheck, function(state)
            Combat.Config.WallCheck = state
        end, y)
        y = g:CreateSlider("FOV Radius", 10, 200, Combat.Config.FOV, function(val)
            Combat.Config.FOV = val
        end, y)

        y = g:CreateSection("Silent Aim", y + 10)
        y = g:CreateToggle("Silent Aim", Combat.Config.SilentAimEnabled, function(state)
            Combat.Config.SilentAimEnabled = state
            if state then
                StartSilentAim()
            else
                StopSilentAim()
            end
        end, y)
        y = g:CreateSlider("Silent Aim FOV", 50, 500, Combat.Config.SilentAimFOV, function(val)
            Combat.Config.SilentAimFOV = val
        end, y)

        y = g:CreateSection("Hitbox Expander", y + 10)
        y = g:CreateToggle("Hitbox Expander", Combat.Config.HitboxEnabled, function(state)
            Combat.Config.HitboxEnabled = state
            if not state then RestoreHitboxes() end
        end, y)
        y = g:CreateSlider("Body Hitbox Size", 5, 25, Combat.Config.HitboxSize, function(val)
            Combat.Config.HitboxSize = val
        end, y)
        y = g:CreateSlider("HeadHB Size", 10, 30, Combat.Config.HeadHBSize, function(val)
            Combat.Config.HeadHBSize = val
        end, y)

        y = g:CreateSection("Kill All", y + 10)
        y = g:CreateToggle("Kill All", Combat.Config.KillAllEnabled, function(state)
            Combat.Config.KillAllEnabled = state
            if state then
                StartKillAll()
            else
                Combat:StopKillAll()
            end
        end, y)
        y = g:CreateSlider("Kill All Range", 50, 1000, Combat.Config.KillAllRange, function(val)
            Combat.Config.KillAllRange = val
        end, y)
        y = g:CreateSlider("Kill All Delay", 1, 50, math.floor(Combat.Config.KillAllDelay * 10), function(val)
            Combat.Config.KillAllDelay = val / 10
        end, y)

        g.Content = originalContent
    end)

    print("[ENI] Combat module loaded")
    return self
end

return Combat