--[[ 
	Shadow Unit Frames (Bars), Shadow of Mal'Ganis (US) PvP
]]

local Bars = select(2, ...)
local L = Bars.L
local SL = ShadowUF.L or ShadowUFLocals
ShadowUF:RegisterModule(Bars, "impbars")

-- Technically speaking, this is invalid. Setting a width to 0 will defaulkt it to 2x the bar size or so (not sure why but quick fix)
-- setting it to anything above or below 0 will make it basically hidden which suits the purpose nicely
local size, percent
local function SetValue(self, value)
	percent = value / self.impBar.maxValue
	percent = percent > 1 and 1 or percent < 0 and 0 or percent
	
	if( self.impBar.growth == "horizontal" ) then
		size = percent * self:GetWidth()
		self.impBar:SetWidth(size <= 0 and 0.01 or size)
	else
		size = percent * self:GetHeight()
		self.impBar:SetHeight(size <= 0 and 0.01 or size)
	end
	
	self.impBar.currentValue = value
end

local function GetValue(self)
	return self.impBar.currentValue
end

local function SetMinMaxValues(self, min, max)
	self.impBar.minValue = min
	self.impBar.maxValue = max
end

local function GetMinMaxValues(self)
	return self.impBar.minValue, self.impBar.maxValue
end

local function SetStatusBarColor(self, r, g, b, a)
	if( self.impBar.invert ) then
		self.impBar:SetVertexColor(0, 0, 0, 0.90)
		self.impBar.origBarColor(self, r, g, b, a)
	else
		self.impBar:SetVertexColor(r, g, b, a)
	end
end

local function positionBar(bar, parent, barType)
	bar.impBar:SetTexture(ShadowUF.Layout.mediaPath.statusbar)
	
	-- When inverted bars are on, the old status bar becomes the background
	if( bar == parent ) then
		bar.impBar.invert = ShadowUF.db.profile.units[bar.parent.unitType][barType].invert
		bar.impBar.origSetValue(bar, bar.impBar.invert and 1 or 0)
	end
	
	local drawType = ShadowUF.db.profile.units[bar.parent.unitType][barType].growth
	-- Top -> Bottom meaning anchor to the top
	if( drawType == "TOP:BOTTOM" ) then
		bar.impBar.growth = "vertical"
		bar.impBar:ClearAllPoints()
		bar.impBar:SetPoint("BOTTOMLEFT", parent)
		bar.impBar:SetPoint("BOTTOMRIGHT", parent)
	
	-- Bottom -> Top meaning anchor to the bottom
	elseif( drawType == "BOTTOM:TOP" ) then
		bar.impBar.growth = "vertical"
		bar.impBar:ClearAllPoints()
		bar.impBar:SetPoint("TOPLEFT", parent)
		bar.impBar:SetPoint("TOPRIGHT", parent)
	
	-- Left -> Right meaning anchor to the right
	elseif( drawType == "LEFT:RIGHT" ) then
		bar.impBar.growth = "horizontal"
		bar.impBar:ClearAllPoints()
		bar.impBar:SetPoint("TOPRIGHT", parent)
		bar.impBar:SetPoint("BOTTOMRIGHT", parent)
	
	-- Right -> Left meaning anchor to the left side so at full width it touches the right side
	else
		bar.impBar.growth = "horizontal"
		bar.impBar:ClearAllPoints()
		bar.impBar:SetPoint("TOPLEFT", parent, 0, 0)
		bar.impBar:SetPoint("BOTTOMLEFT", parent, 0, 0)
	end
end

function Bars:OnLayoutApplied(frame)
	if( frame.healthBar and frame.healthBar.impBar ) then
		positionBar(frame.healthBar, frame.healthBar, "healthBar")
	end

	if( frame.incHeal and frame.incHeal.impBar ) then
		positionBar(frame.incHeal, frame.healthBar, "healthBar")
	end

	if( frame.powerBar and frame.powerBar.impBar ) then
		positionBar(frame.powerBar, frame.powerBar, "powerBar")
	end
end

function Bars:OnConfigurationLoad()
	for _, unit in pairs(ShadowUF.unitList) do
		local data = ShadowUF.db.profile.units[unit]
		data.healthBar.growth = data.healthBar.growth or "RIGHT:LEFT"
		data.powerBar.growth = data.powerBar.growth or "RIGHT:LEFT"
	end
	
	local barTable = ShadowUF.Config.barTable
	barTable.args.invert = {
		order = 2.25,
		type = "toggle",
		name = L["Invert colors"],
		desc = L["Inverts the bar color so it's easier to see the deficit."],
		hidden = function(info) return info[#(info) - 1] ~= "healthBar" and info[#(info) - 1] ~= "powerBar" end,
		arg = "$parent.invert",
	}
	
	barTable.args.growthSep = {
		order = 2.5,
		type = "description",
		name = "",
		hidden = function(info) return info[#(info) - 1] ~= "healthBar" and info[#(info) - 1] ~= "powerBar" end,
		width = "full",
	}

	barTable.args.barGrowh = {
		order = 3,
		type = "select",
		name = L["Bar growth"],
		desc = L["How the bar should grow, left -> right means that at 75% it will be 75% away from the right side, at 25% it means it'll be 25% away from the right side."],
		values = {["LEFT:RIGHT"] = L["Left -> Right"], ["RIGHT:LEFT"] = L["Right -> Left"], ["TOP:BOTTOM"] = L["Top -> Bottom"], ["BOTTOM:TOP"] = L["Bottom -> Top"]},
		arg = "$parent.growth",
		hidden = function(info) return info[#(info) - 1] ~= "healthBar" and info[#(info) - 1] ~= "powerBar" end,
	}
end

-- Hook the OnEnables to ensure we have the first hook on the bars
local function hookModule(module)
	local OnEnable = module.OnEnable
	module.OnEnable = function(self, frame, ...)
		OnEnable(self, frame, ...)

		local bar = frame[self.moduleKey]
		if( not bar.impBar ) then
			bar.impBar = bar:CreateTexture(nil, "ARTWORK")

			bar.impBar.minValue = 0
			bar.impBar.maxValue = 0
			bar.impBar.currentValue = 0
			bar.impBar.origBarColor = bar.SetStatusBarColor
			bar.impBar.origSetValue = bar.SetValue

			bar:SetMinMaxValues(0, 1)
			bar:SetValue(0)

			bar.SetValue = SetValue
			bar.GetValue = GetValue
			bar.SetMinMaxValues = SetMinMaxValues
			bar.GetMinMaxValues = GetMinMaxValues
			bar.SetStatusBarColor = SetStatusBarColor
		end
	end
end

hookModule(ShadowUF.modules.healthBar)
hookModule(ShadowUF.modules.incHeal)
hookModule(ShadowUF.modules.powerBar)

for frame in pairs(ShadowUF.Units.frameList) do
	if( frame.visibility.healthBar ) then
		ShadowUF.modules.healthBar:OnEnable(frame)

		if( frame.visibility.incHeal ) then
			ShadowUF.modules.incHeal:OnEnable(frame)
		end
	end
	
	if( frame.visibility.powerBar ) then
		ShadowUF.modules.powerBar:OnEnable(frame)
	end
	
	if( frame.visibility.healthBar or frame.visibility.powerBar ) then
		ShadowUF.Layout:Load(frame)
		ShadowUF:FireModuleEvent("OnLayoutReload", frame.unit)
		frame:FullUpdate()
	end
end
