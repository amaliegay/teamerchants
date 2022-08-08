local this = {}
local common = require("mer.ashfall.common.common")
local config = require("teaMerchants.config").config
local logger = require("teaMerchants.logging").createLogger("teaMerchant")
local merchantMenu = require("mer.ashfall.merchants.merchantMenu")
local teaConfig = common.staticConfigs.teaConfig
local validTeas = require("teaMerchants.validTeas")

this.guids = { MenuDialog_TeaService = tes3ui.registerID("MenuDialog_service_TeaService") }

local function isTeaMerchant(reference)
	local obj = reference.baseObject or reference.object
	local objId = obj.id:lower()
	local classId = obj.class and reference.object.class.id:lower()
	logger:debug("%s is a %s.", objId, classId)
	return (classId == "tea merchant") or config.teaMerchants[objId]
end

local teaBaseCost = 25
local dispMulti = 1.3
local personalityMulti = 1.1

local function getTeaCost(merchantObj)
	local disposition = math.min(merchantObj.disposition, 100)
	local personality = math.min(tes3.mobilePlayer.personality.current, 100)
	local dispEffect = math.remap(disposition, 0, 100, dispMulti, 1.0)
	local personalityEffect = math.remap(personality, 0, 100, personalityMulti, 1.0)
	local discountApplied = tes3.getJournalIndex { id = "teaMerchants_golden_sedge" } >= 100 or
	                        tes3.getJournalIndex { id = "teaMerchants_scathecraw" } >= 100
	if discountApplied then
		return 10
	end
	return math.floor(teaBaseCost * dispEffect * personalityEffect)
end

local function getTeaMenuText(merchantObj)
	local cost = getTeaCost(merchantObj)
	return string.format("Hot Tea (%d gold)", cost)
end

local function fill(merchant, teaType, bottle)
	local cost = getTeaCost(merchant.object)
	tes3.removeItem({ reference = tes3.player, item = "Gold_001", count = cost })
	tes3.addItem({ reference = merchant.reference, item = "Gold_001", count = cost })
	tes3.addItem({ reference = tes3.player, item = bottle, count = 1 })
	local itemData
	itemData = tes3.addItemData { to = tes3.player, item = bottle }
	itemData.data.waterAmount = 90
	itemData.data.waterType = teaType
	itemData.data.teaProgress = 100
	itemData.data.waterHeat = 100
	common.helper.fadeTimeOut(0.25, 2, function()
	end) -- 15 min has been passed 
	tes3.messageBox("A %s filled with %s has been added to your inventory.", tes3.getObject(bottle).name,
	                teaConfig.teaTypes[teaType].teaName)
end

local function teaSelectMenu()
	local merchant = merchantMenu.getDialogMenu():getPropertyObject("PartHyperText_actor")
	local buttons = {}
	table.insert(buttons, {
		text = string.format("Surprise Me"),
		callback = function()
			fill(merchant, table.choice(validTeas), "jsmk_Misc_Com_Bottle")
		end,
		tooltip = {
			header = string.format("Surprise Me"),
			text = "Feeling adventurous? The Tea Merchant will make a random drink. It might just become your new favourite!",
		},
	})
	for teaType, teaData in pairs(teaConfig.teaTypes) do
		if tes3.getItemCount({ item = teaType, reference = merchant.reference }) ~= 0 then
			table.insert(buttons, {
				text = string.format("%s", teaData.teaName),
				callback = function()
					fill(merchant, teaType, "jsmk_Misc_Com_Bottle")
					tes3.removeItem({ reference = merchant.reference, item = teaType, count = 1 })
				end,
				tooltip = { header = string.format("%s", teaData.teaName), text = teaData.teaDescription },
			})
		end
	end
	tes3ui.showMessageMenu({ message = "Select a type of tea", buttons = buttons, cancels = true })
end
local function onTeaServiceClick()
	teaSelectMenu()
end

local function getDisabled(cost)
	-- check player can afford
	if tes3.getPlayerGold() < cost then
		return true
	end
	return false
end
local function makeTooltip()
	local menuDialog = merchantMenu.getDialogMenu()
	if not menuDialog then
		return
	end
	local merchant = menuDialog:getPropertyObject("PartHyperText_actor")
	local cost = getTeaCost(merchant.object)
	local tooltip = tes3ui.createTooltipMenu()
	local labelText = "Purchase a bottle of tea. "
	if getDisabled(cost) then
		labelText = "You do not have enough gold."
	end
	local tooltipText = tooltip:createLabel{ text = labelText }
	tooltipText.wrapText = true
end
local function updateTeaServiceButton(e)
	timer.frame.delayOneFrame(function()
		local menuDialog = merchantMenu.getDialogMenu()
		if not menuDialog then
			return
		end
		local teaServiceButton = menuDialog:findChild(this.guids.MenuDialog_TeaService)
		local merchant = menuDialog:getPropertyObject("PartHyperText_actor")
		local cost = getTeaCost(merchant.object)
		if getDisabled(cost) then
			teaServiceButton.disabled = true
			teaServiceButton.widget.state = 2
		else
			teaServiceButton.disabled = false
		end
		teaServiceButton.text = getTeaMenuText(merchant.object)
	end)
end
local function createTeaButton(menuDialog)
	local parent = merchantMenu.getButtonBlock()
	local merchant = merchantMenu.getMerchantObject()
	local button = parent:createTextSelect{ id = this.guids.MenuDialog_TeaService, text = getTeaMenuText(merchant) }
	button.widthProportional = 1.0
	button:register("mouseClick", onTeaServiceClick)
	button:register("help", makeTooltip)
	menuDialog:registerAfter("update", updateTeaServiceButton)
end
local function onMenuDialogActivated()
	local menuDialog = merchantMenu.getDialogMenu()
	-- Get the actor that we're talking with.
	local mobileActor = menuDialog:getPropertyObject("PartHyperText_actor")
	local ref = mobileActor.reference
	if isTeaMerchant(ref) then
		logger:debug("Adding Hot Tea Service")
		-- Create our new button.
		createTeaButton(menuDialog)
	end
end
event.register("uiActivated", onMenuDialogActivated, { filter = "MenuDialog", priority = -99 })
