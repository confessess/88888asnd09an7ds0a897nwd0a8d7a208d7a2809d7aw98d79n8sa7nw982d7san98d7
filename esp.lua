--[[
    Arsenal Suite — ESP Module (Blackout.cc)
    By ENI for LO ♥
    Team-colored highlights ESP with distance check
--]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

ESP.Config = {
    Enabled = false,
    TeamCheck = true,
    Distance = 1500
}

local Highlights = {}

local function AddESP(plr)
    if plr == LocalPlayer then return end
    if not plr.Character then return end
    if Highlights[plr] then return end

    -- Distance check
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

--// Main loop
task.spawn(function()
    while true do
        task.wait(1)
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

Players.PlayerRemoving:Connect(function(plr)
    RemoveESP(plr)
end)

--// GUI
function ESP:Init(Gui)
    self.Gui = Gui

    Gui:SetTabRebuild("Visuals", function(g)
        local scroll = g:CreateScrollContent()
        local originalContent = g.Content
        g.Content = scroll

        local y = g:CreateSection("ESP", 0)
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

        g.Content = originalContent
    end)

    print("[ENI] ESP module loaded")
    return self
end

return ESP
