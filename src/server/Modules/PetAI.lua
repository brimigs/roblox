local PetAI = {}
PetAI.__index = PetAI

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local PetData = require(game.ReplicatedStorage.Shared.Modules.PetData)

-- AI States
local AIStates = {
	IDLE = "Idle",
	FOLLOWING = "Following",
	PLAYING = "Playing",
	SLEEPING = "Sleeping",
	EATING = "Eating",
	EXPLORING = "Exploring",
	INTERACTING = "Interacting",
	PERFORMING_TRICK = "PerformingTrick"
}

function PetAI.new(petModel, owner, petInfo)
	local self = setmetatable({}, PetAI)
	
	self.Model = petModel
	self.Owner = owner
	self.PetInfo = petInfo
	self.Personality = petInfo.Personality or "Playful"
	
	-- AI State
	self.CurrentState = AIStates.IDLE
	self.StateTimer = 0
	self.LastStateChange = tick()
	
	-- Stats
	self.Stats = {
		Happiness = 100,
		Energy = 100,
		Hunger = 100,
		Bond = 0,
		Experience = 0,
		Level = 1
	}
	
	-- Behavior parameters based on personality
	local personalityData = PetData.Personalities[self.Personality]
	self.BehaviorParams = {
		FollowDistance = 10,
		WanderRadius = 30,
		InteractionRange = 15,
		EnergyDrainRate = 0.1 * (personalityData.EnergyMultiplier or 1),
		HappinessDecayRate = 0.05 * (personalityData.HappinessDecayRate or 1),
		ResponseTime = personalityData.Shy and 2 or 0.5
	}
	
	-- Movement
	self.Humanoid = petModel:WaitForChild("Humanoid")
	self.RootPart = petModel:WaitForChild("HumanoidRootPart")
	self.Path = nil
	self.Waypoints = {}
	self.CurrentWaypointIndex = 1
	
	-- Memory system for AI learning
	self.Memory = {
		FavoriteSpots = {},
		PlayerInteractions = {},
		LastFedTime = tick(),
		LastPlayTime = tick(),
		LastPetTime = tick(),
		KnownPlayers = {}
	}
	
	-- Animation tracks
	self.Animations = {}
	self:LoadAnimations()
	
	-- Start AI
	self:StartAI()
	
	return self
end

function PetAI:LoadAnimations()
	local animFolder = self.Model:FindFirstChild("Animations")
	if animFolder then
		for _, anim in pairs(animFolder:GetChildren()) do
			if anim:IsA("Animation") then
				self.Animations[anim.Name] = self.Humanoid:LoadAnimation(anim)
			end
		end
	end
end

function PetAI:StartAI()
	-- Main AI loop
	self.AIConnection = RunService.Heartbeat:Connect(function(deltaTime)
		self:Update(deltaTime)
	end)
	
	-- Stats decay loop
	self.StatsConnection = task.spawn(function()
		while self.Model and self.Model.Parent do
			self:UpdateStats()
			task.wait(1)
		end
	end)
end

function PetAI:Update(deltaTime)
	if not self.Model or not self.Model.Parent then
		self:Cleanup()
		return
	end
	
	-- Update state timer
	self.StateTimer = self.StateTimer + deltaTime
	
	-- State machine
	if self.CurrentState == AIStates.IDLE then
		self:IdleBehavior()
	elseif self.CurrentState == AIStates.FOLLOWING then
		self:FollowBehavior()
	elseif self.CurrentState == AIStates.PLAYING then
		self:PlayBehavior()
	elseif self.CurrentState == AIStates.SLEEPING then
		self:SleepBehavior()
	elseif self.CurrentState == AIStates.EATING then
		self:EatBehavior()
	elseif self.CurrentState == AIStates.EXPLORING then
		self:ExploreBehavior()
	elseif self.CurrentState == AIStates.INTERACTING then
		self:InteractBehavior()
	end
	
	-- Check for state transitions
	self:EvaluateStateTransition()
end

function PetAI:EvaluateStateTransition()
	local ownerCharacter = self.Owner.Character
	if not ownerCharacter then return end
	
	local ownerRoot = ownerCharacter:FindFirstChild("HumanoidRootPart")
	if not ownerRoot then return end
	
	local distance = (self.RootPart.Position - ownerRoot.Position).Magnitude
	
	-- Priority checks
	if self.Stats.Energy < 20 then
		self:ChangeState(AIStates.SLEEPING)
		return
	elseif self.Stats.Hunger < 30 then
		self:ChangeState(AIStates.EATING)
		return
	end
	
	-- Distance-based transitions
	if distance > self.BehaviorParams.FollowDistance * 2 then
		self:ChangeState(AIStates.FOLLOWING)
	elseif distance < self.BehaviorParams.FollowDistance and self.CurrentState == AIStates.FOLLOWING then
		-- Decide next action based on personality
		local rand = math.random()
		if self.Personality == "Playful" and rand < 0.4 then
			self:ChangeState(AIStates.PLAYING)
		elseif self.Personality == "Curious" and rand < 0.5 then
			self:ChangeState(AIStates.EXPLORING)
		elseif self.Personality == "Lazy" and rand < 0.6 then
			self:ChangeState(AIStates.SLEEPING)
		else
			self:ChangeState(AIStates.IDLE)
		end
	end
	
	-- Check for nearby players to interact with
	if self.CurrentState == AIStates.IDLE or self.CurrentState == AIStates.EXPLORING then
		local nearbyPlayers = self:GetNearbyPlayers(self.BehaviorParams.InteractionRange)
		if #nearbyPlayers > 0 and math.random() < 0.1 then
			self.InteractionTarget = nearbyPlayers[math.random(1, #nearbyPlayers)]
			self:ChangeState(AIStates.INTERACTING)
		end
	end
end

function PetAI:ChangeState(newState)
	if self.CurrentState == newState then return end
	
	-- Exit current state
	self:ExitState(self.CurrentState)
	
	-- Enter new state
	self.CurrentState = newState
	self.StateTimer = 0
	self.LastStateChange = tick()
	
	self:EnterState(newState)
end

function PetAI:EnterState(state)
	if state == AIStates.IDLE then
		self:PlayAnimation("Idle")
	elseif state == AIStates.FOLLOWING then
		self:PlayAnimation("Walk")
	elseif state == AIStates.PLAYING then
		self:PlayAnimation("Play")
		self.PlayTarget = self:GetRandomPlayPosition()
	elseif state == AIStates.SLEEPING then
		self:PlayAnimation("Sleep")
		self.Humanoid.WalkSpeed = 0
	elseif state == AIStates.EATING then
		self:PlayAnimation("Eat")
		self.Humanoid.WalkSpeed = 0
	elseif state == AIStates.EXPLORING then
		self:PlayAnimation("Walk")
		self.ExploreTarget = self:GetRandomExplorePosition()
	elseif state == AIStates.INTERACTING then
		self:PlayAnimation("Interact")
	end
end

function PetAI:ExitState(state)
	if state == AIStates.SLEEPING or state == AIStates.EATING then
		self.Humanoid.WalkSpeed = self.PetInfo.BaseStats.Speed or 16
	end
	
	-- Stop current animation
	for _, track in pairs(self.Animations) do
		if track.IsPlaying then
			track:Stop()
		end
	end
end

function PetAI:IdleBehavior()
	-- Random idle animations and movements
	if self.StateTimer > 3 then
		local rand = math.random()
		if rand < 0.3 then
			self:ChangeState(AIStates.EXPLORING)
		elseif rand < 0.5 then
			-- Do a trick or emote
			self:PerformTrick()
		end
	end
end

function PetAI:FollowBehavior()
	local ownerCharacter = self.Owner.Character
	if not ownerCharacter then return end
	
	local ownerRoot = ownerCharacter:FindFirstChild("HumanoidRootPart")
	if not ownerRoot then return end
	
	local targetPosition = ownerRoot.Position - (ownerRoot.CFrame.LookVector * self.BehaviorParams.FollowDistance)
	
	-- Use pathfinding for complex terrain
	if not self.Path or tick() - (self.LastPathUpdate or 0) > 1 then
		self:ComputePath(targetPosition)
		self.LastPathUpdate = tick()
	end
	
	if self.Path and self.Waypoints and #self.Waypoints > 0 then
		self:FollowPath()
	else
		-- Simple movement if pathfinding fails
		self.Humanoid:MoveTo(targetPosition)
	end
end

function PetAI:PlayBehavior()
	if not self.PlayTarget then
		self.PlayTarget = self:GetRandomPlayPosition()
	end
	
	local distance = (self.RootPart.Position - self.PlayTarget).Magnitude
	
	if distance > 2 then
		self.Humanoid:MoveTo(self.PlayTarget)
		
		-- Jump occasionally while playing
		if math.random() < 0.05 then
			self.Humanoid.Jump = true
		end
	else
		-- Reached play target, get new one or change state
		if self.StateTimer > 5 then
			self:ChangeState(AIStates.IDLE)
		else
			self.PlayTarget = self:GetRandomPlayPosition()
		end
	end
	
	-- Increase happiness while playing
	self.Stats.Happiness = math.min(100, self.Stats.Happiness + 0.1)
end

function PetAI:SleepBehavior()
	-- Restore energy while sleeping
	self.Stats.Energy = math.min(100, self.Stats.Energy + 0.5)
	
	-- Wake up when energy is restored
	if self.Stats.Energy >= 80 then
		self:ChangeState(AIStates.IDLE)
	end
end

function PetAI:EatBehavior()
	-- Restore hunger while eating
	self.Stats.Hunger = math.min(100, self.Stats.Hunger + 1)
	
	-- Finish eating
	if self.Stats.Hunger >= 90 or self.StateTimer > 5 then
		self.Memory.LastFedTime = tick()
		self:ChangeState(AIStates.IDLE)
	end
end

function PetAI:ExploreBehavior()
	if not self.ExploreTarget then
		self.ExploreTarget = self:GetRandomExplorePosition()
	end
	
	local distance = (self.RootPart.Position - self.ExploreTarget).Magnitude
	
	if distance > 3 then
		self.Humanoid:MoveTo(self.ExploreTarget)
	else
		-- Reached exploration target
		if math.random() < 0.3 then
			-- Remember this spot if pet likes it
			table.insert(self.Memory.FavoriteSpots, self.ExploreTarget)
		end
		
		if self.StateTimer > 10 then
			self:ChangeState(AIStates.IDLE)
		else
			self.ExploreTarget = self:GetRandomExplorePosition()
		end
	end
end

function PetAI:InteractBehavior()
	if not self.InteractionTarget or not self.InteractionTarget.Character then
		self:ChangeState(AIStates.IDLE)
		return
	end
	
	local targetRoot = self.InteractionTarget.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then
		self:ChangeState(AIStates.IDLE)
		return
	end
	
	local distance = (self.RootPart.Position - targetRoot.Position).Magnitude
	
	if distance > 5 then
		self.Humanoid:MoveTo(targetRoot.Position)
	else
		-- Face the player
		self.RootPart.CFrame = CFrame.lookAt(self.RootPart.Position, Vector3.new(targetRoot.Position.X, self.RootPart.Position.Y, targetRoot.Position.Z))
		
		-- Perform interaction animation
		if math.random() < 0.1 then
			self:PerformTrick()
		end
		
		-- Remember this interaction
		if not self.Memory.KnownPlayers[self.InteractionTarget.Name] then
			self.Memory.KnownPlayers[self.InteractionTarget.Name] = {
				FirstMet = tick(),
				InteractionCount = 0,
				Affection = 0
			}
		end
		
		local playerMemory = self.Memory.KnownPlayers[self.InteractionTarget.Name]
		playerMemory.InteractionCount = playerMemory.InteractionCount + 1
		playerMemory.Affection = math.min(100, playerMemory.Affection + 1)
		
		-- End interaction after some time
		if self.StateTimer > 5 then
			self:ChangeState(AIStates.IDLE)
		end
	end
	
	-- Increase bond if interacting with owner
	if self.InteractionTarget == self.Owner then
		self.Stats.Bond = math.min(100, self.Stats.Bond + 0.2)
	end
end

function PetAI:PerformTrick()
	local tricks = {"Wave", "Spin", "Backflip", "Dance"}
	local trick = tricks[math.random(1, #tricks)]
	
	if self.Animations[trick] then
		self.Animations[trick]:Play()
	end
	
	-- Gain experience for performing tricks
	self:GainExperience(5)
end

function PetAI:ComputePath(targetPosition)
	self.Path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentJumpHeight = 7.5,
		AgentMaxSlope = 45
	})
	
	local success, errorMessage = pcall(function()
		self.Path:ComputeAsync(self.RootPart.Position, targetPosition)
	end)
	
	if success and self.Path.Status == Enum.PathStatus.Success then
		self.Waypoints = self.Path:GetWaypoints()
		self.CurrentWaypointIndex = 1
	else
		self.Path = nil
		self.Waypoints = {}
	end
end

function PetAI:FollowPath()
	if not self.Waypoints or #self.Waypoints == 0 then return end
	
	local currentWaypoint = self.Waypoints[self.CurrentWaypointIndex]
	if not currentWaypoint then return end
	
	local distance = (self.RootPart.Position - currentWaypoint.Position).Magnitude
	
	if distance < 3 then
		self.CurrentWaypointIndex = self.CurrentWaypointIndex + 1
		
		if currentWaypoint.Action == Enum.PathWaypointAction.Jump then
			self.Humanoid.Jump = true
		end
	else
		self.Humanoid:MoveTo(currentWaypoint.Position)
	end
end

function PetAI:UpdateStats()
	-- Decay stats over time
	self.Stats.Energy = math.max(0, self.Stats.Energy - self.BehaviorParams.EnergyDrainRate)
	self.Stats.Hunger = math.max(0, self.Stats.Hunger - 0.05)
	self.Stats.Happiness = math.max(0, self.Stats.Happiness - self.BehaviorParams.HappinessDecayRate)
	
	-- Bond increases slowly when near owner
	if self.Owner.Character then
		local ownerRoot = self.Owner.Character:FindFirstChild("HumanoidRootPart")
		if ownerRoot then
			local distance = (self.RootPart.Position - ownerRoot.Position).Magnitude
			if distance < 20 then
				self.Stats.Bond = math.min(100, self.Stats.Bond + 0.01)
			end
		end
	end
end

function PetAI:GainExperience(amount)
	local personalityData = PetData.Personalities[self.Personality]
	local multiplier = personalityData.ExperienceGain or 1
	
	self.Stats.Experience = self.Stats.Experience + (amount * multiplier)
	
	-- Check for level up
	local requiredExp = 100 * self.Stats.Level
	if self.Stats.Experience >= requiredExp then
		self.Stats.Level = self.Stats.Level + 1
		self.Stats.Experience = self.Stats.Experience - requiredExp
		
		-- Notify player of level up
		-- Fire remote event here
	end
end

function PetAI:GetNearbyPlayers(range)
	local nearbyPlayers = {}
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= self.Owner and player.Character then
			local humanoidRoot = player.Character:FindFirstChild("HumanoidRootPart")
			if humanoidRoot then
				local distance = (self.RootPart.Position - humanoidRoot.Position).Magnitude
				if distance <= range then
					table.insert(nearbyPlayers, player)
				end
			end
		end
	end
	
	return nearbyPlayers
end

function PetAI:GetRandomPlayPosition()
	local ownerCharacter = self.Owner.Character
	if not ownerCharacter then return self.RootPart.Position end
	
	local ownerRoot = ownerCharacter:FindFirstChild("HumanoidRootPart")
	if not ownerRoot then return self.RootPart.Position end
	
	local angle = math.random() * math.pi * 2
	local distance = math.random(5, 15)
	
	return ownerRoot.Position + Vector3.new(
		math.cos(angle) * distance,
		0,
		math.sin(angle) * distance
	)
end

function PetAI:GetRandomExplorePosition()
	-- Check if pet has favorite spots
	if #self.Memory.FavoriteSpots > 0 and math.random() < 0.3 then
		return self.Memory.FavoriteSpots[math.random(1, #self.Memory.FavoriteSpots)]
	end
	
	-- Otherwise explore new area
	local angle = math.random() * math.pi * 2
	local distance = math.random(10, self.BehaviorParams.WanderRadius)
	
	return self.RootPart.Position + Vector3.new(
		math.cos(angle) * distance,
		0,
		math.sin(angle) * distance
	)
end

function PetAI:PlayAnimation(animName)
	-- Stop all current animations
	for _, track in pairs(self.Animations) do
		if track.IsPlaying then
			track:Stop()
		end
	end
	
	-- Play new animation
	if self.Animations[animName] then
		self.Animations[animName]:Play()
	end
end

function PetAI:Feed(food)
	self.Stats.Hunger = math.min(100, self.Stats.Hunger + (food.NutritionValue or 20))
	self.Memory.LastFedTime = tick()
	self:ChangeState(AIStates.EATING)
	self:GainExperience(10)
end

function PetAI:Pet()
	self.Stats.Happiness = math.min(100, self.Stats.Happiness + 5)
	self.Memory.LastPetTime = tick()
	self:PerformTrick()
	self:GainExperience(5)
end

function PetAI:Play()
	self.Stats.Happiness = math.min(100, self.Stats.Happiness + 10)
	self.Memory.LastPlayTime = tick()
	self:ChangeState(AIStates.PLAYING)
	self:GainExperience(15)
end

function PetAI:Cleanup()
	if self.AIConnection then
		self.AIConnection:Disconnect()
	end
	
	if self.StatsConnection then
		task.cancel(self.StatsConnection)
	end
	
	for _, track in pairs(self.Animations) do
		if track.IsPlaying then
			track:Stop()
		end
	end
end

return PetAI