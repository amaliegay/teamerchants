local interop = require("mer.drip")
--Tea Merchants
local weapons = require("mer.drip.integrations.teaMerchants.weapons")
for _, weapon in ipairs(weapons) do
    interop.registerWeapon(weapon)
end


