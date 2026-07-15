-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Remotes --
local GetData = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Inventory"):WaitForChild("GetData")

-- Controllers --
local UserInputController = require(ReplicatedStorage.Shared.Controllers.UserInputController)

-- Modules --
local Inventory = ReplicatedStorage.Shared.Controllers.Inventory
local InventoryView = require(Inventory.InventoryView)
local ItemsView = require(Inventory.ItemsView)

-- InventoryGUI --
local InventoryGUI = ReplicatedStorage.InventoryGUI

local InventoryController = {}

-- Get player and playerGUI
local player = Players.LocalPlayer
local playerGUI = player.PlayerGui

local data = nil

function InventoryController.Start()
	-- Create a fresh new inventory object
	local newInventory = InventoryGUI:Clone()
	
	-- Put the newInventory in playerGUI
	newInventory.Parent = playerGUI
	
	-- Creates a new inventory object
	local newInventoryObject = InventoryView.new(newInventory)
	
	-- Initialize the buttons
	newInventoryObject:InitButtons()
	
	-- Then, when player clicks "i", it will open/close the initialized newInventory
	UserInputController.ToggleInventory:Connect(function()
		-- Get the data to send to the inventory
		data = GetData:InvokeServer()
		newInventoryObject:Toggle(player, data)
	end)
	
end
	
return InventoryController
