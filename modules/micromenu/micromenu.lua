-- ####################################################################################################################
-- ##### Setup and Locals #############################################################################################
-- ####################################################################################################################

local _, LUI = ...
local module = LUI:NewModule("Micromenu", "AceEvent-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local L = LUI.L
local db

local format = format

-- Local variables
local microStorage = {}
local addonLoadedCallbacks = {}

-- List of buttons, starting from the right.
local microList = {
	"Settings",
	"Bags",
	"Store",
	"Collections",
	"EJ",
	"LFG",
	"Guild",
	"Quests",
	"Achievements",
	"Talents",
	"Spellbook",
	"Player",
}

-- Constants
local TEXTURE_PATH_FORMAT = "Interface\\AddOns\\LUI4\\media\\textures\\micromenu\\micro_%s.tga"
local BACKGROUND_TEXTURE_PATH = "Interface\\AddOns\\LUI4\\media\\textures\\micromenu\\micro_background.tga"
local FIRST_TEXTURE_SIZE_WIDTH = 46
local LAST_TEXTURE_SIZE_WIDTH = 48
local TEXTURE_SIZE_HEIGHT = 28
local TEXTURE_SIZE_WIDTH = 33
local ALERT_ALPHA_MULT = 0.7

-- the clickable area is only 27x24
-- Wide buttons clickable area: 42x24
local WIDE_TEXTURE_CLICK_HEIGHT = 24
local WIDE_TEXTURE_CLICK_WIDTH = 42
local TEXTURE_CLICK_HEIGHT = 24
local TEXTURE_CLICK_WIDTH = 27

-- Level Requirements
local TALENT_LEVEL_REQ = 10
local LFG_LEVEL_REQ = 10

-- ####################################################################################################################
-- ##### Default Settings #############################################################################################
-- ####################################################################################################################

module.defaults = {
	profile = {
		HideSettings = false,
		HideBags = false,
		HideStore = false,
		HideCollections = false,
		HideEJ = false,
		HideLFG = false,
		HideGuild = false,
		HideQuests = false,
		HideAchievements = false,
		HideTalents = false,
		HideSpellbook = false,
		HidePlayer = false,
		ColorMatch = true,
		Spacing = 1,
		Point = "TOPRIGHT",
		Direction = "RIGHT",
		X = -15,
		Y = -18,
		Colors = {
			Background = { r = 0.12, g = 0.12,  b = 0.12, a = 1, t = "Class", },
			Micromenu = { r = 0.12, g = 0.58,  b = 0.89, a = 1, t = "Class", },
		},
	},
}

-- ####################################################################################################################
-- ##### MicroButton Definitions ######################################################################################
-- ####################################################################################################################

local microDefinitions = {
	{ -- [1]
		name = "Settings",
		title = L["Options"],
		left = L["MicroSettings_Left"],
		right = L["MicroSettings_Right"],
		state = "ConsolidatedOptionsFrame",
		OnClick = function(self, btn)
			if btn == "RightButton" then
				--LUI Option Panel
				LUI:OpenOptions()
			else
				--WoW Option Panel
				module:TogglePanel(GameMenuFrame)
			end
		end,
	},

	{ -- [2]
		name = "Bags",
		title = L["Bags_Name"],
		any = L["MicroBags_Any"],
		state = "ConsolidatedBagFrame",
		OnClick = function(self, btn_)
			ToggleAllBags()
		end,
	},

	{ -- [3]
		name = "Store",
		title = L["MicroStore_Name"],
		any = L["MicroStore_Any"],
		state = "StoreFrame",
		OnClick = function(self, btn_)
			ToggleStoreUI()
		end,
	},

	{ -- [4]
		name = "Collections",
		alertFrame = "Collections",
		title = L["MicroCollect_Name"],
		any = L["MicroCollect_Any"],
		state = "CollectionsJournal",
		addon = "Blizzard_CollectionsJournal",
		OnClick = function(self, btn_)
			ToggleCollectionsJournal()
		end,
	},

	{ -- [5]
		name = "EJ",
		alertFrame = "EJ",
		title = L["MicroEJ_Name"],
		any = L["MicroEJ_Any"],
		state = "EncounterJournal",
		addon = "Blizzard_EncounterJournal",
		OnClick = function(self, btn_)
			ToggleEncounterJournal()
		end,
	},

	{ -- [6]
		name = "LFG",
		level = LFG_LEVEL_REQ,
		title = L["MicroLFG_Name"],
		left = L["MicroLFG_Left"],
		right = L["MicroLFG_Right"],
		state = "PVEFrame",
		OnClick = function(self, btn)
			if btn == "RightButton" then
				TogglePVPUI()
			else
				ToggleLFDParentFrame()
			end
		end,
	},

	{ -- [7]
		name = "Guild",
		title = L["MicroGuild_Name"],
		left = L["MicroGuild_Left"],
		right = L["MicroGuild_Right"],
		state = "ConsolidatedSocialFrame",
		OnClick = function(self, btn)
			if btn == "RightButton" then
				ToggleFriendsFrame()
			else
				ToggleGuildFrame()
			end
		end,
	},

	{ -- [8]
		name = "Quests",
		title = L["MicroQuest_Name"],
		any = L["MicroQuest_Any"],
		state = "WorldMapFrame",
		OnClick = function(self, btn_)
			ToggleWorldMap()
		end,
	},

	{ -- [9]
		name = "Achievements",
		title = L["MicroAch_Name"],
		any = L["MicroAch_Any"],
		state = "AchievementFrame",
		addon = "Blizzard_AchievementUI",
		OnClick = function(self, btn_)
			ToggleAchievementFrame()
		end,
	},

	{ -- [10]
		name = "Talents",
		alertFrame = "Talent",
		level = TALENT_LEVEL_REQ,
		title = L["MicroTalents_Name"],
		any = L["MicroTalents_Any"],
		state = "PlayerTalentFrame",
		addon = "Blizzard_TalentUI",
		OnClick = function(self, btn_)
			ToggleTalentFrame()
		end,
	},

	{ -- [11]
		name = "Spellbook",
		title = L["MicroSpell_Name"],
		any = L["MicroSpell_Any"],
		state = "SpellBookFrame",
		OnClick = function(self, btn_)
			module:TogglePanel(SpellBookFrame)
		end,
	},

	{ -- [12]
		name = "Player",
		isWide = "Left",
		title = L["MicroPlayer_Name"],
		any = L["MicroPlayer_Any"],
		state = "CharacterFrame",
		OnClick = function(self, btn_)
			module:TogglePanel(CharacterFrame)
		end,
	},
}

-- ####################################################################################################################
-- ##### Module Functions #############################################################################################
-- ####################################################################################################################

-- Function to attach the alert frame to point to micromenu buttons
-- function module:HookAlertFrame(name, anchor)
-- 	local r, g, b, a = module:RGBA("Micromenu")
-- 	local alertFrame      = _G[name.."MicroButtonAlert"]
-- 	local alertFrameBg    = _G[name.."MicroButtonAlertBg"]
-- 	local alertFrameArrow = _G[name.."MicroButtonAlertArrow"]
-- 	local alertFrameGlow  = _G[name.."MicroButtonAlertGlow"]

-- 	alertFrame:ClearAllPoints()
-- 	alertFrame:SetPoint("TOP", anchor, "BOTTOM", 0, -12)
-- 	alertFrameBg:SetGradientAlpha("VERTICAL", r/4, g/4, b/4, 1, 0, 0, 0, 1)
-- 	alertFrameArrow:ClearAllPoints()
-- 	alertFrameArrow:SetPoint("BOTTOM", alertFrame, "TOP", 0, -10)
-- 	alertFrameArrow:SetDesaturated(true)
-- 	alertFrameArrow:SetVertexColor(r, g, b, a * ALERT_ALPHA_MULT)
-- 	alertFrameGlow:SetVertexColor(r, g, b, a * ALERT_ALPHA_MULT)
-- 	alertFrameGlow:SetDesaturated(true)
-- 	alertFrameGlow:ClearAllPoints()
-- 	alertFrameGlow:SetAllPoints(alertFrameArrow)
-- 	module:SetAlertFrameColors(name)
-- end

-- -- Function to change the color of an alert frame to match micromenu.
-- local gAlertGlows = {"TopLeft", "TopRight", "BottomLeft", "BottomRight", "Top", "Bottom", "Left", "Right"}
-- function module:SetAlertFrameColors(name)
-- 	local r, g, b, a = module:RGBA("Micromenu")
-- 	_G[name.."MicroButtonAlertBg"]:SetGradientAlpha("VERTICAL", r/4, g/4, b/4, 1, 0, 0, 0, 1)
-- 	_G[name.."MicroButtonAlertArrow"]:SetVertexColor(r, g, b, a * ALERT_ALPHA_MULT)
-- 	_G[name.."MicroButtonAlertGlow"]:SetVertexColor(r, g, b, a * ALERT_ALPHA_MULT)
-- 	for i = 1, #gAlertGlows do
-- 		local tex = _G[name.."MicroButtonAlertGlow"..gAlertGlows[i]]
-- 		tex:SetDesaturated(true)
-- 		tex:SetVertexColor(r, g, b)
-- 	end
-- end

function module:TogglePanel(panel)
	if panel:IsShown() then
		HideUIPanel(panel)
	else
		ShowUIPanel(panel)
	end
end

function module:GetDirectionalTexCoord(atlas)
	local left, right, top, bottom = LUI:GetCoordAtlas(atlas)

	if db.Direction == "LEFT" then
		return right, left, top, bottom
	end

	return left, right, top, bottom
end

--- Updates the micromenu clicker alpha based on frames being shown and hidden
--- Works well and looks OK
-- @param button The actual micromenu button object
-- @param object The object to hook and use as state update reference
function module:ClickerStateUpdateHandler(button, object)
	local objectToHook = _G[object]
	if not objectToHook then return end

	local function OnShow()
		button.Opened = true
		button.clicker:SetAlpha(1)
	end

	local function OnHide()
		button.Opened = false
		button.clicker:SetAlpha(button.clicker.Hover and 1 or 0)
	end

	-- Hook Show and Hide to trigger an update
	hooksecurefunc(objectToHook, "Show", OnShow)
	hooksecurefunc(objectToHook, "Hide", OnHide)
end

-- ####################################################################################################################
-- ##### MicroButton Creation #########################################################################################
-- ####################################################################################################################
local MicroButtonClickerMixin = {}

function MicroButtonClickerMixin:OnEnter()
	self:SetAlpha(1)
	self.Hover = true
	GameTooltip:SetOwner(self, "ANCHOR_NONE ", 40, -100)

	local parent = self:GetParent()
	GameTooltip:SetText(parent.title)
	if parent.any then GameTooltip:AddLine(parent.any, 1, 1, 1) end
	if parent.left then GameTooltip:AddLine(parent.left, 1, 1, 1) end
	if parent.right then GameTooltip:AddLine(parent.right, 1, 1, 1) end
	if parent.level and UnitLevel("player") < parent.level then
		GameTooltip:AddLine(format(L["Micro_PlayerReq"], parent.level), LUI:NegativeColor())
	end
	GameTooltip:Show()
end

function MicroButtonClickerMixin:OnLeave()
	self:SetAlpha(self:GetParent().Opened and 1 or 0)
	self.Hover = nil
	GameTooltip:Hide()
end

MicroButtonClickerMixin.clickerBackdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = nil, tile = false, tileSize = 0, edgeSize = 1,
	insets = {left = 0, right = 0, top = 0, bottom = 0}
}

function module:NewMicroButton(buttonData)
	local r, g, b, a_ = module:RGBA("Micromenu")
	local name = buttonData.name

	local button = CreateFrame("Frame", "LUIMicromenu_"..name, UIParent)
	button:SetSize(TEXTURE_SIZE_WIDTH, TEXTURE_SIZE_HEIGHT)
	Mixin(button, buttonData)

	-- Make an icon for the button
	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetPoint("CENTER", 0, 0)
	button.icon:SetTexture(format(TEXTURE_PATH_FORMAT, strlower(name)))
	button.icon:SetTexCoord(LUI:GetCoordAtlas("MicroBtn_Icon"))
	button.icon:SetVertexColor(r, g, b)

	-- Make a border for the button
	button.border = button:CreateTexture(nil, "ARTWORK")
	button.border:SetAllPoints()
	button.border:SetTexture(format(TEXTURE_PATH_FORMAT, "border"))
	button.border:SetTexCoord(LUI:GetCoordAtlas("MicroBtn_Default"))
	button.border:SetVertexColor(r, g, b)

	-- Make a button for the clickable area of the texture with black background.
	button.clicker = CreateFrame("Button", nil, button, "BackdropTemplate")
	button.clicker:SetSize(TEXTURE_CLICK_WIDTH , TEXTURE_CLICK_HEIGHT)
	button.clicker:RegisterForClicks("AnyUp")
	button.clicker:SetBackdrop(MicroButtonClickerMixin.clickerBackdrop)
	button.clicker:SetPoint("CENTER", button, "CENTER", -1, 0)
	button.clicker:SetBackdropColor(0, 0, 0, 1)
	button.clicker:SetAlpha(0)
	-- Push down the clicker frame so it doesn't go above the texture.
	button.clicker:SetFrameLevel(button:GetFrameLevel()-1)

	-- Handle some definition-based info
	if button.OnClick then
		button.clicker:SetScript("OnClick", button.OnClick)
	end
	-- This is a bit of a mess and can probably be modified
	if button.state then
		if button.addon then
			if not IsAddOnLoaded(button.addon) then
				addonLoadedCallbacks[button.addon] = function() 
					module:ClickerStateUpdateHandler(button, button.state)
				end
			else
				module:ClickerStateUpdateHandler(button, button.state)
			end
		else
			module:ClickerStateUpdateHandler(button, button.state)
		end
	end
	-- if button.alertFrame then
	-- 	module:HookAlertFrame(button.alertFrame, button)
	-- end

	button.clicker:SetScript("OnEnter", MicroButtonClickerMixin.OnEnter)
	button.clicker:SetScript("OnLeave", MicroButtonClickerMixin.OnLeave)
	return button
end

-- ####################################################################################################################
-- ##### Module Setup #################################################################################################
-- ####################################################################################################################

--- Consolidates all the possible options frames into one for easy hooking
function module:ConsolidateOptionsFrames()
	local optionsFrames = CreateFrame("Frame", "ConsolidatedOptionsFrame", UIParent)

	local function UpdateState()
		-- When one of the hooked frames are shown or hidden, check if any frame
		-- is currently open and update consolidated state
		if GameMenuFrame:IsShown() or ACD.OpenFrames["LUI4Options"] then
			optionsFrames:Show()
		else
			optionsFrames:Hide()
		end
	end

	-- The GameMenuFrame is easy enough
	hooksecurefunc(GameMenuFrame, "Show", UpdateState)
	hooksecurefunc(GameMenuFrame, "Hide", UpdateState)

	-- We can use ACD to hook Open, which is fired when any options frame is opened
	if ACD then
		hooksecurefunc(ACD, "Open", function()
			-- We get the LUI options frame, if its there
			optionsFrame = ACD.OpenFrames["LUI4Options"]
			if optionsFrame then
				-- Register a callback for when the frame is closed
				hooksecurefunc(optionsFrame, "Hide", UpdateState)
				-- Invoke update for this opening
				UpdateState()
			end
		end)
	end
end

--- Consolidates all the social frames into one for easy hooking
function module:ConsolidateSocialFrames()
	local socialFrames = CreateFrame("Frame", "ConsolidatedSocialFrame", UIParent)

	-- When one of the hooked frames are shown or hidden, check if any frame
	-- is currently open and update consolidated state
	local function UpdateState()
		if FriendsFrame:IsShown() or (CommunitiesFrame and CommunitiesFrame:IsShown()) then
			socialFrames:Show()
		else
			socialFrames:Hide()
		end
	end

	-- Hook OnShow and OnHide from the friends frame
	FriendsFrame:HookScript("OnShow", UpdateState)
	FriendsFrame:HookScript("OnHide", UpdateState)

	-- Hook OnShow and OnHide from the communities frame once its available
	addonLoadedCallbacks["Blizzard_Communities"] = function()
		CommunitiesFrame:HookScript("OnShow", UpdateState)
		CommunitiesFrame:HookScript("OnHide", UpdateState)
	end
end

--- Consolidates all the possible bag frames into one for easy hooking
function module:ConsolidateBagFrames()
	local bagFrames = CreateFrame("Frame", "ConsolidatedBagFrame", UIParent)

	-- AddOn support
	local addonBagFrame
	-- ENABLE ONCE MODULE IS DONE
	-- if LUI:GetModule("Bags").db.profile.Enable then
	-- 	addonBagFrame = LUIBags
	-- else
	if IsAddOnLoaded("Stuffing") then
		addonBagFrame = StuffingFrameBags
	elseif IsAddOnLoaded("Bagnon") then
		addonBagFrame = BagnonFrameinventory
	elseif IsAddOnLoaded("ArkInventory") then
		addonBagFrame = ARKINV_Frame1
	elseif IsAddOnLoaded("OneBag") then
		addonBagFrame = OneBagFrame
	else
		addonBagFrame = nil
	end

	-- When one of the hooked frames are shown or hidden, check if any frame
	-- is currently open and update consolidated state
	local function UpdateState()
		if (addonBagFrame and addonBagFrame:IsShown()) or IsBagOpen(0) or IsBagOpen(1) or IsBagOpen(2) or IsBagOpen(3) or IsBagOpen(4) then
			bagFrames:Show()
		else
			bagFrames:Hide()
		end
	end

	-- Hook OnShow and OnHide from the default UI bag frames
	for i = 1, 5 do
		_G["ContainerFrame"..i]:HookScript("OnShow", UpdateState)
		_G["ContainerFrame"..i]:HookScript("OnHide", UpdateState)
	end

	-- Hook OnShow and OnHide from any addon bag frame
	if addonBagFrame then
		addonBagFrame:HookScript("OnShow", UpdateState)
		addonBagFrame:HookScript("OnHide", UpdateState)
	end
end

function module:SetMicromenuAnchors()
	local firstAnchor, previousAnchor

	-- Need to invert this depending on direction, or it will increase one and shrink the other
	local buttonSpacing = (db.Direction == "LEFT" and (db.Spacing - 2)) or -(db.Spacing - 2)

	-- Due to the visual appearance of the borders, a fully centered icon will look badly placed
	-- in the smaller buttons, so need a a little offset
	local iconXOffset = (db.Direction == "LEFT") and 1 or -1

	-- Iterate through all the created micromenu buttons
	for i = 1, #microStorage do
		-- Local reference to button, and clear its point
		local button = microStorage[i]
		button:ClearAllPoints()

		-- Update its state based on db options
		if db[("Hide")..button.name] then
			button:Hide()
		else
			button:Show()
		end

		-- Only continue if the button is shown
		if button:IsShown() then
			-- We are dealing with the first button
			if not firstAnchor then
				-- The first button should use the first texture width, wide size, and the first texture coords
				button:SetPoint(db.Point, UIParent, db.Point, db.X, db.Y)
				button:SetWidth(FIRST_TEXTURE_SIZE_WIDTH)
				button.clicker:SetWidth(WIDE_TEXTURE_CLICK_WIDTH)
				button.border:SetTexCoord(module:GetDirectionalTexCoord("MicroBtn_First"))
				button.icon:ClearAllPoints()
				button.icon:SetPoint("CENTER", 0, 0)
				firstAnchor = button
				previousAnchor = button
			-- We are dealing with a middle button
			else
				-- The middle button should use the normal texture width, size, and the default texture coords
				button:SetPoint(db.Direction, previousAnchor, LUI.Opposites[db.Direction], buttonSpacing, 0)
				button:SetWidth(TEXTURE_SIZE_WIDTH)
				button.clicker:SetWidth(TEXTURE_CLICK_WIDTH)
				button.border:SetTexCoord(module:GetDirectionalTexCoord("MicroBtn_Default"))
				button.icon:ClearAllPoints()
				button.icon:SetPoint("CENTER", iconXOffset, 0)
				previousAnchor = button
			end
		end
	end

	-- In order to update the last button, we need to iterate from the back of the list,
	-- check for the first shown button that we find and update accordingly
	-- Maybe this can also be dealt with another way
	for i = #microStorage, 1, -1 do
		local button = microStorage[i]
		if button:IsShown() then
			button:SetWidth(LAST_TEXTURE_SIZE_WIDTH)
			button.clicker:SetWidth(WIDE_TEXTURE_CLICK_WIDTH)
			button.border:SetTexCoord(module:GetDirectionalTexCoord("MicroBtn_Last"))
			button.icon:ClearAllPoints()
			button.icon:SetPoint("CENTER", 0, 0)
			return
		end
	end

	module.background:ClearAllPoints()
	-- In case all the buttons are hidden in the options
	if not firstAnchor then return end

	local point = "TOP"..db.Direction
	module.background:SetPoint(point, firstAnchor, point)
	module.background:SetPoint(LUI.Opposites[point], previousAnchor, LUI.Opposites[point])
end

function module:SetMicromenu()
	-- Create Micromenu background
	local background = CreateFrame("Frame", "LUIMicromenu_Background", UIParent, "BackdropTemplate")
	background:SetBackdrop({
		bgFile = BACKGROUND_TEXTURE_PATH,
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false, tilseSize = 0, edgeSize = 1,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	})
	background:SetFrameStrata("BACKGROUND")
	background:SetBackdropColor(module:RGBA((db.ColorMatch) and "Micromenu" or "Background"))
	background:SetBackdropBorderColor(0, 0, 0, 0)
	module.background = background

	-- Create Micromenu buttons
	for i = 1, #microDefinitions do
		table.insert(microStorage, module:NewMicroButton(microDefinitions[i]))
	end

	module:SetMicromenuAnchors()
end

--- Fires the stored functions for the frame hooks
-- Doing it this way instead of loading the required addons in OnEnable
function module:OnEvent(_, addon)
	if addonLoadedCallbacks[addon] then
		addonLoadedCallbacks[addon]()
		addonLoadedCallbacks[addon] = nil
	end
end

-- ####################################################################################################################
-- ##### Module Refresh ###############################################################################################
-- ####################################################################################################################

function module:Refresh()
	module:SetMicromenuAnchors()
	-- module:SetAlertFrameColors("EJ")
	-- module:SetAlertFrameColors("Talent")
	-- module:SetAlertFrameColors("Collections")

	module.background:SetBackdropColor(module:RGBA((db.ColorMatch) and "Micromenu" or "Background"))
	local r, g, b, a_ = module:RGBA("Micromenu")
	for i = 1, #microList do
		local button = microStorage[microList[i]]
		if button then
			button.tex:SetVertexColor(r, g, b)
		end
	end
end

-- ####################################################################################################################
-- ##### Framework Events #############################################################################################
-- ####################################################################################################################

function module:OnInitialize()
	LUI:RegisterModule(module)
	db = module.db.profile
end

function module:OnEnable()
	-- We use the OnEvent function to fire functions required for the clicker state handlers
	module:RegisterEvent("ADDON_LOADED", "OnEvent")

	-- We consolidate some frames into one for easy hooking and less spaghetti
	module:ConsolidateOptionsFrames()
	module:ConsolidateSocialFrames()
	module:ConsolidateBagFrames()

	-- Finally we set up the actual micromenu
	module:SetMicromenu()
end

function module:OnDisable()
end
