-- Services --
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes --
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetData = Remotes:WaitForChild("Inventory"):WaitForChild("GetData")

-- Get data modules --
local Data = ServerStorage:WaitForChild("Data")
local ItemsInformation = Data:WaitForChild("ItemsInformation")
-- Player data 
local PlayerEquipment = require(Data:WaitForChild("PlayerEquipment"))
local PlayerInventory = require(Data:WaitForChild("PlayerInventory"))
local InventoryInformations = require(Data:WaitForChild("InventoryInformations"))
-- Items data 
local ItemsIndex = require(ItemsInformation.ItemsIndex)

GetData.OnServerInvoke = function()
	return {
		InventoryInformations = InventoryInformations,
		PlayerInventory = PlayerInventory,
		PlayerEquipment = PlayerEquipment,
		ItemsIndex = ItemsIndex.Data,
	}
end
