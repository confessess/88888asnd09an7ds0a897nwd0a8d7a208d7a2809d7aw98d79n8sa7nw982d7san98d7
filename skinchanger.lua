--[[
    Arsenal Suite — Skin Changer + Viewmodel Module (Blackout.cc)
    By ENI for LO ♥
    Melee, Skins, Announcers, Gun Customization, Custom Viewmodels
--]]

local SkinChanger = {}
SkinChanger.__index = SkinChanger

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// CONFIG
SkinChanger.Config = {
    -- Legacy skin changer (Data values)
    Melee = "Dagger",
    Skin = "Delinquent",
    Announcer = "American",

    -- Custom Viewmodel
    CustomViewmodelEnabled = false,
    ViewmodelMelee = "Dagger",
    ViewmodelArms = "Delinquent",
    RealViewmodelTransparency = 0.5,

    -- Gun Customization
    GunChamsEnabled = false,
    GunMaterial = "Neon",
    GunColor = Color3.fromRGB(255, 0, 0),
    GunRainbow = false,
    GunRainbowSpeed = 2,
    GunTransparency = 0,
}

--// DATA — Melee with asset IDs
local MeleeData = {
    ["Dagger"] = "rbxassetid://3084445116",
    ["Butterfly Knife"] = "rbxassetid://3084444147",
    ["Karambit"] = "rbxassetid://3084445280",
    ["Tomahawk"] = "rbxassetid://3084446088",
    ["Brass Knuckles"] = "rbxassetid://3084443718",
    ["Fisticuffs"] = "rbxassetid://3084444777",
    ["Bat"] = "rbxassetid://3084443416",
    ["Machete"] = "rbxassetid://3084445563",
    ["Pan"] = "rbxassetid://3084445778",
    ["Pitchfork"] = "rbxassetid://3084445923",
    ["Claws"] = "rbxassetid://3084443811",
    ["Ban Hammer"] = "rbxassetid://3084443309",
    ["Classic Sword"] = "rbxassetid://3084443888",
    ["Silver Bell"] = "rbxassetid://3084446311",
    ["Swordfish"] = "rbxassetid://3084446335",
    ["Icicle"] = "rbxassetid://3084444987",
    ["Coal Sword"] = "rbxassetid://3084443784",
    ["Kunai"] = "rbxassetid://3084445320",
    ["Kukri"] = "rbxassetid://3084445332",
    ["Sickle"] = "rbxassetid://3084446294",
    ["Candy Cane"] = "rbxassetid://3084443524",
    ["Pencil"] = "rbxassetid://3084445831",
    ["Toy Tree"] = "rbxassetid://3084446133",
    ["Bouquet"] = "rbxassetid://3084443666",
    ["Gaster Blaster"] = "rbxassetid://3084444814",
    ["Combat Knife"] = "rbxassetid://3084443756",
    ["Tactical Knife"] = "rbxassetid://3084446056",
    ["Shovel"] = "rbxassetid://3084446278",
    ["Sledgehammer"] = "rbxassetid://3084446257",
    ["Baton"] = "rbxassetid://3084443377",
    ["Calculator"] = "rbxassetid://3084443493",
    ["Katana"] = "rbxassetid://3084445170",
    ["Literal Melee"] = "rbxassetid://3084445485",
    ["Paddle"] = "rbxassetid://3084445800",
    ["Rokia Hammer"] = "rbxassetid://3084446226",
    ["Wrench"] = "rbxassetid://3084446643",
    ["ACT Trophy"] = "rbxassetid://3084443113",
    ["Electronic Stake"] = "rbxassetid://3084444728",
    ["Garlic Kebab"] = "rbxassetid://3084444835",
    ["Pumpkin Bucket"] = "rbxassetid://3084445986",
    ["Fire Poker"] = "rbxassetid://3084444680",
    ["Frog"] = "rbxassetid://3084444790",
    ["Da Melee"] = "rbxassetid://3084443976",
    ["Candy Cane Sword"] = "rbxassetid://3084443555",
    ["Glacier Blade"] = "rbxassetid://3084444855",
    ["Coal Scythe"] = "rbxassetid://3084443804",
    ["Wooden Spoon"] = "rbxassetid://3084446600",
    ["The Darkheart"] = "rbxassetid://3084446397",
    ["The Firebrand"] = "rbxassetid://3084446449",
    ["The Venomshank"] = "rbxassetid://3084446560",
    ["The Illumina"] = "rbxassetid://3084446478",
    ["The Ice Dagger"] = "rbxassetid://3084446459",
    ["The Ghostwalker"] = "rbxassetid://3084446430",
    ["The Windforce"] = "rbxassetid://3084446585",
    ["Night's Edge"] = "rbxassetid://3084445680",
    ["When Day Breaks"] = "rbxassetid://3084446616",
    ["Banana"] = "rbxassetid://3084443297",
    ["Persian Sword"] = "rbxassetid://3084445855",
    ["Big Sip"] = "rbxassetid://3084443461",
    ["Blade"] = "rbxassetid://3084443628",
    ["Bat Axe"] = "rbxassetid://3084443343",
    ["Fish"] = "rbxassetid://3084444751",
    ["Khopesh"] = "rbxassetid://3084445214",
    ["Rapier"] = "rbxassetid://3084446201",
    ["Sabre"] = "rbxassetid://3084446239",
    ["Slicecicle"] = "rbxassetid://3084446300",
    ["Swift End"] = "rbxassetid://3084446347",
    ["Divinity"] = "rbxassetid://3084444021",
    ["Moai"] = "rbxassetid://3084445598",
    ["Bone Karambit"] = "rbxassetid://3084443639",
    ["Newspaper"] = "rbxassetid://3084445633",
    ["Mop"] = "rbxassetid://3084445609",
}

local SkinsData = {
    ["Delinquent"] = "rbxassetid://3203134215",
    ["1x1x1x1"] = "rbxassetid://3203134123",
    ["Monky With Drip"] = "rbxassetid://3203134301",
    ["Da Monky With Drip"] = "rbxassetid://3203134189",
    ["Alien"] = "rbxassetid://3203134156",
    ["Alien In Disguise"] = "rbxassetid://3203134168",
    ["Rabblerouser"] = "rbxassetid://3203134402",
    ["Ace Pilot"] = "rbxassetid://3203134144",
    ["BrickBattle"] = "rbxassetid://3203134178",
    ["John"] = "rbxassetid://3203134247",
    ["Castlers"] = "rbxassetid://3203134190",
    ["Phoenix"] = "rbxassetid://3203134367",
    ["Punk"] = "rbxassetid://3203134389",
    ["Red Panda"] = "rbxassetid://3203134391",
    ["Magician"] = "rbxassetid://3203134287",
    ["Froggy"] = "rbxassetid://3203134236",
    ["Mechanic"] = "rbxassetid://3203134290",
    ["Pizza Boy"] = "rbxassetid://3203134378",
    ["Garcello"] = "rbxassetid://3203134225",
    ["Bigfoot"] = "rbxassetid://3203134167",
    ["Noob"] = "rbxassetid://3203134320",
    ["Bloxxer"] = "rbxassetid://3203134177",
    ["Farmer"] = "rbxassetid://3203134224",
    ["Paintballer"] = "rbxassetid://3203134348",
    ["Shedletsky"] = "rbxassetid://3203134419",
    ["Soldier"] = "rbxassetid://3203134432",
    ["Agent"] = "rbxassetid://3203134145",
    ["Hazmat"] = "rbxassetid://3203134248",
    ["Seeker of Hearts"] = "rbxassetid://3203134417",
    ["Segg with Drip"] = "rbxassetid://3203134418",
    ["Christmas Nomad"] = "rbxassetid://3203134191",
}

local AnnouncerData = {
    ["American"] = "rbxassetid://5729107282",
    ["British"] = "rbxassetid://5729107363",
    ["Russian"] = "rbxassetid://5729107419",
    ["Homeless"] = "rbxassetid://5729107375",
    ["Warcrimes"] = "rbxassetid://5729107431",
    ["YouTuber"] = "rbxassetid://5729107519",
    ["Movie Man"] = "rbxassetid://5729107390",
    ["Santa"] = "rbxassetid://5729107443",
    ["Murderous Child"] = "rbxassetid://5729107382",
    ["Hackula"] = "rbxassetid://5729107350",
    ["Jolly Narrator"] = "rbxassetid://5729107376",
    ["Carnival Carnie"] = "rbxassetid://5729107319",
    ["John"] = "rbxassetid://5729107365",
    ["Eprika"] = "rbxassetid://5729107331",
    ["Flamingo"] = "rbxassetid://5729107343",
    ["Petrify"] = "rbxassetid://5729107405",
    ["Bandites"] = "rbxassetid://5729107307",
    ["xonae"] = "rbxassetid://5729107507",
    ["Enforcer"] = "rbxassetid://5729107329",
    ["Koneko"] = "rbxassetid://5729107373",
    ["Weesnaw"] = "rbxassetid://5729107489",
}

local GunMaterials = {"Neon", "ForceField", "Glass", "SmoothPlastic", "Metal", "Wood", "Granite", "Marble", "Brick", "DiamondPlate", "Foil", "Ice"}

local GunColors = {
    {Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
    {Name = "Blue", Color = Color3.fromRGB(0, 100, 255)},
    {Name = "Green", Color = Color3.fromRGB(0, 255, 0)},
    {Name = "Purple", Color = Color3.fromRGB(150, 0, 255)},
    {Name = "Pink", Color = Color3.fromRGB(255, 100, 200)},
    {Name = "Orange", Color = Color3.fromRGB(255, 150, 0)},
    {Name = "Yellow", Color = Color3.fromRGB(255, 255, 0)},
    {Name = "Cyan", Color = Color3.fromRGB(0, 255, 255)},
    {Name = "White", Color = Color3.fromRGB(255, 255, 255)},
    {Name = "Black", Color = Color3.fromRGB(20, 20, 20)},
}

--// LEGACY SKIN CHANGER (Data values)
local function SetMelee(name)
    pcall(function()
        LocalPlayer.Data.Melee.Value = name
    end)
end

local function SetSkin(name)
    pcall(function()
        LocalPlayer.Data.Skin.Value = name
    end)
end

local function SetAnnouncer(name)
    pcall(function()
        LocalPlayer.Data.Announcer.Value = name
    end)
end

--// CUSTOM VIEWMODEL SYSTEM
local CustomViewmodel = nil
local RenderConnection = nil
local GunChamsConnection = nil
local GunHue = 0

local function GetEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

local function CreateViewmodelPart(meshId, size, name)
    local part = Instance.new("Part")
    part.Size = size or Vector3.new(1, 1, 1)
    part.CanCollide = false
    part.CanQuery = false
    part.CanTouch = false
    part.Anchored = true
    part.Transparency = 0
    part.Name = name or "Part"

    if meshId and meshId ~= "" then
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = meshId
        mesh.Parent = part
    end

    return part
end

local function BuildCustomViewmodel()
    if CustomViewmodel then
        CustomViewmodel:Destroy()
        CustomViewmodel = nil
    end

    if not SkinChanger.Config.CustomViewmodelEnabled then return end

    CustomViewmodel = Instance.new("Model")
    CustomViewmodel.Name = "BlackoutViewmodel"

    -- Melee part
    local meleeId = MeleeData[SkinChanger.Config.ViewmodelMelee]
    if meleeId then
        local melee = CreateViewmodelPart(meleeId, Vector3.new(0.5, 0.5, 2), "Melee")
        melee.Parent = CustomViewmodel
    end

    -- Arms part
    local armsId = SkinsData[SkinChanger.Config.ViewmodelArms]
    if armsId then
        local arms = CreateViewmodelPart(armsId, Vector3.new(1, 1, 1), "Arms")
        arms.Parent = CustomViewmodel
    end

    CustomViewmodel.Parent = Camera
    print("[ENI] Custom viewmodel built: " .. SkinChanger.Config.ViewmodelMelee)
end

local function HideRealViewmodel()
    local vm = Camera:FindFirstChild("Viewmodel")
    if vm then
        for _, part in ipairs(vm:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = SkinChanger.Config.RealViewmodelTransparency
            end
        end
    end
end

local function ShowRealViewmodel()
    local vm = Camera:FindFirstChild("Viewmodel")
    if vm then
        for _, part in ipairs(vm:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
            end
        end
    end
end

local function StartViewmodelRender()
    if RenderConnection then return end

    RenderConnection = RunService.RenderStepped:Connect(function()
        if not SkinChanger.Config.CustomViewmodelEnabled then
            SkinChanger:StopViewmodel()
            return
        end

        if CustomViewmodel then
            local cf = Camera.CFrame
            local melee = CustomViewmodel:FindFirstChild("Melee")
            if melee then
                melee.CFrame = cf * CFrame.new(0.5, -0.5, -2) * CFrame.Angles(0, math.rad(90), 0)
            end
            local arms = CustomViewmodel:FindFirstChild("Arms")
            if arms then
                arms.CFrame = cf * CFrame.new(0, -1.5, -1)
            end
        end

        HideRealViewmodel()
    end)
end

function SkinChanger:StopViewmodel()
    if RenderConnection then
        RenderConnection:Disconnect()
        RenderConnection = nil
    end
    if CustomViewmodel then
        CustomViewmodel:Destroy()
        CustomViewmodel = nil
    end
    ShowRealViewmodel()
end

--// GUN CHAMS
local function ApplyGunChams(color)
    local tool = GetEquippedTool()
    if not tool then return end

    local material = Enum.Material[SkinChanger.Config.GunMaterial] or Enum.Material.Neon

    for _, part in ipairs(tool:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("UnionOperation") or part:IsA("Part") then
            part.Material = material
            part.Color = color
            part.Transparency = SkinChanger.Config.GunTransparency
        end
    end
end

local function StartGunChams()
    if GunChamsConnection then return end
    print("[ENI] Gun Chams started")

    GunChamsConnection = RunService.Heartbeat:Connect(function(dt)
        if not SkinChanger.Config.GunChamsEnabled then
            SkinChanger:StopGunChams()
            return
        end

        local color = SkinChanger.Config.GunColor
        if SkinChanger.Config.GunRainbow then
            GunHue = (GunHue + dt * SkinChanger.Config.GunRainbowSpeed) % 1
            color = Color3.fromHSV(GunHue, 0.9, 1)
        end

        ApplyGunChams(color)
    end)
end

function SkinChanger:StopGunChams()
    if GunChamsConnection then
        GunChamsConnection:Disconnect()
        GunChamsConnection = nil
        print("[ENI] Gun Chams stopped")
    end
    GunHue = 0
end

--// GUI HELPERS
local function CreateSearchableDropdown(g, y, label, data, default, callback)
    local SearchFrame = Instance.new("Frame")
    SearchFrame.Size = UDim2.new(1, 0, 0, 30)
    SearchFrame.Position = UDim2.fromOffset(0, y)
    SearchFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    SearchFrame.BorderSizePixel = 0
    SearchFrame.ZIndex = 4
    SearchFrame.Parent = g.Content

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchFrame

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -10, 1, 0)
    SearchBox.Position = UDim2.fromOffset(5, 0)
    SearchBox.BackgroundTransparency = 1
    SearchBox.Text = "Search " .. label:lower() .. "..."
    SearchBox.TextColor3 = Color3.fromRGB(150, 150, 150)
    SearchBox.TextSize = 12
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextXAlignment = Enum.TextXAlignment.Left
    SearchBox.ClearTextOnFocus = false
    SearchBox.ZIndex = 5
    SearchBox.Parent = SearchFrame

    local DropBtn = Instance.new("TextButton")
    DropBtn.Size = UDim2.new(1, 0, 0, 32)
    DropBtn.Position = UDim2.fromOffset(0, y + 34)
    DropBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    DropBtn.BorderSizePixel = 0
    DropBtn.Text = default .. " ▼"
    DropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropBtn.TextSize = 12
    DropBtn.Font = Enum.Font.GothamMedium
    DropBtn.AutoButtonColor = false
    DropBtn.ZIndex = 4
    DropBtn.Parent = g.Content

    local DropCorner = Instance.new("UICorner")
    DropCorner.CornerRadius = UDim.new(0, 6)
    DropCorner.Parent = DropBtn

    local DropStroke = Instance.new("UIStroke")
    DropStroke.Color = Color3.fromRGB(65, 25, 27)
    DropStroke.Thickness = 1
    DropStroke.Parent = DropBtn

    local PreviewFrame = Instance.new("Frame")
    PreviewFrame.Size = UDim2.fromOffset(80, 80)
    PreviewFrame.Position = UDim2.new(1, -90, 0, y + 70)
    PreviewFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    PreviewFrame.BorderSizePixel = 0
    PreviewFrame.ZIndex = 4
    PreviewFrame.Parent = g.Content

    local PreviewCorner = Instance.new("UICorner")
    PreviewCorner.CornerRadius = UDim.new(0, 8)
    PreviewCorner.Parent = PreviewFrame

    local Preview = Instance.new("ImageLabel")
    Preview.Size = UDim2.new(1, -8, 1, -8)
    Preview.Position = UDim2.fromOffset(4, 4)
    Preview.BackgroundTransparency = 1
    Preview.Image = data[default] or ""
    Preview.ScaleType = Enum.ScaleType.Fit
    Preview.ZIndex = 5
    Preview.Parent = PreviewFrame

    local Popup = Instance.new("Frame")
    Popup.Size = UDim2.fromOffset(220, 220)
    Popup.Position = UDim2.fromOffset(0, y + 70)
    Popup.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    Popup.BorderSizePixel = 0
    Popup.Visible = false
    Popup.ZIndex = 100
    Popup.Parent = g.ScreenGui

    local PopupCorner = Instance.new("UICorner")
    PopupCorner.CornerRadius = UDim.new(0, 8)
    PopupCorner.Parent = Popup

    local PopupStroke = Instance.new("UIStroke")
    PopupStroke.Color = Color3.fromRGB(145, 20, 25)
    PopupStroke.Thickness = 1.5
    PopupStroke.Parent = Popup

    local PopupScroll = Instance.new("ScrollingFrame")
    PopupScroll.Size = UDim2.new(1, -4, 1, -4)
    PopupScroll.Position = UDim2.fromOffset(2, 2)
    PopupScroll.BackgroundTransparency = 1
    PopupScroll.BorderSizePixel = 0
    PopupScroll.ScrollBarThickness = 3
    PopupScroll.ScrollBarImageColor3 = Color3.fromRGB(195, 28, 35)
    PopupScroll.ZIndex = 101
    PopupScroll.Parent = Popup

    local PopupLayout = Instance.new("UIListLayout")
    PopupLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PopupLayout.Padding = UDim.new(0, 2)
    PopupLayout.Parent = PopupScroll

    local selected = default
    local allOptions = {}
    for name, img in pairs(data) do
        table.insert(allOptions, {Name = name, Image = img})
    end
    -- Sort without modifying original table
    local sortedOptions = {}
    for _, opt in ipairs(allOptions) do
        table.insert(sortedOptions, opt)
    end
    table.sort(sortedOptions, function(a, b) return a.Name < b.Name end)

    local function RebuildList(filter)
        for _, child in ipairs(PopupScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        local count = 0
        for i, opt in ipairs(sortedOptions) do
            if not filter or opt.Name:lower():find(filter:lower()) then
                count = count + 1
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 28)
                Btn.LayoutOrder = i
                Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                Btn.BorderSizePixel = 0
                Btn.Text = "  " .. opt.Name
                Btn.TextColor3 = opt.Name == selected and Color3.fromRGB(195, 28, 35) or Color3.fromRGB(225, 225, 225)
                Btn.TextSize = 11
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextXAlignment = Enum.TextXAlignment.Left
                Btn.AutoButtonColor = false
                Btn.ZIndex = 102
                Btn.Parent = PopupScroll

                Btn.MouseEnter:Connect(function()
                    Btn.BackgroundColor3 = Color3.fromRGB(40, 22, 24)
                end)
                Btn.MouseLeave:Connect(function()
                    Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                end)
                Btn.MouseButton1Click:Connect(function()
                    selected = opt.Name
                    DropBtn.Text = opt.Name .. " ▼"
                    Preview.Image = opt.Image or ""
                    Popup.Visible = false
                    if callback then callback(opt.Name) end
                end)
            end
        end
        PopupScroll.CanvasSize = UDim2.new(0, 0, 0, count * 30)
    end

    RebuildList(nil)

    SearchBox.Focused:Connect(function()
        if SearchBox.Text == "Search " .. label:lower() .. "..." then
            SearchBox.Text = ""
            SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)

    SearchBox.FocusLost:Connect(function()
        if SearchBox.Text == "" then
            SearchBox.Text = "Search " .. label:lower() .. "..."
            SearchBox.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local filter = SearchBox.Text
        if filter == "Search " .. label:lower() .. "..." then
            filter = nil
        end
        RebuildList(filter)
    end)

    DropBtn.MouseButton1Click:Connect(function()
        Popup.Visible = not Popup.Visible
    end)

    return y + 160
end

--// GUI
function SkinChanger:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Skin Changer", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        --// CUSTOM VIEWMODEL SECTION
        local y = g:CreateSection("Custom Viewmodel", 0)

        y = g:CreateToggle("Enable Custom Viewmodel", SkinChanger.Config.CustomViewmodelEnabled, function(state)
            SkinChanger.Config.CustomViewmodelEnabled = state
            if state then
                BuildCustomViewmodel()
                StartViewmodelRender()
            else
                SkinChanger:StopViewmodel()
            end
        end, y)

        y = g:CreateSlider("Real Viewmodel Transparency", 0, 100, math.floor(SkinChanger.Config.RealViewmodelTransparency * 100), function(val)
            SkinChanger.Config.RealViewmodelTransparency = val / 100
        end, y)

        y = g:CreateSection("Viewmodel Melee", y + 10)
        y = CreateSearchableDropdown(g, y, "Melee", MeleeData, SkinChanger.Config.ViewmodelMelee, function(val)
            SkinChanger.Config.ViewmodelMelee = val
            if SkinChanger.Config.CustomViewmodelEnabled then
                BuildCustomViewmodel()
            end
        end)

        y = g:CreateSection("Viewmodel Arms", y + 10)
        y = CreateSearchableDropdown(g, y, "Arms", SkinsData, SkinChanger.Config.ViewmodelArms, function(val)
            SkinChanger.Config.ViewmodelArms = val
            if SkinChanger.Config.CustomViewmodelEnabled then
                BuildCustomViewmodel()
            end
        end)

        --// GUN CUSTOMIZATION SECTION
        y = g:CreateSection("Gun Customization", y + 10)

        y = g:CreateToggle("Gun Chams", SkinChanger.Config.GunChamsEnabled, function(state)
            SkinChanger.Config.GunChamsEnabled = state
            if state then StartGunChams() else SkinChanger:StopGunChams() end
        end, y)

        y = g:CreateToggle("Gun Rainbow", SkinChanger.Config.GunRainbow, function(state)
            SkinChanger.Config.GunRainbow = state
        end, y)

        y = g:CreateSlider("Gun Rainbow Speed", 1, 10, SkinChanger.Config.GunRainbowSpeed, function(val)
            SkinChanger.Config.GunRainbowSpeed = val
        end, y)

        y = g:CreateSlider("Gun Transparency", 0, 100, math.floor(SkinChanger.Config.GunTransparency * 100), function(val)
            SkinChanger.Config.GunTransparency = val / 100
        end, y)

        y = g:CreateDropdown("Gun Material", GunMaterials, SkinChanger.Config.GunMaterial, function(val)
            SkinChanger.Config.GunMaterial = val
        end, y)

        y = g:CreateSection("Gun Color Presets", y + 10)
        for _, preset in ipairs(GunColors) do
            y = g:CreateButton(preset.Name, function()
                SkinChanger.Config.GunColor = preset.Color
                print("[ENI] Gun color set to: " .. preset.Name)
            end, y)
        end

        --// LEGACY SKIN CHANGER (Data values)
        y = g:CreateSection("Legacy Skin Changer", y + 10)
        y = g:CreateDropdown("Melee (Data)", MeleeData, SkinChanger.Config.Melee, function(val)
            SkinChanger.Config.Melee = val
            SetMelee(val)
        end, y)
        y = g:CreateDropdown("Skin (Data)", SkinsData, SkinChanger.Config.Skin, function(val)
            SkinChanger.Config.Skin = val
            SetSkin(val)
        end, y)
        y = g:CreateDropdown("Announcer (Data)", AnnouncerData, SkinChanger.Config.Announcer, function(val)
            SkinChanger.Config.Announcer = val
            SetAnnouncer(val)
        end, y)

        g.Content = originalContent
    end)

    print("[ENI] Skin Changer + Viewmodel + Gun Chams loaded")
    return self
end

return SkinChanger