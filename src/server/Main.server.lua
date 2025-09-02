local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

-- Services
local MapService = require(script.Parent.Services.MapService)
local PetService = require(script.Parent.Services.PetService)
local DataService = require(script.Parent.Services.DataService)
local ShopService = require(script.Parent.Services.ShopService)
local TradingService = require(script.Parent.Services.TradingService)

-- Initialize game
print("🎮 AI Pet Paradise - Server Starting...")

-- Initialize map
MapService:Initialize()
print("✅ Map loaded successfully")

-- Initialize services
PetService:Initialize()
DataService:Initialize()
ShopService:Initialize()
TradingService:Initialize()
print("✅ All services initialized")

-- Player join handler
Players.PlayerAdded:Connect(function(player)
	print("👋 Player joined:", player.Name)
	
	-- Load player data
	DataService:LoadPlayerData(player)
	
	-- Setup leaderstats
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 100
	coins.Parent = leaderstats
	
	local level = Instance.new("IntValue")
	level.Name = "Level"
	level.Value = 1
	level.Parent = leaderstats
	
	local pets = Instance.new("IntValue")
	pets.Name = "Pets"
	pets.Value = 0
	pets.Parent = leaderstats
	
	-- Give starter pet when character spawns
	player.CharacterAdded:Connect(function(character)
		task.wait(2) -- Wait for character to load
		
		-- Check if player has any pets
		local playerPets = PetService:GetPlayerPets(player)
		if #playerPets == 0 then
			-- Give starter pet
			PetService:GivePet(player, "Puppy", {
				Personality = "Playful",
				Name = "Starter Puppy"
			})
			print("🐕 Gave starter pet to", player.Name)
		end
		
		-- Spawn active pets
		PetService:SpawnPlayerPets(player)
	end)
end)

-- Player leave handler
Players.PlayerRemoving:Connect(function(player)
	print("👋 Player left:", player.Name)
	
	-- Save player data
	DataService:SavePlayerData(player)
	
	-- Cleanup pets
	PetService:RemovePlayerPets(player)
end)

-- Auto-save loop
task.spawn(function()
	while true do
		task.wait(60) -- Save every minute
		
		for _, player in pairs(Players:GetPlayers()) do
			DataService:SavePlayerData(player)
		end
		
		print("💾 Auto-saved all player data")
	end
end)

-- Server heartbeat for game updates
RunService.Heartbeat:Connect(function(deltaTime)
	-- Update any server-side game mechanics here
end)

print("🚀 AI Pet Paradise - Server Ready!")