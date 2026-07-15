-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ItemClass --
local ItemClass = require(ReplicatedStorage.Shared.Classes.ItemClass)

local ArmorClass = {}
ArmorClass.__index = ArmorClass

-- Set the ArmorClass as an object of ItemClass
setmetatable(ArmorClass, {__index = ItemClass})

-- Create the ArmorClass type
export type ArmorClass = ItemClass.ItemClass & {
	CanEquip: boolean,
	CanConsume: boolean,
	Equiped: boolean,
	ArmorType: string,
	Armor: number
}

-- Constructor function for the object
function ArmorClass.new(itemDefinition, inventoryItem): ArmorClass
	local self = setmetatable(ItemClass.new(itemDefinition, inventoryItem) :: ArmorClass, ArmorClass)
	
	self.CanEquip = true
	self.CanConsume = false
	self.Equiped = inventoryItem.Equiped
	self.ArmorType = itemDefinition.ArmorType
	self.Armor = itemDefinition.Armor
	
	return self
end

return ArmorClass
