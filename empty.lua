local Empty = {}
local L = SUFBarsLocals
local SL = ShadowUFLocals
ShadowUF:RegisterModule(Empty, "emptyBar", L["Empty bar"], true)

function Empty:OnEnable(frame)
	frame.emptyBar = frame.emptyBar or CreateFrame("StatusBar", nil, frame)
end

function Empty:OnDisable(frame)

end

function Empty:OnLayoutApplied(frame, config)
	if( frame.visibility.emptyBar ) then
		frame.emptyBar:SetStatusBarTexture(config.emptyBar.texture and ShadowUF.Layout.mediaPath.statusbar or nil)
		frame.emptyBar:SetStatusBarColor(config.emptyBar.r, config.emptyBar.g, config.emptyBar.b, config.emptyBar.a)
	end
end

function Empty:OnDefaultsSet()
	for _, unit in pairs(ShadowUF.units) do
		ShadowUF.defaults.profile.units[unit].emptyBar = {enabled = false, texture = true, height = 0.8, order = 0, r = 0, g = 0, b = 0, a = 1}
	end
end

function Empty:OnConfigurationLoad()
	ShadowUF.Config.unitTable.args.bars.args.emptyBar = {
		order = 1.5,
		type = "group",
		inline = true,
		name = L["Empty bar"],
		hidden = false,
		args = {
			enabled = {
				order = 1,
				type = "toggle",
				name = string.format(SL["Enable %s"], "Empty bar"),
				arg = "emptyBar.enabled",
			},
			--[[
			texture = {
				order = 2,
				type = "toggle",
				name = L["Use texture"],
				desc = L["When enabled it will use a bar texture colored by whatever you set, if you don't enabled this then a solid color is shown with whatever alpha setting you choose."],
				arg = "emptyBar.texture",
			},
			]]
			color = {
				order = 3,
				type = "color",
				name = L["Color"],
				hasAlpha = true,
				set = function(info, r, g, b, a)
					local tbl = ShadowUF.Config.getVariable(info[2], nil, nil, "emptyBar")
					tbl.r = r
					tbl.g = g
					tbl.b = b
					tbl.a = a
					
					ShadowUF.Layout:Reload()
				end,
				get = function(info)
					local tbl = ShadowUF.Config.getVariable(info[2], nil, nil, "emptyBar")
					return tbl.r, tbl.g, tbl.b, tbl.a
				end,
			},
		},
	}
end

local OnInitialize = ShadowUF.OnInitialize
ShadowUF.OnInitialize = function(self)
	OnInitialize(self)
	
	-- Add new text for the empty bar
	for _, unit in pairs(ShadowUF.units) do
		local foundLeft, foundRight
		for _, text in pairs(ShadowUF.db.profile.units[unit].text) do
			if( text.anchorTo == "$emptyBar" ) then
				if( text.name == SL["Left text"] ) then foundLeft = text end
				if( text.name == SL["Right text"] ) then foundRight = text end
			end
		end
		
		if( not foundLeft ) then
			table.insert(ShadowUF.db.profile.units[unit].text, {width = 0.60, enabled = true, name = SL["Left text"], text = "[name]", anchorTo = "$emptyBar", anchorPoint = "CLI", size = 0, x = 0, y = 0})
		elseif( foundLeft.anchorPoint == "ICL" ) then
			foundLeft.anchorPoint = "CLI"
		end
		
		if( not foundRight ) then
			table.insert(ShadowUF.db.profile.units[unit].text, {width = 0.40, enabled = true, name = SL["Right text"], text = "", anchorTo = "$emptyBar", anchorPoint = "CRI", size = 0, x = 0, y = 0})
		elseif( foundRight.anchorPoint == "ICL" ) then
			foundRight.anchorPoint = "CLI"
		end
	end
end
