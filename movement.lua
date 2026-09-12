

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
    FlySpeed = 50,
    Noclip = false,
    ThirdPerson = false,
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
    if Movement.Config.Noclip then
        task.wait(0.5)
        Movement:StartNoclip()
    end
    if Movement.Config.ThirdPerson then
        task.wait(0.5)
        Movement:EnableThirdPerson()
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

--// Fly logic
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

--// Z3US 3RD PERSON CAMERA
local thirdPersonConnection = nil

function Movement:EnableThirdPerson()
    Movement.Config.ThirdPerson = true

    local function ForceThirdPerson()
        if LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        end
    end

    -- Initial force
    ForceThirdPerson()

    -- Keep forcing every frame
    if thirdPersonConnection then thirdPersonConnection:Disconnect() end
    thirdPersonConnection = RunService.RenderStepped:Connect(ForceThirdPerson)

    -- Also hook property changes
    LocalPlayer:GetPropertyChangedSignal("CameraMode"):Connect(ForceThirdPerson)

    
end

function Movement:DisableThirdPerson()
    Movement.Config.ThirdPerson = false

    if thirdPersonConnection then
        thirdPersonConnection:Disconnect()
        thirdPersonConnection = nil
    end

    LocalPlayer.CameraMode = Enum.CameraMode.Classic
   
end

function Movement:SetThirdPerson(enabled)
    if enabled then
        Movement:EnableThirdPerson()
    else
        Movement:DisableThirdPerson()
    end
end

--// Z3US NOCLIP
local NoclipConnection = nil

function Movement:StartNoclip()
    if NoclipConnection then NoclipConnection:Disconnect() end
    NoclipConnection = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

function Movement:StopNoclip()
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function Movement:SetNoclip(enabled)
    Movement.Config.Noclip = enabled
    if enabled then
        Movement:StartNoclip()
    else
        Movement:StopNoclip()
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

        y = g:CreateSection("Z3US Camera", y + 16)
        y = g:CreateToggle("3rd Person", false, function(state)
            Movement:SetThirdPerson(state)
        end, y)

        y = g:CreateSection("Z3US Movement", y + 16)
        y = g:CreateToggle("Noclip", false, function(state)
            Movement:SetNoclip(state)
        end, y)

        g.Content = originalContent
    end)

    
    return self
end

return Movement