local MapService = {}

local workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

function MapService:Initialize()
	self:CreateMap()
	self:SetupLighting()
	self:CreateSpawnPoints()
end

function MapService:CreateMap()
	local map = workspace:FindFirstChild("Map") or Instance.new("Folder")
	map.Name = "Map"
	map.Parent = workspace
	
	-- Create base terrain
	self:CreateBaseTerrain()
	
	-- Create different zones
	self:CreateSpawnArea(map)
	self:CreatePetPark(map)
	self:CreateShopArea(map)
	self:CreateVIPZone(map)
	self:CreatePlaygroundArea(map)
end

function MapService:CreateBaseTerrain()
	local terrain = workspace.Terrain
	
	-- Create a simple grass base (simplified for now)
	-- In production, you'd use more complex terrain generation
	local region = Region3.new(Vector3.new(-500, -10, -500), Vector3.new(500, 0, 500))
	region = region:ExpandToGrid(4)
	
	terrain:FillBlock(
		CFrame.new(0, -5, 0),
		Vector3.new(1000, 10, 1000),
		Enum.Material.Grass
	)
end

function MapService:CreateSpawnArea(parent)
	local spawnArea = Instance.new("Folder")
	spawnArea.Name = "SpawnArea"
	spawnArea.Parent = parent
	
	-- Main spawn platform
	local spawnPlatform = Instance.new("Part")
	spawnPlatform.Name = "SpawnPlatform"
	spawnPlatform.Size = Vector3.new(50, 1, 50)
	spawnPlatform.Position = Vector3.new(0, 0.5, 0)
	spawnPlatform.Material = Enum.Material.Marble
	spawnPlatform.BrickColor = BrickColor.new("Pearl")
	spawnPlatform.TopSurface = Enum.SurfaceType.Smooth
	spawnPlatform.BottomSurface = Enum.SurfaceType.Smooth
	spawnPlatform.Anchored = true
	spawnPlatform.Parent = spawnArea
	
	-- Decorative fountain in center
	local fountain = Instance.new("Part")
	fountain.Name = "Fountain"
	fountain.Shape = Enum.PartType.Cylinder
	fountain.Size = Vector3.new(3, 10, 10)
	fountain.Position = Vector3.new(0, 1.5, 0)
	fountain.Material = Enum.Material.Marble
	fountain.BrickColor = BrickColor.new("Light blue")
	fountain.Anchored = true
	fountain.Parent = spawnArea
	
	-- Welcome sign
	self:CreateSign(Vector3.new(0, 5, -20), "Welcome to AI Pet Paradise!", spawnArea)
	
	-- Spawn points
	for i = 1, 8 do
		local angle = (i - 1) * (math.pi * 2 / 8)
		local spawnPoint = Instance.new("SpawnLocation")
		spawnPoint.Size = Vector3.new(4, 1, 4)
		spawnPoint.Position = Vector3.new(
			math.cos(angle) * 20,
			1,
			math.sin(angle) * 20
		)
		spawnPoint.Material = Enum.Material.Neon
		spawnPoint.BrickColor = BrickColor.new("Lime green")
		spawnPoint.TopSurface = Enum.SurfaceType.Smooth
		spawnPoint.Anchored = true
		spawnPoint.Parent = spawnArea
	end
end

function MapService:CreatePetPark(parent)
	local petPark = Instance.new("Folder")
	petPark.Name = "PetPark"
	petPark.Parent = parent
	
	-- Park base
	local parkFloor = Instance.new("Part")
	parkFloor.Name = "ParkFloor"
	parkFloor.Size = Vector3.new(100, 1, 100)
	parkFloor.Position = Vector3.new(100, 0.5, 0)
	parkFloor.Material = Enum.Material.Grass
	parkFloor.BrickColor = BrickColor.new("Bright green")
	parkFloor.TopSurface = Enum.SurfaceType.Smooth
	parkFloor.Anchored = true
	parkFloor.Parent = petPark
	
	-- Pet playground equipment
	self:CreatePlayEquipment(Vector3.new(100, 1, 0), petPark)
	
	-- Trees for decoration
	for i = 1, 10 do
		self:CreateTree(
			Vector3.new(
				50 + math.random() * 100,
				0,
				-50 + math.random() * 100
			),
			petPark
		)
	end
	
	-- Pet feeding area
	local feedingArea = Instance.new("Part")
	feedingArea.Name = "FeedingArea"
	feedingArea.Size = Vector3.new(20, 0.5, 20)
	feedingArea.Position = Vector3.new(120, 1, 20)
	feedingArea.Material = Enum.Material.WoodPlanks
	feedingArea.BrickColor = BrickColor.new("Brown")
	feedingArea.Anchored = true
	feedingArea.Parent = petPark
	
	-- Benches for players
	for i = 1, 4 do
		local bench = self:CreateBench(
			Vector3.new(80 + i * 10, 1, -20),
			petPark
		)
	end
end

function MapService:CreateShopArea(parent)
	local shopArea = Instance.new("Folder")
	shopArea.Name = "ShopArea"
	shopArea.Parent = parent
	
	-- Shop building
	local shopBuilding = Instance.new("Model")
	shopBuilding.Name = "PetShop"
	shopBuilding.Parent = shopArea
	
	-- Shop floor
	local shopFloor = Instance.new("Part")
	shopFloor.Name = "Floor"
	shopFloor.Size = Vector3.new(40, 1, 40)
	shopFloor.Position = Vector3.new(-100, 0.5, 0)
	shopFloor.Material = Enum.Material.Wood
	shopFloor.BrickColor = BrickColor.new("Dark orange")
	shopFloor.Anchored = true
	shopFloor.Parent = shopBuilding
	
	-- Shop walls
	local wallPositions = {
		{Vector3.new(-120, 10, 0), Vector3.new(1, 20, 40)}, -- Left wall
		{Vector3.new(-80, 10, 0), Vector3.new(1, 20, 40)}, -- Right wall
		{Vector3.new(-100, 10, 20), Vector3.new(40, 20, 1)}, -- Back wall
		{Vector3.new(-100, 10, -20), Vector3.new(40, 20, 1)} -- Front wall with door
	}
	
	for i, wallData in ipairs(wallPositions) do
		local wall = Instance.new("Part")
		wall.Name = "Wall" .. i
		wall.Size = wallData[2]
		wall.Position = wallData[1]
		wall.Material = Enum.Material.Brick
		wall.BrickColor = BrickColor.new("Sand red")
		wall.Anchored = true
		wall.Parent = shopBuilding
		
		-- Add door to front wall
		if i == 4 then
			local door = Instance.new("Part")
			door.Name = "Door"
			door.Size = Vector3.new(8, 12, 1)
			door.Position = Vector3.new(-100, 6, -20)
			door.Material = Enum.Material.Glass
			door.Transparency = 0.5
			door.BrickColor = BrickColor.new("Light blue")
			door.Anchored = true
			door.CanCollide = false
			door.Parent = shopBuilding
		end
	end
	
	-- Shop roof
	local roof = Instance.new("Part")
	roof.Name = "Roof"
	roof.Size = Vector3.new(42, 2, 42)
	roof.Position = Vector3.new(-100, 21, 0)
	roof.Material = Enum.Material.Slate
	roof.BrickColor = BrickColor.new("Dark grey")
	roof.Anchored = true
	roof.Parent = shopBuilding
	
	-- Shop sign
	self:CreateSign(Vector3.new(-100, 15, -21), "Pet Shop", shopArea)
	
	-- Egg pedestals inside shop
	local eggPositions = {
		{-110, 2, -10, "Basic"},
		{-105, 2, -10, "Rare"},
		{-100, 2, -10, "Epic"},
		{-95, 2, -10, "Legendary"},
		{-90, 2, -10, "Mythical"}
	}
	
	for _, eggData in ipairs(eggPositions) do
		self:CreateEggPedestal(
			Vector3.new(eggData[1], eggData[2], eggData[3]),
			eggData[4],
			shopArea
		)
	end
end

function MapService:CreateVIPZone(parent)
	local vipZone = Instance.new("Folder")
	vipZone.Name = "VIPZone"
	vipZone.Parent = parent
	
	-- VIP platform
	local vipPlatform = Instance.new("Part")
	vipPlatform.Name = "VIPPlatform"
	vipPlatform.Size = Vector3.new(60, 2, 60)
	vipPlatform.Position = Vector3.new(0, 50, 100)
	vipPlatform.Material = Enum.Material.Marble
	vipPlatform.BrickColor = BrickColor.new("Gold")
	vipPlatform.Anchored = true
	vipPlatform.Parent = vipZone
	
	-- VIP fence
	local fencePositions = {
		{Vector3.new(-30, 52, 100), Vector3.new(1, 4, 60)},
		{Vector3.new(30, 52, 100), Vector3.new(1, 4, 60)},
		{Vector3.new(0, 52, 70), Vector3.new(60, 4, 1)},
		{Vector3.new(0, 52, 130), Vector3.new(60, 4, 1)}
	}
	
	for _, fenceData in ipairs(fencePositions) do
		local fence = Instance.new("Part")
		fence.Name = "Fence"
		fence.Size = fenceData[2]
		fence.Position = fenceData[1]
		fence.Material = Enum.Material.Metal
		fence.BrickColor = BrickColor.new("Gold")
		fence.Transparency = 0.5
		fence.Anchored = true
		fence.Parent = vipZone
	end
	
	-- VIP teleporter
	local teleporter = Instance.new("Part")
	teleporter.Name = "VIPTeleporter"
	teleporter.Shape = Enum.PartType.Cylinder
	teleporter.Size = Vector3.new(2, 8, 8)
	teleporter.Position = Vector3.new(0, 1, 50)
	teleporter.Material = Enum.Material.Neon
	teleporter.BrickColor = BrickColor.new("Gold")
	teleporter.Anchored = true
	teleporter.Parent = vipZone
	
	-- VIP sign
	self:CreateSign(Vector3.new(0, 8, 45), "VIP Zone", vipZone)
	
	-- Exclusive VIP features
	self:CreateVIPFeatures(vipZone)
end

function MapService:CreatePlaygroundArea(parent)
	local playground = Instance.new("Folder")
	playground.Name = "Playground"
	playground.Parent = parent
	
	-- Agility course for pets
	local obstacles = {
		{Vector3.new(0, 2, -100), "JumpHoop"},
		{Vector3.new(10, 1, -100), "Tunnel"},
		{Vector3.new(20, 3, -100), "Ramp"},
		{Vector3.new(30, 2, -100), "Weave"},
		{Vector3.new(40, 4, -100), "HighJump"}
	}
	
	for _, obstacleData in ipairs(obstacles) do
		self:CreateObstacle(obstacleData[1], obstacleData[2], playground)
	end
end

function MapService:CreateTree(position, parent)
	local tree = Instance.new("Model")
	tree.Name = "Tree"
	tree.Parent = parent
	
	-- Trunk
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = Vector3.new(2, 8, 2)
	trunk.Position = position + Vector3.new(0, 4, 0)
	trunk.Material = Enum.Material.Wood
	trunk.BrickColor = BrickColor.new("Brown")
	trunk.Anchored = true
	trunk.Parent = tree
	
	-- Leaves
	local leaves = Instance.new("Part")
	leaves.Name = "Leaves"
	leaves.Shape = Enum.PartType.Ball
	leaves.Size = Vector3.new(10, 10, 10)
	leaves.Position = position + Vector3.new(0, 10, 0)
	leaves.Material = Enum.Material.Grass
	leaves.BrickColor = BrickColor.new("Bright green")
	leaves.Anchored = true
	leaves.Parent = tree
end

function MapService:CreateBench(position, parent)
	local bench = Instance.new("Model")
	bench.Name = "Bench"
	bench.Parent = parent
	
	-- Seat
	local seat = Instance.new("Seat")
	seat.Size = Vector3.new(6, 0.5, 2)
	seat.Position = position + Vector3.new(0, 1.5, 0)
	seat.Material = Enum.Material.Wood
	seat.BrickColor = BrickColor.new("Dark orange")
	seat.Anchored = true
	seat.Parent = bench
	
	-- Back
	local back = Instance.new("Part")
	back.Size = Vector3.new(6, 3, 0.5)
	back.Position = position + Vector3.new(0, 3, -0.75)
	back.Material = Enum.Material.Wood
	back.BrickColor = BrickColor.new("Dark orange")
	back.Anchored = true
	back.Parent = bench
	
	return bench
end

function MapService:CreateSign(position, text, parent)
	local sign = Instance.new("Model")
	sign.Name = "Sign"
	sign.Parent = parent
	
	-- Sign board
	local board = Instance.new("Part")
	board.Name = "Board"
	board.Size = Vector3.new(10, 4, 0.5)
	board.Position = position
	board.Material = Enum.Material.Wood
	board.BrickColor = BrickColor.new("Dark orange")
	board.Anchored = true
	board.Parent = sign
	
	-- Text label
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.Parent = board
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = text
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Parent = surfaceGui
end

function MapService:CreateEggPedestal(position, eggType, parent)
	local pedestal = Instance.new("Model")
	pedestal.Name = eggType .. "EggPedestal"
	pedestal.Parent = parent
	
	-- Base
	local base = Instance.new("Part")
	base.Name = "Base"
	base.Size = Vector3.new(3, 1, 3)
	base.Position = position
	base.Material = Enum.Material.Marble
	base.BrickColor = BrickColor.new("Black")
	base.Anchored = true
	base.Parent = pedestal
	
	-- Egg display
	local egg = Instance.new("Part")
	egg.Name = "Egg"
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(2, 2.5, 2)
	egg.Position = position + Vector3.new(0, 2, 0)
	egg.Material = Enum.Material.Neon
	
	-- Set egg color based on rarity
	local eggColors = {
		Basic = BrickColor.new("White"),
		Rare = BrickColor.new("Lime green"),
		Epic = BrickColor.new("Royal purple"),
		Legendary = BrickColor.new("Gold"),
		Mythical = BrickColor.new("Really red")
	}
	
	egg.BrickColor = eggColors[eggType] or BrickColor.new("White")
	egg.Anchored = true
	egg.Parent = pedestal
	
	-- Interaction part
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 10
	clickDetector.Parent = egg
	
	-- Floating effect
	task.spawn(function()
		local startY = egg.Position.Y
		local time = 0
		while egg and egg.Parent do
			time = time + 0.05
			egg.Position = Vector3.new(
				egg.Position.X,
				startY + math.sin(time) * 0.5,
				egg.Position.Z
			)
			egg.Rotation = Vector3.new(0, time * 20, 0)
			task.wait(0.05)
		end
	end)
	
	return pedestal
end

function MapService:CreatePlayEquipment(position, parent)
	local equipment = Instance.new("Model")
	equipment.Name = "PlayEquipment"
	equipment.Parent = parent
	
	-- Slide
	local slide = Instance.new("Part")
	slide.Name = "Slide"
	slide.Size = Vector3.new(4, 0.5, 15)
	slide.Position = position + Vector3.new(10, 5, 0)
	slide.Orientation = Vector3.new(-30, 0, 0)
	slide.Material = Enum.Material.Plastic
	slide.BrickColor = BrickColor.new("Bright yellow")
	slide.Anchored = true
	slide.Parent = equipment
	
	-- Climbing frame
	local frame = Instance.new("Part")
	frame.Name = "ClimbingFrame"
	frame.Size = Vector3.new(8, 8, 8)
	frame.Position = position + Vector3.new(-10, 4, 0)
	frame.Material = Enum.Material.Wood
	frame.BrickColor = BrickColor.new("Brown")
	frame.Transparency = 0.5
	frame.Anchored = true
	frame.Parent = equipment
	
	-- Seesaw
	local seesaw = Instance.new("Part")
	seesaw.Name = "Seesaw"
	seesaw.Size = Vector3.new(10, 0.5, 2)
	seesaw.Position = position + Vector3.new(0, 2, 10)
	seesaw.Material = Enum.Material.Wood
	seesaw.BrickColor = BrickColor.new("Dark orange")
	seesaw.Anchored = false
	seesaw.Parent = equipment
	
	-- Seesaw pivot
	local pivot = Instance.new("Part")
	pivot.Name = "Pivot"
	pivot.Shape = Enum.PartType.Cylinder
	pivot.Size = Vector3.new(1, 2, 2)
	pivot.Position = position + Vector3.new(0, 1, 10)
	pivot.Material = Enum.Material.Metal
	pivot.BrickColor = BrickColor.new("Medium stone grey")
	pivot.Anchored = true
	pivot.Parent = equipment
	
	-- HingeConstraint for seesaw
	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(0, 0, 0)
	attachment1.Parent = seesaw
	
	local attachment2 = Instance.new("Attachment")
	attachment2.Position = Vector3.new(0, 1, 0)
	attachment2.Parent = pivot
	
	local hinge = Instance.new("HingeConstraint")
	hinge.Attachment0 = attachment1
	hinge.Attachment1 = attachment2
	hinge.Parent = seesaw
end

function MapService:CreateObstacle(position, obstacleType, parent)
	local obstacle = Instance.new("Model")
	obstacle.Name = obstacleType
	obstacle.Parent = parent
	
	if obstacleType == "JumpHoop" then
		local hoop = Instance.new("Part")
		hoop.Name = "Hoop"
		hoop.Shape = Enum.PartType.Cylinder
		hoop.Size = Vector3.new(0.5, 6, 6)
		hoop.Position = position
		hoop.Orientation = Vector3.new(0, 0, 90)
		hoop.Material = Enum.Material.Plastic
		hoop.BrickColor = BrickColor.new("Bright red")
		hoop.Anchored = true
		hoop.Parent = obstacle
		
	elseif obstacleType == "Tunnel" then
		local tunnel = Instance.new("Part")
		tunnel.Name = "Tunnel"
		tunnel.Shape = Enum.PartType.Cylinder
		tunnel.Size = Vector3.new(8, 4, 4)
		tunnel.Position = position
		tunnel.Orientation = Vector3.new(0, 0, 90)
		tunnel.Material = Enum.Material.Concrete
		tunnel.BrickColor = BrickColor.new("Dark grey")
		tunnel.Anchored = true
		tunnel.Parent = obstacle
		
	elseif obstacleType == "Ramp" then
		local ramp = Instance.new("WedgePart")
		ramp.Name = "Ramp"
		ramp.Size = Vector3.new(6, 4, 8)
		ramp.Position = position
		ramp.Material = Enum.Material.Wood
		ramp.BrickColor = BrickColor.new("Brown")
		ramp.Anchored = true
		ramp.Parent = obstacle
		
	elseif obstacleType == "Weave" then
		for i = 1, 5 do
			local pole = Instance.new("Part")
			pole.Name = "Pole" .. i
			pole.Shape = Enum.PartType.Cylinder
			pole.Size = Vector3.new(3, 0.5, 0.5)
			pole.Position = position + Vector3.new(i * 2 - 5, 0, (i % 2 == 0 and 2 or -2))
			pole.Material = Enum.Material.Plastic
			pole.BrickColor = BrickColor.new("Bright orange")
			pole.Anchored = true
			pole.Parent = obstacle
		end
		
	elseif obstacleType == "HighJump" then
		local platform = Instance.new("Part")
		platform.Name = "Platform"
		platform.Size = Vector3.new(4, 0.5, 4)
		platform.Position = position
		platform.Material = Enum.Material.Wood
		platform.BrickColor = BrickColor.new("Dark orange")
		platform.Anchored = true
		platform.Parent = obstacle
	end
	
	return obstacle
end

function MapService:CreateVIPFeatures(parent)
	-- Exclusive VIP pet spawner
	local vipSpawner = Instance.new("Part")
	vipSpawner.Name = "VIPPetSpawner"
	vipSpawner.Size = Vector3.new(5, 5, 5)
	vipSpawner.Position = Vector3.new(0, 52, 100)
	vipSpawner.Material = Enum.Material.ForceField
	vipSpawner.BrickColor = BrickColor.new("Gold")
	vipSpawner.Transparency = 0.5
	vipSpawner.Shape = Enum.PartType.Ball
	vipSpawner.Anchored = true
	vipSpawner.Parent = parent
	
	-- VIP lounge chairs
	for i = 1, 4 do
		local chair = Instance.new("Seat")
		chair.Name = "VIPChair" .. i
		chair.Size = Vector3.new(3, 0.5, 3)
		chair.Position = Vector3.new(-15 + i * 10, 51, 115)
		chair.Material = Enum.Material.Fabric
		chair.BrickColor = BrickColor.new("Royal purple")
		chair.Anchored = true
		chair.Parent = parent
	end
	
	-- VIP chest for daily rewards
	local chest = Instance.new("Part")
	chest.Name = "VIPChest"
	chest.Size = Vector3.new(4, 3, 3)
	chest.Position = Vector3.new(20, 51.5, 100)
	chest.Material = Enum.Material.Wood
	chest.BrickColor = BrickColor.new("Dark orange")
	chest.Anchored = true
	chest.Parent = parent
	
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 10
	clickDetector.Parent = chest
end

function MapService:SetupLighting()
	-- Time of day
	Lighting.ClockTime = 14
	
	-- Atmosphere
	local atmosphere = Lighting:FindFirstChild("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Density = 0.3
	atmosphere.Offset = 0.25
	atmosphere.Color = Color3.fromRGB(199, 199, 199)
	atmosphere.Decay = Color3.fromRGB(106, 112, 125)
	atmosphere.Glare = 0
	atmosphere.Haze = 0
	atmosphere.Parent = Lighting
	
	-- ColorCorrection
	local colorCorrection = Lighting:FindFirstChild("ColorCorrection") or Instance.new("ColorCorrectionEffect")
	colorCorrection.Brightness = 0.05
	colorCorrection.Contrast = 0.1
	colorCorrection.Saturation = 0.2
	colorCorrection.Parent = Lighting
	
	-- Bloom
	local bloom = Lighting:FindFirstChild("Bloom") or Instance.new("BloomEffect")
	bloom.Intensity = 0.5
	bloom.Size = 24
	bloom.Threshold = 0.8
	bloom.Parent = Lighting
	
	-- SunRays
	local sunRays = Lighting:FindFirstChild("SunRays") or Instance.new("SunRaysEffect")
	sunRays.Intensity = 0.25
	sunRays.Spread = 1
	sunRays.Parent = Lighting
end

function MapService:CreateSpawnPoints()
	-- Already created in CreateSpawnArea
	-- This function can be used for additional spawn logic if needed
end

return MapService