local ItemClass = {}
ItemClass.__index = ItemClass

export type ItemClass = {
	InstanceId: string,
	Id: number,
	Name: string,
	Category: string,
	Rarity: string,
	Level: number,
	Value: number,
	ImageId: string,
	Amount: number,
	MaxAmount: number,
	CurrentAmount: number,
}

-- Constructor function for the object 
function ItemClass.new(itemDefinition, inventoryItem): ItemClass
	local self = setmetatable({} :: ItemClass, ItemClass)
	
	-- itemDefinition -> Table with static item data
	-- inventoryItem -> Table with the dinamic inventory item data
	
	self.InstanceId = inventoryItem.InstanceId
	self.Id = itemDefinition.Id
	self.Name = itemDefinition.Name
	self.Category = itemDefinition.Category
	self.Rarity = itemDefinition.Rarity
	self.Level = itemDefinition.Level
	self.Value = itemDefinition.Value
	self.ImageId = itemDefinition.ImageId
	self.MaxAmount = itemDefinition.MaxAmount
	self.Amount = inventoryItem.Amount
	self.CurrentAmount = inventoryItem.CurrentAmount
	
	return self
end

return ItemClass

