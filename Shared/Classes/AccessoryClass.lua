-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ItemClass --
local ItemClass = require(ReplicatedStorage.Shared.Classes.ItemClass)

local AccessoryClass = {}
AccessoryClass.__index = AccessoryClass

-- Set the AccessoryClass as an "object" of ItemClass
setmetatable(AccessoryClass, {__index = ItemClass})

-- Create the AccessoryClass type
export type AccessoryClass = ItemClass.ItemClass & {
	CanEquip: boolean,
	CanConsume: boolean,
	Equiped: boolean,
	AcessoryType: string,
	MaxHealth: number,
	MaxMana: number,	
}

-- Constructor function for the object
function AccessoryClass.new(itemDefinition, inventoryItem): AccessoryClass
	local self = setmetatable(ItemClass.new(itemDefinition, inventoryItem) :: AccessoryClass, AccessoryClass)
	
	self.CanEquip = true
	self.CanConsume = false
	self.Equiped = inventoryItem.Equiped
	self.AccessoryType = itemDefinition.AccessoryType
	self.MaxHealth = itemDefinition.MaxHealth
	self.MaxMana = itemDefinition.MaxMana
	
	return self
end

return AccessoryClass
