local DataService = {}

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PetService = require(script.Parent.PetService)

-- Data stores
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")
local PetDataStore = DataStoreService:GetDataStore("PetData_v1")

-- Cache for player data
local PlayerDataCache = {}

function DataService:Initialize()
	-- Setup auto-save
	self:SetupAutoSave()
end

function DataService:LoadPlayerData(player)
	local key = "Player_" .. player.UserId
	
	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(key)
	end)
	
	if success and data then
		PlayerDataCache[player] = data
		
		-- Load pet data
		if data.Pets then
			PetService:SetPlayerData(player, {
				OwnedPets = data.Pets,
				ActivePets = {}
			})
		end
		
		-- Update leaderstats
		local leaderstats = player:WaitForChild("leaderstats")
		if leaderstats then
			local coins = leaderstats:FindFirstChild("Coins")
			if coins then
				coins.Value = data.Coins or 100
			end
			
			local level = leaderstats:FindFirstChild("Level")
			if level then
				level.Value = data.Level or 1
			end
			
			local pets = leaderstats:FindFirstChild("Pets")
			if pets and data.Pets then
				pets.Value = #data.Pets
			end
		end
		
		print("✅ Loaded data for", player.Name)
	else
		-- New player
		PlayerDataCache[player] = {
			Coins = 100,
			Level = 1,
			Experience = 0,
			Pets = {},
			GamePasses = {},
			LastLogin = os.time(),
			TotalPlayTime = 0,
			DailyStreak = 0,
			LastDailyReward = 0
		}
		
		print("🆕 New player data created for", player.Name)
	end
	
	-- Update last login
	PlayerDataCache[player].LastLogin = os.time()
	
	-- Check daily reward
	self:CheckDailyReward(player)
end

function DataService:SavePlayerData(player)
	local data = PlayerDataCache[player]
	if not data then return end
	
	-- Get current pet data
	local petData = PetService:GetPlayerData(player)
	if petData then
		data.Pets = petData.OwnedPets
	end
	
	-- Update stats from leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins then
			data.Coins = coins.Value
		end
		
		local level = leaderstats:FindFirstChild("Level")
		if level then
			data.Level = level.Value
		end
	end
	
	-- Save to datastore
	local key = "Player_" .. player.UserId
	
	local success, error = pcall(function()
		PlayerDataStore:SetAsync(key, data)
	end)
	
	if success then
		print("💾 Saved data for", player.Name)
	else
		warn("Failed to save data for", player.Name, error)
	end
end

function DataService:CheckDailyReward(player)
	local data = PlayerDataCache[player]
	if not data then return end
	
	local currentTime = os.time()
	local lastReward = data.LastDailyReward or 0
	local timeSinceLastReward = currentTime - lastReward
	
	-- Check if 24 hours have passed
	if timeSinceLastReward >= 86400 then -- 86400 seconds = 24 hours
		-- Calculate streak
		if timeSinceLastReward < 172800 then -- Less than 48 hours
			data.DailyStreak = (data.DailyStreak or 0) + 1
		else
			data.DailyStreak = 1 -- Reset streak
		end
		
		-- Give daily reward based on streak
		local rewardAmount = 100 * data.DailyStreak
		rewardAmount = math.min(rewardAmount, 1000) -- Cap at 1000 coins
		
		local leaderstats = player:WaitForChild("leaderstats")
		local coins = leaderstats:WaitForChild("Coins")
		coins.Value = coins.Value + rewardAmount
		
		data.LastDailyReward = currentTime
		
		-- Notify player
		local remotes = game.ReplicatedStorage:WaitForChild("Remotes")
		local playerRemotes = remotes:FindFirstChild("PlayerRemotes") or Instance.new("Folder")
		playerRemotes.Name = "PlayerRemotes"
		playerRemotes.Parent = remotes
		
		local dailyRewardEvent = playerRemotes:FindFirstChild("DailyReward") or Instance.new("RemoteEvent")
		dailyRewardEvent.Name = "DailyReward"
		dailyRewardEvent.Parent = playerRemotes
		
		dailyRewardEvent:FireClient(player, {
			Amount = rewardAmount,
			Streak = data.DailyStreak
		})
		
		print("🎁 Daily reward given to", player.Name, "- Streak:", data.DailyStreak)
	end
end

function DataService:SetupAutoSave()
	-- Auto-save every 5 minutes
	task.spawn(function()
		while true do
			task.wait(300) -- 5 minutes
			
			for _, player in pairs(Players:GetPlayers()) do
				self:SavePlayerData(player)
			end
			
			print("⏰ Auto-save completed")
		end
	end)
end

function DataService:GetPlayerData(player)
	return PlayerDataCache[player]
end

function DataService:UpdatePlayerData(player, key, value)
	if not PlayerDataCache[player] then return end
	
	PlayerDataCache[player][key] = value
end

function DataService:IncrementPlayerStat(player, stat, amount)
	if not PlayerDataCache[player] then return end
	
	PlayerDataCache[player][stat] = (PlayerDataCache[player][stat] or 0) + amount
end

function DataService:HasGamePass(player, passName)
	local data = PlayerDataCache[player]
	if not data or not data.GamePasses then return false end
	
	return data.GamePasses[passName] == true
end

function DataService:GrantGamePass(player, passName)
	if not PlayerDataCache[player] then return end
	
	if not PlayerDataCache[player].GamePasses then
		PlayerDataCache[player].GamePasses = {}
	end
	
	PlayerDataCache[player].GamePasses[passName] = true
end

return DataService