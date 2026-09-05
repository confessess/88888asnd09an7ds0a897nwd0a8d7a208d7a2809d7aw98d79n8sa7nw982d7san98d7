--[[
    Arsenal Suite — Movement Module (Blackout.cc)
    By ENI for LO ♥
    Speed, Fly (inlined)
--]]

local Movement = {}
Movement.__index = Movement

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

Movement.Config = {
    SpeedEnabled = false,
    WalkSpeed = 50,
    FlyEnabled = false,
    FlySpeed = 50
}

--// Speed logic
local function SetSpeed(speed)
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if Movement.Config.SpeedEnabled then
        char:WaitForChild("Humanoid")
        SetSpeed(Movement.Config.WalkSpeed)
    end
    if Movement.Config.FlyEnabled then
        task.wait(0.3)
        Movement:StartFlying()
    end
end)

RunService.RenderStepped:Connect(function()
    if Movement.Config.SpeedEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= Movement.Config.WalkSpeed then
            humanoid.WalkSpeed = Movement.Config.WalkSpeed
        end
    end
end)

--// Fly logic (inlined)
local FlyConnection = nil
local FlyBodyVel = nil
local FlyBodyGyro = nil

function Movement:StartFlying()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not humanoid then return end

    humanoid.PlatformStand = true

    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    FlyBodyGyro.P = 10000
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp

    FlyBodyVel = Instance.new("BodyVelocity")
    FlyBodyVel.MaxForce = Vector3.new(400000, 400000, 400000)
    FlyBodyVel.Velocity = Vector3.zero
    FlyBodyVel.Parent = hrp

    FlyConnection = RunService.Heartbeat:Connect(function()
        if not Movement.Config.FlyEnabled then
            Movement:StopFlying()
            return
        end

        local currentChar = LocalPlayer.Character
        if not currentChar then return end
        local currentHrp = currentChar:FindFirstChild("HumanoidRootPart")
        local currentHumanoid = currentChar:FindFirstChildOfClass("Humanoid")
        if not currentHrp or not currentHumanoid then return end

        if FlyBodyGyro and FlyBodyGyro.Parent then
            FlyBodyGyro.CFrame = Camera.CFrame
        end

        if FlyBodyVel and FlyBodyVel.Parent then
            local moveDir = Vector3.zero

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end

            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * Movement.Config.FlySpeed
            end

            FlyBodyVel.Velocity = moveDir
        end
    end)
end

function Movement:StopFlying()
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            for _, child in ipairs(hrp:GetChildren()) do
                if child:IsA("BodyGyro") or child:IsA("BodyVelocity") then
                    child:Destroy()
                end
            end
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    FlyBodyVel = nil
    FlyBodyGyro = nil
end

function Movement:ToggleFly(state)
    Movement.Config.FlyEnabled = state
    if state then
        Movement:StartFlying()
    else
        Movement:StopFlying()
    end
end

--// GUI
function Movement:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Movement", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        local y = g:CreateSection("Character Movement", 0)
        y = g:CreateToggle("Speed", Movement.Config.SpeedEnabled, function(state)
            Movement.Config.SpeedEnabled = state
            if state then
                SetSpeed(Movement.Config.WalkSpeed)
            else
                local char = LocalPlayer.Character
                if char then
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    if humanoid then humanoid.WalkSpeed = 16 end
                end
            end
        end, y)
        y = g:CreateSlider("Walk Speed", 16, 100, Movement.Config.WalkSpeed, function(val)
            Movement.Config.WalkSpeed = val
            if Movement.Config.SpeedEnabled then SetSpeed(val) end
        end, y)

        y = g:CreateSection("Flight", y + 16)
        y = g:CreateToggle("Fly", Movement.Config.FlyEnabled, function(state)
            Movement:ToggleFly(state)
        end, y)
        y = g:CreateSlider("Fly Speed", 10, 200, Movement.Config.FlySpeed, function(val)
            Movement.Config.FlySpeed = val
        end, y)

        g.Content = originalContent
    end)

    print("[ENI] Movement module loaded")
    return self
end

return Movement