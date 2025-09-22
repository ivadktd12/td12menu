--[[ 
TD12 Menu - Roblox Script
Abre um menu com Insert, permite ativar ESP e voo.
Execute no LocalScript dentro do StarterPlayerScripts.
]]

-- GUI Setup
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Menu Variables
local menuOpen = false
local espEnabled = false
local flyEnabled = false
local flySpeed = 50

-- GUI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TD12Menu"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 180)
frame.Position = UDim2.new(0.5, -150, 0.4, 0)
frame.BackgroundColor3 = Color3.new(0, 0.7, 0)
frame.Visible = false
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "TD12 Menu"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Parent = frame

local espButton = Instance.new("TextButton")
espButton.Text = "ESP: OFF"
espButton.Font = Enum.Font.SourceSans
espButton.TextSize = 18
espButton.Size = UDim2.new(1, -40, 0, 40)
espButton.Position = UDim2.new(0, 20, 0, 50)
espButton.BackgroundColor3 = Color3.new(0.2, 0.4, 0.2)
espButton.TextColor3 = Color3.new(1,1,1)
espButton.Parent = frame

local flyButton = Instance.new("TextButton")
flyButton.Text = "Fly: OFF"
flyButton.Font = Enum.Font.SourceSans
flyButton.TextSize = 18
flyButton.Size = UDim2.new(1, -40, 0, 40)
flyButton.Position = UDim2.new(0, 20, 0, 100)
flyButton.BackgroundColor3 = Color3.new(0.2, 0.4, 0.2)
flyButton.TextColor3 = Color3.new(1,1,1)
flyButton.Parent = frame

-- Menu Toggle
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        frame.Visible = menuOpen
    end
end)

-- ESP Functionality
local espObjects = {}

local function updateESP()
    -- Remove old ESP
    for _,v in pairs(espObjects) do
        if v and v.Parent then v:Destroy() end
    end
    espObjects = {}

    if not espEnabled then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local box = Instance.new("BillboardGui")
            box.Adornee = p.Character.HumanoidRootPart
            box.Size = UDim2.new(0,100,0,40)
            box.AlwaysOnTop = true
            box.Parent = screenGui

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1,0,1,0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = p.Name
            nameLabel.TextColor3 = Color3.new(0,1,0)
            nameLabel.TextStrokeTransparency = 0.4
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.TextSize = 16
            nameLabel.Parent = box
            table.insert(espObjects, box)
        end
    end
end

RunService.RenderStepped:Connect(updateESP)

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espButton.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    updateESP()
end)

-- Fly Functionality
local flying = false
local flyBodyGyro, flyBodyVel

local function startFly()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    flying = true

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.P = 9e4
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.CFrame = char.HumanoidRootPart.CFrame
    flyBodyGyro.Parent = char.HumanoidRootPart

    flyBodyVel = Instance.new("BodyVelocity")
    flyBodyVel.Velocity = Vector3.new(0,0,0)
    flyBodyVel.MaxForce = Vector3.new(9e9,9e9,9e9)
    flyBodyVel.Parent = char.HumanoidRootPart
end

local function stopFly()
    flying = false
    if flyBodyGyro then flyBodyGyro:Destroy() end
    if flyBodyVel then flyBodyVel:Destroy() end
end

flyButton.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyButton.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
    if flyEnabled then startFly() else stopFly() end
end)

-- Fly Movement
UserInputService.InputBegan:Connect(function(input, processed)
    if not flyEnabled or not flying then return end
    if input.KeyCode == Enum.KeyCode.W then
        flyBodyVel.Velocity = LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * flySpeed
    elseif input.KeyCode == Enum.KeyCode.S then
        flyBodyVel.Velocity = -LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector * flySpeed
    elseif input.KeyCode == Enum.KeyCode.Space then
        flyBodyVel.Velocity = Vector3.new(0,flySpeed,0)
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        flyBodyVel.Velocity = Vector3.new(0,-flySpeed,0)
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if not flyEnabled or not flying then return end
    if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S
        or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl then
        flyBodyVel.Velocity = Vector3.new(0,0,0)
    end
end)
