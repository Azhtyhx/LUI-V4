------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
-- Unitframes elements need to be named exactly like Blizzard unit values (player, target, etc)
local addonname, LUI = ...
local module = LUI:GetModule("Unitframes")
local element = module:NewElement("focus")
local db

element.defaults = {
	profile = {	
		Enable = true,
		Height = 24,
		Width = 200,
		X = -435,
		Y = -250,
		Point = "CENTER",
		Scale = 1,
		Border = {
			Aggro = false,
			EdgeSize = 5,
			Insets = {
				Left = 3,
				Right = 3,
				Top = 3,
				Bottom = 3,
			},
		},
		Backdrop = {
			Padding = {
				Left = -4,
				Right = 4,
				Top = 4,
				Bottom = -4,
			},
		},
		Bars = {
			Health = {
				Height = 24,
				Width = 200,
				X = 0,
				Y = 0,
				BGAlpha = 1,
				BGMultiplier = 0.4,
				BGInvert = false,
				Smooth = true,
				HealthPredict = false,
				Absorb = false,
			},
			Power = {
				Enable = false,
				Height = 10,
				Width = 200,
				X = 0,
				Y = -26,
				BGAlpha = 1,
				BGMultiplier = 0.4,
				BGInvert = false,
				Smooth = true,
			},
		},
		Aura = {
			Buffs = {
				Enable = false,
				ColorByType = false,
				PlayerOnly = false,
				IncludePet = false,
				AuraTimer = false,
				DisableCooldown = false,
				CooldownReverse = true,
				X = -0.5,
				Y = -30,
				InitialAnchor = "BOTTOMRIGHT",
				GrowthY = "DOWN",
				GrowthX = "LEFT",
				Size = 26,
				Spacing = 2,
				Num = 8,
			},
			Debuffs = {
				Enable = false,
				ColorByType = false,
				PlayerOnly = false,
				IncludePet = false,
				FadeOthers = true,
				AuraTimer = false,
				DisableCooldown = false,
				CooldownReverse = true,
				X = -0.5,
				Y = -60,
				InitialAnchor = "BOTTOMLEFT",
				GrowthY = "DOWN",
				GrowthX = "RIGHT",
				Size = 26,
				Spacing = 2,
				Num = 36,
			},
		},
		Portrait = {
			Enable = false,
			Height = 43,
			Width = 90,
			X = 0,
			Y = 0,
			Alpha = 1,
		},
		Texts = {
			Name = {
				Enable = true,
				X = 5,
				Y = 0,
				Point = "LEFT",
				RelativePoint = "LEFT",
				Format = "Name",
				Length = "Medium",
				ColorNameByClass = false,
				ColorClassByClass = false,
				ColorLevelByDifficulty = false,
				ShowClassification = false,
				ShortClassification = false,
			},
			Health = {
				Enable = false,
				X = 0,
				Y = -43,
				ShowAlways = true,
				Point = "BOTTOMLEFT",
				RelativePoint = "BOTTOMRIGHT",
				Format = "Absolut Short",
				ShowDead = false,
			},
			Power = {
				Enable = false,
				X = 0,
				Y = -66,
				ShowFull = true,
				ShowEmpty = true,
				Point = "BOTTOMLEFT",
				RelativePoint = "BOTTOMRIGHT",
				Format = "Absolut Short",
			},
			HealthPercent = {
				Enable = true,
				X = -5,
				Y = 0,
				ShowAlways = false,
				Point = "RIGHT",
				RelativePoint = "RIGHT",
				ShowDead = false,
			},
			PowerPercent = {
				Enable = false,
				X = 0,
				Y = 0,
				ShowFull = false,
				ShowEmpty = false,
				Point = "CENTER",
				RelativePoint = "CENTER",
			},
			HealthMissing = {
				Enable = false,
				X = 0,
				Y = 0,
				ShortValue = true,
				ShowAlways = false,
				Point = "RIGHT",
				RelativePoint = "RIGHT",
			},
			PowerMissing = {
				Enable = false,
				X = 0,
				Y = 0,
				ShortValue = true,
				ShowFull = false,
				ShowEmpty = false,
				Point = "RIGHT",
				RelativePoint = "RIGHT",
			},
			Combat = {
				Enable = false,
				Point = "CENTER",
				RelativePoint = "BOTTOM",
				X = 0,
				Y = 0,
				ShowDamage = true,
				ShowHeal = true,
				ShowImmune = true,
				ShowEnergize = true,
				ShowOther = true,
				MaxAlpha = 0.6,
			},
		},
		Icons = {
			Lootmaster = { Enable = false, Size = 15, X = 16,  Y = 0,  Point = "TOPLEFT",  },
			Leader =     { Enable = false, Size = 17, X = 0,   Y = 0,  Point = "TOPLEFT",  },
			Role =       { Enable = false, Size = 22, X = 15,  Y = 10, Point = "TOPRIGHT", },
			Raid =       { Enable = true,  Size = 55, X = 0,   Y = 0,  Point = "CENTER",   },
			PvP =        { Enable = false, Size = 35, X = -12, Y = 10, Point = "TOPLEFT",  },
		},
		Colors = {
			-- Note: Type is not currently supported by :Color() as it relates to unitframes only.
			Border =       { r = 0,    g = 0,    b = 0,    a = 1,    },
			Background =   { r = 0,    g = 0,    b = 0,    a = 1,    },
			HealPredict =  { r = 0,    g = 0.5,  b = 0,    a = 0.25, },
			Absorb =       { r = 0,    g = 1,    b = 0,    a = 0.5,  },
			PvPTime =      { r = 1,    g = 0.1,  b = 0.1,  a = 1,    },
			HealthBar =    { r = 0.25, g = 0.25, b = 0.25, t = "Individual", },
			PowerBar =     { r = 0.8,  g = 0.8,  b = 0.8,  t = "Class",      },
			NameText =     { r = 1,    g = 1,    b = 1,    t = "Class",      },
			HealthText =   { r = 1,    g = 1,    b = 1,    t = "Individual", },
			PowerText =    { r = 1,    g = 1,    b = 1,    t = "Class",      },
			HealthPerc =   { r = 1,    g = 1,    b = 1,    t = "Individual", },
			PowerPerc =    { r = 1,    g = 1,    b = 1,    t = "Individual", },
			HealthMiss =   { r = 1,    g = 1,    b = 1,    t = "Individual", },
			PowerMiss =    { r = 1,    g = 1,    b = 1,    t = "Individual", },
		}, 
		Fonts = {
			NameText =   { Name = "Prototype", Size = 24, Flag = "NONE",    },
			HealthText = { Name = "Prototype", Size = 28, Flag = "NONE",    },
			PowerText =  { Name = "Prototype", Size = 21, Flag = "NONE",    },
			HealthPerc = { Name = "Prototype", Size = 16, Flag = "NONE",    },
			PowerPerc =  { Name = "Prototype", Size = 14, Flag = "NONE",    },
			HealthMiss = { Name = "Prototype", Size = 15, Flag = "NONE",    },
			PowerMiss =  { Name = "Prototype", Size = 13, Flag = "NONE",    },
			Combat =     { Name = "vibrocen",  Size = 20, Flag = "OUTLINE", },
			PvPTime =    { Name = "vibroceb",  Size = 12, Flag = "NONE",    },
		},
		StatusBars = {
			Health = "LUI_Gradient",
			Power = "LUI_Minimalist",
			HealthBG = "LUI_Gradient",
			PowerBG = "LUI_Minimalist",
			HealPredict = "LUI_Gradient",
			Absorb = "LUI_Gradient",
			
		},
		Backgrounds = {
			Frame = "Blizzard Tooltip",
		},
		Borders = {
			Frame = "glow",
		},
	},
}

function element.SetUnitStyle(self, unit, isSingle)
end


function element:OnInitialize()
end

function element:OnEnable()
	db = element:GetDB()
end

function element:OnDisable()
end