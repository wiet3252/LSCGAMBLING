loadstring(game:HttpGet("https://raw.githubusercontent.com/omaromar242/Esp/refs/heads/main/Esp"))()

loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()

--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
loadstring(game:HttpGet('https://raw.githubusercontent.com/MassiveHubs/loadstring/refs/heads/main/DexXenoAndRezware'))()

-- LocalScript (StarterPlayerScripts)
-- Toggle button (top-right) that makes all world parts non-collidable once.
-- No constant loop = no lag. Does NOT affect your character.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- GUI setup
local gui = Instance.new("ScreenGui")
gui.Name = "WorldNoclipGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Name = "ToggleWorldNoclip"
button.Size = UDim2.new(0, 160, 0, 40)
button.Position = UDim2.new(1, -180, 0, 20) -- top-right corner
button.AnchorPoint = Vector2.new(0, 0)
button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 18
button.Text = "World Noclip: OFF"
button.Parent = gui

-- State
local enabled = false

-- Helper: flip parts (ignoring player character)
local function affectWorld(on)
for _, part in ipairs(Workspace:GetDescendants()) do
if part:IsA("BasePart") then
if not part:IsDescendantOf(player.Character or Instance.new("Folder")) then
pcall(function()
part.CanCollide = not on
end)
end
end
end
end

-- Toggle
button.MouseButton1Click:Connect(function()
enabled = not enabled
if enabled then
affectWorld(true)
button.Text = "World Noclip: ON"
button.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
else
affectWorld(false)
button.Text = "World Noclip: OFF"
button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
end
end)

-- Reset to OFF on spawn
player.CharacterAdded:Connect(function()
if not enabled then
affectWorld(false)
button.Text = "World Noclip: OFF"
button.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
end
end)

-- Start OFF
affectWorld(false)

local FlyScript = {}

local SPEED = 100
local MOBILE_SENSITIVITY = 0.07

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
local Camera = workspace.CurrentCamera
local ORIGINAL_GRAVITY = workspace.Gravity

local Flying = false
local Keys = {W=false,A=false,S=false,D=false,Space=false,LeftShift=false}

local TouchControls = {Enabled=false,TouchStartPosition=nil,TouchCurrentPosition=nil,ForwardButton=nil,BackwardButton=nil,UpButton=nil,DownButton=nil}

LocalPlayer.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HRP = Character:WaitForChild("HumanoidRootPart")
    if Flying then
        FlyScript:StopFlying()
        FlyScript:StartFlying() 
    end
end)

UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    local key = input.KeyCode
    if key==Enum.KeyCode.X then FlyScript:ToggleFly()
    elseif key==Enum.KeyCode.W then Keys.W=true
    elseif key==Enum.KeyCode.A then Keys.A=true
    elseif key==Enum.KeyCode.S then Keys.S=true
    elseif key==Enum.KeyCode.D then Keys.D=true
    elseif key==Enum.KeyCode.Space then Keys.Space=true
    elseif key==Enum.KeyCode.LeftShift then Keys.LeftShift=true end
end)

UserInputService.InputEnded:Connect(function(input,gp)
    if gp then return end
    local key = input.KeyCode
    if key==Enum.KeyCode.W then Keys.W=false
    elseif key==Enum.KeyCode.A then Keys.A=false
    elseif key==Enum.KeyCode.S then Keys.S=false
    elseif key==Enum.KeyCode.D then Keys.D=false
    elseif key==Enum.KeyCode.Space then Keys.Space=false
    elseif key==Enum.KeyCode.LeftShift then Keys.LeftShift=false end
end)

function FlyScript:StartFlying()
    if Flying then return end
    if not Humanoid or not HRP then return end
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    workspace.Gravity = 0
    Flying = true

    FlyScript.FlyConnection = RunService.RenderStepped:Connect(function()
        if not Flying or not Character or not HRP then return end
        local moveDirection = Vector3.zero

        if Keys.W then moveDirection += Camera.CFrame.LookVector end
        if Keys.S then moveDirection -= Camera.CFrame.LookVector end
        if Keys.A then moveDirection -= Camera.CFrame.RightVector end
        if Keys.D then moveDirection += Camera.CFrame.RightVector end
        if Keys.Space then moveDirection += Vector3.new(0,1,0) end
        if Keys.LeftShift then moveDirection -= Vector3.new(0,1,0) end

        if TouchControls.Enabled and TouchControls.TouchStartPosition and TouchControls.TouchCurrentPosition then
            local delta = TouchControls.TouchCurrentPosition - TouchControls.TouchStartPosition
            moveDirection += Camera.CFrame.LookVector * (-delta.Y * MOBILE_SENSITIVITY)
            moveDirection += Camera.CFrame.RightVector * (delta.X * MOBILE_SENSITIVITY)
        end

        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        else
            moveDirection = Vector3.zero
        end

        local seat = Humanoid.SeatPart
        if seat and (seat:IsA("VehicleSeat") or seat:IsA("Seat")) then
            local model = seat:FindFirstAncestorOfClass("Model")
            if model and model.PrimaryPart then
                model.PrimaryPart.Velocity = moveDirection * SPEED
                model.PrimaryPart.RotVelocity = Vector3.zero
            else
                seat.Velocity = moveDirection * SPEED
                seat.RotVelocity = Vector3.zero
            end
        else
            HRP.Velocity = moveDirection * SPEED
            HRP.RotVelocity = Vector3.zero
        end
    end)
end

function FlyScript:StopFlying()
    if not Flying then return end
    if FlyScript.FlyConnection then FlyScript.FlyConnection:Disconnect() FlyScript.FlyConnection=nil end
    if Character and Character:FindFirstChild("Humanoid") then
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    workspace.Gravity = ORIGINAL_GRAVITY
    Flying = false
end

function FlyScript:ToggleFly()
    if Flying then
        self:StopFlying()
    else
        self:StartFlying()
    end
end

return FlyScript

local player = game.Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 120, 0, 40)
button.AnchorPoint = Vector2.new(1, 0)
button.Position = UDim2.new(1, -10, 0, 10)
button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
button.Text = "Run"

button.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    -- Teleport
    root.CFrame = CFrame.new(829, 2, 869)
    task.wait(0.25)

    -- Execute the RemoteEvent
    local args = {
        "SpawnVehicle",
        "Van",
        workspace:WaitForChild("Ignore"):WaitForChild("VehicleSpawnButton"),
        Color3.new(1, 1, 1)
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("WeaponEvent"):FireServer(unpack(args))
end)
