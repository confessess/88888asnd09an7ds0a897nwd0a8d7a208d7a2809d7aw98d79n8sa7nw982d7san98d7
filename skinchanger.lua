--[[
    Arsenal Suite — Skin Changer Module (Blackout.cc)
    By ENI for LO ♥
    Melee, Skins, Announcers with search + previews
--]]

local SkinChanger = {}
SkinChanger.__index = SkinChanger

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

--// DATA
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

--// LOGIC
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

--// GUI HELPERS
local function CreateSearchableDropdown(g, y, label, data, default, callback)
    -- Search box
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

    -- Dropdown button
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

    -- Preview image - FIXED: better sizing and loading
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

    -- Loading fallback
    if data[default] then
        Preview.Image = data[default]
    end

    -- Popup list
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
    table.sort(allOptions, function(a, b) return a.Name < b.Name end)

    local function RebuildList(filter)
        for _, child in ipairs(PopupScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        local count = 0
        for i, opt in ipairs(allOptions) do
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

        local y = g:CreateSection("Melee", 0)
        y = CreateSearchableDropdown(g, y, "Melee", MeleeData, "Dagger", function(val)
            SetMelee(val)
        end)

        y = g:CreateSection("Character Skin", y + 10)
        y = CreateSearchableDropdown(g, y, "Skin", SkinsData, "Delinquent", function(val)
            SetSkin(val)
        end)

        y = g:CreateSection("Announcer", y + 10)
        y = CreateSearchableDropdown(g, y, "Announcer", AnnouncerData, "American", function(val)
            SetAnnouncer(val)
        end)

        g.Content = originalContent
    end)

    print("[ENI] Skin Changer loaded")
    return self
end

return SkinChanger