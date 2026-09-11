--[[
    Arsenal Suite — GUI Framework (Blackout.cc)
    By ENI for LO ♥
    v4 — Tight spacing, fixed RightShift toggle, wave effect
--]]

local Gui = {}
Gui.__index = Gui

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// Colors
local BLACK      = Color3.fromRGB(2, 2, 2)
local BACKGROUND = Color3.fromRGB(7, 7, 7)
local DARK_PANEL = Color3.fromRGB(14, 14, 14)
local RED        = Color3.fromRGB(145, 20, 25)
local RED_BRIGHT = Color3.fromRGB(195, 28, 35)
local RED_DARK   = Color3.fromRGB(70, 10, 13)
local SELECTED   = Color3.fromRGB(45, 15, 17)
local HOVER      = Color3.fromRGB(18, 7, 8)
local WHITE      = Color3.fromRGB(255, 255, 255)
local LIGHT      = Color3.fromRGB(225, 225, 225)
local GRAY       = Color3.fromRGB(150, 150, 150)
local BORDER     = Color3.fromRGB(65, 25, 27)

--// Wave Config
local WAVE_COLOR        = Color3.fromRGB(255, 130, 130)
local WAVE_PEAK_TRANS   = 0.82
local WAVE_BAND_WIDTH   = 0.28
local WAVE_DURATION     = 2.4
local WAVE_PAUSE        = 1.0
local WAVE_ROTATION     = -45

--// State
local ToggleKey = Enum.KeyCode.RightShift
local WaitingForKey = false
local MenuOpen = true
local Animating = false

--// ScreenGui
function Gui:Init()
    local old = PlayerGui:FindFirstChild("BlackoutGUI")
    if old then old:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BlackoutGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.fromOffset(680, 440)
    Main.Position = UDim2.new(0.5, -340, 0.5, -220)
    Main.BackgroundColor3 = BACKGROUND
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = RED
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.25
    MainStroke.Parent = Main

    local SavedPosition = Main.Position
    local OriginalSize = Main.Size

    --// Background + Wave
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.fromScale(1, 1)
    Background.BackgroundColor3 = BACKGROUND
    Background.BorderSizePixel = 0
    Background.ZIndex = 1
    Background.Parent = Main

    local BgCorner = Instance.new("UICorner")
    BgCorner.CornerRadius = UDim.new(0, 12)
    BgCorner.Parent = Background

    local sheen = Instance.new("Frame")
    sheen.Name = "ENI_WaveSheen"
    sheen.Size = UDim2.fromScale(1, 1)
    sheen.BackgroundColor3 = WAVE_COLOR
    sheen.BackgroundTransparency = 0
    sheen.BorderSizePixel = 0
    sheen.ZIndex = 1
    sheen.Parent = Background

    local waveGrad = Instance.new("UIGradient")
    waveGrad.Rotation = WAVE_ROTATION
    waveGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 1),
        NumberSequenceKeypoint.new(math.clamp(0.50 - WAVE_BAND_WIDTH, 0, 1), 1),
        NumberSequenceKeypoint.new(0.50, WAVE_PEAK_TRANS),
        NumberSequenceKeypoint.new(math.clamp(0.50 + WAVE_BAND_WIDTH, 0, 1), 1),
        NumberSequenceKeypoint.new(1.00, 1)
    })
    waveGrad.Parent = sheen

    do
        local offset = 1.5
        local paused = false
        local pauseTimer = 0
        local speed = 3.0 / WAVE_DURATION

        RunService.RenderStepped:Connect(function(dt)
            if not sheen.Parent then return end
            if not Main.Visible then return end
            if paused then
                pauseTimer = pauseTimer - dt
                if pauseTimer <= 0 then paused = false offset = 1.5 end
                return
            end
            offset = offset - (speed * dt)
            if offset <= -1.5 then paused = true pauseTimer = WAVE_PAUSE end
            waveGrad.Offset = Vector2.new(offset, 0)
        end)
    end

    --// TopBar
    local Top = Instance.new("Frame")
    Top.Name = "TopBar"
    Top.Size = UDim2.new(1, 0, 0, 58)
    Top.BackgroundColor3 = BLACK
    Top.BorderSizePixel = 0
    Top.ZIndex = 2
    Top.Parent = Main

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 12)
    TopCorner.Parent = Top

    local TopBottom = Instance.new("Frame")
    TopBottom.Size = UDim2.new(1, 0, 0, 12)
    TopBottom.Position = UDim2.new(0, 0, 1, -12)
    TopBottom.BackgroundColor3 = BLACK
    TopBottom.BorderSizePixel = 0
    TopBottom.ZIndex = 2
    TopBottom.Parent = Top

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(1, -36, 0, 3)
    Accent.Position = UDim2.fromOffset(18, 55)
    Accent.BackgroundColor3 = RED_BRIGHT
    Accent.BorderSizePixel = 0
    Accent.ZIndex = 5
    Accent.Parent = Top

    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(1, 0)
    AccentCorner.Parent = Accent

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 0, 24)
    Title.Position = UDim2.fromOffset(20, 9)
    Title.BackgroundTransparency = 1
    Title.Text = "Blackout.cc"
    Title.TextColor3 = WHITE
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 6
    Title.Parent = Top

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Size = UDim2.new(1, -100, 0, 16)
    Subtitle.Position = UDim2.fromOffset(21, 32)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "Made by confess"
    Subtitle.TextColor3 = GRAY
    Subtitle.TextSize = 10
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.ZIndex = 6
    Subtitle.Parent = Top

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.fromOffset(30, 28)
    Close.Position = UDim2.new(1, -44, 0, 12)
    Close.BackgroundColor3 = WHITE
    Close.BorderSizePixel = 0
    Close.Text = "×"
    Close.TextColor3 = BLACK
    Close.TextSize = 18
    Close.Font = Enum.Font.GothamBold
    Close.AutoButtonColor = false
    Close.ZIndex = 7
    Close.Parent = Top

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = Close

    Close.MouseEnter:Connect(function() Close.BackgroundColor3 = Color3.fromRGB(215, 215, 215) end)
    Close.MouseLeave:Connect(function() Close.BackgroundColor3 = WHITE end)
    Close.MouseButton1Click:Connect(function() self:HideMenu() end)

    --// Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.fromOffset(160, 356)
    Sidebar.Position = UDim2.fromOffset(12, 70)
    Sidebar.BackgroundColor3 = BLACK
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 2
    Sidebar.Parent = Main

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 10)
    SidebarCorner.Parent = Sidebar

    local SidebarStroke = Instance.new("UIStroke")
    SidebarStroke.Color = BORDER
    SidebarStroke.Thickness = 1
    SidebarStroke.Transparency = 0.15
    SidebarStroke.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 10)
    SidebarPadding.PaddingLeft = UDim.new(0, 10)
    SidebarPadding.PaddingRight = UDim.new(0, 10)
    SidebarPadding.PaddingBottom = UDim.new(0, 10)
    SidebarPadding.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 3)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = Sidebar

    --// Content
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -196, 1, -78)
    Content.Position = UDim2.fromOffset(184, 70)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 2
    Content.Parent = Main

    local ContentTitle = Instance.new("TextLabel")
    ContentTitle.Size = UDim2.new(1, 0, 0, 26)
    ContentTitle.Position = UDim2.fromOffset(0, 0)
    ContentTitle.BackgroundTransparency = 1
    ContentTitle.Text = "Combat"
    ContentTitle.TextColor3 = WHITE
    ContentTitle.TextSize = 19
    ContentTitle.Font = Enum.Font.GothamBold
    ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
    ContentTitle.ZIndex = 3
    ContentTitle.Parent = Content

    local ContentSubtitle = Instance.new("TextLabel")
    ContentSubtitle.Size = UDim2.new(1, 0, 0, 16)
    ContentSubtitle.Position = UDim2.fromOffset(0, 25)
    ContentSubtitle.BackgroundTransparency = 1
    ContentSubtitle.Text = "Configure your combat settings."
    ContentSubtitle.TextColor3 = GRAY
    ContentSubtitle.TextSize = 11
    ContentSubtitle.Font = Enum.Font.Gotham
    ContentSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    ContentSubtitle.ZIndex = 3
    ContentSubtitle.Parent = Content

    --// Dragging
    local Dragging = false
    local DragStart
    local StartPosition

    Top.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        Dragging = true
        DragStart = input.Position
        StartPosition = Main.Position
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
                SavedPosition = Main.Position
                if connection then connection:Disconnect() end
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not Dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local delta = input.Position - DragStart
        Main.Position = UDim2.new(
            StartPosition.X.Scale, StartPosition.X.Offset + delta.X,
            StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y
        )
    end)

    self.ScreenGui = ScreenGui
    self.Main = Main
    self.Content = Content
    self.ContentTitle = ContentTitle
    self.ContentSubtitle = ContentSubtitle
    self.Sidebar = Sidebar
    self.SavedPosition = SavedPosition
    self.OriginalSize = OriginalSize
    self.Tabs = {}
    self.CurrentTab = nil
    self.TabButtons = {}

    --// ═══════════ FIXED TOGGLE — checks key BEFORE processed ═══════════
    UserInputService.InputBegan:Connect(function(input, processed)
        --// Keybind capture mode
        if WaitingForKey then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode ~= Enum.KeyCode.Unknown then
                    ToggleKey = input.KeyCode
                    WaitingForKey = false
                    local settingsBtn = Content:FindFirstChild("Keybind")
                    if settingsBtn then
                        settingsBtn.Text = ToggleKey.Name
                        settingsBtn.TextColor3 = WHITE
                        settingsBtn.BackgroundColor3 = DARK_PANEL
                        local stroke = settingsBtn:FindFirstChildOfClass("UIStroke")
                        if stroke then stroke.Color = BORDER end
                    end
                end
            end
            return
        end

        --// Toggle check FIRST — before processed check so RightShift works in-game
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == ToggleKey then
            if MenuOpen then self:HideMenu() else self:ShowMenu() end
            return
        end

        --// (processed check removed from blocking the toggle — game can process it too, we don't care)
    end)

    print("[ENI] Blackout GUI initialized")
    return self
end

function Gui:HideMenu()
    if Animating or not MenuOpen then return end
    Animating = true
    MenuOpen = false
    self.SavedPosition = self.Main.Position

    local closeSize = UDim2.fromOffset(self.OriginalSize.X.Offset - 50, self.OriginalSize.Y.Offset - 35)
    local closePos = UDim2.new(
        self.SavedPosition.X.Scale, self.SavedPosition.X.Offset + 25,
        self.SavedPosition.Y.Scale, self.SavedPosition.Y.Offset + 18
    )

    local tween = TweenService:Create(self.Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Size = closeSize, Position = closePos, BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        self.Main.Visible = false
        self.Main.Size = self.OriginalSize
        self.Main.Position = self.SavedPosition
        self.Main.BackgroundTransparency = 0
        Animating = false
    end)
end

function Gui:ShowMenu()
    if Animating or MenuOpen then return end
    Animating = true
    MenuOpen = true
    self.Main.Visible = true
    self.Main.Size = UDim2.fromOffset(self.OriginalSize.X.Offset - 50, self.OriginalSize.Y.Offset - 35)
    self.Main.Position = UDim2.new(
        self.SavedPosition.X.Scale, self.SavedPosition.X.Offset + 25,
        self.SavedPosition.Y.Scale, self.SavedPosition.Y.Offset + 18
    )
    self.Main.BackgroundTransparency = 1

    local tween = TweenService:Create(self.Main, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = self.OriginalSize, Position = self.SavedPosition, BackgroundTransparency = 0
    })
    tween:Play()
    tween.Completed:Connect(function()
        self.Main.Position = self.SavedPosition
        self.Main.Size = self.OriginalSize
        Animating = false
    end)
end

--// FIXED CreateTab — no overlap
function Gui:CreateTab(name, description)
    description = description or "Configure your " .. name:lower() .. " settings."
    local index = #self.Tabs + 1

    local Button = Instance.new("TextButton")
    Button.Name = name:gsub("%s+", "")
    Button.Size = UDim2.new(1, 0, 0, 44)
    Button.LayoutOrder = index
    Button.BackgroundColor3 = BLACK
    Button.BorderSizePixel = 0
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.ClipsDescendants = true
    Button.ZIndex = 3
    Button.Parent = self.Sidebar

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button

    local Text = Instance.new("TextLabel")
    Text.Name = "TabText"
    Text.Size = UDim2.new(1, -28, 1, 0)
    Text.Position = UDim2.fromOffset(15, 0)
    Text.BackgroundTransparency = 1
    Text.Text = name
    Text.TextColor3 = Color3.fromRGB(165, 165, 165)
    Text.TextSize = 13
    Text.Font = Enum.Font.GothamMedium
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.TextTruncate = Enum.TextTruncate.AtEnd
    Text.ZIndex = 4
    Text.Parent = Button

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.fromOffset(3, 18)
    Indicator.Position = UDim2.new(0, 5, 0.5, -9)
    Indicator.BackgroundColor3 = RED_BRIGHT
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.ZIndex = 5
    Indicator.Parent = Button

    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator

    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Thickness = 1
    ButtonStroke.Transparency = 1
    ButtonStroke.Parent = Button

    self.TabButtons[name] = { Button = Button, Text = Text, Indicator = Indicator, Stroke = ButtonStroke }

    Button.MouseEnter:Connect(function()
        if self.CurrentTab ~= name then
            Button.BackgroundColor3 = HOVER
            Text.TextColor3 = WHITE
        end
    end)
    Button.MouseLeave:Connect(function()
        if self.CurrentTab ~= name then
            Button.BackgroundColor3 = BLACK
            Text.TextColor3 = Color3.fromRGB(165, 165, 165)
        end
    end)
    Button.MouseButton1Click:Connect(function() self:SwitchTab(name) end)

    local tabData = { Name = name, Description = description, Elements = {} }
    table.insert(self.Tabs, tabData)

    if #self.Tabs == 1 then self:SwitchTab(name) end
    return tabData
end

function Gui:SwitchTab(name)
    self.CurrentTab = name
    for tabName, data in pairs(self.TabButtons) do
        if tabName == name then
            data.Button.BackgroundColor3 = SELECTED
            data.Text.TextColor3 = WHITE
            data.Indicator.Visible = true
            data.Stroke.Color = RED_BRIGHT
            data.Stroke.Transparency = 0.45
        else
            data.Button.BackgroundColor3 = BLACK
            data.Text.TextColor3 = Color3.fromRGB(165, 165, 165)
            data.Indicator.Visible = false
            data.Stroke.Color = BLACK
            data.Stroke.Transparency = 1
        end
    end

    self.ContentTitle.Text = name
    self.ContentSubtitle.Text = self:GetTabDescription(name) or ""

    for _, child in ipairs(self.Content:GetChildren()) do
        if child ~= self.ContentTitle and child ~= self.ContentSubtitle then
            child:Destroy()
        end
    end

    local tab = self:GetTab(name)
    if tab and tab.Rebuild then tab.Rebuild(self) end
end

function Gui:GetTab(name)
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == name then return tab end
    end
    return nil
end

function Gui:GetTabDescription(name)
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == name then return tab.Description end
    end
    return ""
end

function Gui:SetTabRebuild(name, callback)
    local tab = self:GetTab(name)
    if tab then tab.Rebuild = callback end
end

--// Scroll content — starts at y=48 (tight under subtitle)
function Gui:CreateScrollContent()
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Name = "TabScroll"
    ScrollFrame.Size = UDim2.new(1, 0, 1, -48)
    ScrollFrame.Position = UDim2.fromOffset(0, 48)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 2
    ScrollFrame.ScrollBarImageColor3 = RED_BRIGHT
    ScrollFrame.ScrollBarImageTransparency = 0.6
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.ZIndex = 3
    ScrollFrame.Parent = self.Content

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 4)
    Padding.PaddingLeft = UDim.new(0, 2)
    Padding.PaddingRight = UDim.new(0, 6)
    Padding.PaddingBottom = UDim.new(0, 10)
    Padding.Parent = ScrollFrame

    return ScrollFrame
end

--// ═══════════ TIGHT-SPACED ELEMENTS ═══════════
--// Section: 20px label, divider at +24, next at +34
function Gui:CreateSection(text, y)
    y = y or 0
    local Section = Instance.new("TextLabel")
    Section.Size = UDim2.new(1, 0, 0, 20)
    Section.Position = UDim2.fromOffset(0, y)
    Section.BackgroundTransparency = 1
    Section.Text = text
    Section.TextColor3 = WHITE
    Section.TextSize = 13
    Section.Font = Enum.Font.GothamBold
    Section.TextXAlignment = Enum.TextXAlignment.Left
    Section.ZIndex = 3
    Section.Parent = self.Content

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, 0, 0, 1)
    Divider.Position = UDim2.fromOffset(0, y + 24)
    Divider.BackgroundColor3 = Color3.fromRGB(65, 30, 31)
    Divider.BorderSizePixel = 0
    Divider.ZIndex = 3
    Divider.Parent = self.Content

    return y + 34
end

--// Toggle: 32px tall, returns +38
function Gui:CreateToggle(label, default, callback, y)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 32)
    ToggleFrame.Position = UDim2.fromOffset(0, y)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.ZIndex = 3
    ToggleFrame.Parent = self.Content

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 0, 32)
    Label.BackgroundTransparency = 1
    Label.Text = label
    Label.TextColor3 = LIGHT
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 4
    Label.Parent = ToggleFrame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.fromOffset(42, 22)
    ToggleBtn.Position = UDim2.new(1, -46, 0, 5)
    ToggleBtn.BackgroundColor3 = default and RED_BRIGHT or DARK_PANEL
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Text = default and "ON" or "OFF"
    ToggleBtn.TextColor3 = default and WHITE or GRAY
    ToggleBtn.TextSize = 10
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.AutoButtonColor = false
    ToggleBtn.ZIndex = 4
    ToggleBtn.Parent = ToggleFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleBtn

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = default and RED or BORDER
    ToggleStroke.Thickness = 1
    ToggleStroke.Parent = ToggleBtn

    local State = default

    ToggleBtn.MouseEnter:Connect(function()
        ToggleBtn.BackgroundColor3 = State and Color3.fromRGB(215, 40, 45) or Color3.fromRGB(25, 25, 25)
    end)
    ToggleBtn.MouseLeave:Connect(function()
        ToggleBtn.BackgroundColor3 = State and RED_BRIGHT or DARK_PANEL
    end)
    ToggleBtn.MouseButton1Click:Connect(function()
        State = not State
        ToggleBtn.BackgroundColor3 = State and RED_BRIGHT or DARK_PANEL
        ToggleBtn.TextColor3 = State and WHITE or GRAY
        ToggleBtn.Text = State and "ON" or "OFF"
        ToggleStroke.Color = State and RED or BORDER
        if callback then callback(State) end
    end)

    return y + 38
end

--// Slider: 44px tall, returns +50
function Gui:CreateSlider(label, min, max, default, callback, y)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 44)
    SliderFrame.Position = UDim2.fromOffset(0, y)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.ZIndex = 3
    SliderFrame.Parent = self.Content

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -50, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = label
    Label.TextColor3 = LIGHT
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 4
    Label.Parent = SliderFrame

    local ValueText = Instance.new("TextLabel")
    ValueText.Size = UDim2.fromOffset(44, 18)
    ValueText.Position = UDim2.new(1, -44, 0, 0)
    ValueText.BackgroundTransparency = 1
    ValueText.Text = tostring(default)
    ValueText.TextColor3 = RED_BRIGHT
    ValueText.TextSize = 12
    ValueText.Font = Enum.Font.GothamBold
    ValueText.TextXAlignment = Enum.TextXAlignment.Right
    ValueText.ZIndex = 4
    ValueText.Parent = SliderFrame

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, -8, 0, 3)
    Track.Position = UDim2.fromOffset(4, 30)
    Track.BackgroundColor3 = DARK_PANEL
    Track.BorderSizePixel = 0
    Track.ZIndex = 4
    Track.Parent = SliderFrame

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(0, 2)
    TrackCorner.Parent = Track

    local Fill = Instance.new("Frame")
    local range = max - min
    local startPos = range > 0 and (default - min) / range or 0
    Fill.Size = UDim2.new(startPos, 0, 1, 0)
    Fill.BackgroundColor3 = RED_BRIGHT
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 5
    Fill.Parent = Track

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 2)
    FillCorner.Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(12, 12)
    Knob.Position = UDim2.new(startPos, -6, 0.5, -6)
    Knob.BackgroundColor3 = WHITE
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 5
    Knob.Parent = Track

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local Dragging = false

    local function update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (pos * range))
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        Knob.Position = UDim2.new(pos, -6, 0.5, -6)
        ValueText.Text = tostring(value)
        if callback then callback(value) end
    end

    Knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end
    end)
    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)

    return y + 50
end

--// Dropdown: 32px tall, returns +38
function Gui:CreateDropdown(label, options, default, callback, y)
    local DropFrame = Instance.new("Frame")
    DropFrame.Size = UDim2.new(1, 0, 0, 32)
    DropFrame.Position = UDim2.fromOffset(0, y)
    DropFrame.BackgroundTransparency = 1
    DropFrame.ZIndex = 3
    DropFrame.Parent = self.Content

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = label
    Label.TextColor3 = LIGHT
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 4
    Label.Parent = DropFrame

    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.fromOffset(100, 24)
    DropBtn.Position = UDim2.new(1, -104, 0, 4)
    DropBtn.BackgroundColor3 = DARK_PANEL
    DropBtn.BorderSizePixel = 0
    DropBtn.Text = default or options[1]
    DropBtn.TextColor3 = WHITE
    DropBtn.TextSize = 11
    DropBtn.Font = Enum.Font.GothamMedium
    DropBtn.AutoButtonColor = false
    DropBtn.ZIndex = 4
    DropBtn.Parent = DropFrame

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, 5)
    DropCorner.Parent = DropBtn

    local DropStroke = Instance.new("UIStroke")
    DropStroke.Color = BORDER
    DropStroke.Thickness = 1
    DropStroke.Parent = DropBtn

    local selected = default or options[1]

    DropBtn.MouseEnter:Connect(function() DropBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25) end)
    DropBtn.MouseLeave:Connect(function() DropBtn.BackgroundColor3 = DARK_PANEL end)
    DropBtn.MouseButton1Click:Connect(function()
        local currentIdx = 1
        for i, opt in ipairs(options) do
            if opt == selected then currentIdx = i break end
        end
        selected = options[(currentIdx % #options) + 1]
        DropBtn.Text = selected
        if callback then callback(selected) end
    end)

    return y + 38
end

--// Button: 30px tall, returns +36
function Gui:CreateButton(label, callback, y)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 30)
    Btn.Position = UDim2.fromOffset(0, y)
    Btn.BackgroundColor3 = DARK_PANEL
    Btn.BorderSizePixel = 0
    Btn.Text = label
    Btn.TextColor3 = WHITE
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Btn.AutoButtonColor = false
    Btn.ZIndex = 3
    Btn.Parent = self.Content

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn

    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Color = BORDER
    BtnStroke.Thickness = 1
    BtnStroke.Parent = Btn

    Btn.MouseEnter:Connect(function()
        Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        BtnStroke.Color = RED
    end)
    Btn.MouseLeave:Connect(function()
        Btn.BackgroundColor3 = DARK_PANEL
        BtnStroke.Color = BORDER
    end)
    Btn.MouseButton1Click:Connect(function() if callback then callback() end end)

    return y + 36
end

--// Keybind setting: compact 54px total
function Gui:CreateKeybindSetting(y)
    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.Size = UDim2.new(1, -130, 0, 28)
    KeyLabel.Position = UDim2.fromOffset(0, y)
    KeyLabel.BackgroundTransparency = 1
    KeyLabel.Text = "GUI Toggle Keybind"
    KeyLabel.TextColor3 = LIGHT
    KeyLabel.TextSize = 13
    KeyLabel.Font = Enum.Font.GothamMedium
    KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeyLabel.ZIndex = 3
    KeyLabel.Parent = self.Content

    local KeyDescription = Instance.new("TextLabel")
    KeyDescription.Size = UDim2.new(1, -130, 0, 14)
    KeyDescription.Position = UDim2.fromOffset(0, y + 21)
    KeyDescription.BackgroundTransparency = 1
    KeyDescription.Text = "Press this key to show or hide the GUI."
    KeyDescription.TextColor3 = GRAY
    KeyDescription.TextSize = 10
    KeyDescription.Font = Enum.Font.Gotham
    KeyDescription.TextXAlignment = Enum.TextXAlignment.Left
    KeyDescription.ZIndex = 3
    KeyDescription.Parent = self.Content

    local Keybind = Instance.new("TextButton")
    Keybind.Name = "Keybind"
    Keybind.Size = UDim2.fromOffset(100, 30)
    Keybind.Position = UDim2.new(1, -100, 0, y)
    Keybind.BackgroundColor3 = DARK_PANEL
    Keybind.BorderSizePixel = 0
    Keybind.Text = ToggleKey.Name
    Keybind.TextColor3 = WHITE
    Keybind.TextSize = 12
    Keybind.Font = Enum.Font.GothamMedium
    Keybind.AutoButtonColor = false
    Keybind.ZIndex = 3
    Keybind.Parent = self.Content

    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 7)
    KeyCorner.Parent = Keybind

    local KeyStroke = Instance.new("UIStroke")
    KeyStroke.Color = BORDER
    KeyStroke.Thickness = 1
    KeyStroke.Parent = Keybind

    Keybind.MouseEnter:Connect(function()
        if not WaitingForKey then Keybind.BackgroundColor3 = SELECTED KeyStroke.Color = RED end
    end)
    Keybind.MouseLeave:Connect(function()
        if not WaitingForKey then Keybind.BackgroundColor3 = DARK_PANEL KeyStroke.Color = BORDER end
    end)
    Keybind.MouseButton1Click:Connect(function()
        if WaitingForKey then return end
        WaitingForKey = true
        Keybind.Text = "Press a key..."
        Keybind.TextColor3 = RED_BRIGHT
        Keybind.BackgroundColor3 = RED_DARK
        KeyStroke.Color = RED_BRIGHT
    end)

    return y + 54
end

return Gui