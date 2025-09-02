local ShopService = {}

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetService = require(script.Parent.PetService)
local DataService = require(script.Parent.DataService)
local GameConfig = require(ReplicatedStorage.Shared.Data.GameConfig)
local PetData = require(ReplicatedStorage.Shared.Data.PetData)

function ShopService:Initialize()
	-- Create remotes
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local shopRemotes = remotes:WaitForChild("ShopRemotes")
	
	-- Create remote events
	local buyEgg = Instance.new("RemoteEvent")
	buyEgg.Name = "BuyEgg"
	buyEgg.Parent = shopRemotes
	
	local buyItem = Instance.new("RemoteEvent")
	buyItem.Name = "BuyItem"
	buyItem.Parent = shopRemotes
	
	local openEgg = Instance.new("RemoteEvent")
	openEgg.Name = "OpenEgg"
	openEgg.Parent = shopRemotes
	
	-- Connect events
	buyEgg.OnServerEvent:Connect(function(player, eggType)
		self:BuyEgg(player, eggType)
	end)
	
	buyItem.OnServerEvent:Connect(function(player, itemType, itemName)
		self:BuyItem(player, itemType, itemName)
	end)
	
	openEgg.OnServerEvent:Connect(function(player, eggType)
		self:OpenEgg(player, eggType)
	end)
	
	-- Setup product purchases
	self:SetupProductPurchases()
end

function ShopService:SetupProductPurchases()
	-- Handle Robux purchases
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		-- Find product in config
		for productName, productData in pairs(GameConfig.Products) do
			if productData.ProductId == receiptInfo.ProductId then
				-- Process based on product type
				if productData.Coins then
					-- Give coins
					local leaderstats = player:FindFirstChild("leaderstats")
					if leaderstats then
						local coins = leaderstats:FindFirstChild("Coins")
						if coins then
							coins.Value = coins.Value + productData.Coins
							
							-- Save data
							DataService:UpdatePlayerData(player, "Coins", coins.Value)
							
							print("💰 Gave", productData.Coins, "coins to", player.Name)
						end
					end
				elseif productData.EggType then
					-- Give egg
					self:GiveEgg(player, productData.EggType)
				end
				
				return Enum.ProductPurchaseDecision.PurchaseGranted
			end
		end
		
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
	-- Handle game pass purchases
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
		if not wasPurchased then return end
		
		-- Find pass in config
		for passName, passData in pairs(GameConfig.GamePasses) do
			if passData.PassId == passId then
				-- Grant game pass benefits
				DataService:GrantGamePass(player, passName)
				
				-- Apply immediate benefits
				self:ApplyGamePassBenefits(player, passName)
				
				print("🎫 Game pass purchased:", passName, "by", player.Name)
				break
			end
		end
	end)
end

function ShopService:BuyEgg(player, eggType)
	local eggData = GameConfig.Eggs[eggType]
	if not eggData then
		warn("Invalid egg type:", eggType)
		return false
	end
	
	-- Check if using Robux or coins
	if eggData.RobuxPrice then
		-- Prompt Robux purchase
		-- This would be handled by ProcessReceipt
		return false
	else
		-- Check coins
		local leaderstats = player:FindFirstChild("leaderstats")
		if not leaderstats then return false end
		
		local coins = leaderstats:FindFirstChild("Coins")
		if not coins or coins.Value < eggData.Price then
			-- Not enough coins
			return false
		end
		
		-- Deduct coins
		coins.Value = coins.Value - eggData.Price
		
		-- Open egg immediately
		return self:OpenEgg(player, eggType)
	end
end

function ShopService:OpenEgg(player, eggType)
	local eggData = GameConfig.Eggs[eggType]
	if not eggData then
		warn("Invalid egg type:", eggType)
		return false
	end
	
	-- Calculate which pet to give
	local petToGive = self:CalculateEggResult(eggData)
	
	if petToGive then
		-- Give pet to player
		local success, petData = PetService:GivePet(player, petToGive, {
			FromEgg = eggType,
			Personality = PetService:GetRandomPersonality()
		})
		
		if success then
			-- Fire event to client for egg opening animation
			local remotes = ReplicatedStorage:WaitForChild("Remotes")
			local shopRemotes = remotes:WaitForChild("ShopRemotes")
			local eggOpened = shopRemotes:FindFirstChild("EggOpened") or Instance.new("RemoteEvent")
			eggOpened.Name = "EggOpened"
			eggOpened.Parent = shopRemotes
			
			eggOpened:FireClient(player, {
				EggType = eggType,
				PetReceived = petData
			})
			
			print("🥚 Egg opened:", eggType, "- Got:", petToGive)
			return true
		end
	end
	
	return false
end

function ShopService:CalculateEggResult(eggData)
	if not eggData.Pets or not eggData.Chances then
		return nil
	end
	
	-- Calculate total chance
	local totalChance = 0
	for _, chance in ipairs(eggData.Chances) do
		totalChance = totalChance + chance
	end
	
	-- Roll random number
	local roll = math.random() * totalChance
	
	-- Determine which pet
	local currentChance = 0
	for i, petName in ipairs(eggData.Pets) do
		currentChance = currentChance + eggData.Chances[i]
		if roll <= currentChance then
			return petName
		end
	end
	
	-- Fallback to first pet
	return eggData.Pets[1]
end

function ShopService:GiveEgg(player, eggType)
	-- Store egg in inventory (simplified - just open immediately)
	return self:OpenEgg(player, eggType)
end

function ShopService:BuyItem(player, itemType, itemName)
	-- Handle other shop items (accessories, etc.)
	-- This would be expanded based on game needs
end

function ShopService:ApplyGamePassBenefits(player, passName)
	local passData = GameConfig.GamePasses[passName]
	if not passData then return end
	
	if passName == "VIP" then
		-- Grant VIP benefits
		-- Add VIP tag, access to VIP zone, etc.
		local character = player.Character
		if character then
			-- Add VIP tag above head
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				humanoid.DisplayName = "[VIP] " .. player.Name
			end
		end
		
	elseif passName == "DoubleCoins" then
		-- This would be checked when giving coins
		
	elseif passName == "ExtraPetSlots" then
		-- Increase max pets
		-- This would be checked in PetService
		
	elseif passName == "AutoFeed" then
		-- Enable auto feeding for pets
		-- This would be handled in pet AI
		
	end
	
	-- Notify player
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local shopRemotes = remotes:WaitForChild("ShopRemotes")
	local passGranted = shopRemotes:FindFirstChild("GamePassGranted") or Instance.new("RemoteEvent")
	passGranted.Name = "GamePassGranted"
	passGranted.Parent = shopRemotes
	
	passGranted:FireClient(player, passName, passData)
end

function ShopService:HasGamePass(player, passName)
	-- Check if player owns game pass
	local passData = GameConfig.GamePasses[passName]
	if not passData or not passData.PassId then
		return false
	end
	
	local hasPass = false
	local success, result = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passData.PassId)
	end)
	
	if success then
		hasPass = result
	end
	
	-- Also check data store cache
	if not hasPass then
		hasPass = DataService:HasGamePass(player, passName)
	end
	
	return hasPass
end

return ShopService