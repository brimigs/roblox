local PetController = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local petRemotes = remotes:WaitForChild("PetRemotes")

function PetController:Initialize()
	-- Setup pet interaction
	self:SetupPetInteraction()
	
	-- Connect to pet events
	self:ConnectRemoteEvents()
	
	-- Setup pet hotkeys
	self:SetupHotkeys()
end

function PetController:SetupPetInteraction()
	-- Click detection for pets
	mouse.Button1Down:Connect(function()
		local target = mouse.Target
		if target and target.Parent then
			local model = target.Parent
			if model:FindFirstChild("Humanoid") and model.Name ~= player.Name then
				-- Check if it's a pet
				local isPet = false
				for _, part in pairs(model:GetChildren()) do
					if part.Name == "NameTag" then
						isPet = true
						break
					end
				end
				
				if isPet then
					self:OnPetClicked(model)
				end
			end
		end
	end)
end

function PetController:ConnectRemoteEvents()
	-- Pet obtained event
	local petObtained = petRemotes:WaitForChild("PetObtained")
	petObtained.OnClientEvent:Connect(function(petData)
		self:OnPetObtained(petData)
	end)
	
	-- Egg opened event
	local shopRemotes = remotes:WaitForChild("ShopRemotes")
	local eggOpened = shopRemotes:FindFirstChild("EggOpened")
	if eggOpened then
		eggOpened.OnClientEvent:Connect(function(data)
			self:PlayEggOpenAnimation(data)
		end)
	end
end

function PetController:SetupHotkeys()
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.E then
			-- Interact with nearest pet
			self:InteractWithNearestPet()
		elseif input.KeyCode == Enum.KeyCode.F then
			-- Feed nearest pet
			self:FeedNearestPet()
		elseif input.KeyCode == Enum.KeyCode.R then
			-- Recall all pets
			self:RecallAllPets()
		end
	end)
end

function PetController:OnPetClicked(petModel)
	-- Create interaction menu
	local screenGui = player.PlayerGui:FindFirstChild("PetInteraction") or Instance.new("ScreenGui")
	screenGui.Name = "PetInteraction"
	screenGui.Parent = player.PlayerGui
	
	-- Clear previous menu
	for _, child in pairs(screenGui:GetChildren()) do
		child:Destroy()
	end
	
	-- Create menu frame
	local menuFrame = Instance.new("Frame")
	menuFrame.Size = UDim2.new(0, 200, 0, 150)
	menuFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
	menuFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	menuFrame.BorderSizePixel = 0
	menuFrame.Parent = screenGui
	
	-- Pet name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.2, 0)
	nameLabel.Text = petModel.Name
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = menuFrame
	
	-- Interaction buttons
	local buttons = {"Pet", "Feed", "Play", "Stats"}
	for i, buttonName in ipairs(buttons) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0.9, 0, 0.15, 0)
		button.Position = UDim2.new(0.05, 0, 0.2 + (i - 1) * 0.18, 0)
		button.Text = buttonName
		button.Font = Enum.Font.SourceSans
		button.TextScaled = true
		button.TextColor3 = Color3.new(1, 1, 1)
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		button.BorderSizePixel = 0
		button.Parent = menuFrame
		
		button.MouseButton1Click:Connect(function()
			self:PerformPetAction(petModel, buttonName)
			screenGui:Destroy()
		end)
	end
	
	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 5)
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.BorderSizePixel = 0
	closeButton.Parent = menuFrame
	
	closeButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
	
	-- Auto close after 5 seconds
	task.wait(5)
	if screenGui and screenGui.Parent then
		screenGui:Destroy()
	end
end

function PetController:PerformPetAction(petModel, action)
	-- Get pet ID (simplified - would need proper tracking)
	local petId = petModel:GetAttribute("PetId") or "unknown"
	
	if action == "Pet" then
		petRemotes.PetInteract:FireServer(petId, "Pet")
		self:ShowActionFeedback(petModel, "❤️")
	elseif action == "Feed" then
		petRemotes.FeedPet:FireServer(petId)
		self:ShowActionFeedback(petModel, "🍖")
	elseif action == "Play" then
		petRemotes.PetInteract:FireServer(petId, "Play")
		self:ShowActionFeedback(petModel, "🎾")
	elseif action == "Stats" then
		self:ShowPetStats(petModel, petId)
	end
end

function PetController:ShowActionFeedback(petModel, emoji)
	-- Create floating text
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Position = petModel.PrimaryPart.Position + Vector3.new(0, 3, 0)
	part.Parent = workspace
	
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(2, 0, 2, 0)
	billboardGui.Parent = part
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = emoji
	textLabel.Font = Enum.Font.SourceSans
	textLabel.TextScaled = true
	textLabel.BackgroundTransparency = 1
	textLabel.Parent = billboardGui
	
	-- Float up and fade
	local startPos = part.Position
	local endPos = startPos + Vector3.new(0, 3, 0)
	
	local tween = TweenService:Create(part, TweenInfo.new(1), {
		Position = endPos
	})
	
	local fadeTween = TweenService:Create(textLabel, TweenInfo.new(1), {
		TextTransparency = 1
	})
	
	tween:Play()
	fadeTween:Play()
	
	task.wait(1)
	part:Destroy()
end

function PetController:ShowPetStats(petModel, petId)
	-- Request stats from server
	local stats = petRemotes.GetPetStats:InvokeServer(petId)
	
	if not stats then return end
	
	-- Create stats display
	local screenGui = player.PlayerGui:FindFirstChild("PetStats") or Instance.new("ScreenGui")
	screenGui.Name = "PetStats"
	screenGui.Parent = player.PlayerGui
	
	-- Clear previous display
	for _, child in pairs(screenGui:GetChildren()) do
		child:Destroy()
	end
	
	-- Stats frame
	local statsFrame = Instance.new("Frame")
	statsFrame.Size = UDim2.new(0, 250, 0, 200)
	statsFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
	statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	statsFrame.BorderSizePixel = 0
	statsFrame.Parent = screenGui
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.15, 0)
	title.Text = petModel.Name .. " Stats"
	title.Font = Enum.Font.SourceSansBold
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)
	title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	title.BorderSizePixel = 0
	title.Parent = statsFrame
	
	-- Stat bars
	local statNames = {"Happiness", "Energy", "Hunger", "Bond"}
	local statColors = {
		Happiness = Color3.fromRGB(255, 200, 50),
		Energy = Color3.fromRGB(50, 200, 255),
		Hunger = Color3.fromRGB(255, 100, 50),
		Bond = Color3.fromRGB(255, 50, 200)
	}
	
	for i, statName in ipairs(statNames) do
		local statFrame = Instance.new("Frame")
		statFrame.Size = UDim2.new(0.9, 0, 0.15, 0)
		statFrame.Position = UDim2.new(0.05, 0, 0.15 + i * 0.18, 0)
		statFrame.BackgroundTransparency = 1
		statFrame.Parent = statsFrame
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.4, 0, 1, 0)
		label.Text = statName
		label.Font = Enum.Font.SourceSans
		label.TextScaled = true
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.BackgroundTransparency = 1
		label.Parent = statFrame
		
		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.new(0.55, 0, 0.8, 0)
		barBg.Position = UDim2.new(0.45, 0, 0.1, 0)
		barBg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		barBg.BorderSizePixel = 0
		barBg.Parent = statFrame
		
		local barFill = Instance.new("Frame")
		barFill.Size = UDim2.new((stats[statName] or 0) / 100, 0, 1, 0)
		barFill.BackgroundColor3 = statColors[statName]
		barFill.BorderSizePixel = 0
		barFill.Parent = barBg
	end
	
	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 5)
	closeButton.Text = "X"
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextScaled = true
	closeButton.TextColor3 = Color3.new(1, 1, 1)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.BorderSizePixel = 0
	closeButton.Parent = statsFrame
	
	closeButton.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)
end

function PetController:OnPetObtained(petData)
	-- Show pet obtained notification
	local UIController = require(script.Parent.UIController)
	UIController:ShowNotification("New Pet: " .. petData.Name .. " [" .. petData.Rarity .. "]", "Success", 5)
	
	-- Play celebration effect
	self:PlayCelebrationEffect()
end

function PetController:PlayEggOpenAnimation(data)
	-- Create egg opening animation
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "EggAnimation"
	screenGui.Parent = player.PlayerGui
	
	-- Black overlay
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 0.3
	overlay.Parent = screenGui
	
	-- Egg model
	local eggFrame = Instance.new("Frame")
	eggFrame.Size = UDim2.new(0, 200, 0, 250)
	eggFrame.Position = UDim2.new(0.5, -100, 0.5, -125)
	eggFrame.BackgroundColor3 = Color3.new(1, 1, 1)
	eggFrame.BorderSizePixel = 0
	eggFrame.Parent = screenGui
	
	-- Shake animation
	local shakeAmount = 10
	for i = 1, 20 do
		eggFrame.Position = UDim2.new(0.5, -100 + math.random(-shakeAmount, shakeAmount), 0.5, -125)
		task.wait(0.05)
		shakeAmount = shakeAmount * 0.9
	end
	
	-- Crack effect
	eggFrame.BackgroundColor3 = Color3.new(0.8, 0.8, 0.8)
	
	task.wait(0.5)
	
	-- Reveal pet
	eggFrame:Destroy()
	
	local petFrame = Instance.new("Frame")
	petFrame.Size = UDim2.new(0, 300, 0, 300)
	petFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
	petFrame.BackgroundTransparency = 1
	petFrame.Parent = screenGui
	
	local petName = Instance.new("TextLabel")
	petName.Size = UDim2.new(1, 0, 0.2, 0)
	petName.Position = UDim2.new(0, 0, 0.8, 0)
	petName.Text = data.PetReceived.Name
	petName.Font = Enum.Font.SourceSansBold
	petName.TextScaled = true
	petName.TextColor3 = Color3.new(1, 1, 1)
	petName.BackgroundTransparency = 1
	petName.Parent = petFrame
	
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Size = UDim2.new(1, 0, 0.15, 0)
	rarityLabel.Position = UDim2.new(0, 0, 0.95, 0)
	rarityLabel.Text = "[" .. data.PetReceived.Rarity .. "]"
	rarityLabel.Font = Enum.Font.SourceSans
	rarityLabel.TextScaled = true
	rarityLabel.TextColor3 = self:GetRarityColor(data.PetReceived.Rarity)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Parent = petFrame
	
	-- Celebration particles
	self:PlayCelebrationEffect()
	
	task.wait(3)
	
	-- Fade out
	TweenService:Create(overlay, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
	TweenService:Create(petName, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	TweenService:Create(rarityLabel, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
	
	task.wait(0.5)
	screenGui:Destroy()
end

function PetController:PlayCelebrationEffect()
	-- Create confetti particles
	local character = player.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	local attachment = Instance.new("Attachment")
	attachment.Parent = rootPart
	
	local confetti = Instance.new("ParticleEmitter")
	confetti.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	confetti.Rate = 100
	confetti.Lifetime = NumberRange.new(2, 3)
	confetti.VelocityInheritance = 0
	confetti.EmissionDirection = Enum.NormalId.Top
	confetti.Speed = NumberRange.new(20, 30)
	confetti.SpreadAngle = Vector2.new(360, 360)
	confetti.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 255))
	})
	confetti.Parent = attachment
	
	task.wait(1)
	confetti.Enabled = false
	
	task.wait(3)
	attachment:Destroy()
end

function PetController:GetRarityColor(rarity)
	local colors = {
		Common = Color3.fromRGB(158, 158, 158),
		Uncommon = Color3.fromRGB(76, 209, 55),
		Rare = Color3.fromRGB(68, 138, 255),
		Epic = Color3.fromRGB(156, 39, 176),
		Legendary = Color3.fromRGB(255, 193, 7),
		Mythical = Color3.fromRGB(255, 61, 0)
	}
	
	return colors[rarity] or Color3.new(1, 1, 1)
end

function PetController:InteractWithNearestPet()
	-- Find nearest pet
	local character = player.Character
	if not character then return end
	
	local humanoidRoot = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRoot then return end
	
	local nearestPet = nil
	local nearestDistance = math.huge
	
	for _, model in pairs(workspace:GetChildren()) do
		if model:FindFirstChild("Humanoid") and model:FindFirstChild("NameTag") then
			local distance = (model.PrimaryPart.Position - humanoidRoot.Position).Magnitude
			if distance < nearestDistance and distance < 20 then
				nearestPet = model
				nearestDistance = distance
			end
		end
	end
	
	if nearestPet then
		self:OnPetClicked(nearestPet)
	end
end

function PetController:FeedNearestPet()
	-- Similar to interact but directly feeds
	local character = player.Character
	if not character then return end
	
	local humanoidRoot = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRoot then return end
	
	local nearestPet = nil
	local nearestDistance = math.huge
	
	for _, model in pairs(workspace:GetChildren()) do
		if model:FindFirstChild("Humanoid") and model:FindFirstChild("NameTag") then
			local distance = (model.PrimaryPart.Position - humanoidRoot.Position).Magnitude
			if distance < nearestDistance and distance < 20 then
				nearestPet = model
				nearestDistance = distance
			end
		end
	end
	
	if nearestPet then
		local petId = nearestPet:GetAttribute("PetId") or "unknown"
		petRemotes.FeedPet:FireServer(petId)
		self:ShowActionFeedback(nearestPet, "🍖")
	end
end

function PetController:RecallAllPets()
	-- Request server to teleport all pets to player
	petRemotes:FindFirstChild("RecallPets"):FireServer()
	
	local UIController = require(script.Parent.UIController)
	UIController:ShowNotification("Pets recalled!", "Info", 2)
end

return PetController