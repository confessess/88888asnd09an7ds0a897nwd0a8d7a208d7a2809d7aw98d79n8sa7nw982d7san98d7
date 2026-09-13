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
    BhopEnabled = false,
    BhopSpeed = 40,
    BhopNormalSpeed = 22,
    BhopRayStartOffset = -3,
    BhopRayLength = 1,
    -- Toggle keys
    SpeedToggleKey = Enum.KeyCode.LeftShift,
    FlyToggleKey = Enum.KeyCode.F,
    NoclipToggleKey = Enum.KeyCode.N,
    BhopToggleKey = Enum.KeyCode.B,
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
    if Movement.Config.BhopEnabled then
        task.wait(0.3)
        Movement:StartBhop()
    end
end)

RunService.RenderStepped:Connect(function()
    if Movement.Config.SpeedEnabled and not Movement.Config.BhopEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= Movement.Config.WalkSpeed then
            humanoid.WalkSpeed = Movement.Config.WalkSpeed
        end
    end
end)

--// Bhop logic
local BhopConnection = nil

function Movement:StartBhop()
    if BhopConnection then return end
    BhopConnection = RunService.Heartbeat:Connect(function()
        if not Movement.Config.BhopEnabled then
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.WalkSpeed ~= Movement.Config.BhopNormalSpeed then
                    humanoid.WalkSpeed = Movement.Config.BhopNormalSpeed
                end
            end
            return
        end

        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end

        local holdingSpace = UserInputService:IsKeyDown(Enum.KeyCode.Space)

        if holdingSpace then
            if humanoid.WalkSpeed ~= Movement.Config.BhopSpeed then
                humanoid.WalkSpeed = Movement.Config.BhopSpeed
            end

            local rootPart = char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local rayOrigin = rootPart.Position + Vector3.new(0, Movement.Config.BhopRayStartOffset, 0)
                local rayDirection = Vector3.new(0, -Movement.Config.BhopRayLength, 0)
                
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {char}
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                raycastParams.IgnoreWater = true
                
                local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                
                if raycastResult then
                    humanoid.Jump = true
                end
            end
        else
            if humanoid.WalkSpeed ~= Movement.Config.BhopNormalSpeed then
                humanoid.WalkSpeed = Movement.Config.BhopNormalSpeed
            end
        end
    end)
end

function Movement:StopBhop()
    if BhopConnection then
        BhopConnection:Disconnect()
        BhopConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Movement.Config.BhopNormalSpeed
        end
    end
end

function Movement:ToggleBhop(state)
    Movement.Config.BhopEnabled = state
    if state then
        Movement:StartBhop()
    else
        Movement:StopBhop()
    end
end

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

--//  3RD PERSON CAMERA
local thirdPersonConnection = nil
local thirdPersonPropConnection = nil

function Movement:EnableThirdPerson()
    Movement.Config.ThirdPerson = true

    local function ForceThirdPerson()
        if LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        end
    end

    ForceThirdPerson()

    if thirdPersonConnection then thirdPersonConnection:Disconnect() end
    thirdPersonConnection = RunService.RenderStepped:Connect(ForceThirdPerson)

    if thirdPersonPropConnection then thirdPersonPropConnection:Disconnect() end
    thirdPersonPropConnection = LocalPlayer:GetPropertyChangedSignal("CameraMode"):Connect(ForceThirdPerson)
end

function Movement:DisableThirdPerson()
    Movement.Config.ThirdPerson = false

    if thirdPersonConnection then
        thirdPersonConnection:Disconnect()
        thirdPersonConnection = nil
    end

    if thirdPersonPropConnection then
        thirdPersonPropConnection:Disconnect()
        thirdPersonPropConnection = nil
    end

    LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
end

function Movement:SetThirdPerson(enabled)
    if enabled then
        Movement:EnableThirdPerson()
    else
        Movement:DisableThirdPerson()
    end
end

--//  NOCLIP
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

--// ═══════════════════════════════════════════════════════════════
--//  KEYBIND CAPTURE HELPERS
--// ═══════════════════════════════════════════════════════════════

local DARK_PANEL = Color3.fromRGB(14, 14, 14)
local BORDER = Color3.fromRGB(65, 25, 27)
local RED = Color3.fromRGB(145, 20, 25)
local RED_BRIGHT = Color3.fromRGB(195, 28, 35)
local WHITE = Color3.fromRGB(255, 255, 255)
local LIGHT = Color3.fromRGB(225, 225, 225)
local GRAY = Color3.fromRGB(150, 150, 150)
local SELECTED = Color3.fromRGB(45, 15, 17)

local WaitingForKey = nil
local KeybindButtons = {}

local function GetKeyDisplayName(key)
    if not key then return "None" end
    if typeof(key) == "EnumItem" then
        if key.EnumType == Enum.KeyCode then
            return key.Name
        elseif key.EnumType == Enum.UserInputType then
            if key == Enum.UserInputType.MouseButton1 then return "LMB" end
            if key == Enum.UserInputType.MouseButton2 then return "RMB" end
            if key == Enum.UserInputType.MouseButton3 then return "MMB" end
            return key.Name
        end
    end
    return tostring(key)
end

local function UpdateKeybindButton(name)
    local btn = KeybindButtons[name]
    if not btn then return end
    local key = nil
    if name == "Speed" then key = Movement.Config.SpeedToggleKey
    elseif name == "Fly" then key = Movement.Config.FlyToggleKey
    elseif name == "Noclip" then key = Movement.Config.NoclipToggleKey
    elseif name == "Bhop" then key = Movement.Config.BhopToggleKey end
    btn.Text = "Bind: " .. GetKeyDisplayName(key)
end

local function CreateKeybindCapture(g, y, name, configKey)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 36)
    Frame.Position = UDim2.fromOffset(0, y)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 3
    Frame.Parent = g.Content

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -140, 0, 36)
    Label.BackgroundTransparency = 1
    Label.Text = name .. " Toggle Key"
    Label.TextColor3 = LIGHT
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 4
    Label.Parent = Frame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.fromOffset(120, 28)
    Btn.Position = UDim2.new(1, -140, 0, 4)
    Btn.BackgroundColor3 = DARK_PANEL
    Btn.BorderSizePixel = 0
    Btn.Text = "Bind: " .. GetKeyDisplayName(Movement.Config[configKey])
    Btn.TextColor3 = WHITE
    Btn.TextSize = 11
    Btn.Font = Enum.Font.GothamMedium
    Btn.AutoButtonColor = false
    Btn.ZIndex = 4
    Btn.Parent = Frame

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = BORDER
    Stroke.Thickness = 1
    Stroke.Parent = Btn

    KeybindButtons[name] = Btn

    Btn.MouseEnter:Connect(function()
        if WaitingForKey ~= name then
            Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Stroke.Color = RED
        end
    end)
    Btn.MouseLeave:Connect(function()
        if WaitingForKey ~= name then
            Btn.BackgroundColor3 = DARK_PANEL
            Stroke.Color = BORDER
        end
    end)

    Btn.MouseButton1Click:Connect(function()
        if WaitingForKey then return end
        WaitingForKey = name
        Btn.Text = "Press a key..."
        Btn.TextColor3 = RED_BRIGHT
        Btn.BackgroundColor3 = SELECTED
        Stroke.Color = RED_BRIGHT
    end)

    return y + 42
end

-- Global input listener for keybind capture
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not WaitingForKey then return end
    if gameProcessed then return end

    local captured = nil
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
        captured = input.KeyCode
    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
        captured = Enum.UserInputType.MouseButton1
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        captured = Enum.UserInputType.MouseButton2
    elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
        captured = Enum.UserInputType.MouseButton3
    end

    if captured then
        local name = WaitingForKey
        WaitingForKey = nil

        if name == "Speed" then Movement.Config.SpeedToggleKey = captured
        elseif name == "Fly" then Movement.Config.FlyToggleKey = captured
        elseif name == "Noclip" then Movement.Config.NoclipToggleKey = captured
        elseif name == "Bhop" then Movement.Config.BhopToggleKey = captured end

        UpdateKeybindButton(name)
        local btn = KeybindButtons[name]
        if btn then
            btn.TextColor3 = WHITE
            btn.BackgroundColor3 = DARK_PANEL
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = BORDER end
        end
    end
end)

-- Toggle handlers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    local function matches(key)
        if typeof(key) ~= "EnumItem" then return false end
        if key.EnumType == Enum.KeyCode then
            return input.KeyCode == key
        elseif key.EnumType == Enum.UserInputType then
            return input.UserInputType == key
        end
        return false
    end

    -- Speed toggle
    if matches(Movement.Config.SpeedToggleKey) then
        Movement.Config.SpeedEnabled = not Movement.Config.SpeedEnabled
        if Movement.Config.SpeedEnabled then
            SetSpeed(Movement.Config.WalkSpeed)
        else
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then humanoid.WalkSpeed = 16 end
            end
        end
    end

    -- Fly toggle
    if matches(Movement.Config.FlyToggleKey) then
        Movement:ToggleFly(not Movement.Config.FlyEnabled)
    end

    -- Noclip toggle
    if matches(Movement.Config.NoclipToggleKey) then
        Movement:SetNoclip(not Movement.Config.Noclip)
    end

    -- Bhop toggle
    if matches(Movement.Config.BhopToggleKey) then
        Movement:ToggleBhop(not Movement.Config.BhopEnabled)
    end
end)

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
        y = CreateKeybindCapture(g, y, "Speed", "SpeedToggleKey")

        y = g:CreateSection("Bunny Hop", y + 16)
        y = g:CreateToggle("Bhop", Movement.Config.BhopEnabled, function(state)
            Movement:ToggleBhop(state)
        end, y)
        y = g:CreateSlider("Bhop Speed", 16, 100, Movement.Config.BhopSpeed, function(val)
            Movement.Config.BhopSpeed = val
        end, y)
        y = CreateKeybindCapture(g, y, "Bhop", "BhopToggleKey")

        y = g:CreateSection("Flight", y + 16)
        y = g:CreateToggle("Fly", Movement.Config.FlyEnabled, function(state)
            Movement:ToggleFly(state)
        end, y)
        y = g:CreateSlider("Fly Speed", 10, 200, Movement.Config.FlySpeed, function(val)
            Movement.Config.FlySpeed = val
        end, y)
        y = CreateKeybindCapture(g, y, "Fly", "FlyToggleKey")

        y = g:CreateSection("Camera", y + 16)
        y = g:CreateToggle("3rd Person", false, function(state)
            Movement:SetThirdPerson(state)
        end, y)

        y = g:CreateSection("Movement", y + 16)
        y = g:CreateToggle("Noclip", false, function(state)
            Movement:SetNoclip(state)
        end, y)
        y = CreateKeybindCapture(g, y, "Noclip", "NoclipToggleKey")

        g.Content = originalContent
    end)

    return self
end

return Movement