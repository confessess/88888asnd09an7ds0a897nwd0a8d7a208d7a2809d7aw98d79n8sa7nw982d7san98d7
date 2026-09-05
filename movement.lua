
local Movement = {}
Movement.__index = Movement

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

Movement.Config = {
    SpeedEnabled = false,
    WalkSpeed = 50,
    AirJumpEnabled = false,
    JumpPower = 70
}

local JumpCount = 0

local function SetSpeed(speed)
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

local function SetupAirJump()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.JumpPower = Movement.Config.JumpPower

    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Landed then
            JumpCount = 0
        end
    end)
end

UserInputService.JumpRequest:Connect(function()
    if not Movement.Config.AirJumpEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if humanoid:GetState() == Enum.HumanoidStateType.Dead then return end

    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    JumpCount = JumpCount + 1
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    if Movement.Config.SpeedEnabled then
        char:WaitForChild("Humanoid")
        SetSpeed(Movement.Config.WalkSpeed)
    end
    if Movement.Config.AirJumpEnabled then
        SetupAirJump()
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

function Movement:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Movement", function(g)
        local y = g:CreateSection("Character Movement", 68)
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
        y = g:CreateToggle("Air Jump", Movement.Config.AirJumpEnabled, function(state)
            Movement.Config.AirJumpEnabled = state
            if state then
                JumpCount = 0
                SetupAirJump()
            end
        end, y)
        y = g:CreateSlider("Jump Power", 50, 150, Movement.Config.JumpPower, function(val)
            Movement.Config.JumpPower = val
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.JumpPower = val end
            end
        end, y)
    end)

    print("Movement module loaded")
    return self
end

return Movement