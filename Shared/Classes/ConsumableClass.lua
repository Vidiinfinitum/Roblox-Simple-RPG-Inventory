-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ItemClass --
local ItemClass = require(ReplicatedStorage.Shared.Classes.ItemClass)

local ConsumableClass = {}
ConsumableClass.__index = ConsumableClass

-- Set the ConsumableClass as an "object" of ItemClass
setmetatable(ConsumableClass, {__index = ItemClass})

-- Create ConsumableClass type
export type ConsumableClass = ItemClass.ItemClass & {
	CanEquip: boolean,
	CanConsume: boolean,
	ConsumableType: string,
	Health: number,
	Mana: number,
}

-- Constructor function for the object
function ConsumableClass.new(itemDefinition, inventoryItem): ConsumableClass
	local self = setmetatable(ItemClass.new(itemDefinition, inventoryItem) :: ConsumableClass, ConsumableClass)
	
	self.CanEquip = false
	self.CanConsume = true
	self.ConsumableType = itemDefinition.ConsumableType
	self.Health = itemDefinition.Health
	self.Mana = itemDefinition.Mana
	
	return self
end




return ConsumableClass
