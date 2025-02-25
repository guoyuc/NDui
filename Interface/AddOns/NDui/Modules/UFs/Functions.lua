local _, ns = ...
local B, C, L, DB = unpack(ns)

local oUF = ns.oUF
local UF = B:RegisterModule("UnitFrames")
local AURA = B:GetModule("Auras")

local format, floor = string.format, math.floor
local pairs, next, unpack = pairs, next, unpack
local UnitGUID, IsItemInRange = UnitGUID, IsItemInRange
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave
local SpellGetVisibilityInfo, UnitAffectingCombat, SpellIsSelfBuff, SpellIsPriorityAura = SpellGetVisibilityInfo, UnitAffectingCombat, SpellIsSelfBuff, SpellIsPriorityAura

-- Custom colors
oUF.colors.smooth = {1, 0, 0, .85, .8, .45, .1, .1, .1}
oUF.colors.debuff.none = {0, 0, 0}

local function ReplacePowerColor(name, index, color)
	oUF.colors.power[name] = color
	oUF.colors.power[index] = oUF.colors.power[name]
end
ReplacePowerColor("MANA", 0, {0, .4, 1})
ReplacePowerColor("SOUL_SHARDS", 7, {.58, .51, .79})
ReplacePowerColor("HOLY_POWER", 9, {.88, .88, .06})
ReplacePowerColor("CHI", 12, {0, 1, .59})
ReplacePowerColor("ARCANE_CHARGES", 16, {.41, .8, .94})

-- Various values
local function retVal(self, val1, val2, val3, val4, val5)
	local mystyle = self.mystyle
	if mystyle == "player" or mystyle == "target" then
		return val1
	elseif mystyle == "focus" then
		return val2
	elseif mystyle == "boss" or mystyle == "arena" then
		return val3
	else
		if mystyle == "nameplate" and val5 then
			return val5
		else
			return val4
		end
	end
end

-- Elements
local function UF_OnEnter(self)
	if not self.disableTooltip then
		UnitFrame_OnEnter(self)
	end
	self.Highlight:Show()
end

local function UF_OnLeave(self)
	if not self.disableTooltip then
		UnitFrame_OnLeave(self)
	end
	self.Highlight:Hide()
end

function UF:CreateHeader(self)
	local hl = self:CreateTexture(nil, "OVERLAY")
	hl:SetAllPoints()
	hl:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	hl:SetTexCoord(0, 1, .5, 1)
	hl:SetVertexColor(.6, .6, .6)
	hl:SetBlendMode("ADD")
	hl:Hide()
	self.Highlight = hl

	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", UF_OnEnter)
	self:HookScript("OnLeave", UF_OnLeave)
end

local function UpdateHealthColorByIndex(health, index)
	health.colorClass = (index == 2)
	health.colorReaction = (index == 2)
	if health.SetColorTapping then
		health:SetColorTapping(index == 2)
	else
		health.colorTapping = (index == 2)
	end
	if health.SetColorDisconnected then
		health:SetColorDisconnected(index == 2)
	else
		health.colorDisconnected = (index == 2)
	end
	health.colorSmooth = (index == 3)
	if index == 1 then
		health:SetStatusBarColor(.1, .1, .1)
		health.bg:SetVertexColor(.6, .6, .6)
	end
end

function UF:UpdateHealthBarColor(self, force)
	local health = self.Health
	local mystyle = self.mystyle
	if mystyle == "PlayerPlate" then
		health.colorHealth = true
	elseif mystyle == "raid" then
		UpdateHealthColorByIndex(health, C.db["UFs"]["RaidHealthColor"])
	else
		UpdateHealthColorByIndex(health, C.db["UFs"]["HealthColor"])
	end

	if force then
		health:ForceUpdate()
	end
end

function UF:CreateHealthBar(self)
	local mystyle = self.mystyle
	local health = CreateFrame("StatusBar", nil, self)
	health:SetPoint("TOPLEFT", self)
	health:SetPoint("TOPRIGHT", self)
	local healthHeight
	if mystyle == "PlayerPlate" then
		healthHeight = C.db["Nameplate"]["PPHealthHeight"]
	elseif mystyle == "raid" then
		if self.raidType == "party" then
			healthHeight = C.db["UFs"]["PartyHeight"]
		elseif self.raidType == "pet" then
			healthHeight = C.db["UFs"]["PartyPetHeight"]
		elseif self.raidType == "simple" then
			local scale = C.db["UFs"]["SMRScale"]/10
			healthHeight = 20*scale - 2*scale - C.mult
		else
			healthHeight = C.db["UFs"]["RaidHeight"]
		end
	else
		healthHeight = retVal(self, C.db["UFs"]["PlayerHeight"], C.db["UFs"]["FocusHeight"], C.db["UFs"]["BossHeight"], C.db["UFs"]["PetHeight"])
	end
	health:SetHeight(healthHeight)
	health:SetStatusBarTexture(DB.normTex)
	health:SetStatusBarColor(.1, .1, .1)
	health:SetFrameLevel(self:GetFrameLevel() - 2)
	health.backdrop = B.SetBD(health, 0) -- don't mess up with libs
	health.shadow = health.backdrop.__shadow
	B:SmoothBar(health)

	local bg = health:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.bdTex)
	bg:SetVertexColor(.6, .6, .6)
	bg.multiplier = .25

	self.Health = health
	self.Health.bg = bg

	UF:UpdateHealthBarColor(self)
end

function UF:UpdateRaidHealthMethod()
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "raid" then
			frame:SetHealthUpdateMethod(C.db["UFs"]["FrequentHealth"])
			frame:SetHealthUpdateSpeed(C.db["UFs"]["HealthFrequency"])
			frame.Health:ForceUpdate()
		end
	end
end

UF.VariousTagIndex = {
	[1] = "",
	[2] = "currentpercent",
	[3] = "currentmax",
	[4] = "current",
	[5] = "percent",
	[6] = "loss",
	[7] = "losspercent",
}

function UF:UpdateFrameHealthTag()
	local mystyle = self.mystyle
	local valueType
	if mystyle == "player" or mystyle == "target" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["PlayerHPTag"]]
	elseif mystyle == "focus" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["FocusHPTag"]]
	elseif mystyle == "boss" or mystyle == "arena" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["BossHPTag"]]
	else
		valueType = UF.VariousTagIndex[C.db["UFs"]["PetHPTag"]]
	end

	self:Tag(self.healthValue, "[VariousHP("..valueType..")]")
	self.healthValue:UpdateTag()
end

function UF:UpdateFrameNameTag()
	local name = self.nameText
	if not name then return end

	local mystyle = self.mystyle
	if mystyle == "nameplate" then return end

	local value = mystyle == "raid" and "RCCName" or "CCName"
	local colorTag = C.db["UFs"][value] and "[color]" or ""

	if mystyle == "player" then
		self:Tag(name, " "..colorTag.."[name]")
	elseif mystyle == "target" then
		self:Tag(name, "[fulllevel] "..colorTag.."[name][afkdnd]")
	elseif mystyle == "focus" then
		self:Tag(name, colorTag.."[name][afkdnd]")
	elseif mystyle == "arena" then
		self:Tag(name, "[arenaspec] "..colorTag.."[name]")
	elseif self.raidType == "simple" and C.db["UFs"]["TeamIndex"] then
		self:Tag(name, "[group] "..colorTag.."[name]")
	else
		self:Tag(name, colorTag.."[name]")
	end
	name:UpdateTag()
end

function UF:UpdateRaidNameAnchor(name)
	if self.raidType == "pet" then
		name:ClearAllPoints()
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetWidth(self:GetWidth()*.95)
			name:SetJustifyH("CENTER")
			name:SetPoint("CENTER")
		else
			name:SetWidth(self:GetWidth()*.65)
			name:SetJustifyH("LEFT")
			name:SetPoint("LEFT", 3, -1)
		end
	elseif self.raidType == "simple" then
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetWidth(self:GetWidth()*.95)
		else
			name:SetWidth(self:GetWidth()*.65)
		end
	else
		name:ClearAllPoints()
		name:SetWidth(self:GetWidth()*.95)
		name:SetJustifyH("CENTER")
		if C.db["UFs"]["RaidHPMode"] == 1 then
			name:SetPoint("CENTER")
		else
			name:SetPoint("TOP", 0, -3)
		end
	end
end

function UF:CreateHealthText(self)
	local mystyle = self.mystyle
	local textFrame = CreateFrame("Frame", nil, self)
	textFrame:SetAllPoints(self.Health)

	local name = B.CreateFS(textFrame, retVal(self, 13, 12, 12, 12, C.db["Nameplate"]["NameTextSize"]), "", false, "LEFT", 3, 0)
	self.nameText = name
	name:SetJustifyH("LEFT")
	if mystyle == "raid" then
		UF.UpdateRaidNameAnchor(self, name)
		name:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "nameplate" then
		name:ClearAllPoints()
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
		name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 5)
		self:Tag(name, "[nplevel][name]")
	else
		name:SetWidth(self:GetWidth()*.55)
	end

	UF.UpdateFrameNameTag(self)

	local hpval = B.CreateFS(textFrame, retVal(self, 13, 12, 12, 12, C.db["Nameplate"]["HealthTextSize"]), "", false, "RIGHT", -3, 0)
	self.healthValue = hpval
	if mystyle == "raid" then
		self:Tag(hpval, "[raidhp]")
		if self.raidType == "pet" then
			hpval:SetPoint("RIGHT", -3, -1)
		elseif self.raidType == "simple" then
			hpval:SetPoint("RIGHT", -4, 0)
		else
			hpval:ClearAllPoints()
			hpval:SetPoint("BOTTOM", 0, 1)
			hpval:SetJustifyH("CENTER")
		end
		hpval:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "nameplate" then
		hpval:SetPoint("RIGHT", self, 0, 5)
		self:Tag(hpval, "[VariousHP(currentpercent)]")
	else
		UF.UpdateFrameHealthTag(self)
	end
end

local function UpdatePowerColorByIndex(power, index)
	power.colorPower = (index == 2)
	power.colorClass = (index ~= 2)
	power.colorReaction = (index ~= 2)
	if power.SetColorTapping then
		power:SetColorTapping(index ~= 2)
	else
		power.colorTapping = (index ~= 2)
	end
	if power.SetColorDisconnected then
		power:SetColorDisconnected(index ~= 2)
	else
		power.colorDisconnected = (index ~= 2)
	end
end

function UF:UpdatePowerBarColor(self, force)
	local power = self.Power
	local mystyle = self.mystyle
	if mystyle == "PlayerPlate" then
		power.colorPower = true
	elseif mystyle == "raid" then
		UpdatePowerColorByIndex(power, C.db["UFs"]["RaidHealthColor"])
	else
		UpdatePowerColorByIndex(power, C.db["UFs"]["HealthColor"])
	end

	if force then
		power:ForceUpdate()
	end
end

local frequentUpdateCheck = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["PlayerPlate"] = true,
}
function UF:CreatePowerBar(self)
	local mystyle = self.mystyle
	local power = CreateFrame("StatusBar", nil, self)
	power:SetStatusBarTexture(DB.normTex)
	power:SetPoint("BOTTOMLEFT", self)
	power:SetPoint("BOTTOMRIGHT", self)
	local powerHeight
	if mystyle == "PlayerPlate" then
		powerHeight = C.db["Nameplate"]["PPPowerHeight"]
	elseif mystyle == "raid" then
		if self.raidType == "party" then
			powerHeight = C.db["UFs"]["PartyPowerHeight"]
		elseif self.raidType == "pet" then
			powerHeight = C.db["UFs"]["PartyPetPowerHeight"]
		elseif self.raidType == "simple" then
			powerHeight = 2*C.db["UFs"]["SMRScale"]/10
		else
			powerHeight = C.db["UFs"]["RaidPowerHeight"]
		end
	else
		powerHeight = retVal(self, C.db["UFs"]["PlayerPowerHeight"], C.db["UFs"]["FocusPowerHeight"], C.db["UFs"]["BossPowerHeight"], C.db["UFs"]["PetPowerHeight"])
	end
	power:SetHeight(powerHeight)
	power:SetFrameLevel(self:GetFrameLevel() - 2)
	power.backdrop = B.CreateBDFrame(power, 0)
	B:SmoothBar(power)

	if self.Health.shadow then
		self.Health.shadow:SetPoint("BOTTOMRIGHT", power.backdrop, C.mult+3, -C.mult-3)
	end

	local bg = power:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25

	self.Power = power
	self.Power.bg = bg

	power.frequentUpdates = frequentUpdateCheck[mystyle]
	UF:UpdatePowerBarColor(self)
end

function UF:UpdateFramePowerTag()
	local mystyle = self.mystyle
	local valueType
	if mystyle == "player" or mystyle == "target" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["PlayerMPTag"]]
	elseif mystyle == "focus" then
		valueType = UF.VariousTagIndex[C.db["UFs"]["FocusMPTag"]]
	else
		valueType = UF.VariousTagIndex[C.db["UFs"]["BossMPTag"]]
	end

	self:Tag(self.powerText, "[color][VariousMP("..valueType..")]")
	self.powerText:UpdateTag()
end

function UF:CreatePowerText(self)
	local textFrame = CreateFrame("Frame", nil, self)
	textFrame:SetAllPoints(self.Power)

	local ppval = B.CreateFS(textFrame, retVal(self, 13, 12, 12, 12), "", false, "RIGHT", -3, 2)
	local mystyle = self.mystyle
	if mystyle == "raid" then
		ppval:SetScale(C.db["UFs"]["RaidTextScale"])
	elseif mystyle == "player" or mystyle == "target" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["PlayerPowerOffset"])
	elseif mystyle == "focus" then
		ppval:SetPoint("RIGHT", -3, C.db["UFs"]["FocusPowerOffset"])
	end
	self.powerText = ppval
	UF.UpdateFramePowerTag(self)
end

local textScaleFrames = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["pet"] = true,
	["tot"] = true,
	["focustarget"] = true,
	["boss"] = true,
	["arena"] = true,
}
function UF:UpdateTextScale()
	local scale = C.db["UFs"]["UFTextScale"]
	for _, frame in pairs(oUF.objects) do
		local style = frame.mystyle
		if style and textScaleFrames[style] then
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			if frame.powerText then frame.powerText:SetScale(scale) end
			local castbar = frame.Castbar
			if castbar then
				castbar.Text:SetScale(scale)
				castbar.Time:SetScale(scale)
				if castbar.Lag then castbar.Lag:SetScale(scale) end
			end
			UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
		end
	end
end

function UF:UpdateRaidTextScale()
	local scale = C.db["UFs"]["RaidTextScale"]
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "raid" then
			UF.UpdateRaidNameAnchor(frame, frame.nameText)
			frame.nameText:SetScale(scale)
			frame.healthValue:SetScale(scale)
			frame.healthValue:UpdateTag()
			if frame.powerText then frame.powerText:SetScale(scale) end
			UF:UpdateHealthBarColor(frame, true)
			UF:UpdatePowerBarColor(frame, true)
			UF.UpdateFrameNameTag(frame)
			frame.disableTooltip = C.db["UFs"]["HideTip"]
		end
	end
end

function UF:CreatePortrait(self)
	if not C.db["UFs"]["Portrait"] then return end

	local portrait = CreateFrame("PlayerModel", nil, self.Health)
	portrait:SetInside()
	portrait:SetAlpha(.2)
	self.Portrait = portrait

	self.Health.bg:ClearAllPoints()
	self.Health.bg:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
	self.Health.bg:SetPoint("TOPRIGHT", self.Health)
	self.Health.bg:SetParent(self)
end

local roleTexCoord = {
	["TANK"] = {.5, .75, 0, 1},
	["HEALER"] = {.75, 1, 0, 1},
	["DAMAGER"] = {.25, .5, 0, 1},
}
local function postUpdateRole(element, role)
	if element:IsShown() then
		element:SetTexCoord(unpack(roleTexCoord[role]))
	end
end

function UF:CreateIcons(self)
	local mystyle = self.mystyle
	if mystyle == "player" then
		local combat = self:CreateTexture(nil, "OVERLAY")
		combat:SetPoint("CENTER", self, "BOTTOMLEFT")
		combat:SetSize(28, 28)
		combat:SetAtlas(DB.objectTex)
		self.CombatIndicator = combat

		local rest = self:CreateTexture(nil, "OVERLAY")
		rest:SetPoint("CENTER", self, "LEFT", -2, 4)
		rest:SetSize(18, 18)
		rest:SetTexture("Interface\\PLAYERFRAME\\DruidEclipse")
		rest:SetTexCoord(.445, .55, .648, .905)
		rest:SetVertexColor(.6, .8, 1)
		rest:SetAlpha(.7)
		self.RestingIndicator = rest
	elseif mystyle == "target" then
		local quest = self:CreateTexture(nil, "OVERLAY")
		quest:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 8)
		quest:SetSize(16, 16)
		self.QuestIndicator = quest
	end

	local phase = CreateFrame("Frame", nil, self)
	phase:SetSize(24, 24)
	phase:SetPoint("CENTER", self.Health)
	phase:SetFrameLevel(5)
	phase:EnableMouse(true)
	local icon = phase:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints()
	phase.Icon = icon
	self.PhaseIndicator = phase

	local ri = self:CreateTexture(nil, "OVERLAY")
	if mystyle == "raid" then
		ri:SetPoint("TOPRIGHT", self, 5, 5)
	else
		ri:SetPoint("TOPRIGHT", self, 0, 8)
	end
	ri:SetSize(12, 12)
	ri:SetTexture("Interface\\LFGFrame\\LFGROLE")
	ri.PostUpdate = postUpdateRole
	self.GroupRoleIndicator = ri

	local li = self:CreateTexture(nil, "OVERLAY")
	li:SetPoint("TOPLEFT", self, 0, 8)
	li:SetSize(12, 12)
	self.LeaderIndicator = li

	local ai = self:CreateTexture(nil, "OVERLAY")
	ai:SetPoint("TOPLEFT", self, 0, 8)
	ai:SetSize(12, 12)
	self.AssistantIndicator = ai
end

function UF:CreateRaidMark(self)
	local mystyle = self.mystyle
	local ri = self:CreateTexture(nil, "OVERLAY")
	if mystyle == "raid" then
		ri:SetPoint("TOP", self, 0, 10)
	elseif mystyle == "nameplate" then
		ri:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", 0, 3)
	else
		ri:SetPoint("CENTER", self, "TOP")
	end
	local size = retVal(self, 18, 13, 12, 12, 32)
	ri:SetSize(size, size)
	self.RaidTargetIndicator = ri
end

local function createBarMover(bar, text, value, anchor)
	local mover = B.Mover(bar, text, value, anchor, bar:GetHeight()+bar:GetWidth()+3, bar:GetHeight()+3)
	bar:ClearAllPoints()
	bar:SetPoint("RIGHT", mover)
	bar.mover = mover
end

local function updateSpellTarget(self, _, unit)
	UF.PostCastUpdate(self.Castbar, unit)
end

function UF:ToggleCastBarLatency(frame)
	frame = frame or _G.oUF_Player
	if not frame then return end

	if C.db["UFs"]["LagString"] then
		frame:RegisterEvent("GLOBAL_MOUSE_UP", UF.OnCastSent, true) -- Fix quests with WorldFrame interaction
		frame:RegisterEvent("GLOBAL_MOUSE_DOWN", UF.OnCastSent, true)
		frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", UF.OnCastSent, true)
	else
		frame:UnregisterEvent("GLOBAL_MOUSE_UP", UF.OnCastSent)
		frame:UnregisterEvent("GLOBAL_MOUSE_DOWN", UF.OnCastSent)
		frame:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED", UF.OnCastSent)
		if frame.Castbar then frame.Castbar.__sendTime = nil end
	end
end

function UF:CreateCastBar(self)
	local mystyle = self.mystyle
	if mystyle ~= "nameplate" and not C.db["UFs"]["Castbars"] then return end

	local cb = CreateFrame("StatusBar", "oUF_Castbar"..mystyle, self)
	cb:SetHeight(20)
	cb:SetWidth(self:GetWidth() - 22)
	B.CreateSB(cb, true, .3, .7, 1)

	if mystyle == "player" then
		cb:SetFrameLevel(10)
		cb:SetSize(C.db["UFs"]["PlayerCBWidth"], C.db["UFs"]["PlayerCBHeight"])
		createBarMover(cb, L["Player Castbar"], "PlayerCB", C.UFs.Playercb)
	elseif mystyle == "target" then
		cb:SetFrameLevel(10)
		cb:SetSize(C.db["UFs"]["TargetCBWidth"], C.db["UFs"]["TargetCBHeight"])
		createBarMover(cb, L["Target Castbar"], "TargetCB", C.UFs.Targetcb)
	elseif mystyle == "focus" then
		cb:SetFrameLevel(10)
		cb:SetSize(C.db["UFs"]["FocusCBWidth"], C.db["UFs"]["FocusCBHeight"])
		createBarMover(cb, L["Focus Castbar"], "FocusCB", C.UFs.Focuscb)
	elseif mystyle == "boss" or mystyle == "arena" then
		cb:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -8)
		cb:SetSize(self:GetWidth(), 10)
	elseif mystyle == "nameplate" then
		cb:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
		cb:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
		cb:SetHeight(self:GetHeight())
	end

	local timer = B.CreateFS(cb, 12, "", false, "RIGHT", -2, 0)
	local name = B.CreateFS(cb, 12, "", false, "LEFT", 2, 0)
	name:SetPoint("RIGHT", timer, "LEFT", -5, 0)
	name:SetJustifyH("LEFT")

	if mystyle ~= "boss" and mystyle ~= "arena" then
		cb.Icon = cb:CreateTexture(nil, "ARTWORK")
		cb.Icon:SetSize(cb:GetHeight(), cb:GetHeight())
		cb.Icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -3, 0)
		cb.Icon:SetTexCoord(unpack(DB.TexCoord))
		B.SetBD(cb.Icon)
	end

	if mystyle == "player" then
		local safeZone = cb:CreateTexture(nil, "OVERLAY")
		safeZone:SetTexture(DB.normTex)
		safeZone:SetVertexColor(1, 0, 0, .6)
		safeZone:SetPoint("TOPRIGHT")
		safeZone:SetPoint("BOTTOMRIGHT")
		cb:SetFrameLevel(10)
		cb.SafeZone = safeZone

		local lagStr = B.CreateFS(cb, 10)
		lagStr:ClearAllPoints()
		lagStr:SetPoint("BOTTOM", cb, "TOP", 0, 2)
		cb.LagString = lagStr

		UF:ToggleCastBarLatency(self)
	elseif mystyle == "nameplate" then
		name:SetPoint("TOPLEFT", cb, "LEFT", 0, -1)
		timer:SetPoint("TOPRIGHT", cb, "RIGHT", 0, -1)

		local shield = cb:CreateTexture(nil, "OVERLAY")
		shield:SetAtlas("nameplates-InterruptShield")
		shield:SetSize(18, 18)
		shield:SetPoint("TOP", cb, "CENTER", 0, -1)
		cb.Shield = shield

		local iconSize = self:GetHeight()*2 + 5
		cb.Icon:SetSize(iconSize, iconSize)
		cb.Icon:SetPoint("BOTTOMRIGHT", cb, "BOTTOMLEFT", -5, 0)
		cb.timeToHold = .5

		cb.glowFrame = B.CreateGlowFrame(cb, iconSize)
		cb.glowFrame:SetPoint("CENTER", cb.Icon)

		local spellTarget = B.CreateFS(cb, C.db["Nameplate"]["NameTextSize"]+3)
		spellTarget:ClearAllPoints()
		spellTarget:SetJustifyH("LEFT")
		spellTarget:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -2)
		cb.spellTarget = spellTarget

		self:RegisterEvent("UNIT_TARGET", updateSpellTarget)
	end

	if mystyle == "nameplate" or mystyle == "boss" or mystyle == "arena" then
		cb.decimal = "%.1f"
	else
		cb.decimal = "%.2f"
	end

	cb.Time = timer
	cb.Text = name
	cb.OnUpdate = UF.OnCastbarUpdate
	cb.PostCastStart = UF.PostCastStart
	cb.PostCastUpdate = UF.PostCastUpdate
	cb.PostCastStop = UF.PostCastStop
	cb.PostCastFail = UF.PostCastFailed
	cb.PostCastInterruptible = UF.PostUpdateInterruptible

	self.Castbar = cb
end

function UF:ToggleCastBar(unit)
	if not self or not unit then return end

	if C.db["UFs"][unit.."CB"] and not self:IsElementEnabled("Castbar") then
		self:EnableElement("Castbar")
	elseif not C.db["UFs"][unit.."CB"] and self:IsElementEnabled("Castbar") then
		self:DisableElement("Castbar")
	end
end

local function reskinTimerBar(bar)
	bar:SetSize(280, 15)
	B.StripTextures(bar)

	local statusbar = _G[bar:GetName().."StatusBar"]
	if statusbar then
		statusbar:SetAllPoints()
		statusbar:SetStatusBarTexture(DB.normTex)
	else
		bar:SetStatusBarTexture(DB.normTex)
	end

	B.SetBD(bar)
end

function UF:ReskinMirrorBars()
	local previous
	for i = 1, 3 do
		local bar = _G["MirrorTimer"..i]
		reskinTimerBar(bar)

		if previous then
			bar:SetPoint("TOP", previous, "BOTTOM", 0, -5)
		end
		previous = bar
	end
end

function UF:ReskinTimerTrakcer(self)
	local function updateTimerTracker()
		for _, timer in pairs(TimerTracker.timerList) do
			if timer.bar and not timer.bar.styled then
				reskinTimerBar(timer.bar)

				timer.bar.styled = true
			end
		end
	end
	self:RegisterEvent("START_TIMER", updateTimerTracker, true)
end

-- Auras Relevant
function UF.PostCreateIcon(element, button)
	local fontSize = element.fontSize or element.size*.6
	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints()
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)
	button.count = B.CreateFS(parentFrame, fontSize, "", false, "BOTTOMRIGHT", 6, -3)
	button.cd:SetReverse(true)
	local needShadow = true
	if element.__owner.mystyle == "raid" and not C.db["UFs"]["RaidBuffIndicator"] then
		needShadow = false
	end
	button.iconbg = B.ReskinIcon(button.icon, needShadow)

	button.HL = button:CreateTexture(nil, "HIGHLIGHT")
	button.HL:SetColorTexture(1, 1, 1, .25)
	button.HL:SetAllPoints()

	button.overlay:SetTexture(nil)
	button.stealable:SetAtlas("bags-newitem")
	button:HookScript("OnMouseDown", AURA.RemoveSpellFromIgnoreList)

	if element.disableCooldown then button.timer = B.CreateFS(button, 12, "") end
end

local filteredStyle = {
	["target"] = true,
	["nameplate"] = true,
	["boss"] = true,
	["arena"] = true,
}

function UF.PostUpdateIcon(element, _, button, _, _, duration, expiration, debuffType)
	if duration then button.iconbg:Show() end

	local style = element.__owner.mystyle
	if style == "nameplate" then
		button:SetSize(element.size, element.size - 4)
	else
		button:SetSize(element.size, element.size)
	end

	local fontSize = element.fontSize or element.size*.6
	button.count:SetFont(DB.Font[1], fontSize, DB.Font[3])

	if element.desaturateDebuff and button.isDebuff and filteredStyle[style] and not button.isPlayer then
		button.icon:SetDesaturated(true)
	else
		button.icon:SetDesaturated(false)
	end

	if element.showDebuffType and button.isDebuff then
		local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
		button.iconbg:SetBackdropBorderColor(color[1], color[2], color[3])
	else
		button.iconbg:SetBackdropBorderColor(0, 0, 0)
	end

	if element.disableCooldown then
		if duration and duration > 0 then
			button.expiration = expiration
			button:SetScript("OnUpdate", B.CooldownOnUpdate)
			button.timer:Show()
		else
			button:SetScript("OnUpdate", nil)
			button.timer:Hide()
		end
	end
end

local function bolsterPreUpdate(element)
	element.bolster = 0
	element.bolsterIndex = nil
end

local function bolsterPostUpdate(element)
	local button = element.bolsterIndex
	if button then
		button.count:SetText(element.bolster)
	end
end

function UF.PostUpdateGapIcon(_, _, icon)
	if icon.iconbg and icon.iconbg:IsShown() then
		icon.iconbg:Hide()
	end
end

local isCasterPlayer = {
	["player"] = true,
	["pet"] = true,
	["vehicle"] = true,
}
function UF.CustomFilter(element, unit, button, name, _, _, _, _, _, caster, isStealable, _, spellID, _, _, _, nameplateShowAll)
	local style = element.__owner.mystyle
	if name and spellID == 209859 then
		element.bolster = element.bolster + 1
		if not element.bolsterIndex then
			element.bolsterIndex = button
			return true
		end
	elseif style == "raid" then
		if C.RaidBuffs["ALL"][spellID] or NDuiADB["RaidAuraWatch"][spellID] then
			element.__owner.rawSpellID = spellID
			return true
		else
			element.__owner.rawSpellID = nil
		end
	elseif style == "nameplate" or style == "boss" or style == "arena" then
		if element.__owner.plateType == "NameOnly" then
			return NDuiADB["NameplateFilter"][1][spellID] or C.WhiteList[spellID]
		elseif NDuiADB["NameplateFilter"][2][spellID] or C.BlackList[spellID] then
			return false
		elseif element.showStealableBuffs and isStealable and not UnitIsPlayer(unit) then
			return true
		elseif NDuiADB["NameplateFilter"][1][spellID] or C.WhiteList[spellID] then
			return true
		else
			local auraFilter = C.db["Nameplate"]["AuraFilter"]
			return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and isCasterPlayer[caster])
		end
	else
		return (element.onlyShowPlayer and button.isPlayer) or (not element.onlyShowPlayer and name)
	end
end

function UF.UnitCustomFilter(element, _, button, name, _, _, _, _, _, _, isStealable)
	local value = element.__value
	if button.isDebuff then
		if C.db["UFs"][value.."DebuffType"] == 2 then
			return name
		elseif C.db["UFs"][value.."DebuffType"] == 3 then
			return button.isPlayer
		end
	else
		if C.db["UFs"][value.."BuffType"] == 2 then
			return name
		elseif C.db["UFs"][value.."BuffType"] == 3 then
			return isStealable
		end
	end
end

function UF.RaidBuffFilter(_, _, _, _, _, _, _, _, _, caster, _, _, spellID, canApplyAura, isBossAura)
	if isBossAura then
		return true
	else
		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
		local isPlayerSpell = (caster == "player" or caster == "pet" or caster == "vehicle")
		if hasCustom then
			return showForMySpec or (alwaysShowMine and isPlayerSpell)
		else
			return isPlayerSpell and canApplyAura and not SpellIsSelfBuff(spellID)
		end
	end
end

local debuffBlackList = {
	[206151] = true,
	[296847] = true,
	[338906] = true,
}
function UF.RaidDebuffFilter(element, _, _, _, _, _, _, _, _, caster, _, _, spellID, _, isBossAura)
	local parent = element.__owner
	if debuffBlackList[spellID] then
		return false
	elseif (C.db["UFs"]["RaidBuffIndicator"] and UF.CornerSpells[spellID]) or parent.RaidDebuffs.spellID == spellID or parent.rawSpellID == spellID then
		return false
	elseif isBossAura or SpellIsPriorityAura(spellID) then
		return true
	else
		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellID, UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT")
		if hasCustom then
			return showForMySpec or (alwaysShowMine and (caster == "player" or caster == "pet" or caster == "vehicle"))
		else
			return true
		end
	end
end

local function auraIconSize(w, n, s)
	return (w-(n-1)*s)/n
end

function UF:UpdateAuraContainer(parent, element, maxAuras)
	local width = parent:GetWidth()
	local iconsPerRow = element.iconsPerRow
	local maxLines = iconsPerRow and B:Round(maxAuras/iconsPerRow) or 2
	element.size = iconsPerRow and auraIconSize(width, iconsPerRow, element.spacing) or element.size
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
end

function UF:ConfigureAuras(element)
	local value = element.__value
	element.numBuffs = C.db["UFs"][value.."BuffType"] ~= 1 and C.db["UFs"][value.."NumBuff"] or 0
	element.numDebuffs = C.db["UFs"][value.."DebuffType"] ~= 1 and C.db["UFs"][value.."NumDebuff"] or 0
	element.iconsPerRow = C.db["UFs"][value.."AurasPerRow"]
	element.showDebuffType = C.db["UFs"]["DebuffColor"]
	element.desaturateDebuff = C.db["UFs"]["Desaturate"]
end

function UF:RefreshUFAuras(frame)
	if not frame then return end
	local element = frame.Auras
	if not element then return end

	UF:ConfigureAuras(element)
	UF:UpdateAuraContainer(frame, element, element.numBuffs + element.numDebuffs)
	element:ForceUpdate()
end

function UF:ConfigureBuffAndDebuff(element, isDebuff)
	local value = element.__value
	local vType = isDebuff and "Debuff" or "Buff"
	element.num = C.db["UFs"][value..vType.."Type"] ~= 1 and C.db["UFs"][value.."Num"..vType] or 0
	element.iconsPerRow = C.db["UFs"][value..vType.."PerRow"]
	element.showDebuffType = C.db["UFs"]["DebuffColor"]
	element.desaturateDebuff = C.db["UFs"]["Desaturate"]
end

function UF:RefreshBuffAndDebuff(frame)
	if not frame then return end

	local element = frame.Buffs
	if element then
		UF:ConfigureBuffAndDebuff(element)
		UF:UpdateAuraContainer(frame, element, element.num)
		element:ForceUpdate()
	end

	local element = frame.Debuffs
	if element then
		UF:ConfigureBuffAndDebuff(element, true)
		UF:UpdateAuraContainer(frame, element, element.num)
		element:ForceUpdate()
	end
end

function UF:UpdateUFAuras()
	UF:RefreshUFAuras(_G.oUF_Player)
	UF:RefreshUFAuras(_G.oUF_Target)
	UF:RefreshUFAuras(_G.oUF_Focus)
	UF:RefreshUFAuras(_G.oUF_ToT)
	UF:RefreshUFAuras(_G.oUF_Pet)

	for i = 1, 5 do
		UF:RefreshBuffAndDebuff(_G["oUF_Boss"..i])
		UF:RefreshBuffAndDebuff(_G["oUF_Arena"..i])
	end
end

function UF:ToggleUFAuras(frame, enable)
	if not frame then return end
	if enable then
		if not frame:IsElementEnabled("Auras") then
			frame:EnableElement("Auras")
		end
	else
		if frame:IsElementEnabled("Auras") then
			frame:DisableElement("Auras")
			frame.Auras:ForceUpdate()
		end
	end
end

function UF:ToggleAllAuras()
	local enable = C.db["UFs"]["ShowAuras"]
	UF:ToggleUFAuras(_G.oUF_Player, enable)
	UF:ToggleUFAuras(_G.oUF_Target, enable)
	UF:ToggleUFAuras(_G.oUF_Focus, enable)
	UF:ToggleUFAuras(_G.oUF_ToT, enable)
end

function UF:CreateAuras(self)
	local mystyle = self.mystyle
	local bu = CreateFrame("Frame", nil, self)
	bu:SetFrameLevel(self:GetFrameLevel() + 2)
	bu.gap = true
	bu.initialAnchor = "TOPLEFT"
	bu["growth-y"] = "DOWN"
	bu.spacing = 3
	bu.tooltipAnchor = "ANCHOR_BOTTOMLEFT"
	if mystyle == "player" then
		bu.initialAnchor = "TOPRIGHT"
		bu["growth-x"] = "LEFT"
		bu:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -10)
		bu.__value = "Player"
		UF:ConfigureAuras(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "target" then
		bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -10)
		bu.__value = "Target"
		UF:ConfigureAuras(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "tot" then
		bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -5)
		bu.__value = "ToT"
		UF:ConfigureAuras(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "pet" then
		bu.initialAnchor = "TOPRIGHT"
		bu["growth-x"] = "LEFT"
		bu:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -5)
		bu.__value = "Pet"
		UF:ConfigureAuras(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "focus" then
		bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -10)
		bu.numTotal = 23
		bu.iconsPerRow = 8
		bu.__value = "Focus"
		UF:ConfigureAuras(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	elseif mystyle == "raid" then
		bu.initialAnchor = "LEFT"
		bu:SetPoint("LEFT", self, 15, 0)
		bu.size = 18*C.db["UFs"]["SMRScale"]/10
		bu.numTotal = 1
		bu.disableCooldown = true
		bu.gap = false
		bu.disableMouse = true
		bu.showDebuffType = nil
		bu.CustomFilter = UF.CustomFilter
	elseif mystyle == "nameplate" then
		bu.initialAnchor = "BOTTOMLEFT"
		bu["growth-y"] = "UP"
		if C.db["Nameplate"]["TargetPower"] then
			bu:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 10 + C.db["Nameplate"]["PPBarHeight"])
		else
			bu:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
		end
		bu.numTotal = C.db["Nameplate"]["maxAuras"]
		bu.size = C.db["Nameplate"]["AuraSize"]
		bu.showDebuffType = C.db["Nameplate"]["DebuffColor"]
		bu.desaturateDebuff = C.db["Nameplate"]["Desaturate"]
		bu.gap = false
		bu.disableMouse = true
		bu.CustomFilter = UF.CustomFilter
	end

	UF:UpdateAuraContainer(self, bu, bu.numTotal or bu.numBuffs + bu.numDebuffs)
	bu.showStealableBuffs = true
	bu.PostCreateIcon = UF.PostCreateIcon
	bu.PostUpdateIcon = UF.PostUpdateIcon
	bu.PostUpdateGapIcon = UF.PostUpdateGapIcon
	bu.PreUpdate = bolsterPreUpdate
	bu.PostUpdate = bolsterPostUpdate

	self.Auras = bu
end

function UF:CreateBuffs(self)
	local bu = CreateFrame("Frame", nil, self)
	bu:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
	bu.initialAnchor = "BOTTOMLEFT"
	bu["growth-x"] = "RIGHT"
	bu["growth-y"] = "UP"
	bu.spacing = 3

	if self.mystyle == "raid" then
		bu.initialAnchor = "BOTTOMRIGHT"
		bu["growth-x"] = "LEFT"
		bu:ClearAllPoints()
		bu:SetPoint("BOTTOMRIGHT", self.Health, -C.mult, C.mult)
		bu.num = (self.raidType == "simple" or not C.db["UFs"]["ShowRaidBuff"]) and 0 or 3
		bu.size = C.db["UFs"]["RaidBuffSize"]
		bu.CustomFilter = UF.RaidBuffFilter
		bu.disableMouse = true
		bu.fontSize = C.db["UFs"]["RaidBuffSize"]-2
	else -- boss and arena
		bu.__value = "Boss"
		UF:ConfigureBuffAndDebuff(bu)
		bu.CustomFilter = UF.UnitCustomFilter
	end

	UF:UpdateAuraContainer(self, bu, bu.num)
	bu.showStealableBuffs = true
	bu.PostCreateIcon = UF.PostCreateIcon
	bu.PostUpdateIcon = UF.PostUpdateIcon

	self.Buffs = bu
end

function UF:CreateDebuffs(self)
	local mystyle = self.mystyle
	local bu = CreateFrame("Frame", nil, self)
	bu.spacing = 3
	bu.initialAnchor = "TOPRIGHT"
	bu["growth-x"] = "LEFT"
	bu["growth-y"] = "DOWN"
	bu.tooltipAnchor = "ANCHOR_BOTTOMLEFT"
	bu.showDebuffType = true
	if mystyle == "raid" then
		bu.initialAnchor = "BOTTOMLEFT"
		bu["growth-x"] = "RIGHT"
		bu:SetPoint("BOTTOMLEFT", self.Health, C.mult, C.mult)
		bu.num = (self.raidType == "simple" or not C.db["UFs"]["ShowRaidDebuff"]) and 0 or 3
		bu.size = C.db["UFs"]["RaidDebuffSize"]
		bu.CustomFilter = UF.RaidDebuffFilter
		bu.disableMouse = true
		bu.fontSize = C.db["UFs"]["RaidDebuffSize"]-2
	else -- boss and arena
		bu:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 0)
		bu.__value = "Boss"
		UF:ConfigureBuffAndDebuff(bu, true)
		bu.CustomFilter = UF.UnitCustomFilter
	end

	UF:UpdateAuraContainer(self, bu, bu.num)
	bu.PostCreateIcon = UF.PostCreateIcon
	bu.PostUpdateIcon = UF.PostUpdateIcon

	self.Debuffs = bu
end

function UF:UpdateRaidAuras()
	for _, frame in pairs(oUF.objects) do
		if frame.mystyle == "raid" then
			local debuffs = frame.Debuffs
			if debuffs then
				debuffs.num = (frame.raidType == "simple" or not C.db["UFs"]["ShowRaidDebuff"]) and 0 or 3
				debuffs.size = C.db["UFs"]["RaidDebuffSize"]
				debuffs.fontSize = C.db["UFs"]["RaidDebuffSize"]-2
				UF:UpdateAuraContainer(frame, debuffs, debuffs.num)
				debuffs:ForceUpdate()
			end

			local buffs = frame.Buffs
			if buffs then
				buffs.num = (frame.raidType == "simple" or not C.db["UFs"]["ShowRaidBuff"]) and 0 or 3
				buffs.size = C.db["UFs"]["RaidBuffSize"]
				buffs.fontSize = C.db["UFs"]["RaidBuffSize"]-2
				UF:UpdateAuraContainer(frame, buffs, buffs.num)
				buffs:ForceUpdate()
			end
		end
	end
end

local function refreshAurasElements(self)
	local buffs = self.Buffs
	if buffs then buffs:ForceUpdate() end

	local debuffs = self.Debuffs
	if debuffs then debuffs:ForceUpdate() end
end

function UF:RefreshAurasByCombat(self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", refreshAurasElements, true)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", refreshAurasElements, true)
end

-- Class Powers
function UF.PostUpdateClassPower(element, cur, max, diff, powerType, chargedPowerPoints)
	if not cur or cur == 0 then
		for i = 1, 6 do
			element[i].bg:Hide()
		end

		element.prevColor = nil
	else
		for i = 1, max do
			element[i].bg:Show()
		end

		element.thisColor = cur == max and 1 or 2
		if not element.prevColor or element.prevColor ~= element.thisColor then
			local r, g, b = 1, 0, 0
			if element.thisColor == 2 then
				local color = element.__owner.colors.power[powerType]
				r, g, b = color[1], color[2], color[3]
			end
			for i = 1, #element do
				element[i]:SetStatusBarColor(r, g, b)
			end
			element.prevColor = element.thisColor
		end
	end

	if diff then
		for i = 1, max do
			element[i]:SetWidth((element.__owner.ClassPowerBar:GetWidth() - (max-1)*C.margin)/max)
		end
		for i = max + 1, 6 do
			element[i].bg:Hide()
		end
	end

	for i = 1, 6 do
		local bar = element[i]
		if not bar.chargeStar then break end

		bar.chargeStar:SetShown(chargedPowerPoints and tContains(chargedPowerPoints, i))
	end
end

function UF:OnUpdateRunes(elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)
	self.timer:SetText(nil)
	if C.db["UFs"]["RuneTimer"] then
		local remain = self.runeDuration - duration
		if remain > 0 then
			self.timer:SetText(B.FormatTime(remain))
		end
	end
end

function UF.PostUpdateRunes(element, runemap)
	for index, runeID in next, runemap do
		local rune = element[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if rune:IsShown() then
			if runeReady then
				rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				rune.timer:SetText(nil)
			elseif start then
				rune:SetAlpha(.6)
				rune.runeDuration = duration
				rune:SetScript("OnUpdate", UF.OnUpdateRunes)
			end
		end
	end
end

function UF:CreateClassPower(self)
	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local barPoint = {"BOTTOMLEFT", self, "TOPLEFT", C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]}
	if self.mystyle == "PlayerPlate" then
		barWidth, barHeight = C.db["Nameplate"]["PPWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, C.margin}
	elseif self.mystyle == "targetplate" then
		barWidth, barHeight = C.db["Nameplate"]["PlateWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"CENTER", self}
	end

	local isDK = DB.MyClass == "DEATHKNIGHT"
	local bar = CreateFrame("Frame", "$parentClassPowerBar", self.Health)
	bar:SetSize(barWidth, barHeight)
	bar:SetPoint(unpack(barPoint))

	-- show bg while size changed
	if not isDK then
		bar.bg = B.SetBD(bar)
		bar.bg:SetFrameLevel(5)
		bar.bg:SetBackdropBorderColor(1, .8, 0)
		bar.bg:Hide()
	end

	local bars = {}
	for i = 1, 6 do
		bars[i] = CreateFrame("StatusBar", nil, bar)
		bars[i]:SetHeight(barHeight)
		bars[i]:SetWidth((barWidth - 5*C.margin) / 6)
		bars[i]:SetStatusBarTexture(DB.normTex)
		bars[i]:SetFrameLevel(self:GetFrameLevel() + 5)
		B.SetBD(bars[i], 0)
		if i == 1 then
			bars[i]:SetPoint("BOTTOMLEFT")
		else
			bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", C.margin, 0)
		end

		bars[i].bg = (isDK and bars[i] or bar):CreateTexture(nil, "BACKGROUND")
		bars[i].bg:SetAllPoints(bars[i])
		bars[i].bg:SetTexture(DB.normTex)
		bars[i].bg.multiplier = .25

		if isDK then
			bars[i].timer = B.CreateFS(bars[i], 13, "")
		elseif DB.MyClass == "ROGUE" then
			local chargeStar = bars[i]:CreateTexture()
			chargeStar:SetAtlas("VignetteKill")
			chargeStar:SetDesaturated(true)
			chargeStar:SetSize(22, 22)
			chargeStar:SetPoint("CENTER")
			chargeStar:Hide()
			bars[i].chargeStar = chargeStar
		end
	end

	if isDK then
		bars.colorSpec = true
		bars.sortOrder = "asc"
		bars.PostUpdate = UF.PostUpdateRunes
		bars.__max = 6
		self.Runes = bars
	else
		bars.PostUpdate = UF.PostUpdateClassPower
		self.ClassPower = bars
	end

	self.ClassPowerBar = bar
end

function UF:StaggerBar(self)
	if DB.MyClass ~= "MONK" then return end

	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local barPoint = {"BOTTOMLEFT", self, "TOPLEFT", C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]}
	if self.mystyle == "PlayerPlate" then
		barWidth, barHeight = C.db["Nameplate"]["PPWidth"], C.db["Nameplate"]["PPBarHeight"]
		barPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, C.margin}
	end

	local stagger = CreateFrame("StatusBar", nil, self.Health)
	stagger:SetSize(barWidth, barHeight)
	stagger:SetPoint(unpack(barPoint))
	stagger:SetStatusBarTexture(DB.normTex)
	stagger:SetFrameLevel(self:GetFrameLevel() + 5)
	B.SetBD(stagger, 0)

	local bg = stagger:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25

	local text = B.CreateFS(stagger, 13)
	text:SetPoint("CENTER", stagger, "TOP")
	self:Tag(text, "[monkstagger]")

	self.Stagger = stagger
	self.Stagger.bg = bg
end

function UF:ToggleUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	if C.db["UFs"]["ClassPower"] then
		if playerFrame.ClassPower then
			if not playerFrame:IsElementEnabled("ClassPower") then
				playerFrame:EnableElement("ClassPower")
				playerFrame.ClassPower:ForceUpdate()
			end
		end
		if playerFrame.Runes then
			if not playerFrame:IsElementEnabled("Runes") then
				playerFrame:EnableElement("Runes")
				playerFrame.Runes:ForceUpdate()
			end
		end
		if playerFrame.Stagger then
			if not playerFrame:IsElementEnabled("Stagger") then
				playerFrame:EnableElement("Stagger")
				playerFrame.Stagger:ForceUpdate()
			end
		end
	else
		if playerFrame.ClassPower then
			if playerFrame:IsElementEnabled("ClassPower") then
				playerFrame:DisableElement("ClassPower")
			end
		end
		if playerFrame.Runes then
			if playerFrame:IsElementEnabled("Runes") then
				playerFrame:DisableElement("Runes")
			end
		end
		if playerFrame.Stagger then
			if playerFrame:IsElementEnabled("Stagger") then
				playerFrame:DisableElement("Stagger")
			end
		end
	end
end

function UF:UpdateUFClassPower()
	local playerFrame = _G.oUF_Player
	if not playerFrame then return end

	local barWidth, barHeight = C.db["UFs"]["CPWidth"], C.db["UFs"]["CPHeight"]
	local xOffset, yOffset = C.db["UFs"]["CPxOffset"], C.db["UFs"]["CPyOffset"]
	local bars = playerFrame.ClassPower or playerFrame.Runes
	if bars then
		local bar = playerFrame.ClassPowerBar
		bar:SetSize(barWidth, barHeight)
		bar:SetPoint("BOTTOMLEFT", playerFrame, "TOPLEFT", xOffset, yOffset)
		if bar.bg then bar.bg:Show() end
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max-1)*C.margin) / max)
		end
	end

	if playerFrame.Stagger then
		playerFrame.Stagger:SetSize(barWidth, barHeight)
		playerFrame.Stagger:SetPoint("BOTTOMLEFT", playerFrame, "TOPLEFT", xOffset, yOffset)
	end
end

function UF.PostUpdateAltPower(element, _, cur, _, max)
	if cur and max then
		local perc = floor((cur/max)*100)
		if perc < 35 then
			element:SetStatusBarColor(0, 1, 0)
		elseif perc < 70 then
			element:SetStatusBarColor(1, 1, 0)
		else
			element:SetStatusBarColor(1, 0, 0)
		end
	end
end

function UF:CreateAltPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetStatusBarTexture(DB.normTex)
	bar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -3)
	bar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -3)
	bar:SetHeight(2)
	B.SetBD(bar, 0)

	local text = B.CreateFS(bar, 14, "")
	text:SetJustifyH("CENTER")
	self:Tag(text, "[altpower]")

	self.AlternativePower = bar
	self.AlternativePower.PostUpdate = UF.PostUpdateAltPower
end

function UF:CreateExpRepBar(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 0)
	bar:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", 10, 0)
	bar:SetOrientation("VERTICAL")
	B.CreateSB(bar)

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints(bar)
	rest:SetStatusBarTexture(DB.normTex)
	rest:SetStatusBarColor(0, .4, 1, .6)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	rest:SetOrientation("VERTICAL")
	bar.restBar = rest

	B:GetModule("Misc"):SetupScript(bar)
end

function UF:CreatePrediction(self)
	local frame = CreateFrame("Frame", nil, self)
	frame:SetAllPoints()

	local mhpb = frame:CreateTexture(nil, "BORDER", nil, 5)
	mhpb:SetWidth(1)
	mhpb:SetTexture(DB.normTex)
	mhpb:SetVertexColor(0, 1, .5, .5)

	local ohpb = frame:CreateTexture(nil, "BORDER", nil, 5)
	ohpb:SetWidth(1)
	ohpb:SetTexture(DB.normTex)
	ohpb:SetVertexColor(0, 1, 0, .5)

	local abb = frame:CreateTexture(nil, "BORDER", nil, 5)
	abb:SetWidth(1)
	abb:SetTexture(DB.normTex)
	abb:SetVertexColor(.66, 1, 1, .7)

	local abbo = frame:CreateTexture(nil, "ARTWORK", nil, 1)
	abbo:SetAllPoints(abb)
	abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
	abbo.tileSize = 32

	local oag = frame:CreateTexture(nil, "ARTWORK", nil, 1)
	oag:SetWidth(15)
	oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	oag:SetBlendMode("ADD")
	oag:SetAlpha(.7)
	oag:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 2)
	oag:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -2)

	local hab = CreateFrame("StatusBar", nil, frame)
	hab:SetPoint("TOPLEFT", self.Health)
	hab:SetPoint("BOTTOMRIGHT", self.Health:GetStatusBarTexture())
	hab:SetReverseFill(true)
	hab:SetStatusBarTexture(DB.normTex)
	hab:SetStatusBarColor(0, .5, .8, .5)
	hab:SetFrameLevel(frame:GetFrameLevel())

	local ohg = frame:CreateTexture(nil, "ARTWORK", nil, 1)
	ohg:SetWidth(15)
	ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
	ohg:SetBlendMode("ADD")
	ohg:SetAlpha(.5)
	ohg:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
	ohg:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)

	self.HealPredictionAndAbsorb = {
		myBar = mhpb,
		otherBar = ohpb,
		absorbBar = abb,
		absorbBarOverlay = abbo,
		overAbsorbGlow = oag,
		healAbsorbBar = hab,
		overHealAbsorbGlow = ohg,
		maxOverflow = 1,
	}
	self.predicFrame = frame
end

function UF.PostUpdateAddPower(element, cur, max)
	if element.Text and max > 0 then
		local perc = cur/max * 100
		if perc > 95 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = format("%d%%", perc)
			element:SetAlpha(1)
		end
		element.Text:SetText(perc)
	end
end

function UF:CreateAddPower(self)
	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -3)
	bar:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -3)
	bar:SetHeight(4)
	bar:SetStatusBarTexture(DB.normTex)
	B.SetBD(bar, 0)
	bar.colorPower = true
	B:SmoothBar(bar)

	local bg = bar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(DB.normTex)
	bg.multiplier = .25
	local text = B.CreateFS(bar, 12, "", false, "CENTER", 1, -3)

	self.AdditionalPower = bar
	self.AdditionalPower.bg = bg
	self.AdditionalPower.Text = text
	self.AdditionalPower.PostUpdate = UF.PostUpdateAddPower
	self.AdditionalPower.displayPairs = {
		["DRUID"] = {
			[1] = true,
			[3] = true,
			[8] = true,
		},
		["SHAMAN"] = {
			[11] = true,
		},
		["PRIEST"] = {
			[13] = true,
		}
	}
end

function UF:CreateSwing(self)
	if not C.db["UFs"]["Castbars"] then return end

	local bar = CreateFrame("StatusBar", nil, self)
	local width = C.db["UFs"]["PlayerCBWidth"] - C.db["UFs"]["PlayerCBHeight"] - 5
	bar:SetSize(width, 3)
	bar:SetPoint("TOP", self.Castbar.mover, "BOTTOM", 0, -5)

	local two = CreateFrame("StatusBar", nil, bar)
	two:Hide()
	two:SetAllPoints()
	B.CreateSB(two, true, .8, .8, .8)

	local main = CreateFrame("StatusBar", nil, bar)
	main:Hide()
	main:SetAllPoints()
	B.CreateSB(main, true, .8, .8, .8)

	local off = CreateFrame("StatusBar", nil, bar)
	off:Hide()
	off:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -3)
	off:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, -6)
	B.CreateSB(off, true, .8, .8, .8)

	if C.db["UFs"]["SwingTimer"] then
		bar.Text = B.CreateFS(bar, 12, "")
		bar.TextMH = B.CreateFS(main, 12, "")
		bar.TextOH = B.CreateFS(off, 12, "", false, "CENTER", 1, -5)
	end

	self.Swing = bar
	self.Swing.Twohand = two
	self.Swing.Mainhand = main
	self.Swing.Offhand = off
	self.Swing.hideOoc = true
end

function UF:CreateQuakeTimer(self)
	if not C.db["UFs"]["Castbars"] then return end

	local bar = CreateFrame("StatusBar", nil, self)
	bar:SetSize(C.db["UFs"]["PlayerCBWidth"], C.db["UFs"]["PlayerCBHeight"])
	B.CreateSB(bar, true, 0, 1, 0)
	bar:Hide()

	bar.SpellName = B.CreateFS(bar, 12, "", false, "LEFT", 2, 0)
	bar.Text = B.CreateFS(bar, 12, "", false, "RIGHT", -2, 0)
	createBarMover(bar, L["QuakeTimer"], "QuakeTimer", {"BOTTOM", UIParent, "BOTTOM", 0, 200})

	local icon = bar:CreateTexture(nil, "ARTWORK")
	icon:SetSize(bar:GetHeight(), bar:GetHeight())
	icon:SetPoint("RIGHT", bar, "LEFT", -3, 0)
	B.ReskinIcon(icon, true)
	bar.Icon = icon

	self.QuakeTimer = bar
end

function UF:CreateFCT(self)
	if not C.db["UFs"]["CombatText"] then return end

	local parentFrame = CreateFrame("Frame", nil, UIParent)
	local fcf = CreateFrame("Frame", "oUF_CombatTextFrame", parentFrame)
	fcf:SetSize(32, 32)
	if self.mystyle == "player" then
		B.Mover(fcf, L["CombatText"], "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})
	else
		B.Mover(fcf, L["CombatText"], "TargetCombatText", {"BOTTOM", self, "TOPRIGHT", 0, 120})
	end

	for i = 1, 36 do
		fcf[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
	end

	fcf.font = DB.Font[1]
	fcf.fontFlags = DB.Font[3]
	fcf.abbreviateNumbers = true
	self.FloatingCombatFeedback = fcf

	-- Default CombatText
	SetCVar("enableFloatingCombatText", 0)
	B.HideOption(InterfaceOptionsCombatPanelEnableFloatingCombatText)
end

function UF:CreatePVPClassify(self)
	local bu = self:CreateTexture(nil, "ARTWORK")
	bu:SetSize(30, 30)
	bu:SetPoint("LEFT", self, "RIGHT", 5, -2)

	self.PvPClassificationIndicator = bu
end

local function updatePartySync(self)
	local hasJoined = C_QuestSession.HasJoined()
	if(hasJoined) then
		self.QuestSyncIndicator:Show()
	else
		self.QuestSyncIndicator:Hide()
	end
end

function UF:CreateQuestSync(self)
	local sync = self:CreateTexture(nil, "OVERLAY")
	sync:SetPoint("CENTER", self, "BOTTOMLEFT", 16, 0)
	sync:SetSize(28, 28)
	sync:SetAtlas("QuestSharing-DialogIcon")
	sync:Hide()

	self.QuestSyncIndicator = sync
	self:RegisterEvent("QUEST_SESSION_LEFT", updatePartySync, true)
	self:RegisterEvent("QUEST_SESSION_JOINED", updatePartySync, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", updatePartySync, true)
end

-- Demonic Gateway
local GatewayTexs = {
	[59262] = 607512, -- green
	[59271] = 607513, -- purple
}
local function DGI_UpdateGlow()
	local frame = _G.oUF_Focus
	if not frame then return end

	local element = frame.DemonicGatewayIndicator
	if element:IsShown() and IsItemInRange(37727, "focus") then
		B.ShowOverlayGlow(element.glowFrame)
	else
		B.HideOverlayGlow(element.glowFrame)
	end
end

local function DGI_Visibility()
	local frame = _G.oUF_Focus
	if not frame then return end

	local element = frame.DemonicGatewayIndicator
	local guid = UnitGUID("focus")
	local npcID = guid and B.GetNPCID(guid)
	local isGate = npcID and GatewayTexs[npcID]

	element:SetTexture(isGate)
	element:SetShown(isGate)
	element.updater:SetShown(isGate)
	DGI_UpdateGlow()
end

local function DGI_OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > .1 then
		DGI_UpdateGlow()

		self.elapsed = 0
	end
end

function UF:DemonicGatewayIcon(self)
	local icon = self:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("CENTER")
	icon:SetSize(22, 22)
	icon:SetTexture(607512) -- 607513 for purple
	icon:SetTexCoord(unpack(DB.TexCoord))
	icon.glowFrame = B.CreateGlowFrame(self, 22)

	local updater = CreateFrame("Frame")
	updater:SetScript("OnUpdate", DGI_OnUpdate)
	updater:Hide()

	self.DemonicGatewayIndicator = icon
	self.DemonicGatewayIndicator.updater = updater
	B:RegisterEvent("PLAYER_FOCUS_CHANGED", DGI_Visibility)
end