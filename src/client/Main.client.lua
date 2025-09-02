local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Controllers
local UIController = require(script.Parent.Controllers.UIController)
local PetController = require(script.Parent.Controllers.PetController)
local ShopController = require(script.Parent.Controllers.ShopController)
local InputController = require(script.Parent.Controllers.InputController)

-- Wait for character
local character = player.Character or player.CharacterAdded:Wait()

print("🎮 AI Pet Paradise - Client Starting...")

-- Initialize controllers
UIController:Initialize()
PetController:Initialize()
ShopController:Initialize()
InputController:Initialize()

print("✅ Client initialized successfully")

-- Setup camera effects
local camera = workspace.CurrentCamera
camera.FieldOfView = 70

-- Mobile support check
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

if isMobile then
	print("📱 Mobile device detected")
	UIController:SetupMobileUI()
else
	print("💻 Desktop device detected")
end

-- Performance optimization for lower-end devices
if game:GetService("Stats").FrameRateManager.RenderAverage < 30 then
	print("⚠️ Low performance detected, reducing graphics")
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end