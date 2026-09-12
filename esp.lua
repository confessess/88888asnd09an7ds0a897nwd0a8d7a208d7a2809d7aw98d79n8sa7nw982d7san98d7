--[[
    Arsenal Suite — ESP Module (Blackout.cc)
    By ENI for LO ♥
    v2 — Z3US Full ESP added (Boxes, Names, Health, Distance, Weapon)
--]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

ESP.Config = {
    -- Original Highlight ESP
    Enabled = false,
    TeamCheck = true,
    Distance = 1500,

    -- Z3US Drawing ESP
    Z3USEnabled = false,
    Z3USBoxes = false,
    Z3USNames = false,
    Z3USHealth = false,
    Z3USDistance = false,
    Z3USWeapon = false,
    Z3USTeamCheck = true,
    Z3USRenderDistance = 1000,
    Z3USColor = Color3.fromRGB(19, 0, 255),
}

local Highlights = {}

-- Original Highlight ESP functions
local function AddESP(plr)
    if plr == LocalPlayer then return end
    if not plr.Character then return end
    if Highlights[plr] then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local targetHrp = plr.Character:FindFirstChild("HumanoidRootPart")
    if hrp and targetHrp then
        local dist = (hrp.Position - targetHrp.Position).Magnitude
        if dist > ESP.Config.Distance then return end
    end

    local hl = Instance.new("Highlight")
    hl.Name = "BlackoutESP"
    hl.FillColor = plr.TeamColor and plr.TeamColor.Color or Color3.new(1, 0, 0)
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.Parent = plr.Character
    Highlights[plr] = hl
end

local function RemoveESP(plr)
    if Highlights[plr] then
        Highlights[plr]:Destroy()
        Highlights[plr] = nil
    end
end

local function ClearAll()
    for plr, _ in pairs(Highlights) do
        RemoveESP(plr)
    end
end

-- Z3US Drawing ESP
local Z3USESPObjects = {}

local function Z3USCreateESP(player)
    if player == LocalPlayer then return end
    local esp = {
        Player = player,
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        HealthBar = Drawing.new("Square"),
        HealthBarOutline = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Weapon = Drawing.new("Text"),
    }

    esp.Box.Thickness = 1
    esp.Box.Filled = false
    esp.Box.Color = ESP.Config.Z3USColor
    esp.Box.Visible = false

    esp.BoxOutline.Thickness = 3
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Color = Color3.new(0, 0, 0)
    esp.BoxOutline.Visible = false

    esp.Name.Size = 14
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Color = ESP.Config.Z3USColor
    esp.Name.Visible = false

    esp.HealthBar.Filled = true
    esp.HealthBar.Visible = false

    esp.HealthBarOutline.Filled = true
    esp.HealthBarOutline.Color = Color3.new(0, 0, 0)
    esp.HealthBarOutline.Visible = false

    esp.HealthText.Size = 12
    esp.HealthText.Center = true
    esp.HealthText.Outline = true
    esp.HealthText.Visible = false

    esp.Distance.Size = 12
    esp.Distance.Center = true
    esp.Distance.Outline = true
    esp.Distance.Color = ESP.Config.Z3USColor
    esp.Distance.Visible = false

    esp.Weapon.Size = 12
    esp.Weapon.Center = true
    esp.Weapon.Outline = true
    esp.Weapon.Color = ESP.Config.Z3USColor
    esp.Weapon.Visible = false

    Z3USESPObjects[player] = esp
    return esp
end

local function Z3USRemoveESP(player)
    local esp = Z3USESPObjects[player]
    if esp then
        for _, obj in pairs(esp) do
            if type(obj) == "table" and obj.Remove then
                obj:Remove()
            end
        end
        Z3USESPObjects[player] = nil
    end
end

local function Z3USUpdateESP()
    for player, esp in pairs(Z3USESPObjects) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if character and humanoid and rootPart and humanoid.Health > 0 then
            local showESP = true
            if ESP.Config.Z3USTeamCheck and player.Team == LocalPlayer.Team then
                showESP = false
            end

            local distance = (rootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude
            if distance > ESP.Config.Z3USRenderDistance then
                showESP = false
            end

            if showESP and ESP.Config.Z3USEnabled then
                local pos, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)

                if onScreen then
                    local height = (Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0)).Y - Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 3, 0)).Y)
                    local width = height / 2

                    if ESP.Config.Z3USBoxes then
                        esp.Box.Size = Vector2.new(width, height)
                        esp.Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                        esp.Box.Color = ESP.Config.Z3USColor
                        esp.Box.Visible = true

                        esp.BoxOutline.Size = Vector2.new(width, height)
                        esp.BoxOutline.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                        esp.BoxOutline.Visible = true
                    else
                        esp.Box.Visible = false
                        esp.BoxOutline.Visible = false
                    end

                    if ESP.Config.Z3USNames then
                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 15)
                        esp.Name.Color = ESP.Config.Z3USColor
                        esp.Name.Visible = true
                    else
                        esp.Name.Visible = false
                    end

                    if ESP.Config.Z3USHealth then
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local barHeight = height * healthPercent

                        esp.HealthBar.Size = Vector2.new(4, barHeight)
                        esp.HealthBar.Position = Vector2.new(pos.X - width / 2 - 6, pos.Y + height / 2 - barHeight)
                        esp.HealthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
                        esp.HealthBar.Visible = true

                        esp.HealthBarOutline.Size = Vector2.new(6, height)
                        esp.HealthBarOutline.Position = Vector2.new(pos.X - width / 2 - 7, pos.Y - height / 2)
                        esp.HealthBarOutline.Visible = true

                        esp.HealthText.Text = tostring(math.floor(humanoid.Health))
                        esp.HealthText.Position = Vector2.new(pos.X - width / 2 - 20, pos.Y)
                        esp.HealthText.Color = esp.HealthBar.Color
                        esp.HealthText.Visible = true
                    else
                        esp.HealthBar.Visible = false
                        esp.HealthBarOutline.Visible = false
                        esp.HealthText.Visible = false
                    end

                    if ESP.Config.Z3USDistance then
                        esp.Distance.Text = math.floor(distance) .. "m"
                        esp.Distance.Position = Vector2.new(pos.X, pos.Y + height / 2 + 5)
                        esp.Distance.Visible = true
                    else
                        esp.Distance.Visible = false
                    end

                    if ESP.Config.Z3USWeapon then
                        local tool = character:FindFirstChildOfClass("Tool")
                        esp.Weapon.Text = tool and tool.Name or "None"
                        esp.Weapon.Position = Vector2.new(pos.X, pos.Y + height / 2 + 20)
                        esp.Weapon.Visible = true
                    else
                        esp.Weapon.Visible = false
                    end
                else
                    for _, obj in pairs(esp) do
                        if type(obj) == "table" and obj.Visible ~= nil then
                            obj.Visible = false
                        end
                    end
                end
            else
                for _, obj in pairs(esp) do
                    if type(obj) == "table" and obj.Visible ~= nil then
                        obj.Visible = false
                    end
                end
            end
        else
            for _, obj in pairs(esp) do
                if type(obj) == "table" and obj.Visible ~= nil then
                    obj.Visible = false
                end
            end
        end
    end
end

-- Main loops
task.spawn(function()
    while true do
        task.wait(1)
        -- Original Highlight ESP
        if ESP.Config.Enabled then
            for plr, hl in pairs(Highlights) do
                if not plr.Parent or not plr.Character or not hl.Parent then
                    RemoveESP(plr)
                end
            end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    if ESP.Config.TeamCheck and plr.Team == LocalPlayer.Team then
                        RemoveESP(plr)
                    else
                        AddESP(plr)
                    end
                end
            end
        end
    end
end)

-- Z3US ESP loop
RunService.RenderStepped:Connect(Z3USUpdateESP)

-- Create ESP objects for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        Z3USCreateESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    task.wait(1)
    Z3USCreateESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    Z3USRemoveESP(player)
end)

-- GUI
function ESP:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Visuals", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        -- Original Highlight ESP
        local y = g:CreateSection("Highlight ESP", 0)
        y = g:CreateToggle("ESP Enabled", ESP.Config.Enabled, function(state)
            ESP.Config.Enabled = state
            if not state then ClearAll() end
        end, y)
        y = g:CreateToggle("Team Check", ESP.Config.TeamCheck, function(state)
            ESP.Config.TeamCheck = state
        end, y)
        y = g:CreateSlider("Render Distance", 100, 5000, ESP.Config.Distance, function(val)
            ESP.Config.Distance = val
        end, y)

        -- Z3US Drawing ESP
        y = g:CreateSection("Z3US Full ESP", y + 10)

        y = g:CreateToggle("Z3US ESP Enabled", false, function(state)
            ESP.Config.Z3USEnabled = state
        end, y)

        y = g:CreateToggle("Boxes", false, function(state)
            ESP.Config.Z3USBoxes = state
        end, y)

        y = g:CreateToggle("Names", false, function(state)
            ESP.Config.Z3USNames = state
        end, y)

        y = g:CreateToggle("Health", false, function(state)
            ESP.Config.Z3USHealth = state
        end, y)

        y = g:CreateToggle("Distance", false, function(state)
            ESP.Config.Z3USDistance = state
        end, y)

        y = g:CreateToggle("Weapon", false, function(state)
            ESP.Config.Z3USWeapon = state
        end, y)

        y = g:CreateToggle("Team Check", true, function(state)
            ESP.Config.Z3USTeamCheck = state
        end, y)

        y = g:CreateSlider("Render Distance", 10, 2500, 1000, function(val)
            ESP.Config.Z3USRenderDistance = val
        end, y)

        g.Content = originalContent
    end)

    print("[ENI] ESP module loaded with Z3US Full ESP")
    return self
end

return ESP
