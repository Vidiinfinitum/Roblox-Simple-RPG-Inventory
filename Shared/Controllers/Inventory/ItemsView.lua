-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remotes --
local UpdateInventory = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Inventory"):WaitForChild("UpdateInventory")

-- Controllers --
local Controllers = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Controllers")
local InventoryView = require(Controllers:WaitForChild("Inventory"):WaitForChild("InventoryView"))

-- Classes --
local Classes = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Classes")
local WeaponClass = require(Classes:WaitForChild("WeaponClass"))
local ArmorClass = require(Classes:WaitForChild("ArmorClass"))
local AccessoryClass = require(Classes:WaitForChild("AccessoryClass"))
local ConsumableClass = require(Classes:WaitForChild("ConsumableClass"))

-- Functions --
local function ShouldShowItem(category: string, filter: string)
	print("Entrou no shouldshowitems")
	if filter == "All" then
		return true
	end

	if filter == "Weapons" then
		return category == "Weapon"
	end

	if filter == "Armors" then
		return category == "Armor"
	end

	if filter == "Accessories" then
		return category == "Accessory"
	end

	if filter == "Consumables" then
		return category == "Consumable"
	end

	return false
end

local function CreateObject(information, data)
	local itemId = information.Id
	local itemCategory = information.Category
	
	if itemCategory == "Weapon" then
		return WeaponClass.new(data.ItemsIndex[itemId], information)
	elseif itemCategory == "Armor" then
		return ArmorClass.new(data.ItemsIndex[itemId], information)
	elseif itemCategory == "Accessory" then
		return AccessoryClass.new(data.ItemsIndex[itemId], information)
	elseif itemCategory == "Consumable" then
		return ConsumableClass.new(data.ItemsIndex[itemId], information)
	end
end

local function CreateItem(template: Frame, showFrame: ScrollingFrame, itemObject)
	local newItem = template:Clone()
	
	-- Configs
	newItem.Name = itemObject.Name
	newItem.Button.Image = itemObject.ImageId
	newItem.Amount.Text = itemObject.Amount
	
	if itemObject.Rarity == "Common" then
		newItem.BackgroundColor3 = Color3.fromRGB(212, 212, 212)
	elseif itemObject.Rarity == "Uncommon" then
		newItem.BackgroundColor3 = Color3.fromRGB(116, 232, 0)
	elseif itemObject.Rarity == "Rare" then
		newItem.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
	elseif itemObject.Rarity == "Epic" then
		newItem.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
	elseif itemObject.Rarity == "Legendary" then
		newItem.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
	end
	
	-- Put it in the inventory
	newItem.Parent = showFrame
	newItem.Visible = true
	
	return newItem
end

local function ConfigSpecificationsFrame(itemObject, specificationsFrame: Frame)
	if itemObject.Equiped then
		print(itemObject.Equiped)
		specificationsFrame.EquipButton.Text = "Equiped"
		specificationsFrame.EquipButton.TextColor3 = Color3.fromRGB(90, 90, 90)
		specificationsFrame.EquipButton.Interactable = false
	else
		specificationsFrame.EquipButton.Text = "Equip"
		specificationsFrame.EquipButton.TextColor3 = Color3.fromRGB(0, 197, 0)
		specificationsFrame.EquipButton.Interactable = true
	end
	
	if itemObject.Category == "Consumable" then
		specificationsFrame.EquipButton.Text = "Use"
	end
	
	specificationsFrame.ItemName.Text = itemObject.Name
	specificationsFrame.ItemLevel.Text = ("Level: %s"):format(tostring(itemObject.Level))
	specificationsFrame.ItemValue.Text = ("Value: %s"):format(tostring(itemObject.Value))
	specificationsFrame.ItemCategory.Text = ("Category: %s"):format(itemObject.Category)
	specificationsFrame.ItemRarity.Text = ("Rarity: %s"):format(itemObject.Rarity)
	
	if itemObject.Damage then
		specificationsFrame.ItemDamage.Text = ("Damage: %s"):format(tostring(itemObject.Damage))
	else
		specificationsFrame.ItemDamage.Text = "Damage: N/A"
	end

	if itemObject.Armor then
		specificationsFrame.ItemArmor.Text = ("Armor: %s"):format(tostring(itemObject.Armor))
	else
		specificationsFrame.ItemArmor.Text = "Armor: N/A"
	end

	if itemObject.Health then
		specificationsFrame.ItemHealth.TextTransparency = 0
		specificationsFrame.ItemHealth.Text = ("Health: +%s"):format(tostring(itemObject.Health))
	else
		specificationsFrame.ItemHealth.TextTransparency = 1
	end

	if itemObject.MaxHealth then
		specificationsFrame.ItemHealth.TextTransparency = 0
		specificationsFrame.ItemHealth.Text = ("MaxHealth: %s"):format(tostring(itemObject.MaxHealth))
	else
		specificationsFrame.ItemHealth.TextTransparency = 1
	end

	if itemObject.Mana then
		specificationsFrame.ItemMana.TextTransparency = 0
		specificationsFrame.ItemMana.Text = ("Mana: +%s"):format(tostring(itemObject.Mana))
	else
		specificationsFrame.ItemMana.TextTransparency = 1
	end

	if itemObject.MaxMana then
		specificationsFrame.ItemMana.TextTransparency = 0
		specificationsFrame.ItemMana.Text = ("MaxMana: %s"):format(tostring(itemObject.MaxMana))
	else
		specificationsFrame.ItemMana.TextTransparency = 1
	end
end

local function UpdateCanvas(scrollingFrame:ScrollingFrame, uiGrid:UIGridLayout)
	scrollingFrame.CanvasSize = UDim2.fromOffset(
		0,
		uiGrid.AbsoluteContentSize.Y + 30
	)
end

local ItemsView = {}

local buttons = {}
local buttonConnections = {}
local specificationsConnections = {}

-- Get the update show frame signal
InventoryView.UpdateShowFrame:Connect(function(whatUpdate: string, showFrame: ScrollingFrame, template: Frame, data, specificationsFrame: Frame)
	-- Clear the showFrame
	for _, item in pairs(showFrame:GetChildren()) do
		if item:IsA("Frame") then
			item:Destroy()
		end
	end
	
	-- Clear connections
	for _, connection in pairs(buttonConnections) do
		connection:Disconnect()
	end
	
	for _, connection in pairs(specificationsConnections) do
		connection:Disconnect()
	end
	
	-- Clear buttons
	buttons = {}
	
	for instanceId, information in pairs(data.PlayerInventory) do
		-- To filter
		if ShouldShowItem(information.Category, whatUpdate) then

			-- Creates a new item object
			local newObject = CreateObject(information, data)
			
			-- Create the item
			if newObject then
				local newItem = CreateItem(template, showFrame, newObject)
				local newButton = newItem:FindFirstChild("Button")
				buttons[newObject] = newButton
			else
				warn("Item object was not created!")
				continue
			end
		end
	end
	
	-- Update the canvas size
	UpdateCanvas(showFrame, showFrame.UIGridLayout)
	
	-- Create the connections
	for itemObject, button in pairs(buttons) do
		local buttonConnection = button.MouseButton1Click:Connect(function()
			ConfigSpecificationsFrame(itemObject, specificationsFrame)
			specificationsFrame.Visible = true
			
			for itemObject, button in pairs(buttons) do
				button.Interactable = false
			end
			
			-- Clear the connections
			for _, connection in pairs(specificationsConnections) do
				connection:Disconnect()
			end
			
			local equipButton = specificationsFrame:FindFirstChild("EquipButton") :: TextButton
			local leaveButton = specificationsFrame:FindFirstChild("LeaveButton") :: TextButton
			
			local leaveButtonConnection = leaveButton.MouseButton1Click:Connect(function()
				specificationsFrame.Visible = false
				
				for itemObject, button in pairs(buttons) do
					button.Interactable = true
				end
			end)
			table.insert(specificationsConnections, leaveButtonConnection)
			
			local equipButtonConnection = equipButton.MouseButton1Click:Connect(function()
				-- Send remote to update the data
				-- Send signal to update 
			end)
			
		end)
		buttonConnections[itemObject] = buttonConnection
	end
	
end)

return ItemsView
