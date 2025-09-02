local TradingService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Shared.Data.GameConfig)
local PetService = require(script.Parent.PetService)
local DataService = require(script.Parent.DataService)

-- Active trades
local ActiveTrades = {}
local TradeCooldowns = {}

function TradingService:Initialize()
	if not GameConfig.Trading.Enabled then
		return
	end
	
	-- Create remotes
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local tradeRemotes = Instance.new("Folder")
	tradeRemotes.Name = "TradeRemotes"
	tradeRemotes.Parent = remotes
	
	-- Remote events
	local sendTradeRequest = Instance.new("RemoteEvent")
	sendTradeRequest.Name = "SendTradeRequest"
	sendTradeRequest.Parent = tradeRemotes
	
	local acceptTrade = Instance.new("RemoteEvent")
	acceptTrade.Name = "AcceptTrade"
	acceptTrade.Parent = tradeRemotes
	
	local declineTrade = Instance.new("RemoteEvent")
	declineTrade.Name = "DeclineTrade"
	declineTrade.Parent = tradeRemotes
	
	local addTradeItem = Instance.new("RemoteEvent")
	addTradeItem.Name = "AddTradeItem"
	addTradeItem.Parent = tradeRemotes
	
	local removeTradeItem = Instance.new("RemoteEvent")
	removeTradeItem.Name = "RemoveTradeItem"
	removeTradeItem.Parent = tradeRemotes
	
	local confirmTrade = Instance.new("RemoteEvent")
	confirmTrade.Name = "ConfirmTrade"
	confirmTrade.Parent = tradeRemotes
	
	local cancelTrade = Instance.new("RemoteEvent")
	cancelTrade.Name = "CancelTrade"
	cancelTrade.Parent = tradeRemotes
	
	-- Connect events
	sendTradeRequest.OnServerEvent:Connect(function(player, targetPlayer)
		self:SendTradeRequest(player, targetPlayer)
	end)
	
	acceptTrade.OnServerEvent:Connect(function(player, tradeId)
		self:AcceptTradeRequest(player, tradeId)
	end)
	
	declineTrade.OnServerEvent:Connect(function(player, tradeId)
		self:DeclineTradeRequest(player, tradeId)
	end)
	
	addTradeItem.OnServerEvent:Connect(function(player, itemType, itemId)
		self:AddItemToTrade(player, itemType, itemId)
	end)
	
	removeTradeItem.OnServerEvent:Connect(function(player, itemType, itemId)
		self:RemoveItemFromTrade(player, itemType, itemId)
	end)
	
	confirmTrade.OnServerEvent:Connect(function(player)
		self:ConfirmTrade(player)
	end)
	
	cancelTrade.OnServerEvent:Connect(function(player)
		self:CancelTrade(player)
	end)
end

function TradingService:SendTradeRequest(sender, targetPlayerName)
	-- Check cooldown
	if TradeCooldowns[sender] and tick() - TradeCooldowns[sender] < GameConfig.Trading.TradeCooldown then
		return false, "Please wait before sending another trade request"
	end
	
	-- Find target player
	local targetPlayer = Players:FindFirstChild(targetPlayerName)
	if not targetPlayer then
		return false, "Player not found"
	end
	
	if targetPlayer == sender then
		return false, "Cannot trade with yourself"
	end
	
	-- Check if players meet level requirement
	local senderData = DataService:GetPlayerData(sender)
	local targetData = DataService:GetPlayerData(targetPlayer)
	
	if not senderData or senderData.Level < GameConfig.Trading.MinLevel then
		return false, "You must be level " .. GameConfig.Trading.MinLevel .. " to trade"
	end
	
	if not targetData or targetData.Level < GameConfig.Trading.MinLevel then
		return false, "Target player must be level " .. GameConfig.Trading.MinLevel .. " to trade"
	end
	
	-- Check if either player is already in a trade
	for _, trade in pairs(ActiveTrades) do
		if trade.Player1 == sender or trade.Player2 == sender or
		   trade.Player1 == targetPlayer or trade.Player2 == targetPlayer then
			return false, "One of the players is already in a trade"
		end
	end
	
	-- Create trade request
	local tradeId = tostring(tick()) .. "_" .. sender.UserId
	local tradeRequest = {
		Id = tradeId,
		Sender = sender,
		Target = targetPlayer,
		Status = "Pending",
		Timestamp = tick()
	}
	
	-- Send request to target
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local tradeRemotes = remotes:WaitForChild("TradeRemotes")
	local tradeRequestReceived = tradeRemotes:FindFirstChild("TradeRequestReceived") or Instance.new("RemoteEvent")
	tradeRequestReceived.Name = "TradeRequestReceived"
	tradeRequestReceived.Parent = tradeRemotes
	
	tradeRequestReceived:FireClient(targetPlayer, {
		TradeId = tradeId,
		SenderName = sender.Name,
		SenderId = sender.UserId
	})
	
	-- Store request temporarily
	task.wait(30) -- Wait 30 seconds for response
	
	-- Auto-decline if no response
	if ActiveTrades[tradeId] and ActiveTrades[tradeId].Status == "Pending" then
		self:DeclineTradeRequest(targetPlayer, tradeId)
	end
	
	TradeCooldowns[sender] = tick()
	return true
end

function TradingService:AcceptTradeRequest(player, tradeId)
	-- Create trade session
	local trade = {
		Id = tradeId,
		Player1 = player,
		Player2 = nil, -- Will be set from the request
		Player1Items = {Pets = {}, Coins = 0},
		Player2Items = {Pets = {}, Coins = 0},
		Player1Confirmed = false,
		Player2Confirmed = false,
		Status = "Active",
		StartTime = tick()
	}
	
	ActiveTrades[tradeId] = trade
	
	-- Notify both players
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local tradeRemotes = remotes:WaitForChild("TradeRemotes")
	local tradeStarted = tradeRemotes:FindFirstChild("TradeStarted") or Instance.new("RemoteEvent")
	tradeStarted.Name = "TradeStarted"
	tradeStarted.Parent = tradeRemotes
	
	tradeStarted:FireClient(trade.Player1, {TradeId = tradeId})
	if trade.Player2 then
		tradeStarted:FireClient(trade.Player2, {TradeId = tradeId})
	end
	
	return true
end

function TradingService:DeclineTradeRequest(player, tradeId)
	-- Remove trade request
	if ActiveTrades[tradeId] then
		ActiveTrades[tradeId] = nil
	end
	
	-- Notify sender
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local tradeRemotes = remotes:WaitForChild("TradeRemotes")
	local tradeDeclined = tradeRemotes:FindFirstChild("TradeDeclined") or Instance.new("RemoteEvent")
	tradeDeclined.Name = "TradeDeclined"
	tradeDeclined.Parent = tradeRemotes
	
	-- Fire to both players if trade was active
	
	return true
end

function TradingService:AddItemToTrade(player, itemType, itemId)
	-- Find player's active trade
	local trade = self:GetPlayerActiveTrade(player)
	if not trade then return false end
	
	local isPlayer1 = trade.Player1 == player
	local playerItems = isPlayer1 and trade.Player1Items or trade.Player2Items
	
	-- Check max items
	local totalItems = #playerItems.Pets
	if totalItems >= GameConfig.Trading.MaxItemsPerTrade then
		return false, "Maximum items reached"
	end
	
	if itemType == "Pet" then
		-- Verify player owns the pet
		local playerPets = PetService:GetPlayerPets(player)
		local ownsPet = false
		
		for _, pet in ipairs(playerPets) do
			if pet.Id == itemId then
				ownsPet = true
				break
			end
		end
		
		if not ownsPet then
			return false, "You don't own this pet"
		end
		
		-- Add to trade
		table.insert(playerItems.Pets, itemId)
		
		-- Reset confirmations
		trade.Player1Confirmed = false
		trade.Player2Confirmed = false
		
		-- Update both players
		self:UpdateTradeUI(trade)
		
		return true
	elseif itemType == "Coins" then
		-- Check player has enough coins
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local coins = leaderstats:FindFirstChild("Coins")
			if coins and coins.Value >= itemId then
				playerItems.Coins = itemId
				
				-- Reset confirmations
				trade.Player1Confirmed = false
				trade.Player2Confirmed = false
				
				-- Update both players
				self:UpdateTradeUI(trade)
				
				return true
			end
		end
		
		return false, "Not enough coins"
	end
	
	return false
end

function TradingService:RemoveItemFromTrade(player, itemType, itemId)
	local trade = self:GetPlayerActiveTrade(player)
	if not trade then return false end
	
	local isPlayer1 = trade.Player1 == player
	local playerItems = isPlayer1 and trade.Player1Items or trade.Player2Items
	
	if itemType == "Pet" then
		for i, petId in ipairs(playerItems.Pets) do
			if petId == itemId then
				table.remove(playerItems.Pets, i)
				
				-- Reset confirmations
				trade.Player1Confirmed = false
				trade.Player2Confirmed = false
				
				-- Update both players
				self:UpdateTradeUI(trade)
				
				return true
			end
		end
	elseif itemType == "Coins" then
		playerItems.Coins = 0
		
		-- Reset confirmations
		trade.Player1Confirmed = false
		trade.Player2Confirmed = false
		
		-- Update both players
		self:UpdateTradeUI(trade)
		
		return true
	end
	
	return false
end

function TradingService:ConfirmTrade(player)
	local trade = self:GetPlayerActiveTrade(player)
	if not trade then return false end
	
	local isPlayer1 = trade.Player1 == player
	
	if isPlayer1 then
		trade.Player1Confirmed = true
	else
		trade.Player2Confirmed = true
	end
	
	-- Check if both confirmed
	if trade.Player1Confirmed and trade.Player2Confirmed then
		self:ExecuteTrade(trade)
	else
		-- Update UI
		self:UpdateTradeUI(trade)
	end
	
	return true
end

function TradingService:ExecuteTrade(trade)
	-- Exchange items
	local player1Pets = PetService:GetPlayerPets(trade.Player1)
	local player2Pets = PetService:GetPlayerPets(trade.Player2)
	
	-- Transfer pets from Player1 to Player2
	for _, petId in ipairs(trade.Player1Items.Pets) do
		for i, pet in ipairs(player1Pets) do
			if pet.Id == petId then
				-- Remove from player1
				table.remove(player1Pets, i)
				-- Add to player2
				table.insert(player2Pets, pet)
				break
			end
		end
	end
	
	-- Transfer pets from Player2 to Player1
	for _, petId in ipairs(trade.Player2Items.Pets) do
		for i, pet in ipairs(player2Pets) do
			if pet.Id == petId then
				-- Remove from player2
				table.remove(player2Pets, i)
				-- Add to player1
				table.insert(player1Pets, pet)
				break
			end
		end
	end
	
	-- Transfer coins
	local player1Stats = trade.Player1:FindFirstChild("leaderstats")
	local player2Stats = trade.Player2:FindFirstChild("leaderstats")
	
	if player1Stats and player2Stats then
		local player1Coins = player1Stats:FindFirstChild("Coins")
		local player2Coins = player2Stats:FindFirstChild("Coins")
		
		if player1Coins and player2Coins then
			-- Apply tax
			local tax1 = math.floor(trade.Player1Items.Coins * GameConfig.Trading.TaxPercentage / 100)
			local tax2 = math.floor(trade.Player2Items.Coins * GameConfig.Trading.TaxPercentage / 100)
			
			player1Coins.Value = player1Coins.Value - trade.Player1Items.Coins + (trade.Player2Items.Coins - tax2)
			player2Coins.Value = player2Coins.Value - trade.Player2Items.Coins + (trade.Player1Items.Coins - tax1)
		end
	end
	
	-- Complete trade
	trade.Status = "Completed"
	ActiveTrades[trade.Id] = nil
	
	-- Notify players
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local tradeRemotes = remotes:WaitForChild("TradeRemotes")
	local tradeCompleted = tradeRemotes:FindFirstChild("TradeCompleted") or Instance.new("RemoteEvent")
	tradeCompleted.Name = "TradeCompleted"
	tradeCompleted.Parent = tradeRemotes
	
	tradeCompleted:FireClient(trade.Player1, {Success = true})
	tradeCompleted:FireClient(trade.Player2, {Success = true})
	
	print("✅ Trade completed between", trade.Player1.Name, "and", trade.Player2.Name)
end

function TradingService:CancelTrade(player)
	local trade = self:GetPlayerActiveTrade(player)
	if not trade then return false end
	
	-- Cancel trade
	trade.Status = "Cancelled"
	ActiveTrades[trade.Id] = nil
	
	-- Notify both players
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local tradeRemotes = remotes:WaitForChild("TradeRemotes")
	local tradeCancelled = tradeRemotes:FindFirstChild("TradeCancelled") or Instance.new("RemoteEvent")
	tradeCancelled.Name = "TradeCancelled"
	tradeCancelled.Parent = tradeRemotes
	
	tradeCancelled:FireClient(trade.Player1, {CancelledBy = player.Name})
	if trade.Player2 then
		tradeCancelled:FireClient(trade.Player2, {CancelledBy = player.Name})
	end
	
	return true
end

function TradingService:GetPlayerActiveTrade(player)
	for _, trade in pairs(ActiveTrades) do
		if trade.Player1 == player or trade.Player2 == player then
			return trade
		end
	end
	return nil
end

function TradingService:UpdateTradeUI(trade)
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local tradeRemotes = remotes:WaitForChild("TradeRemotes")
	local tradeUpdated = tradeRemotes:FindFirstChild("TradeUpdated") or Instance.new("RemoteEvent")
	tradeUpdated.Name = "TradeUpdated"
	tradeUpdated.Parent = tradeRemotes
	
	local tradeData = {
		Player1Items = trade.Player1Items,
		Player2Items = trade.Player2Items,
		Player1Confirmed = trade.Player1Confirmed,
		Player2Confirmed = trade.Player2Confirmed
	}
	
	tradeUpdated:FireClient(trade.Player1, tradeData)
	if trade.Player2 then
		tradeUpdated:FireClient(trade.Player2, tradeData)
	end
end

return TradingService