local GameConfig = {}

-- Game Settings
GameConfig.MaxPetsPerPlayer = 6
GameConfig.MaxActivePets = 3
GameConfig.DefaultStartingCoins = 100
GameConfig.DailyRewardCoins = 500

-- Monetization Settings
GameConfig.Products = {
	-- Developer Products (Can be purchased multiple times)
	Coins100 = {
		ProductId = 0, -- Replace with actual Product ID
		Name = "100 Coins",
		Robux = 10,
		Coins = 100
	},
	Coins500 = {
		ProductId = 0,
		Name = "500 Coins",
		Robux = 45,
		Coins = 500
	},
	Coins1000 = {
		ProductId = 0,
		Name = "1,000 Coins",
		Robux = 85,
		Coins = 1000
	},
	Coins5000 = {
		ProductId = 0,
		Name = "5,000 Coins",
		Robux = 400,
		Coins = 5000
	},
	Coins10000 = {
		ProductId = 0,
		Name = "10,000 Coins",
		Robux = 750,
		Coins = 10000
	},
	Coins50000 = {
		ProductId = 0,
		Name = "50,000 Coins",
		Robux = 3500,
		Coins = 50000
	},
	
	-- Pet Eggs
	BasicEgg = {
		ProductId = 0,
		Name = "Basic Pet Egg",
		Robux = 25,
		EggType = "Basic"
	},
	RareEgg = {
		ProductId = 0,
		Name = "Rare Pet Egg",
		Robux = 100,
		EggType = "Rare"
	},
	EpicEgg = {
		ProductId = 0,
		Name = "Epic Pet Egg",
		Robux = 500,
		EggType = "Epic"
	},
	LegendaryEgg = {
		ProductId = 0,
		Name = "Legendary Pet Egg",
		Robux = 2000,
		EggType = "Legendary"
	}
}

-- Game Passes
GameConfig.GamePasses = {
	VIP = {
		PassId = 0, -- Replace with actual Pass ID
		Name = "VIP Pass",
		Price = 499,
		Benefits = {
			"Access to VIP Zone",
			"2x Daily Rewards",
			"Exclusive VIP Pets",
			"VIP Chat Tag",
			"10% Shop Discount"
		}
	},
	DoubleCoins = {
		PassId = 0,
		Name = "2x Coins",
		Price = 299,
		Benefits = {
			"Permanent 2x Coins",
			"All activities give double coins"
		}
	},
	ExtraPetSlots = {
		PassId = 0,
		Name = "Extra Pet Slots",
		Price = 199,
		Benefits = {
			"6 Additional Pet Slots",
			"12 Total Pet Storage"
		}
	},
	AutoFeed = {
		PassId = 0,
		Name = "Auto Feed",
		Price = 149,
		Benefits = {
			"Pets automatically fed",
			"Never worry about hunger"
		}
	},
	LuckyGamepass = {
		PassId = 0,
		Name = "Lucky Charm",
		Price = 399,
		Benefits = {
			"2x Luck for rare pets",
			"Better egg hatching odds"
		}
	},
	TeleportPass = {
		PassId = 0,
		Name = "Fast Travel",
		Price = 99,
		Benefits = {
			"Teleport anywhere on map",
			"No cooldown"
		}
	},
	RadioPass = {
		PassId = 0,
		Name = "Boombox",
		Price = 79,
		Benefits = {
			"Play music for everyone",
			"Custom playlists"
		}
	},
	TrailPass = {
		PassId = 0,
		Name = "Rainbow Trails",
		Price = 129,
		Benefits = {
			"Colorful trails behind pets",
			"Customizable colors"
		}
	}
}

-- Private Server Configuration
GameConfig.PrivateServer = {
	Price = 100, -- Robux per month
	MaxPlayers = 10,
	Benefits = {
		"Private pet paradise",
		"Invite friends only",
		"Custom server rules",
		"No random players"
	}
}

-- Battle Pass / Season Pass
GameConfig.BattlePass = {
	Price = 800, -- Robux
	Duration = 30, -- Days
	Tiers = 50,
	FreeRewards = {
		[1] = {Type = "Coins", Amount = 100},
		[5] = {Type = "Coins", Amount = 200},
		[10] = {Type = "Pet", Name = "SeasonPuppy"},
		[15] = {Type = "Coins", Amount = 500},
		[20] = {Type = "Accessory", Name = "BasicHat"},
		[25] = {Type = "Coins", Amount = 1000},
		[30] = {Type = "Pet", Name = "SeasonKitten"},
		[35] = {Type = "Coins", Amount = 1500},
		[40] = {Type = "Accessory", Name = "BasicCollar"},
		[45] = {Type = "Coins", Amount = 2000},
		[50] = {Type = "Pet", Name = "SeasonBunny"}
	},
	PremiumRewards = {
		[1] = {Type = "Coins", Amount = 500},
		[5] = {Type = "Pet", Name = "PremiumFox"},
		[10] = {Type = "Coins", Amount = 1000},
		[15] = {Type = "Pet", Name = "PremiumWolf"},
		[20] = {Type = "Accessory", Name = "GoldenCrown"},
		[25] = {Type = "Coins", Amount = 2500},
		[30] = {Type = "Pet", Name = "PremiumDragon"},
		[35] = {Type = "Accessory", Name = "DiamondCollar"},
		[40] = {Type = "Coins", Amount = 5000},
		[45] = {Type = "Pet", Name = "PremiumUnicorn"},
		[50] = {Type = "Pet", Name = "ExclusivePhoenix"}
	}
}

-- Egg System
GameConfig.Eggs = {
	Basic = {
		Name = "Basic Egg",
		Price = 100, -- Coins
		Pets = {"Puppy", "Kitten", "Bunny"},
		Chances = {70, 20, 10} -- Percentage chances
	},
	Rare = {
		Name = "Rare Egg",
		Price = 1000,
		Pets = {"Fox", "RedPanda", "Wolf", "Owl"},
		Chances = {40, 30, 20, 10}
	},
	Epic = {
		Name = "Epic Egg",
		Price = 10000,
		Pets = {"Wolf", "Owl", "Dragon", "Unicorn"},
		Chances = {30, 30, 25, 15}
	},
	Legendary = {
		Name = "Legendary Egg",
		Price = 50000,
		Pets = {"Dragon", "Unicorn", "Phoenix", "GoldenDragon"},
		Chances = {30, 30, 25, 15}
	},
	Mythical = {
		Name = "Mythical Egg",
		Price = 250000,
		Pets = {"Phoenix", "GoldenDragon", "CelestialGuardian"},
		Chances = {45, 45, 10}
	},
	RobuxExclusive = {
		Name = "Exclusive Egg",
		RobuxPrice = 1000,
		Pets = {"GoldenDragon", "CelestialGuardian"},
		Chances = {80, 20}
	}
}

-- Trading System
GameConfig.Trading = {
	Enabled = true,
	MinLevel = 5,
	MaxItemsPerTrade = 4,
	TradeCooldown = 60, -- Seconds
	TaxPercentage = 5 -- Tax on coin trades
}

-- Daily Rewards
GameConfig.DailyRewards = {
	[1] = {Coins = 100},
	[2] = {Coins = 200},
	[3] = {Coins = 300},
	[4] = {Coins = 500},
	[5] = {Coins = 750},
	[6] = {Coins = 1000},
	[7] = {Coins = 1500, Pet = "Bunny"}, -- Weekly bonus
	[14] = {Coins = 5000, Pet = "Fox"}, -- 2 week streak
	[30] = {Coins = 10000, Pet = "Wolf"} -- Monthly streak
}

-- Level System
GameConfig.Levels = {
	MaxLevel = 100,
	ExperienceFormula = function(level)
		return math.floor(100 * (level ^ 1.5))
	end,
	LevelRewards = {
		[5] = {Coins = 500},
		[10] = {Coins = 1000, Pet = "Fox"},
		[20] = {Coins = 2500},
		[30] = {Coins = 5000, Pet = "Wolf"},
		[40] = {Coins = 7500},
		[50] = {Coins = 10000, Pet = "Dragon"},
		[75] = {Coins = 25000},
		[100] = {Coins = 50000, Pet = "Phoenix"}
	}
}

-- Activities (for earning coins and XP)
GameConfig.Activities = {
	PetPetting = {
		Coins = 1,
		Experience = 5,
		Cooldown = 10
	},
	PetFeeding = {
		Coins = 2,
		Experience = 10,
		Cooldown = 60
	},
	PetPlaying = {
		Coins = 5,
		Experience = 15,
		Cooldown = 120
	},
	PetRacing = {
		Coins = 10,
		Experience = 25,
		Cooldown = 300
	},
	PetShowcase = {
		Coins = 15,
		Experience = 30,
		Cooldown = 600
	}
}

return GameConfig