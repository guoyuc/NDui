local _, ns = ...
local B, C, L, DB = unpack(ns)
local S = B:GetModule("Skins")
local TT = B:GetModule("Tooltip")

local cr, cg, cb = DB.r, DB.g, DB.b
local select, pairs, ipairs, next, unpack = select, pairs, ipairs, next, unpack

function S:RematchFilter()
	B.StripTextures(self)
	B.Reskin(self)
	B.SetupArrow(self.Arrow, "right")
	self.Arrow:ClearAllPoints()
	self.Arrow:SetPoint("RIGHT")
	self.Arrow.SetPoint = B.Dummy
	self.Arrow:SetSize(14, 14)
end

function S:RematchIcon()
	if self.styled then return end

	if self.IconBorder then self.IconBorder:Hide() end
	if self.Background then self.Background:Hide() end
	if self.Icon then
		self.Icon:SetTexCoord(unpack(DB.TexCoord))
		self.Icon.bg = B.CreateBDFrame(self.Icon)
		local hl = self.GetHighlightTexture and self:GetHighlightTexture() or select(3, self:GetRegions())
		if hl then
			hl:SetColorTexture(1, 1, 1, .25)
			hl:SetAllPoints(self.Icon)
		end
	end
	if self.Level then
		if self.Level.BG then self.Level.BG:Hide() end
		if self.Level.Text then self.Level.Text:SetTextColor(1, 1, 1) end
	end
	if self.GetCheckedTexture then
		self:SetCheckedTexture(DB.textures.pushed)
	end

	self.styled = true
end

function S:RematchInput()
	self:DisableDrawLayer("BACKGROUND")
	self:HideBackdrop()
	local bg = B.CreateBDFrame(self, 0, true)
	bg:SetPoint("TOPLEFT", 2, 0)
	bg:SetPoint("BOTTOMRIGHT", -2, 0)
end

local function scrollEndOnLeave(self)
	self.__texture:SetVertexColor(1, .8, 0)
end

local function reskinScrollEnd(self, direction)
	B.ReskinArrow(self, direction)
	self:SetSize(17, 12)
	self.__texture:SetVertexColor(1, .8, 0)
	self:HookScript("OnLeave", scrollEndOnLeave)
end

function S:RematchScroll()
	self.Background:Hide()
	local scrollBar = self.ScrollFrame.ScrollBar
	B.StripTextures(scrollBar)
	scrollBar.thumbTexture = scrollBar.ScrollThumb
	B.ReskinScroll(scrollBar)
	scrollBar.thumbTexture:SetPoint("TOPRIGHT")
	reskinScrollEnd(scrollBar.TopButton, "up")
	reskinScrollEnd(scrollBar.BottomButton, "down")
end

function S:RematchDropdown()
	self:HideBackdrop()
	B.StripTextures(self, 0)
	B.CreateBDFrame(self, 0, true)
	if self.Icon then
		self.Icon:SetAlpha(1)
		B.CreateBDFrame(self.Icon)
	end
	local arrow = select(2, self:GetChildren())
	B.ReskinArrow(arrow, "down")
end

function S:RematchXP()
	B.StripTextures(self)
	self:SetStatusBarTexture(DB.bdTex)
	B.CreateBDFrame(self, .25)
end

function S:RematchCard()
	self:HideBackdrop()
	if self.Source then B.StripTextures(self.Source) end
	B.StripTextures(self.Middle)
	B.CreateBDFrame(self.Middle, .25)
	if self.Middle.XP then S.RematchXP(self.Middle.XP) end
	if self.Bottom.AbilitiesBG then self.Bottom.AbilitiesBG:Hide() end
	if self.Bottom.BottomBG then self.Bottom.BottomBG:Hide() end
	local bg = B.CreateBDFrame(self.Bottom, .25)
	bg:SetPoint("TOPLEFT", -C.mult, -3)
end

function S:RematchInset()
	B.StripTextures(self)
	local bg = B.CreateBDFrame(self, .25)
	bg:SetPoint("TOPLEFT", 3, 0)
	bg:SetPoint("BOTTOMRIGHT", -3, 0)
end

local function buttonOnEnter(self)
	self.bg:SetBackdropColor(cr, cg, cb, .25)
end

local function buttonOnLeave(self)
	self.bg:SetBackdropColor(0, 0, 0, .25)
end

function S:RematchPetList()
	local buttons = self.ScrollFrame.Buttons
	if not buttons then return end

	for i = 1, #buttons do
		local button = buttons[i]
		if not button.styled then
			local parent
			if button.Pet then
				B.CreateBDFrame(button.Pet)
				if button.Rarity then button.Rarity:SetTexture(nil) end
				if button.LevelBack then button.LevelBack:SetTexture(nil) end
				button.LevelText:SetTextColor(1, 1, 1)
				parent = button.Pet
			end

			if button.Pets then
				for j = 1, 3 do
					local bu = button.Pets[j]
					bu:SetWidth(25)
					B.CreateBDFrame(bu)
				end
				if button.Border then button.Border:SetTexture(nil) end
				parent = button.Pets[3]
			end

			if button.Back then
				button.Back:SetTexture(nil)
				local bg = B.CreateBDFrame(button.Back, .25)
				bg:SetPoint("TOPLEFT", parent, "TOPRIGHT", 3, C.mult)
				bg:SetPoint("BOTTOMRIGHT", 0, C.mult)
				button.bg = bg
				button:HookScript("OnEnter", buttonOnEnter)
				button:HookScript("OnLeave", buttonOnLeave)
			end

			button.styled = true
		end
	end
end

function S:RematchSelectedOverlay()
	B.StripTextures(self.SelectedOverlay)
	local bg = B.CreateBDFrame(self.SelectedOverlay)
	bg:SetBackdropColor(1, .8, 0, .5)
	self.SelectedOverlay.bg = bg
end

function S:ResizeJournal()
	local parent = RematchJournal:IsShown() and RematchJournal or CollectionsJournal
	CollectionsJournal.bg:SetPoint("BOTTOMRIGHT", parent, C.mult, -C.mult)
end

function S:RematchLockButton(button)
	B.StripTextures(button, 1)
	local bg = B.CreateBDFrame(button, .25, true)
	bg:SetInside(nil, 7, 7)
end

function S:RematchTeamGroup(panel)
	if panel.styled then return end

	for i = 1, 3 do
		local button = panel.Pets[i]
		S.RematchIcon(button)
		button.bg = button.Icon.bg
		B.ReskinIconBorder(button.IconBorder, true)

		for j = 1, 3 do
			S.RematchIcon(button.Abilities[j])
		end
	end

	panel.styled = true
end

function S:RematchFlyoutButton(flyout)
	flyout:HideBackdrop()
	for i = 1, 2 do
		S.RematchIcon(flyout.Abilities[i])
	end
end

local function hookRematchPetButton(texture, _, _, _, y)
	if y == .5 then
		texture:SetTexCoord(.5625, 1, 0, .4375)
	elseif y == 1 then
		texture:SetTexCoord(0, .4375, 0, .4375)
	end
end

local styled
function S:ReskinRematchElements()
	if styled then return end

	TT.ReskinTooltip(RematchTooltip)
	TT.ReskinTooltip(RematchTableTooltip)
	for i = 1, 3 do
		local menu = Rematch:GetMenuFrame(i, UIParent)
		B.StripTextures(menu.Title)
		local bg = B.CreateBDFrame(menu.Title)
		bg:SetBackdropColor(1, .8, .0, .25)
		B.StripTextures(menu)
		B.SetBD(menu, .7)
	end

	local buttons = {
		RematchHealButton,
		RematchBandageButton,
		RematchToolbar.SafariHat,
		RematchLesserPetTreatButton,
		RematchPetTreatButton,
		RematchToolbar.SummonRandom,
		RematchToolbar.FindBattle,
	}
	for _, button in pairs(buttons) do
		S.RematchIcon(button)
	end

	if ALPTRematchOptionButton then
		ALPTRematchOptionButton:SetPushedTexture(nil)
		ALPTRematchOptionButton:SetHighlightTexture(DB.bdTex)
		ALPTRematchOptionButton:GetHighlightTexture():SetVertexColor(1, 1, 1, .25)
		local tex = ALPTRematchOptionButton:GetNormalTexture()
		tex:SetTexCoord(unpack(DB.TexCoord))
		B.CreateBDFrame(tex)
	end

	local petCount = RematchToolbar.PetCount
	petCount:SetWidth(130)
	B.StripTextures(petCount)
	local bg = B.CreateBDFrame(petCount, .25)
	bg:SetPoint("TOPLEFT", -6, -8)
	bg:SetPoint("BOTTOMRIGHT", -4, 3)

	B.Reskin(RematchBottomPanel.SummonButton)
	B.ReskinCheck(RematchBottomPanel.UseDefault)
	B.Reskin(RematchBottomPanel.SaveButton)
	B.Reskin(RematchBottomPanel.SaveAsButton)
	B.Reskin(RematchBottomPanel.FindBattleButton)

	-- RematchPetPanel
	B.StripTextures(RematchPetPanel.Top)
	B.Reskin(RematchPetPanel.Top.Toggle)
	RematchPetPanel.Top.TypeBar.NineSlice:SetAlpha(0)
	for i = 1, 10 do
		S.RematchIcon(RematchPetPanel.Top.TypeBar.Buttons[i])
	end

	-- quality bar in the new version
	local qualityBar = RematchPetPanel.Top.TypeBar.QualityBar
	if qualityBar then
		local buttons = {"HealthButton", "PowerButton", "SpeedButton", "Level25Button", "RareButton"}
		for _, name in pairs(buttons) do
			local button = qualityBar[name]
			if button then
				S.RematchIcon(button)
			end
		end
	end

	S.RematchSelectedOverlay(RematchPetPanel)
	S.RematchInset(RematchPetPanel.Results)
	S.RematchInput(RematchPetPanel.Top.SearchBox)
	S.RematchFilter(RematchPetPanel.Top.Filter)
	S.RematchScroll(RematchPetPanel.List)

	-- RematchLoadedTeamPanel
	B.StripTextures(RematchLoadedTeamPanel)
	local bg = B.CreateBDFrame(RematchLoadedTeamPanel)
	bg:SetBackdropColor(1, .8, 0, .1)
	bg:SetPoint("TOPLEFT", -C.mult, -C.mult)
	bg:SetPoint("BOTTOMRIGHT", C.mult, C.mult)
	B.StripTextures(RematchLoadedTeamPanel.Footnotes)

	-- RematchLoadoutPanel
	local target = RematchLoadoutPanel.Target
	B.StripTextures(target)
	B.CreateBDFrame(target, .25)
	S.RematchFilter(target.TargetButton)
	target.ModelBorder:HideBackdrop()
	target.ModelBorder:DisableDrawLayer("BACKGROUND")
	B.CreateBDFrame(target.ModelBorder, .25)
	B.StripTextures(target.LoadSaveButton)
	B.Reskin(target.LoadSaveButton)
	for i = 1, 3 do
		S.RematchIcon(target["Pet"..i])
	end
	S:RematchFlyoutButton(RematchLoadoutPanel.Flyout)

	local targetPanel = RematchLoadoutPanel.TargetPanel
	if targetPanel then -- compatible
		B.StripTextures(targetPanel.Top)
		S.RematchInput(targetPanel.Top.SearchBox)
		S.RematchFilter(targetPanel.Top.BackButton)
		S.RematchScroll(targetPanel.List)

		hooksecurefunc(targetPanel, "FillHeader", function(_, button)
			if not button.styled then
				button.Border:SetTexture(nil)
				button.Back:SetTexture(nil)
				button.bg = B.CreateBDFrame(button.Back, .25)
				button.bg:SetInside()
				button:HookScript("OnEnter", buttonOnEnter)
				button:HookScript("OnLeave", buttonOnLeave)
				button.Expand:SetSize(8, 8)
				button.Expand:SetPoint("LEFT", 5, 0)
				button.Expand:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
				hooksecurefunc(button.Expand, "SetTexCoord", hookRematchPetButton)

				button.styled = true
			end
		end)
	end

	-- RematchTeamPanel
	B.StripTextures(RematchTeamPanel.Top)
	S.RematchInput(RematchTeamPanel.Top.SearchBox)
	S.RematchFilter(RematchTeamPanel.Top.Teams)
	S.RematchScroll(RematchTeamPanel.List)
	S.RematchSelectedOverlay(RematchTeamPanel)

	B.StripTextures(RematchQueuePanel.Top)
	S.RematchFilter(RematchQueuePanel.Top.QueueButton)
	S.RematchScroll(RematchQueuePanel.List)
	S.RematchInset(RematchQueuePanel.Status)

	-- RematchOptionPanel
	S.RematchScroll(RematchOptionPanel.List)
	for i = 1, 4 do
		S.RematchIcon(RematchOptionPanel.Growth.Corners[i])
	end
	B.StripTextures(RematchOptionPanel.Top)
	S.RematchInput(RematchOptionPanel.Top.SearchBox)

	-- RematchPetCard
	local petCard = RematchPetCard
	B.StripTextures(petCard)
	B.ReskinClose(petCard.CloseButton)
	B.StripTextures(petCard.Title)
	B.StripTextures(petCard.PinButton)
	B.ReskinArrow(petCard.PinButton, "up")
	petCard.PinButton:SetPoint("TOPLEFT", 5, -5)
	local bg = B.SetBD(petCard.Title, .7)
	bg:SetAllPoints(petCard)
	S.RematchCard(petCard.Front)
	S.RematchCard(petCard.Back)
	for i = 1, 6 do
		local button = RematchPetCard.Front.Bottom.Abilities[i]
		button.IconBorder:Hide()
		select(8, button:GetRegions()):SetTexture(nil)
		B.ReskinIcon(button.Icon)
	end

	-- RematchAbilityCard
	local abilityCard = RematchAbilityCard
	B.StripTextures(abilityCard, 15)
	B.SetBD(abilityCard, .7)
	abilityCard.Hints.HintsBG:Hide()

	-- RematchWinRecordCard
	local card = RematchWinRecordCard
	B.StripTextures(card)
	B.ReskinClose(card.CloseButton)
	B.StripTextures(card.Content)
	local bg = B.CreateBDFrame(card.Content, .25)
	bg:SetPoint("TOPLEFT", 2, -2)
	bg:SetPoint("BOTTOMRIGHT", -2, 2)
	local bg = B.SetBD(card.Content)
	bg:SetAllPoints(card)
	for _, result in pairs({"Wins", "Losses", "Draws"}) do
		S.RematchInput(card.Content[result].EditBox)
		card.Content[result].Add.IconBorder:Hide()
	end
	B.Reskin(card.Controls.ResetButton)
	B.Reskin(card.Controls.SaveButton)
	B.Reskin(card.Controls.CancelButton)

	-- RematchDialog
	local dialog = RematchDialog
	B.StripTextures(dialog)
	B.SetBD(dialog)
	B.ReskinClose(dialog.CloseButton)

	S.RematchIcon(dialog.Slot)
	S.RematchInput(dialog.EditBox)
	B.StripTextures(dialog.Prompt)
	B.Reskin(dialog.Accept)
	B.Reskin(dialog.Cancel)
	B.Reskin(dialog.Other)
	B.ReskinCheck(dialog.CheckButton)
	S.RematchInput(dialog.SaveAs.Name)
	S.RematchInput(dialog.Send.EditBox)
	S.RematchDropdown(dialog.SaveAs.Target)
	S.RematchDropdown(dialog.TabPicker)
	S.RematchIcon(dialog.Pet.Pet)

	local preferences = dialog.Preferences
	S.RematchInput(preferences.MinHP)
	B.ReskinCheck(preferences.AllowMM)
	S.RematchInput(preferences.MaxHP)
	S.RematchInput(preferences.MinXP)
	S.RematchInput(preferences.MaxXP)

	local iconPicker = dialog.TeamTabIconPicker
	B.ReskinScroll(iconPicker.ScrollFrame.ScrollBar)
	B.StripTextures(iconPicker)
	B.CreateBDFrame(iconPicker, .25)

	B.ReskinScroll(dialog.MultiLine.ScrollBar)
	select(2, dialog.MultiLine:GetChildren()):HideBackdrop()
	local bg = B.CreateBDFrame(dialog.MultiLine, .25)
	bg:SetPoint("TOPLEFT", -5, 5)
	bg:SetPoint("BOTTOMRIGHT", 5, -5)
	B.ReskinCheck(dialog.ShareIncludes.IncludePreferences)
	B.ReskinCheck(dialog.ShareIncludes.IncludeNotes)

	local report = dialog.CollectionReport
	S.RematchDropdown(report.ChartTypeComboBox)
	B.StripTextures(report.Chart)
	local bg = B.CreateBDFrame(report.Chart, .25)
	bg:SetPoint("TOPLEFT", -C.mult, -3)
	bg:SetPoint("BOTTOMRIGHT", C.mult, 2)
	B.ReskinRadio(report.ChartTypesRadioButton)
	B.ReskinRadio(report.ChartSourcesRadioButton)

	local border = report.RarityBarBorder
	border:Hide()
	local bg = B.CreateBDFrame(border, .25)
	bg:SetPoint("TOPLEFT", border, 6, -5)
	bg:SetPoint("BOTTOMRIGHT", border, -6, 5)

	styled = true
end

function S:ReskinRematch()
	if not C.db["Skins"]["BlizzardSkins"] then return end
	if not C.db["Skins"]["Rematch"] then return end

	local RematchJournal = RematchJournal
	if not RematchJournal then return end

	if RematchSettings then
		RematchSettings.ColorPetNames = true
		RematchSettings.FixedPetCard = true
	end
	RematchLoreFont:SetTextColor(1, 1, 1)

	hooksecurefunc(RematchJournal, "ConfigureJournal", function()
		S.ResizeJournal()

		if RematchJournal.styled then return end

		-- Main Elements
		hooksecurefunc("CollectionsJournal_UpdateSelectedTab", S.ResizeJournal)

		B.StripTextures(RematchJournal)
		B.ReskinClose(RematchJournal.CloseButton)
		for _, tab in ipairs(RematchJournal.PanelTabs.Tabs) do
			B.ReskinTab(tab)
		end

		B.ReskinCheck(UseRematchButton)
		S:ReskinRematchElements()

		RematchJournal.styled = true
	end)

	hooksecurefunc(RematchNotes, "OnShow", function(self)
		if self.styled then return end

		B.StripTextures(self)
		B.ReskinClose(self.CloseButton)
		S:RematchLockButton(self.LockButton)
		self.LockButton:SetPoint("TOPLEFT")

		local content = self.Content
		B.ReskinScroll(content.ScrollFrame.ScrollBar)
		local bg = B.CreateBDFrame(content.ScrollFrame, .25)
		bg:SetPoint("TOPLEFT", 0, 5)
		bg:SetPoint("BOTTOMRIGHT", 0, -2)
		local bg = B.SetBD(content.ScrollFrame)
		bg:SetAllPoints(self)
		local icons = {}
		for _, icon in pairs({"Left", "Right"}) do
			local bu = content[icon.."Icon"]
			local mask = content[icon.."CircleMask"]
			mask:Hide()
			B.ReskinIcon(bu)
			icons[bu] = bu:GetTexture()
		end

		-- fix content icon texture
		B.StripTextures(content)
		for bu, tex in pairs(icons) do
			bu:SetTexture(tex)
		end

		B.Reskin(self.Controls.DeleteButton)
		B.Reskin(self.Controls.UndoButton)
		B.Reskin(self.Controls.SaveButton)

		self.styled = true
	end)

	hooksecurefunc(Rematch, "FillPetTypeIcon", function(_, texture, _, prefix)
		if prefix then
			local button = texture:GetParent()
			S.RematchIcon(button)
		end
	end)

	hooksecurefunc(Rematch, "MenuButtonSetChecked", function(_, button, isChecked, isRadio)
		if isChecked then
			local x = .5
			local y = isRadio and .5 or .25
			button.Check:SetTexCoord(x, x+.25, y-.25, y)
		else
			button.Check:SetTexCoord(0, 0, 0, 0)
		end

		if not button.styled then
			button.Check:SetVertexColor(cr, cg, cb)
			local bg = B.CreateBDFrame(button.Check, 0, true)
			bg:SetPoint("TOPLEFT", button.Check, 4, -4)
			bg:SetPoint("BOTTOMRIGHT", button.Check, -4, 4)

			button.styled = true
		end
	end)

	hooksecurefunc(Rematch, "FillCommonPetListButton", function(self, petID)
		local petInfo = Rematch.petInfo:Fetch(petID)
		local parentPanel = self:GetParent():GetParent():GetParent():GetParent()
		if petInfo.isSummoned and parentPanel == Rematch.PetPanel then
			local bg = parentPanel.SelectedOverlay.bg
			if bg then
				bg:ClearAllPoints()
				bg:SetAllPoints(self.bg)
			end
		end
	end)

	hooksecurefunc(Rematch, "DimQueueListButton", function(_, button)
		button.LevelText:SetTextColor(1, 1, 1)
	end)

	hooksecurefunc(RematchDialog, "FillTeam", function(_, frame)
		S:RematchTeamGroup(frame)
	end)

	local direcButtons = {"UpButton", "DownButton"}
	hooksecurefunc(RematchTeamTabs, "Update", function(self)
		for _, tab in next, self.Tabs do
			S.RematchIcon(tab)
			tab:SetSize(40, 40)
			tab.Icon:SetPoint("CENTER")
		end

		for _, direc in pairs(direcButtons) do
			S.RematchIcon(self[direc])
			self[direc]:SetSize(40, 40)
			self[direc].Icon:SetPoint("CENTER")
		end
	end)

	hooksecurefunc(RematchTeamTabs, "TabButtonUpdate", function(self, index)
		local selected = self:GetSelectedTab()
		local button = self:GetTabButton(index)
		if not button.Icon.bg then return end

		if index == selected then
			button.Icon.bg:SetBackdropBorderColor(1, 1, 1)
		else
			button.Icon.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	hooksecurefunc(RematchTeamTabs, "UpdateTabIconPickerList", function()
		local buttons = RematchDialog.TeamTabIconPicker.ScrollFrame.buttons
		for i = 1, #buttons do
			local button = buttons[i]
			for j = 1, 10 do
				local bu = button.Icons[j]
				if not bu.styled then
					bu:SetSize(26, 26)
					bu.Icon = bu.Texture
					S.RematchIcon(bu)
				end
			end
		end
	end)

	hooksecurefunc(RematchLoadoutPanel, "UpdateLoadouts", function(self)
		if not self then return end

		for i = 1, 3 do
			local loadout = self.Loadouts[i]
			if not loadout.styled then
				B.StripTextures(loadout)
				local bg = B.CreateBDFrame(loadout, .25)
				bg:SetPoint("BOTTOMRIGHT", C.mult, C.mult)
				S.RematchIcon(loadout.Pet.Pet)
				S.RematchXP(loadout.HP)
				S.RematchXP(loadout.XP)
				loadout.XP:SetSize(255, 7)
				loadout.HP.MiniHP:SetText("HP")
				for j = 1, 3 do
					S.RematchIcon(loadout.Abilities[j])
				end

				loadout.styled = true
			end

			local icon = loadout.Pet.Pet.Icon
			local iconBorder = loadout.Pet.Pet.IconBorder
			if icon.bg then
				icon.bg:SetBackdropBorderColor(iconBorder:GetVertexColor())
			end
		end
	end)

	local activeTypeMode = 1
	hooksecurefunc(RematchPetPanel, "SetTypeMode", function(_, typeMode)
		activeTypeMode = typeMode
	end)
	hooksecurefunc(RematchPetPanel, "UpdateTypeBar", function(self)
		local typeBar = self.Top.TypeBar
		if typeBar:IsShown() then
			for i = 1, 4 do
				local tab = typeBar.Tabs[i]
				if not tab then break end
				if not tab.styled then
					B.StripTextures(tab)
					tab.bg = B.CreateBDFrame(tab)
					local r, g, b = tab.Selected.MidSelected:GetVertexColor()
					tab.bg:SetBackdropColor(r, g, b, .5)
					B.StripTextures(tab.Selected)

					tab.styled = true
				end
				tab.bg:SetShown(activeTypeMode == i)
			end
		end
	end)

	hooksecurefunc(RematchPetPanel.List, "Update", S.RematchPetList)
	hooksecurefunc(RematchQueuePanel.List, "Update", S.RematchPetList)
	hooksecurefunc(RematchTeamPanel.List, "Update", S.RematchPetList)

	hooksecurefunc(RematchTeamPanel, "FillTeamListButton", function(self, key)
		local teamInfo = Rematch.teamInfo:Fetch(key)
		if not teamInfo then return end

		local panel = RematchTeamPanel
		if teamInfo.key == RematchSettings.loadedTeam then
			local bg = panel.SelectedOverlay.bg
			if bg then
				bg:ClearAllPoints()
				bg:SetAllPoints(self.bg)
			end
		end
	end)

	hooksecurefunc(RematchOptionPanel, "FillOptionListButton", function(self, index)
		local panel = RematchOptionPanel
		local opt = panel.opts[index]
		if opt then
			self.optType = opt[1]
			local checkButton = self.CheckButton
			if not checkButton.bg then
				checkButton.bg = B.CreateBDFrame(checkButton, 0, true)
				self.HeaderBack:SetTexture(nil)
			end
			checkButton.bg:SetBackdropColor(0, 0, 0, 0)
			checkButton.bg:Show()

			if self.optType == "header" then
				self.headerIndex = opt[3]
				self.Text:SetPoint("LEFT", checkButton, "RIGHT", 5, 0)
				checkButton:SetSize(8, 8)
				checkButton:SetPoint("LEFT", 5, 0)
				checkButton:SetTexture("Interface\\Buttons\\UI-PlusMinus-Buttons")
				checkButton.bg:SetBackdropColor(0, 0, 0, .25)
				checkButton.bg:SetPoint("TOPLEFT", checkButton, -3, 3)
				checkButton.bg:SetPoint("BOTTOMRIGHT", checkButton, 3, -3)

				local isExpanded = RematchSettings.ExpandedOptHeaders[opt[3]]
				if isExpanded then
					checkButton:SetTexCoord(.5625, 1, 0, .4375)
				else
					checkButton:SetTexCoord(0, .4375, 0, .4375)
				end
				if self.headerIndex == 0 and panel.allCollapsed then
					checkButton:SetTexCoord(0, .4375, 0, .4375)
				end
			elseif self.optType == "check" then
				checkButton:SetSize(22, 22)
				checkButton.bg:SetPoint("TOPLEFT", checkButton, 3, -3)
				checkButton.bg:SetPoint("BOTTOMRIGHT", checkButton, -3, 3)
				if self.isChecked and self.isDisabled then
					checkButton:SetTexCoord(.25, .5, .75, 1)
				elseif self.isChecked then
					checkButton:SetTexCoord(.5, .75, 0, .25)
				else
					checkButton:SetTexCoord(0, 0, 0, 0)
				end
			elseif self.optType == "radio" then
				local isChecked = RematchSettings[opt[2]] == opt[5]
				checkButton:SetSize(22, 22)
				checkButton.bg:SetPoint("TOPLEFT", checkButton, 3, -3)
				checkButton.bg:SetPoint("BOTTOMRIGHT", checkButton, -3, 3)
				if isChecked then
					checkButton:SetTexCoord(.5, .75, .25, .5)
				else
					checkButton:SetTexCoord(0, 0, 0, 0)
				end
			else
				checkButton.bg:Hide()
			end
		end
	end)

	-- Window mode
	hooksecurefunc(RematchFrame, "ConfigureFrame", function(self)
		if self.styled then return end

		B.StripTextures(self)
		B.SetBD(self)
		for _, tab in ipairs(self.PanelTabs.Tabs) do
			B.ReskinTab(tab)
		end

		B.StripTextures(RematchMiniPanel)
		S:RematchTeamGroup(RematchMiniPanel)
		S:RematchFlyoutButton(RematchMiniPanel.Flyout)

		local titleBar = self.TitleBar
		B.StripTextures(titleBar)
		B.ReskinClose(titleBar.CloseButton)

		S:RematchLockButton(titleBar.MinimizeButton)
		S:RematchLockButton(titleBar.LockButton)
		S:RematchLockButton(titleBar.SinglePanelButton)
		S:ReskinRematchElements()

		self.styled = true
	end)
end