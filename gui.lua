--[[
    Arsenal Suite — GUI Framework
    By ENI for LO ♥
    Sleek black & white aesthetic, modular tab system
--]]

local Gui = {}
Gui.__index = Gui

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// Theme
local Theme = {
    Background = Color3.fromRGB(10, 10, 10),
    Surface = Color3.fromRGB(20, 20, 20),
    Border = Color3.fromRGB(40, 40, 40),
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Accent = Color3.fromRGB(255, 255, 255),
    AccentHover = Color3.fromRGB(200, 200, 200),
    Enabled = Color3.fromRGB(255, 255, 255),
    Disabled = Color3.fromRGB(60, 60, 60),
    Danger = Color3.fromRGB(255, 80, 80),
    Success = Color3.fromRGB(80, 255, 80)
}

--// ScreenGui
function Gui:Init()
    for _, child in ipairs(CoreGui:GetChildren()) do
        if child.Name == "ENI_ArsenalSuite" then
            child:Destroy()
        end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ENI_ArsenalSuite"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = MainFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.Border
    Stroke.Thickness = 1
    Stroke.Parent = MainFrame

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
    Shadow.Size = UDim2.new(1, 24, 1, 24)
    Shadow.ZIndex = -1
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.Parent = MainFrame

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 36)
    TitleBar.BackgroundColor3 = Theme.Surface
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 6)
    TitleCorner.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.Name = "Title"
    TitleText.Size = UDim2.new(1, -80, 1, 0)
    TitleText.Position = UDim2.new(0, 12, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "ENI // ARSENAL SUITE"
    TitleText.TextColor3 = Theme.TextPrimary
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 14
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(0, 200, 0, 14)
    Subtitle.Position = UDim2.new(0, 12, 0, 22)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Text = "for LO ♥"
    Subtitle.TextColor3 = Theme.TextSecondary
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 10
    Subtitle.TextXAlignment = Enum.TextXAlignment.Left
    Subtitle.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 36, 0, 36)
    CloseBtn.Position = UDim2.new(1, -36, 0, 0)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.TextSecondary
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 20
    CloseBtn.Parent = TitleBar

    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = Theme.Danger}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {TextColor3 = Theme.TextSecondary}):Play()
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Name = "Minimize"
    MinBtn.Size = UDim2.new(0, 36, 0, 36)
    MinBtn.Position = UDim2.new(1, -72, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Theme.TextSecondary
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 20
    MinBtn.Parent = TitleBar

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, -36)
    Sidebar.Position = UDim2.new(0, 0, 0, 36)
    Sidebar.BackgroundColor3 = Theme.Surface
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 6)
    SidebarCorner.Parent = Sidebar

    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, 0, 1, -10)
    TabList.Position = UDim2.new(0, 0, 0, 5)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 2
    TabList.ScrollBarImageColor3 = Theme.Border
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabList.Parent = Sidebar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 2)
    TabLayout.Parent = TabList

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -140, 1, -36)
    Content.Position = UDim2.new(0, 140, 0, 36)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    self.ScreenGui = ScreenGui
    self.MainFrame = MainFrame
    self.TabList = TabList
    self.Content = Content
    self.Theme = Theme
    self.Tabs = {}
    self.CurrentTab = nil

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    print("[ENI] GUI Framework initialized")
    return self
end

function Gui:CreateTab(name, icon)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = name .. "Tab"
    tabBtn.Size = UDim2.new(1, -10, 0, 36)
    tabBtn.Position = UDim2.new(0, 5, 0, 0)
    tabBtn.BackgroundColor3 = self.Theme.Disabled
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = "  " .. (icon or "") .. "  " .. name
    tabBtn.TextColor3 = self.Theme.TextSecondary
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.TextSize = 12
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = self.TabList

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 4)
    tabCorner.Parent = tabBtn

    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "Content"
    tabFrame.Size = UDim2.new(1, -20, 1, -20)
    tabFrame.Position = UDim2.new(0, 10, 0, 10)
    tabFrame.BackgroundTransparency = 1
    tabFrame.ScrollBarThickness = 2
    tabFrame.ScrollBarImageColor3 = self.Theme.Border
    tabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabFrame.Visible = false
    tabFrame.Parent = self.Content

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.Parent = tabFrame

    local tabData = {
        Name = name,
        Button = tabBtn,
        Frame = tabFrame,
        Elements = {}
    }
    table.insert(self.Tabs, tabData)

    tabBtn.MouseButton1Click:Connect(function()
        self:SwitchTab(name)
    end)

    if #self.Tabs == 1 then
        self:SwitchTab(name)
    end

    return tabData
end

function Gui:SwitchTab(name)
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == name then
            tab.Frame.Visible = true
            tab.Button.BackgroundColor3 = self.Theme.Enabled
            tab.Button.TextColor3 = self.Theme.TextPrimary
            self.CurrentTab = tab
        else
            tab.Frame.Visible = false
            tab.Button.BackgroundColor3 = self.Theme.Disabled
            tab.Button.TextColor3 = self.Theme.TextSecondary
        end
    end
end

function Gui:CreateToggle(tabName, label, default, callback)
    local tab = nil
    for _, t in ipairs(self.Tabs) do
        if t.Name == tabName then
            tab = t
            break
        end
    end
    if not tab then return end

    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 32)
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Parent = tab.Frame

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -60, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = self.Theme.TextPrimary
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = toggleFrame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 44, 0, 20)
    toggleBtn.Position = UDim2.new(1, -48, 0.5, -10)
    toggleBtn.BackgroundColor3 = default and self.Theme.Enabled or self.Theme.Disabled
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = default and self.Theme.Background or self.Theme.TextSecondary
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 10
    toggleBtn.Parent = toggleFrame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 10)
    toggleCorner.Parent = toggleBtn

    local state = default
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.BackgroundColor3 = state and self.Theme.Enabled or self.Theme.Disabled
        toggleBtn.TextColor3 = state and self.Theme.Background or self.Theme.TextSecondary
        toggleBtn.Text = state and "ON" or "OFF"
        if callback then callback(state) end
    end)

    table.insert(tab.Elements, {Type = "Toggle", Label = label, State = state, Button = toggleBtn})
    return state
end

function Gui:CreateSlider(tabName, label, min, max, default, callback)
    local tab = nil
    for _, t in ipairs(self.Tabs) do
        if t.Name == tabName then
            tab = t
            break
        end
    end
    if not tab then return end

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 48)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.Parent = tab.Frame

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(1, -50, 0, 18)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = self.Theme.TextPrimary
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = sliderFrame

    local valueText = Instance.new("TextLabel")
    valueText.Size = UDim2.new(0, 40, 0, 18)
    valueText.Position = UDim2.new(1, -40, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Text = tostring(default)
    valueText.TextColor3 = self.Theme.Accent
    valueText.Font = Enum.Font.GothamBold
    valueText.TextSize = 12
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = sliderFrame

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -10, 0, 4)
    track.Position = UDim2.new(0, 5, 0, 32)
    track.BackgroundColor3 = self.Theme.Disabled
    track.BorderSizePixel = 0
    track.Parent = sliderFrame

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    knob.BackgroundColor3 = self.Theme.TextPrimary
    knob.BorderSizePixel = 0
    knob.Parent = track

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local dragging = false
    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (pos * (max - min)))
        fill.Size = UDim2.new(pos, 0, 1, 0)
        knob.Position = UDim2.new(pos, -6, 0.5, -6)
        valueText.Text = tostring(value)
        if callback then callback(value) end
        return value
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            update(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    table.insert(tab.Elements, {Type = "Slider", Label = label, Min = min, Max = max, Value = default})
    return default
end

function Gui:CreateDropdown(tabName, label, options, default, callback)
    local tab = nil
    for _, t in ipairs(self.Tabs) do
        if t.Name == tabName then
            tab = t
            break
        end
    end
    if not tab then return end

    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, 32)
    dropFrame.BackgroundTransparency = 1
    dropFrame.Parent = tab.Frame

    local labelText = Instance.new("TextLabel")
    labelText.Size = UDim2.new(0.5, 0, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.Text = label
    labelText.TextColor3 = self.Theme.TextPrimary
    labelText.Font = Enum.Font.Gotham
    labelText.TextSize = 12
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Parent = dropFrame

    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.45, 0, 0, 24)
    dropBtn.Position = UDim2.new(0.55, 0, 0.5, -12)
    dropBtn.BackgroundColor3 = self.Theme.Surface
    dropBtn.BorderSizePixel = 0
    dropBtn.Text = default or options[1]
    dropBtn.TextColor3 = self.Theme.TextPrimary
    dropBtn.Font = Enum.Font.Gotham
    dropBtn.TextSize = 11
    dropBtn.Parent = dropFrame

    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 4)
    dropCorner.Parent = dropBtn

    local selected = default or options[1]
    dropBtn.MouseButton1Click:Connect(function()
        local currentIdx = table.find(options, selected) or 1
        selected = options[(currentIdx % #options) + 1]
        dropBtn.Text = selected
        if callback then callback(selected) end
    end)

    table.insert(tab.Elements, {Type = "Dropdown", Label = label, Options = options, Selected = selected})
    return selected
end

function Gui:CreateButton(tabName, label, callback)
    local tab = nil
    for _, t in ipairs(self.Tabs) do
        if t.Name == tabName then
            tab = t
            break
        end
    end
    if not tab then return end

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = self.Theme.Surface
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = self.Theme.TextPrimary
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = tab.Frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Border}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Surface}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    table.insert(tab.Elements, {Type = "Button", Label = label})
end

function Gui:CreateSection(tabName, text)
    local tab = nil
    for _, t in ipairs(self.Tabs) do
        if t.Name == tabName then
            tab = t
            break
        end
    end
    if not tab then return end

    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, 0, 0, 20)
    section.BackgroundTransparency = 1
    section.Text = text:upper()
    section.TextColor3 = self.Theme.TextSecondary
    section.Font = Enum.Font.GothamBold
    section.TextSize = 10
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = tab.Frame

    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0, 20)
    line.BackgroundColor3 = self.Theme.Border
    line.BorderSizePixel = 0
    line.Parent = section
end

function Gui:Notify(text, duration)
    duration = duration or 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 280, 0, 40)
    notif.Position = UDim2.new(1, -300, 1, -60)
    notif.BackgroundColor3 = self.Theme.Surface
    notif.BorderSizePixel = 0
    notif.Parent = self.ScreenGui

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 4)
    notifCorner.Parent = notif

    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = self.Theme.Border
    notifStroke.Thickness = 1
    notifStroke.Parent = notif

    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.BackgroundTransparency = 1
    notifText.Text = text
    notifText.TextColor3 = self.Theme.TextPrimary
    notifText.Font = Enum.Font.Gotham
    notifText.TextSize = 12
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.Parent = notif

    notif.Position = UDim2.new(1, 20, 1, -60)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Position = UDim2.new(1, -300, 1, -60)
    }):Play()

    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = UDim2.new(1, 20, 1, -60)
        }):Play()
        task.wait(0.35)
        notif:Destroy()
    end)
end

return Gui