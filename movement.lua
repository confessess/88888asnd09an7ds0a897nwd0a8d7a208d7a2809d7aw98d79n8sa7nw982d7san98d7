--[[
    Arsenal Suite — ESP Module
    By ENI for LO ♥
    Skeleton ESP, Tracers, Head Circles
    Logic extracted from LO's deobfuscated script, cleaned & fixed
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
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 255),
    HeadCircleColor = Color3.fromRGB(255, 255, 255)
}

--// Drawing storage per player
local Drawings = {}

--// Skeleton connections
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

--// Create Drawing object helper
local function CreateDrawing(type, props)
    local drawing = Drawing.new(type)
    for k, v in pairs(props) do
        drawing[k] = v
    end
    return drawing
end

--// WorldToViewport helper
local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

--// Initialize drawings for a player
local function InitPlayerDrawings(player)
    if Drawings[player] then return end

    local data = {
        Tracer = CreateDrawing("Line", {
            Thickness = 1.5,
            Color = ESP.Config.TracerColor,
            Transparency = 1,
            Visible = false
        }),
        HeadCircle = CreateDrawing("Circle", {
            Radius = 3,
            NumSides = 12,
            Color = ESP.Config.HeadCircleColor,
            Thickness = 1,
            Filled = false,
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

--// Update drawings for a player
local function UpdatePlayerESP(player, character)
    local data = Drawings[player]
    if not data then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        for _, drawing in pairs(data.Skeleton) do
            drawing.Visible = false
        end
        data.Tracer.Visible = false
        data.HeadCircle.Visible = false
        return
    end

    if ESP.Config.TeamCheck and player.Team == LocalPlayer.Team then
        for _, drawing in pairs(data.Skeleton) do
            drawing.Visible = false
        end
        data.Tracer.Visible = false
        data.HeadCircle.Visible = false
        return
    end

    local head = character:FindFirstChild("Head")
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("HumanoidRootPart")

    if head and torso then
        -- Tracer from bottom screen center
        local torsoScreen, torsoVisible = WorldToScreen(torso.Position)
        local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

        if torsoVisible then
            data.Tracer.From = screenBottom
            data.Tracer.To = torsoScreen
            data.Tracer.Visible = true
        else
            data.Tracer.Visible = false
        end

        -- Head circle
        local headScreen, headVisible = WorldToScreen(head.Position)
        if headVisible then
            data.HeadCircle.Position = headScreen
            data.HeadCircle.Visible = true
        else
            data.HeadCircle.Visible = false
        end

        -- Skeleton lines
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
        for _, drawing in pairs(data.Skeleton) do
            drawing.Visible = false
        end
        data.Tracer.Visible = false
        data.HeadCircle.Visible = false
    end
end

--// Cleanup drawings for a player
local function CleanupPlayerDrawings(player)
    if not Drawings[player] then return end
    for _, drawing in pairs(Drawings[player].Skeleton) do
        if drawing and drawing.Remove then drawing:Remove() end
    end
    if Drawings[player].Tracer and Drawings[player].Tracer.Remove then
        Drawings[player].Tracer:Remove()
    end
    if Drawings[player].HeadCircle and Drawings[player].HeadCircle.Remove then
        Drawings[player].HeadCircle:Remove()
    end
    Drawings[player] = nil
end

--// Player events
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

--// Render loop
RunService.RenderStepped:Connect(function()
    if not ESP.Config.Enabled then
        for _, data in pairs(Drawings) do
            for _, drawing in pairs(data.Skeleton) do
                drawing.Visible = false
            end
            data.Tracer.Visible = false
            data.HeadCircle.Visible = false
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

--// Initialize
function ESP:Init(Gui)
    self.Gui = Gui

    Gui:CreateSection("ESP", "Visuals")
    Gui:CreateToggle("ESP", "ESP Master", false, function(state)
        self.Config.Enabled = state
        if not state then
            for _, data in pairs(Drawings) do
                for _, drawing in pairs(data.Skeleton) do
                    drawing.Visible = false
                end
                data.Tracer.Visible = false
                data.HeadCircle.Visible = false
            end
        end
    end)
    Gui:CreateToggle("ESP", "Team Check", true, function(state)
        self.Config.TeamCheck = state
    end)

    print("[ENI] ESP module loaded")
    return self
end

return ESP