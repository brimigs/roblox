local PetService = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local PetAI = require(script.Parent.Parent.Modules.PetAI)
local PetData = require(ReplicatedStorage.Shared.Modules.PetData)
local GameConfig = require(ReplicatedStorage.Shared.Modules.GameConfig)

-- Store active pets
local ActivePets = {}
local PlayerPetData = {}

function PetService:Initialize()
	-- Create remotes
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local petRemotes = remotes:WaitForChild("PetRemotes")
	
	-- Create remote events
	local spawnPet = Instance.new("RemoteEvent")
	spawnPet.Name = "SpawnPet"
	spawnPet.Parent = petRemotes
	
	local despawnPet = Instance.new("RemoteEvent")
	despawnPet.Name = "DespawnPet"
	despawnPet.Parent = petRemotes
	
	local feedPet = Instance.new("RemoteEvent")
	feedPet.Name = "FeedPet"
	feedPet.Parent = petRemotes
	
	local petInteract = Instance.new("RemoteEvent")
	petInteract.Name = "PetInteract"
	petInteract.Parent = petRemotes
	
	local renamePet = Instance.new("RemoteEvent")
	renamePet.Name = "RenamePet"
	renamePet.Parent = petRemotes
	
	local getPetStats = Instance.new("RemoteFunction")
	getPetStats.Name = "GetPetStats"
	getPetStats.Parent = petRemotes
	
	-- Connect remote events
	spawnPet.OnServerEvent:Connect(function(player, petId)
		self:SpawnPet(player, petId)
	end)
	
	despawnPet.OnServerEvent:Connect(function(player, petId)
		self:DespawnPet(player, petId)
	end)
	
	feedPet.OnServerEvent:Connect(function(player, petId)
		self:FeedPet(player, petId)
	end)
	
	petInteract.OnServerEvent:Connect(function(player, petId, interactionType)
		self:InteractWithPet(player, petId, interactionType)
	end)
	
	renamePet.OnServerEvent:Connect(function(player, petId, newName)
		self:RenamePet(player, petId, newName)
	end)
	
	getPetStats.OnServerInvoke = function(player, petId)
		return self:GetPetStats(player, petId)
	end
end

function PetService:GivePet(player, petName, customData)
	if not PlayerPetData[player] then
		PlayerPetData[player] = {
			OwnedPets = {},
			ActivePets = {}
		}
	end
	
	local petInfo = PetData.Pets[petName]
	if not petInfo then
		warn("Pet not found:", petName)
		return false
	end
	
	-- Create pet data
	local petId = tostring(player.UserId) .. "_" .. tostring(tick())
	local newPet = {
		Id = petId,
		Name = customData and customData.Name or petInfo.Name,
		PetType = petName,
		Rarity = petInfo.Rarity,
		Level = 1,
		Experience = 0,
		Personality = customData and customData.Personality or self:GetRandomPersonality(),
		Stats = {
			Happiness = 100,
			Energy = 100,
			Hunger = 100,
			Bond = 0
		},
		DateObtained = os.time(),
		Equipped = false
	}
	
	-- Add to player's pet collection
	table.insert(PlayerPetData[player].OwnedPets, newPet)
	
	-- Update leaderstats
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local petsValue = leaderstats:FindFirstChild("Pets")
		if petsValue then
			petsValue.Value = #PlayerPetData[player].OwnedPets
		end
	end
	
	-- Fire event to client
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local petRemotes = remotes:WaitForChild("PetRemotes")
	local petObtained = petRemotes:FindFirstChild("PetObtained") or Instance.new("RemoteEvent")
	petObtained.Name = "PetObtained"
	petObtained.Parent = petRemotes
	petObtained:FireClient(player, newPet)
	
	return true, newPet
end

function PetService:SpawnPet(player, petId)
	if not PlayerPetData[player] then return false end
	
	-- Check if player has reached max active pets
	if #PlayerPetData[player].ActivePets >= GameConfig.MaxActivePets then
		warn("Player has reached max active pets")
		return false
	end
	
	-- Find pet in owned pets
	local petData = nil
	for _, pet in ipairs(PlayerPetData[player].OwnedPets) do
		if pet.Id == petId then
			petData = pet
			break
		end
	end
	
	if not petData then
		warn("Pet not found in player's collection:", petId)
		return false
	end
	
	-- Check if pet is already spawned
	if ActivePets[petId] then
		warn("Pet is already spawned:", petId)
		return false
	end
	
	-- Create pet model
	local petModel = self:CreatePetModel(petData)
	if not petModel then return false end
	
	-- Position pet near player
	local character = player.Character
	if character then
		local humanoidRoot = character:FindFirstChild("HumanoidRootPart")
		if humanoidRoot then
			petModel:SetPrimaryPartCFrame(
				humanoidRoot.CFrame * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
			)
		end
	end
	
	petModel.Parent = workspace
	
	-- Create AI controller
	local petInfo = PetData.Pets[petData.PetType]
	if petInfo then
		local aiController = PetAI.new(petModel, player, {
			Name = petData.Name,
			Personality = petData.Personality,
			BaseStats = petInfo.BaseStats,
			Abilities = petInfo.Abilities
		})
		
		-- Store reference
		ActivePets[petId] = {
			Model = petModel,
			AI = aiController,
			Owner = player,
			Data = petData
		}
		
		-- Add to active pets list
		table.insert(PlayerPetData[player].ActivePets, petId)
		petData.Equipped = true
	end
	
	return true
end

function PetService:DespawnPet(player, petId)
	local activePet = ActivePets[petId]
	if not activePet or activePet.Owner ~= player then
		warn("Pet not found or not owned by player")
		return false
	end
	
	-- Cleanup AI
	if activePet.AI then
		activePet.AI:Cleanup()
	end
	
	-- Remove model
	if activePet.Model then
		activePet.Model:Destroy()
	end
	
	-- Update data
	activePet.Data.Equipped = false
	
	-- Remove from active pets
	ActivePets[petId] = nil
	
	if PlayerPetData[player] then
		for i, id in ipairs(PlayerPetData[player].ActivePets) do
			if id == petId then
				table.remove(PlayerPetData[player].ActivePets, i)
				break
			end
		end
	end
	
	return true
end

function PetService:SpawnPlayerPets(player)
	if not PlayerPetData[player] then return end
	
	-- Spawn equipped pets
	for _, pet in ipairs(PlayerPetData[player].OwnedPets) do
		if pet.Equipped and #PlayerPetData[player].ActivePets < GameConfig.MaxActivePets then
			self:SpawnPet(player, pet.Id)
		end
	end
end

function PetService:RemovePlayerPets(player)
	if not PlayerPetData[player] then return end
	
	-- Despawn all active pets
	for _, petId in ipairs(PlayerPetData[player].ActivePets) do
		self:DespawnPet(player, petId)
	end
	
	-- Clear player data
	PlayerPetData[player] = nil
end

function PetService:FeedPet(player, petId)
	local activePet = ActivePets[petId]
	if not activePet or activePet.Owner ~= player then
		return false
	end
	
	-- Check if player has food (simplified for now)
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coins = leaderstats:FindFirstChild("Coins")
		if coins and coins.Value >= 10 then
			coins.Value = coins.Value - 10
			
			-- Feed the pet
			if activePet.AI then
				activePet.AI:Feed({NutritionValue = 30})
			end
			
			-- Update pet data
			activePet.Data.Stats.Hunger = math.min(100, activePet.Data.Stats.Hunger + 30)
			
			return true
		end
	end
	
	return false
end

function PetService:InteractWithPet(player, petId, interactionType)
	local activePet = ActivePets[petId]
	if not activePet then
		return false
	end
	
	-- Allow interaction with any pet, but give bonus for own pets
	local isOwner = activePet.Owner == player
	
	if activePet.AI then
		if interactionType == "Pet" then
			activePet.AI:Pet()
			if isOwner then
				activePet.Data.Stats.Happiness = math.min(100, activePet.Data.Stats.Happiness + 5)
				activePet.Data.Stats.Bond = math.min(100, activePet.Data.Stats.Bond + 1)
			end
		elseif interactionType == "Play" then
			activePet.AI:Play()
			if isOwner then
				activePet.Data.Stats.Happiness = math.min(100, activePet.Data.Stats.Happiness + 10)
				activePet.Data.Stats.Bond = math.min(100, activePet.Data.Stats.Bond + 2)
			end
		end
	end
	
	return true
end

function PetService:RenamePet(player, petId, newName)
	if not PlayerPetData[player] then return false end
	
	-- Validate name
	if type(newName) ~= "string" or #newName < 1 or #newName > 20 then
		return false
	end
	
	-- Find and rename pet
	for _, pet in ipairs(PlayerPetData[player].OwnedPets) do
		if pet.Id == petId then
			pet.Name = newName
			
			-- Update active pet if spawned
			local activePet = ActivePets[petId]
			if activePet and activePet.Model then
				local nameTag = activePet.Model:FindFirstChild("NameTag")
				if nameTag then
					local gui = nameTag:FindFirstChild("NameGui")
					if gui then
						local label = gui:FindFirstChild("NameLabel")
						if label then
							label.Text = newName
						end
					end
				end
			end
			
			return true
		end
	end
	
	return false
end

function PetService:GetPetStats(player, petId)
	local activePet = ActivePets[petId]
	if activePet and activePet.AI then
		return activePet.AI.Stats
	end
	
	-- Return stored stats if pet is not active
	if PlayerPetData[player] then
		for _, pet in ipairs(PlayerPetData[player].OwnedPets) do
			if pet.Id == petId then
				return pet.Stats
			end
		end
	end
	
	return nil
end

function PetService:GetPlayerPets(player)
	if not PlayerPetData[player] then
		PlayerPetData[player] = {
			OwnedPets = {},
			ActivePets = {}
		}
	end
	
	return PlayerPetData[player].OwnedPets
end

function PetService:CreatePetModel(petData)
	-- Create a simple pet model (in production, you'd load actual models)
	local model = Instance.new("Model")
	model.Name = petData.Name
	
	-- Body
	local body = Instance.new("Part")
	body.Name = "HumanoidRootPart"
	body.Size = Vector3.new(2, 2, 3)
	body.Material = Enum.Material.Neon
	body.TopSurface = Enum.SurfaceType.Smooth
	body.BottomSurface = Enum.SurfaceType.Smooth
	
	-- Set color based on rarity
	local rarityData = PetData.Rarities[petData.Rarity]
	if rarityData then
		body.Color = rarityData.Color
	else
		body.Color = Color3.new(1, 1, 1)
	end
	
	body.Parent = model
	model.PrimaryPart = body
	
	-- Head
	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(1.5, 1.5, 1.5)
	head.Material = Enum.Material.Neon
	head.Color = body.Color
	head.TopSurface = Enum.SurfaceType.Smooth
	head.BottomSurface = Enum.SurfaceType.Smooth
	head.Parent = model
	
	-- Weld head to body
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = body
	weld.Part1 = head
	weld.Parent = body
	head.CFrame = body.CFrame * CFrame.new(0, 1.5, -1)
	
	-- Add humanoid for movement
	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = 100
	humanoid.Health = 100
	humanoid.WalkSpeed = PetData.Pets[petData.PetType].BaseStats.Speed or 16
	humanoid.JumpPower = PetData.Pets[petData.PetType].BaseStats.Jump or 50
	humanoid.Parent = model
	
	-- Name tag
	local nameTag = Instance.new("Part")
	nameTag.Name = "NameTag"
	nameTag.Size = Vector3.new(0.2, 0.2, 0.2)
	nameTag.Transparency = 1
	nameTag.CanCollide = false
	nameTag.Parent = model
	
	local nameWeld = Instance.new("WeldConstraint")
	nameWeld.Part0 = head
	nameWeld.Part1 = nameTag
	nameWeld.Parent = head
	nameTag.CFrame = head.CFrame * CFrame.new(0, 2, 0)
	
	-- Billboard GUI for name
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "NameGui"
	billboardGui.Size = UDim2.new(4, 0, 1, 0)
	billboardGui.StudsOffset = Vector3.new(0, 2, 0)
	billboardGui.Parent = nameTag
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.Text = petData.Name
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Parent = billboardGui
	
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "RarityLabel"
	rarityLabel.Size = UDim2.new(1, 0, 0.5, 0)
	rarityLabel.Position = UDim2.new(0, 0, 0.5, 0)
	rarityLabel.Text = "[" .. petData.Rarity .. "]"
	rarityLabel.TextScaled = true
	rarityLabel.Font = Enum.Font.SourceSans
	rarityLabel.TextColor3 = rarityData and rarityData.Color or Color3.new(1, 1, 1)
	rarityLabel.BackgroundTransparency = 1
	rarityLabel.Parent = billboardGui
	
	-- Add particle effects based on rarity
	if petData.Rarity == "Epic" or petData.Rarity == "Legendary" or petData.Rarity == "Mythical" then
		local attachment = Instance.new("Attachment")
		attachment.Parent = body
		
		local particle = Instance.new("ParticleEmitter")
		particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particle.Rate = 10
		particle.Lifetime = NumberRange.new(1, 2)
		particle.SpreadAngle = Vector2.new(360, 360)
		particle.VelocityInheritance = 0.5
		particle.Speed = NumberRange.new(2)
		particle.Parent = attachment
		
		if petData.Rarity == "Legendary" then
			particle.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
			particle.Rate = 20
		elseif petData.Rarity == "Mythical" then
			particle.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
			})
			particle.Rate = 30
		end
	end
	
	-- Create animations folder
	local animFolder = Instance.new("Folder")
	animFolder.Name = "Animations"
	animFolder.Parent = model
	
	-- Add basic animations (these would be actual animation assets in production)
	local animNames = {"Idle", "Walk", "Run", "Jump", "Sleep", "Eat", "Play", "Wave", "Spin", "Dance", "Interact"}
	for _, animName in ipairs(animNames) do
		local anim = Instance.new("Animation")
		anim.Name = animName
		anim.AnimationId = "rbxassetid://0" -- Placeholder
		anim.Parent = animFolder
	end
	
	return model
end

function PetService:GetRandomPersonality()
	local personalities = {}
	for name, _ in pairs(PetData.Personalities) do
		table.insert(personalities, name)
	end
	
	return personalities[math.random(1, #personalities)]
end

function PetService:GetPlayerData(player)
	return PlayerPetData[player]
end

function PetService:SetPlayerData(player, data)
	PlayerPetData[player] = data
end

return PetService