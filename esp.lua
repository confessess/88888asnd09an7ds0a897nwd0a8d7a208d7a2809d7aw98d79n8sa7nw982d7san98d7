--[[
    Arsenal Suite — ESP Module (Blackout.cc)
    By ENI for LO ♥
    Skeleton ESP, Tracers, Head Dots — Individual Toggles
--]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

ESP.Config = {
    Enabled = false,
    TeamCheck = true,
    Skeleton = false,
    Tracers = false,
    HeadDot = false,
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
    HeadDotColor = Color3.fromRGB(255, 255, 255)
}

local Drawings = {}

local SkeletonConnections = {
    {"Head", "Torso"},
    {"Torso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"Torso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"Torso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"Torso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"}
}

local function CreateDrawing(type, props)
    local drawing = Drawing.new(type)
    for k, v in pairs(props) do
        drawing[k] = v
    end
    return drawing
end

local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function InitPlayerDrawings(player)
    if Drawings[player] then return end

    local data = {
        Tracer = CreateDrawing("Line", {
            Thickness = 1.5,
            Color = ESP.Config.TracerColor,
            Transparency = 1,
            Visible = false
        }),
        HeadDot = CreateDrawing("Circle", {
            Radius = 4,
            NumSides = 12,
            Color = ESP.Config.HeadDotColor,
            Thickness = 1.5,
            Filled = true,
            Visible = false
        }),
        Skeleton = {}
    }

    for _, conn in ipairs(SkeletonConnections) do
        data.Skeleton[conn[1]] = CreateDrawing("Line", {
            Color = ESP.Config.SkeletonColor,
            Thickness = 1,
            Transparency = 1,
            Visible = false
        })
    end

    Drawings[player] = data
end

local function UpdatePlayerESP(player, character)
    local data = Drawings[player]
    if not data then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        for _, drawing in pairs(data.Skeleton) do drawing.Visible = false end
        data.Tracer.Visible = false
        data.HeadDot.Visible = false
        return
    end

    if ESP.Config.TeamCheck and player.Team == LocalPlayer.Team then
        for _, drawing in pairs(data.Skeleton) do drawing.Visible = false end
        data.Tracer.Visible = false
        data.HeadDot.Visible = false
        return
    end

    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart")

    -- Tracers
    if ESP.Config.Tracers and torso then
        local torsoScreen, torsoVisible = WorldToScreen(torso.Position)
        local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

        if torsoVisible then
            data.Tracer.From = screenBottom
            data.Tracer.To = torsoScreen
            data.Tracer.Visible = true
        else
            data.Tracer.Visible = false
        end
    else
        data.Tracer.Visible = false
    end

    -- Head Dot
    if ESP.Config.HeadDot and head then
        local headScreen, headVisible = WorldToScreen(head.Position)
        if headVisible then
            data.HeadDot.Position = headScreen
            data.HeadDot.Visible = true
        else
            data.HeadDot.Visible = false
        end
    else
        data.HeadDot.Visible = false
    end

    -- Skeleton
    if ESP.Config.Skeleton and torso and head then
        for _, conn in ipairs(SkeletonConnections) do
            local partA = character:FindFirstChild(conn[1])
            local partB = character:FindFirstChild(conn[2])
            local line = data.Skeleton[conn[1]]

            if partA and partB and line then
                local from, visA = WorldToScreen(partA.Position)
                local to, visB = WorldToScreen(partB.Position)

                if visA and visB then
                    line.From = from
                    line.To = to
                    line.Visible = true
                else
                    line.Visible = false
                end
            elseif line then
                line.Visible = false
            end
        end
    else
        for _, drawing in pairs(data.Skeleton) do drawing.Visible = false end
    end
end

local function CleanupPlayerDrawings(player)
    if not Drawings[player] then return end
    for _, drawing in pairs(Drawings[player].Skeleton) do
        if drawing and drawing.Remove then drawing:Remove() end
    end
    if Drawings[player].Tracer and Drawings[player].Tracer.Remove then
        Drawings[player].Tracer:Remove()
    end
    if Drawings[player].HeadDot and Drawings[player].HeadDot.Remove then
        Drawings[player].HeadDot:Remove()
    end
    Drawings[player] = nil
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        InitPlayerDrawings(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    CleanupPlayerDrawings(player)
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then
            InitPlayerDrawings(player)
        end
        player.CharacterAdded:Connect(function()
            task.wait(1)
            InitPlayerDrawings(player)
        end)
    end
end

RunService.RenderStepped:Connect(function()
    if not ESP.Config.Enabled then
        for _, data in pairs(Drawings) do
            for _, drawing in pairs(data.Skeleton) do drawing.Visible = false end
            data.Tracer.Visible = false
            data.HeadDot.Visible = false
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            if not Drawings[player] then
                InitPlayerDrawings(player)
            end
            UpdatePlayerESP(player, player.Character)
        end
    end
end)

function ESP:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("ESP", function(g)
        local y = g:CreateSection("Visuals", 68)
        y = g:CreateToggle("ESP Master", ESP.Config.Enabled, function(state)
            ESP.Config.Enabled = state
            if not state then
                for _, data in pairs(Drawings) do
                    for _, drawing in pairs(data.Skeleton) do drawing.Visible = false end
                    data.Tracer.Visible = false
                    data.HeadDot.Visible = false
                end
            end
        end, y)
        y = g:CreateToggle("Team Check", ESP.Config.TeamCheck, function(state)
            ESP.Config.TeamCheck = state
        end, y)

        y = g:CreateSection("ESP Features", y + 10)
        y = g:CreateToggle("Skeleton", ESP.Config.Skeleton, function(state)
            ESP.Config.Skeleton = state
        end, y)
        y = g:CreateToggle("Tracers", ESP.Config.Tracers, function(state)
            ESP.Config.Tracers = state
        end, y)
        y = g:CreateToggle("Head Dot", ESP.Config.HeadDot, function(state)
            ESP.Config.HeadDot = state
        end, y)
    end)

    print("[ENI] ESP module loaded")
    return self
end

return ESP