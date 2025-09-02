local UIController = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GameConfig = require(ReplicatedStorage.Shared.Data.GameConfig)
local PetData = require(ReplicatedStorage.Shared.Data.PetData)

function UIController:Initialize()
	self:CreateMainUI()
	self:CreatePetInventory()
	self:CreateShopUI()
	self:CreateSettingsMenu()
	self:CreateNotificationSystem()
	self:SetupTopBar()
end

function UIController:CreateMainUI()
	-- Main screen GUI
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MainUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	-- Main frame container
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Parent = screenGui
	
	-- Store reference
	self.MainUI = screenGui
	self.MainFrame = mainFrame
end

function UIController:SetupTopBar()
	-- Top bar container
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 60)
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	topBar.BorderSizePixel = 0
	topBar.Parent = self.MainFrame
	
	-- Currency display
	local currencyFrame = Instance.new("Frame")
	currencyFrame.Name = "CurrencyFrame"
	currencyFrame.Size = UDim2.new(0, 200, 1, -10)
	currencyFrame.Position = UDim2.new(0, 10, 0, 5)
	currencyFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	currencyFrame.BorderSizePixel = 0
	currencyFrame.Parent = topBar
	
	local coinIcon = Instance.new("ImageLabel")
	coinIcon.Name = "CoinIcon"
	coinIcon.Size = UDim2.new(0, 40, 0, 40)
	coinIcon.Position = UDim2.new(0, 5, 0.5, -20)
	coinIcon.Image = "rbxasset://textures/ui/common/robux.png"
	coinIcon.BackgroundTransparency = 1
	coinIcon.Parent = currencyFrame
	
	local coinLabel = Instance.new("TextLabel")
	coinLabel.Name = "CoinLabel"
	coinLabel.Size = UDim2.new(1, -50, 1, 0)
	coinLabel.Position = UDim2.new(0, 50, 0, 0)
	coinLabel.Text = "0"
	coinLabel.Font = Enum.Font.SourceSansBold
	coinLabel.TextScaled = true
	coinLabel.TextColor3 = Color3.new(1, 1, 1)
	coinLabel.BackgroundTransparency = 1
	coinLabel.Parent = currencyFrame
	
	-- Update coins display
	local leaderstats = player:WaitForChild("leaderstats")
	local coins = leaderstats:WaitForChild("Coins")
	
	local function updateCoins()
		coinLabel.Text = tostring(coins.Value)
	end
	
	updateCoins()
	coins.Changed:Connect(updateCoins)
	
	-- Menu buttons
	local buttonNames = {"Pets", "Shop", "Trade", "Settings"}
	local buttonSize = UDim2.new(0, 100, 0, 40)
	
	for i, name in ipairs(buttonNames) do
		local button = Instance.new("TextButton")
		button.Name = name .. "Button"
		button.Size = buttonSize
		button.Position = UDim2.new(1, -110 * (5 - i), 0.5, -20)
		button.Text = name
		button.Font = Enum.Font.SourceSansBold
		button.TextScaled = true
		button.TextColor3 = Color3.new(1, 1, 1)
		button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		button.BorderSizePixel = 0
		button.Parent = topBar
		
		-- Hover effect
		button.MouseEnter:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			}):Play()
		end)
		
		button.MouseLeave:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.2), {
				BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			}):Play()
		end)
		
		-- Button actions
		button.MouseButton1Click:Connect(function()
			self:OnMenuButtonClick(name)
		end)
	end
end

function UIController:CreatePetInventory()
	-- Pet inventory GUI
	local petGui = Instance.new("ScreenGui")
	petGui.Name = "PetInventory"
	petGui.ResetOnSpawn = false
	petGui.Enabled = false
	petGui.Parent = playerGui
	
	-- Main frame
	local frame = Instance.new("Frame")
	frame.Name = "InventoryFrame"
	frame.Size = UDim2.new(0.8, 0, 0.8, 0)
	frame.Position = UDim2.new(0.1, 0, 0.1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BorderSizePixel = 0
	frame.Parent = petGui
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Text = "My Pets"
	title.Font = Enum.Font.SourceSansBold
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)
	title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	title.BorderSizePixel = 0
	title.Parent = frame
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -45, 0, 5)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextScaled = true
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = frame
	
	closeBtn.MouseButton1Click:Connect(function()
		petGui.Enabled = false
	end)
	
	-- Pet grid
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "PetGrid"
	scrollFrame.Size = UDim2.new(1, -20, 1, -70)
	scrollFrame.Position = UDim2.new(0, 10, 0, 60)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.Parent = frame
	
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 150, 0, 150)
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.Parent = scrollFrame
	
	self.PetInventory = petGui
	self.PetGrid = scrollFrame
end

function UIController:CreateShopUI()
	-- Shop GUI
	local shopGui = Instance.new("ScreenGui")
	shopGui.Name = "ShopUI"
	shopGui.ResetOnSpawn = false
	shopGui.Enabled = false
	shopGui.Parent = playerGui
	
	-- Main frame
	local frame = Instance.new("Frame")
	frame.Name = "ShopFrame"
	frame.Size = UDim2.new(0.9, 0, 0.9, 0)
	frame.Position = UDim2.new(0.05, 0, 0.05, 0)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BorderSizePixel = 0
	frame.Parent = shopGui
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Text = "Pet Shop"
	title.Font = Enum.Font.SourceSansBold
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)
	title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	title.BorderSizePixel = 0
	title.Parent = frame
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 50, 0, 50)
	closeBtn.Position = UDim2.new(1, -55, 0, 5)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextScaled = true
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = frame
	
	closeBtn.MouseButton1Click:Connect(function()
		shopGui.Enabled = false
	end)
	
	-- Tab buttons
	local tabFrame = Instance.new("Frame")
	tabFrame.Name = "TabFrame"
	tabFrame.Size = UDim2.new(1, 0, 0, 50)
	tabFrame.Position = UDim2.new(0, 0, 0, 60)
	tabFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	tabFrame.BorderSizePixel = 0
	tabFrame.Parent = frame
	
	local tabs = {"Eggs", "Game Passes", "Coins", "Accessories"}
	for i, tabName in ipairs(tabs) do
		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = tabName .. "Tab"
		tabBtn.Size = UDim2.new(0.25, -2, 1, 0)
		tabBtn.Position = UDim2.new(0.25 * (i - 1), 1, 0, 0)
		tabBtn.Text = tabName
		tabBtn.Font = Enum.Font.SourceSansBold
		tabBtn.TextScaled = true
		tabBtn.TextColor3 = Color3.new(1, 1, 1)
		tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
		tabBtn.BorderSizePixel = 0
		tabBtn.Parent = tabFrame
		
		tabBtn.MouseButton1Click:Connect(function()
			self:SwitchShopTab(tabName)
		end)
	end
	
	-- Content frame
	local contentFrame = Instance.new("ScrollingFrame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, -20, 1, -130)
	contentFrame.Position = UDim2.new(0, 10, 0, 120)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ScrollBarThickness = 8
	contentFrame.Parent = frame
	
	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 200, 0, 250)
	gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
	gridLayout.Parent = contentFrame
	
	self.ShopUI = shopGui
	self.ShopContent = contentFrame
	
	-- Populate initial shop items
	self:PopulateShop("Eggs")
end

function UIController:CreateSettingsMenu()
	-- Settings GUI
	local settingsGui = Instance.new("ScreenGui")
	settingsGui.Name = "SettingsMenu"
	settingsGui.ResetOnSpawn = false
	settingsGui.Enabled = false
	settingsGui.Parent = playerGui
	
	-- Main frame
	local frame = Instance.new("Frame")
	frame.Name = "SettingsFrame"
	frame.Size = UDim2.new(0.5, 0, 0.6, 0)
	frame.Position = UDim2.new(0.25, 0, 0.2, 0)
	frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame.BorderSizePixel = 0
	frame.Parent = settingsGui
	
	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Text = "Settings"
	title.Font = Enum.Font.SourceSansBold
	title.TextScaled = true
	title.TextColor3 = Color3.new(1, 1, 1)
	title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	title.BorderSizePixel = 0
	title.Parent = frame
	
	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -45, 0, 5)
	closeBtn.Text = "X"
	closeBtn.Font = Enum.Font.SourceSansBold
	closeBtn.TextScaled = true
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = frame
	
	closeBtn.MouseButton1Click:Connect(function()
		settingsGui.Enabled = false
	end)
	
	-- Settings options
	local settings = {
		{Name = "Music", Type = "Toggle", Default = true},
		{Name = "Sound Effects", Type = "Toggle", Default = true},
		{Name = "Particles", Type = "Toggle", Default = true},
		{Name = "Pet Names", Type = "Toggle", Default = true},
		{Name = "Graphics Quality", Type = "Slider", Min = 1, Max = 10, Default = 5}
	}
	
	for i, setting in ipairs(settings) do
		local settingFrame = Instance.new("Frame")
		settingFrame.Name = setting.Name .. "Setting"
		settingFrame.Size = UDim2.new(1, -20, 0, 40)
		settingFrame.Position = UDim2.new(0, 10, 0, 60 + (i - 1) * 50)
		settingFrame.BackgroundTransparency = 1
		settingFrame.Parent = frame
		
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.5, 0, 1, 0)
		label.Text = setting.Name
		label.Font = Enum.Font.SourceSans
		label.TextScaled = true
		label.TextColor3 = Color3.new(1, 1, 1)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.BackgroundTransparency = 1
		label.Parent = settingFrame
		
		if setting.Type == "Toggle" then
			local toggle = Instance.new("TextButton")
			toggle.Size = UDim2.new(0, 60, 0, 30)
			toggle.Position = UDim2.new(1, -65, 0.5, -15)
			toggle.Text = setting.Default and "ON" or "OFF"
			toggle.Font = Enum.Font.SourceSansBold
			toggle.TextColor3 = Color3.new(1, 1, 1)
			toggle.BackgroundColor3 = setting.Default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
			toggle.BorderSizePixel = 0
			toggle.Parent = settingFrame
			
			local isOn = setting.Default
			toggle.MouseButton1Click:Connect(function()
				isOn = not isOn
				toggle.Text = isOn and "ON" or "OFF"
				toggle.BackgroundColor3 = isOn and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
				self:OnSettingChanged(setting.Name, isOn)
			end)
		end
	end
	
	self.SettingsMenu = settingsGui
end

function UIController:CreateNotificationSystem()
	-- Notification container
	local notificationGui = Instance.new("ScreenGui")
	notificationGui.Name = "Notifications"
	notificationGui.ResetOnSpawn = false
	notificationGui.Parent = playerGui
	
	local container = Instance.new("Frame")
	container.Name = "NotificationContainer"
	container.Size = UDim2.new(0, 300, 1, 0)
	container.Position = UDim2.new(1, -310, 0, 0)
	container.BackgroundTransparency = 1
	container.Parent = notificationGui
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.Parent = container
	
	self.NotificationContainer = container
end

function UIController:ShowNotification(text, notificationType, duration)
	duration = duration or 3
	
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(1, 0, 0, 60)
	notification.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	notification.BorderSizePixel = 0
	notification.Parent = self.NotificationContainer
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -10, 1, 0)
	textLabel.Position = UDim2.new(0, 5, 0, 0)
	textLabel.Text = text
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextScaled = true
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Parent = notification
	
	-- Color based on type
	if notificationType == "Success" then
		notification.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	elseif notificationType == "Error" then
		notification.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	elseif notificationType == "Warning" then
		notification.BackgroundColor3 = Color3.fromRGB(200, 200, 50)
	end
	
	-- Fade in
	notification.BackgroundTransparency = 1
	textLabel.TextTransparency = 1
	
	TweenService:Create(notification, TweenInfo.new(0.3), {
		BackgroundTransparency = 0
	}):Play()
	
	TweenService:Create(textLabel, TweenInfo.new(0.3), {
		TextTransparency = 0
	}):Play()
	
	-- Auto remove
	task.wait(duration)
	
	TweenService:Create(notification, TweenInfo.new(0.3), {
		BackgroundTransparency = 1
	}):Play()
	
	TweenService:Create(textLabel, TweenInfo.new(0.3), {
		TextTransparency = 1
	}):Play()
	
	task.wait(0.3)
	notification:Destroy()
end

function UIController:OnMenuButtonClick(buttonName)
	if buttonName == "Pets" then
		self.PetInventory.Enabled = not self.PetInventory.Enabled
		if self.PetInventory.Enabled then
			self:RefreshPetInventory()
		end
	elseif buttonName == "Shop" then
		self.ShopUI.Enabled = not self.ShopUI.Enabled
	elseif buttonName == "Trade" then
		self:ShowNotification("Trading coming soon!", "Info", 2)
	elseif buttonName == "Settings" then
		self.SettingsMenu.Enabled = not self.SettingsMenu.Enabled
	end
end

function UIController:RefreshPetInventory()
	-- Clear existing items
	for _, child in pairs(self.PetGrid:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Request pet data from server
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local petRemotes = remotes:WaitForChild("PetRemotes")
	
	-- This would be populated with actual pet data from the server
	-- For now, creating placeholder items
end

function UIController:PopulateShop(tabName)
	-- Clear existing items
	for _, child in pairs(self.ShopContent:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	if tabName == "Eggs" then
		-- Create egg items
		for eggName, eggData in pairs(GameConfig.Eggs) do
			local itemFrame = self:CreateShopItem(eggName, eggData)
			itemFrame.Parent = self.ShopContent
		end
	elseif tabName == "Game Passes" then
		-- Create game pass items
		for passName, passData in pairs(GameConfig.GamePasses) do
			local itemFrame = self:CreateGamePassItem(passName, passData)
			itemFrame.Parent = self.ShopContent
		end
	elseif tabName == "Coins" then
		-- Create coin packages
		for productName, productData in pairs(GameConfig.Products) do
			if productData.Coins then
				local itemFrame = self:CreateCoinItem(productName, productData)
				itemFrame.Parent = self.ShopContent
			end
		end
	end
end

function UIController:CreateShopItem(itemName, itemData)
	local frame = Instance.new("Frame")
	frame.Name = itemName
	frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	frame.BorderSizePixel = 0
	
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(1, -10, 0.6, -10)
	imageLabel.Position = UDim2.new(0, 5, 0, 5)
	imageLabel.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	imageLabel.BorderSizePixel = 0
	imageLabel.Parent = frame
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.15, 0)
	nameLabel.Position = UDim2.new(0, 0, 0.6, 0)
	nameLabel.Text = itemData.Name or itemName
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = frame
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(1, 0, 0.1, 0)
	priceLabel.Position = UDim2.new(0, 0, 0.75, 0)
	priceLabel.Text = itemData.RobuxPrice and (itemData.RobuxPrice .. " R$") or (itemData.Price .. " Coins")
	priceLabel.Font = Enum.Font.SourceSans
	priceLabel.TextScaled = true
	priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Parent = frame
	
	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0.8, 0, 0.12, 0)
	buyButton.Position = UDim2.new(0.1, 0, 0.86, 0)
	buyButton.Text = "Buy"
	buyButton.Font = Enum.Font.SourceSansBold
	buyButton.TextScaled = true
	buyButton.TextColor3 = Color3.new(1, 1, 1)
	buyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	buyButton.BorderSizePixel = 0
	buyButton.Parent = frame
	
	buyButton.MouseButton1Click:Connect(function()
		self:OnPurchaseItem(itemName, itemData)
	end)
	
	return frame
end

function UIController:CreateGamePassItem(passName, passData)
	local frame = Instance.new("Frame")
	frame.Name = passName
	frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	frame.BorderSizePixel = 0
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -10, 0.2, 0)
	nameLabel.Position = UDim2.new(0, 5, 0, 5)
	nameLabel.Text = passData.Name
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = frame
	
	-- Benefits list
	local benefitsFrame = Instance.new("Frame")
	benefitsFrame.Size = UDim2.new(1, -10, 0.5, 0)
	benefitsFrame.Position = UDim2.new(0, 5, 0.2, 0)
	benefitsFrame.BackgroundTransparency = 1
	benefitsFrame.Parent = frame
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Parent = benefitsFrame
	
	for _, benefit in ipairs(passData.Benefits) do
		local benefitLabel = Instance.new("TextLabel")
		benefitLabel.Size = UDim2.new(1, 0, 0, 20)
		benefitLabel.Text = "✓ " .. benefit
		benefitLabel.Font = Enum.Font.SourceSans
		benefitLabel.TextScaled = true
		benefitLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
		benefitLabel.TextXAlignment = Enum.TextXAlignment.Left
		benefitLabel.BackgroundTransparency = 1
		benefitLabel.Parent = benefitsFrame
	end
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(1, 0, 0.1, 0)
	priceLabel.Position = UDim2.new(0, 0, 0.75, 0)
	priceLabel.Text = passData.Price .. " R$"
	priceLabel.Font = Enum.Font.SourceSansBold
	priceLabel.TextScaled = true
	priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Parent = frame
	
	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0.8, 0, 0.12, 0)
	buyButton.Position = UDim2.new(0.1, 0, 0.86, 0)
	buyButton.Text = "Buy Pass"
	buyButton.Font = Enum.Font.SourceSansBold
	buyButton.TextScaled = true
	buyButton.TextColor3 = Color3.new(1, 1, 1)
	buyButton.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
	buyButton.BorderSizePixel = 0
	buyButton.Parent = frame
	
	buyButton.MouseButton1Click:Connect(function()
		self:OnPurchaseGamePass(passName, passData)
	end)
	
	return frame
end

function UIController:CreateCoinItem(productName, productData)
	local frame = Instance.new("Frame")
	frame.Name = productName
	frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	frame.BorderSizePixel = 0
	
	local coinIcon = Instance.new("ImageLabel")
	coinIcon.Size = UDim2.new(0.5, 0, 0.5, 0)
	coinIcon.Position = UDim2.new(0.25, 0, 0.1, 0)
	coinIcon.Image = "rbxasset://textures/ui/common/robux.png"
	coinIcon.BackgroundTransparency = 1
	coinIcon.Parent = frame
	
	local amountLabel = Instance.new("TextLabel")
	amountLabel.Size = UDim2.new(1, 0, 0.15, 0)
	amountLabel.Position = UDim2.new(0, 0, 0.6, 0)
	amountLabel.Text = tostring(productData.Coins) .. " Coins"
	amountLabel.Font = Enum.Font.SourceSansBold
	amountLabel.TextScaled = true
	amountLabel.TextColor3 = Color3.new(1, 1, 1)
	amountLabel.BackgroundTransparency = 1
	amountLabel.Parent = frame
	
	local priceLabel = Instance.new("TextLabel")
	priceLabel.Size = UDim2.new(1, 0, 0.1, 0)
	priceLabel.Position = UDim2.new(0, 0, 0.75, 0)
	priceLabel.Text = productData.Robux .. " R$"
	priceLabel.Font = Enum.Font.SourceSans
	priceLabel.TextScaled = true
	priceLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	priceLabel.BackgroundTransparency = 1
	priceLabel.Parent = frame
	
	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0.8, 0, 0.12, 0)
	buyButton.Position = UDim2.new(0.1, 0, 0.86, 0)
	buyButton.Text = "Buy"
	buyButton.Font = Enum.Font.SourceSansBold
	buyButton.TextScaled = true
	buyButton.TextColor3 = Color3.new(1, 1, 1)
	buyButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	buyButton.BorderSizePixel = 0
	buyButton.Parent = frame
	
	buyButton.MouseButton1Click:Connect(function()
		self:OnPurchaseCoins(productName, productData)
	end)
	
	return frame
end

function UIController:SwitchShopTab(tabName)
	self:PopulateShop(tabName)
end

function UIController:OnPurchaseItem(itemName, itemData)
	-- Handle purchase logic
	self:ShowNotification("Processing purchase...", "Info", 2)
	
	-- Send purchase request to server
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local shopRemotes = remotes:WaitForChild("ShopRemotes")
	
	-- This would connect to actual purchase system
end

function UIController:OnPurchaseGamePass(passName, passData)
	-- Prompt game pass purchase
	if passData.PassId and passData.PassId > 0 then
		MarketplaceService:PromptGamePassPurchase(player, passData.PassId)
	else
		self:ShowNotification("Game pass not available yet", "Warning", 3)
	end
end

function UIController:OnPurchaseCoins(productName, productData)
	-- Prompt product purchase
	if productData.ProductId and productData.ProductId > 0 then
		MarketplaceService:PromptProductPurchase(player, productData.ProductId)
	else
		self:ShowNotification("Product not available yet", "Warning", 3)
	end
end

function UIController:OnSettingChanged(settingName, value)
	-- Handle setting changes
	print("Setting changed:", settingName, value)
	
	-- Apply setting changes
	if settingName == "Music" then
		-- Toggle music
	elseif settingName == "Sound Effects" then
		-- Toggle sound effects
	elseif settingName == "Particles" then
		-- Toggle particles
		for _, pet in pairs(workspace:GetDescendants()) do
			if pet:IsA("ParticleEmitter") then
				pet.Enabled = value
			end
		end
	end
end

function UIController:SetupMobileUI()
	-- Adjust UI for mobile devices
	-- Scale up buttons and text for better touch interaction
end

return UIController