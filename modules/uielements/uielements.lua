-- This module handle various UI Elements by LUI or Blizzard.
-- It's an umbrella module to consolidate the many, many little UI changes that LUI does
--	that do not need a full module for themselves. 

------------------------------------------------------
-- / SETUP AND LOCALS / --
------------------------------------------------------
local addonname, LUI = ...
local module = LUI:NewModule("UI Elements", "AceHook-3.0")
local db

local NUM_OBJECTIVE_HEADERS = 3

local origInfo = {}

--Defaults
module.defaults = {   
	profile = {
		ObjectiveTracker = {
			OffsetX = -90,
			OffsetY = -30,
			HeaderColor = true,
			ManagePosition = true,
		},
		DurabilityFrame = {
			X = -90,
			Y = 0,
			ManagePosition = false,
			HideFrame = true,
		},
		OrderHallCommandBar = {
			HideFrame = true,
		},
	},
}

------------------------------------------------------
-- / MODULE FUNCTIONS / --
------------------------------------------------------
local function ForceHide(frame)
	frame.OldShow = frame.Show
	frame.Show = frame.Hide
	frame:Hide()
end

local function RestoreFrame(frame)
	frame.Show = frame.OldShow
end

local orderUI = false
function module:SetHiddenFrames()

	-- Durability Frame
	if db.DurabilityFrame.HideFrame then
		ForceHide(DurabilityFrame)
	else
		RestoreFrame(DurabilityFrame)
		DurabilityFrame_SetAlerts()
		if db.DurabilityFrame.ManagePosition then
			DurabilityFrame:ClearAllPoints()
			-- Not Working. Figure out why.
			DurabilityFrame:SetPoint("RIGHT", Minimap, "LEFT", db.DurabilityFrame.X, db.DurabilityFrame.Y)
		else
			DurabilityFrame_SetAlerts()
		end
	end
	
	if db.OrderHallCommandBar.HideFrame and not orderUI then
		module:SecureHook("OrderHall_LoadUI", function()
			ForceHide(OrderHallCommandBar)
		end)
		orderUI = true
	end
end

---------------------- --------------------------------
-- / OBJECTIVE FRAME / --
------------------------------------------------------
function module:ChangeHeaderColor(header, r, g, b)
	header.Background:SetDesaturated(true)
	header.Background:SetVertexColor(r, g, b)
end

function module:SetObjectiveFrame()
	if db.ObjectiveTracker.HeaderColor then
		module:SecureHook("ObjectiveTracker_Initialize", function()
			for i, v in pairs(ObjectiveTrackerFrame.MODULES) do
				module:ChangeHeaderColor(v.Header, module:Color(LUI.playerClass))
			end
		end)
	end
	if db.ObjectiveTracker.ManagePosition then
		module:SecureHook("ObjectiveTracker_Update", function()
			ObjectiveTrackerFrame:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", db.ObjectiveTracker.OffsetX, db.ObjectiveTracker.OffsetY)
		end)
	end
end

------------------------------------------------------
-- / FRAMEWORK FUNCTIONS / --
------------------------------------------------------

--[[Taken from Minimap
function module:LoadOptions()
	local options = {
		Header = module:NewHeader(MINIMAP_LABEL, 1),
		General = module:NewGroup(L["Settings"], 2, nil, nil, {
			alwaysShowText = module:NewToggle(L["Minimap_AlwaysShowText_Name"], L["Minimap_AlwaysShowText_Desc"], 1, "ToggleMinimapText"),
			showTextures = module:NewToggle(L["Minimap_ShowTextures_Name"], L["Minimap_ShowTextures_Desc"], 2, "ToggleMinimapTextures"),
			coordPrecision = module:NewSlider(L["Minimap_CoordPrecision_Name"], L["Minimap_CoordPrecision_Desc"], 4, 0, 2, 1),
			Scale = module:NewSlider(L["Minimap_Scale_Name"], L["Minimap_Scale_Desc"], 5, 0.5, 2.5, 0.25, true, "SetMinimapSize"),
			Minimap = module:NewColorMenu(L["Minimap_BorderColor_Name"], 10, true, "SetColors"),
		}),
	}
	return options
end
--]]

function module:Refresh()
	module:SetHiddenFrames()
end

module.childGroups = "select"
function module:LoadOptions()
	local function DisablePosition(info)
		local parent = info[#info-1]
		return not db[parent].ManagePosition
	end
	local options = {
		Header = module:NewHeader("UI Elements", 1),
		--Note: Displaying a tree group inside of a tree group just results in collapsable entries instead of displaying two tree lists.
		--The only way around that is to make a tab group and then have its childs be a tree list.
		Elements = module:NewGroup("UI Elements", 2, "tree", nil, {
			ObjectiveTracker = module:NewGroup("ObjectiveTracker", 1, nil, nil, {
				Desc = module:NewDesc("As of currently, these options requires a Reload UI.",1),
				HeaderColor = module:NewToggle("Color Headers by Class", nil, 2),
				ManagePosition = module:NewToggle("Manage Position", nil, 3, "Refresh"),
				Offset = module:NewPosition("ObjectiveTracker", 4, nil, "Refresh", nil, DisablePosition),
			}),
			DurabilityFrame = module:NewGroup("DurabilityFrame", 2, nil, nil, {
				Desc = module:NewDesc("This frame shows a little armored guy when equipment breaks.", 1),
				HideFrame = module:NewToggle("Hide This Frame", nil, 2, "Refresh"),
				ManagePosition = module:NewToggle("Manage Position", nil, 3, "Refresh"),
				Position = module:NewPosition("DurabilityFrame", 4, true, "Refresh", nil, DisablePosition),
			}),
			OrderHallCommandBar = module:NewGroup("OrderHallCommandBar", 2, nil, nil, {
				Desc = module:NewDesc("This frame shows a bar at the top when you are in your class halls.", 1),
				HideFrame = module:NewToggle("Hide This Frame", nil, 2),
			}),
		}),
	}
	return options
end

function module:OnInitialize()
	LUI:RegisterModule(module)
	db = module:GetDB()
end

function module:OnEnable()
	module:SetHiddenFrames()
	module:SetObjectiveFrame()
end

function module:OnDisable()
end