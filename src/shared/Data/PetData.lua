local PetData = {}

PetData.Rarities = {
	Common = {
		Color = Color3.fromRGB(158, 158, 158),
		Chance = 50,
		PriceMultiplier = 1
	},
	Uncommon = {
		Color = Color3.fromRGB(76, 209, 55),
		Chance = 30,
		PriceMultiplier = 2
	},
	Rare = {
		Color = Color3.fromRGB(68, 138, 255),
		Chance = 15,
		PriceMultiplier = 5
	},
	Epic = {
		Color = Color3.fromRGB(156, 39, 176),
		Chance = 4,
		PriceMultiplier = 10
	},
	Legendary = {
		Color = Color3.fromRGB(255, 193, 7),
		Chance = 0.9,
		PriceMultiplier = 25
	},
	Mythical = {
		Color = Color3.fromRGB(255, 61, 0),
		Chance = 0.1,
		PriceMultiplier = 100
	}
}

PetData.Personalities = {
	Playful = {
		Description = "Loves to play and run around",
		EnergyMultiplier = 1.5,
		HappinessDecayRate = 0.8,
		InteractionBonus = 1.2
	},
	Shy = {
		Description = "Takes time to warm up to players",
		EnergyMultiplier = 0.8,
		HappinessDecayRate = 0.6,
		InteractionBonus = 0.9,
		BondingSpeed = 1.5
	},
	Loyal = {
		Description = "Forms strong bonds with their owner",
		EnergyMultiplier = 1,
		HappinessDecayRate = 0.5,
		InteractionBonus = 1,
		BondingSpeed = 2
	},
	Curious = {
		Description = "Always exploring and discovering",
		EnergyMultiplier = 1.2,
		HappinessDecayRate = 0.7,
		InteractionBonus = 1.1,
		ExperienceGain = 1.3
	},
	Lazy = {
		Description = "Prefers to relax and take it easy",
		EnergyMultiplier = 0.5,
		HappinessDecayRate = 0.4,
		InteractionBonus = 0.8
	},
	Protective = {
		Description = "Guards their owner fiercely",
		EnergyMultiplier = 1.1,
		HappinessDecayRate = 0.6,
		InteractionBonus = 1,
		OwnerBonus = 1.5
	}
}

PetData.Pets = {
	-- Common Pets
	Puppy = {
		Name = "Puppy",
		Rarity = "Common",
		BasePrice = 100,
		BaseStats = {
			Speed = 16,
			Jump = 50,
			Energy = 100,
			Happiness = 100
		},
		Abilities = {},
		ModelId = "rbxassetid://0" -- Placeholder
	},
	Kitten = {
		Name = "Kitten",
		Rarity = "Common",
		BasePrice = 100,
		BaseStats = {
			Speed = 18,
			Jump = 60,
			Energy = 90,
			Happiness = 100
		},
		Abilities = {},
		ModelId = "rbxassetid://0"
	},
	Bunny = {
		Name = "Bunny",
		Rarity = "Common",
		BasePrice = 150,
		BaseStats = {
			Speed = 20,
			Jump = 70,
			Energy = 80,
			Happiness = 100
		},
		Abilities = {},
		ModelId = "rbxassetid://0"
	},
	
	-- Uncommon Pets
	Fox = {
		Name = "Fox",
		Rarity = "Uncommon",
		BasePrice = 500,
		BaseStats = {
			Speed = 22,
			Jump = 55,
			Energy = 110,
			Happiness = 100
		},
		Abilities = {"QuickDash"},
		ModelId = "rbxassetid://0"
	},
	RedPanda = {
		Name = "Red Panda",
		Rarity = "Uncommon",
		BasePrice = 600,
		BaseStats = {
			Speed = 18,
			Jump = 65,
			Energy = 100,
			Happiness = 100
		},
		Abilities = {"Climb"},
		ModelId = "rbxassetid://0"
	},
	
	-- Rare Pets
	Wolf = {
		Name = "Wolf",
		Rarity = "Rare",
		BasePrice = 2000,
		BaseStats = {
			Speed = 25,
			Jump = 60,
			Energy = 120,
			Happiness = 100
		},
		Abilities = {"Howl", "PackBonus"},
		ModelId = "rbxassetid://0"
	},
	Owl = {
		Name = "Owl",
		Rarity = "Rare",
		BasePrice = 2500,
		BaseStats = {
			Speed = 20,
			Jump = 80,
			Energy = 100,
			Happiness = 100
		},
		Abilities = {"Fly", "NightVision"},
		ModelId = "rbxassetid://0"
	},
	
	-- Epic Pets
	Dragon = {
		Name = "Dragon",
		Rarity = "Epic",
		BasePrice = 10000,
		BaseStats = {
			Speed = 28,
			Jump = 90,
			Energy = 150,
			Happiness = 100
		},
		Abilities = {"Fly", "FireBreath", "TreasureFind"},
		ModelId = "rbxassetid://0"
	},
	Unicorn = {
		Name = "Unicorn",
		Rarity = "Epic",
		BasePrice = 12000,
		BaseStats = {
			Speed = 30,
			Jump = 75,
			Energy = 130,
			Happiness = 100
		},
		Abilities = {"MagicAura", "Heal", "RainbowTrail"},
		ModelId = "rbxassetid://0"
	},
	
	-- Legendary Pets
	Phoenix = {
		Name = "Phoenix",
		Rarity = "Legendary",
		BasePrice = 50000,
		BaseStats = {
			Speed = 32,
			Jump = 100,
			Energy = 200,
			Happiness = 100
		},
		Abilities = {"Fly", "Rebirth", "FireAura", "SpeedBoost"},
		ModelId = "rbxassetid://0"
	},
	GoldenDragon = {
		Name = "Golden Dragon",
		Rarity = "Legendary",
		BasePrice = 75000,
		BaseStats = {
			Speed = 35,
			Jump = 95,
			Energy = 180,
			Happiness = 100
		},
		Abilities = {"Fly", "GoldRush", "FireBreath", "TreasureFind", "LuckyAura"},
		ModelId = "rbxassetid://0"
	},
	
	-- Mythical Pets
	CelestialGuardian = {
		Name = "Celestial Guardian",
		Rarity = "Mythical",
		BasePrice = 500000,
		BaseStats = {
			Speed = 40,
			Jump = 120,
			Energy = 300,
			Happiness = 100
		},
		Abilities = {"Fly", "Teleport", "CosmicShield", "StarPower", "Immortality"},
		ModelId = "rbxassetid://0"
	}
}

PetData.Abilities = {
	QuickDash = {
		Name = "Quick Dash",
		Description = "Dash forward quickly",
		Cooldown = 5
	},
	Climb = {
		Name = "Climb",
		Description = "Can climb walls",
		Passive = true
	},
	Howl = {
		Name = "Howl",
		Description = "Boost nearby pets",
		Cooldown = 30,
		Range = 50
	},
	PackBonus = {
		Name = "Pack Bonus",
		Description = "Stronger when near other wolves",
		Passive = true
	},
	Fly = {
		Name = "Fly",
		Description = "Can fly for short periods",
		Duration = 10,
		Cooldown = 20
	},
	NightVision = {
		Name = "Night Vision",
		Description = "See clearly in the dark",
		Passive = true
	},
	FireBreath = {
		Name = "Fire Breath",
		Description = "Breathe fire",
		Cooldown = 15,
		Damage = 10
	},
	TreasureFind = {
		Name = "Treasure Find",
		Description = "Higher chance to find rare items",
		Passive = true,
		Multiplier = 1.5
	},
	MagicAura = {
		Name = "Magic Aura",
		Description = "Magical particles surround the pet",
		Passive = true
	},
	Heal = {
		Name = "Heal",
		Description = "Heal yourself and nearby pets",
		Cooldown = 60,
		HealAmount = 50
	},
	RainbowTrail = {
		Name = "Rainbow Trail",
		Description = "Leave a rainbow trail behind",
		Passive = true
	},
	Rebirth = {
		Name = "Rebirth",
		Description = "Revive once per day",
		Cooldown = 86400
	},
	FireAura = {
		Name = "Fire Aura",
		Description = "Surrounded by flames",
		Passive = true
	},
	SpeedBoost = {
		Name = "Speed Boost",
		Description = "Temporary speed increase",
		Cooldown = 30,
		Duration = 10,
		Multiplier = 1.5
	},
	GoldRush = {
		Name = "Gold Rush",
		Description = "Double coins for 60 seconds",
		Cooldown = 300,
		Duration = 60
	},
	LuckyAura = {
		Name = "Lucky Aura",
		Description = "Increase luck for all nearby players",
		Passive = true,
		Range = 30
	},
	Teleport = {
		Name = "Teleport",
		Description = "Instantly teleport to owner",
		Cooldown = 120
	},
	CosmicShield = {
		Name = "Cosmic Shield",
		Description = "Invulnerable for 5 seconds",
		Cooldown = 180,
		Duration = 5
	},
	StarPower = {
		Name = "Star Power",
		Description = "All abilities enhanced",
		Passive = true,
		Multiplier = 2
	},
	Immortality = {
		Name = "Immortality",
		Description = "Cannot be defeated",
		Passive = true
	}
}

return PetData