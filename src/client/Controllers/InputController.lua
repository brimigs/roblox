local InputController = {}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

function InputController:Initialize()
	-- Setup camera controls
	self:SetupCameraControls()
	
	-- Setup mobile controls if needed
	if UserInputService.TouchEnabled then
		self:SetupMobileControls()
	end
end

function InputController:SetupCameraControls()
	-- Allow zooming
	player.CameraMinZoomDistance = 5
	player.CameraMaxZoomDistance = 100
end

function InputController:SetupMobileControls()
	-- Create mobile UI buttons for pet interactions
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MobileControls"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player.PlayerGui
	
	-- Pet interaction button
	local interactButton = Instance.new("TextButton")
	interactButton.Size = UDim2.new(0, 60, 0, 60)
	interactButton.Position = UDim2.new(1, -70, 0.5, -30)
	interactButton.Text = "🐾"
	interactButton.Font = Enum.Font.SourceSans
	interactButton.TextScaled = true
	interactButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	interactButton.BackgroundTransparency = 0.3
	interactButton.BorderSizePixel = 0
	interactButton.Parent = screenGui
	
	interactButton.TouchTap:Connect(function()
		local PetController = require(script.Parent.PetController)
		PetController:InteractWithNearestPet()
	end)
	
	-- Feed button
	local feedButton = Instance.new("TextButton")
	feedButton.Size = UDim2.new(0, 60, 0, 60)
	feedButton.Position = UDim2.new(1, -70, 0.5, 40)
	feedButton.Text = "🍖"
	feedButton.Font = Enum.Font.SourceSans
	feedButton.TextScaled = true
	feedButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	feedButton.BackgroundTransparency = 0.3
	feedButton.BorderSizePixel = 0
	feedButton.Parent = screenGui
	
	feedButton.TouchTap:Connect(function()
		local PetController = require(script.Parent.PetController)
		PetController:FeedNearestPet()
	end)
end

return InputController