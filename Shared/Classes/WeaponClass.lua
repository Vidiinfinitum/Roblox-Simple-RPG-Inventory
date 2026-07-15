-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get the ItemClass
local ItemClass = require(ReplicatedStorage.Shared.Classes.ItemClass)

local WeaponClass = {}
WeaponClass.__index = WeaponClass

-- Set the WeaponClass as an object of ItemClass
setmetatable(WeaponClass, {__index = ItemClass})

-- Creayes the WeaponClass type
export type WeaponClass = ItemClass.ItemClass & {
	CanEquip: boolean,
	CanConsume: boolean,
	Equiped: boolean,
	WeaponType: string,
	Damage: number
	
}

-- Constructor function for the object
function WeaponClass.new(itemDefinition, inventoryItem): WeaponClass
	local self = setmetatable(ItemClass.new(itemDefinition, inventoryItem) :: WeaponClass, WeaponClass)
	
	self.CanEquip = true
	self.CanConsume = false
	self.Equiped = inventoryItem.Equiped
	self.WeaponType = itemDefinition.WeaponType
	self.Damage = itemDefinition.Damage
	
	return self
end

return WeaponClass
