local common = require("mer.ashfall.common.common")
local logger = require("logging.logger")
local config = require("teaMerchants.mcm").config
local log = logger.new { name = "teaMerchants.addTea", logLevel = config.logLevel }
local thirstController = require("mer.ashfall.needs.thirstController")
local validTeas = require("teaMerchants.validTeas")

-- First time entering a cell, add tea to random Tea Merchants' liquidContainers
local chanceToFill = 1
local fillMin = 25

local function fill(ref, bottleData)
	local fillAmount = math.random(fillMin, bottleData.capacity)
	-- if it is Tea Merchant' bottles, it has to be a full bottle of tea
	if ref.id:lower() == "jsmk_misc_com_bottle" then
		fillAmount = bottleData.capacity
	end
	ref.data.waterAmount = fillAmount
	local waterType = table.choice(validTeas)
	if tes3.getObject(waterType) then
		ref.data.waterType = waterType
		ref.data.teaProgress = 100
		ref.data.waterHeat = math.random(0, 100)
	end
	ref.modified = true
end
local function addTeaToWorld(e)
	for ref in e.cell:iterateReferences(tes3.objectType.miscItem) do
		local teaOwner = tes3.getOwner(ref)
		if teaOwner and teaOwner.id == "Tea Merchants" or ref.id:lower() == "jsmk_misc_com_bottle" then
			local bottleData = thirstController.getBottleData(ref.object.id)
			if bottleData and not ref.data.waterAmount then
				if math.random() < chanceToFill then
					fill(ref, bottleData)
				end
			end
		end
	end
end
event.register("cellChanged", addTeaToWorld)
