-- Services --
local ServerStorage = game:GetService("ServerStorage")

-- ItemsInformation
local ItemsInformation = ServerStorage.Data.ItemsInformation

-- Require the items informations --
local Weapons = require(ItemsInformation.Weapons)
local Armors = require(ItemsInformation.Armors)
local Consumables = require(ItemsInformation.Consumables)
local Accessories = require(ItemsInformation.Accessories)

local ItemsIndex = {}

ItemsIndex.Data = {}

local ItemsCategory = {
	Weapons,
	Armors,
	Consumables,
	Accessories,
}

-- Put all itens in the index
for _, category in ipairs(ItemsCategory) do
	for id, data in pairs(category) do
		-- To make sure that the same id is not duplicated
		assert(not ItemsIndex.Data[id], ("Duplicated item for '%s' id"):format(id))
		
		ItemsIndex.Data[id] = data
	end
end

return ItemsIndex
