-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Controllers --
local Controllers = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Controllers")
local UserInputController = require(Controllers:WaitForChild("UserInputController"))
local InventoryController = require(Controllers:WaitForChild("Inventory"):WaitForChild("InventoryController"))


-- Main Script --

-- Start the UserInputController
UserInputController.Start()

-- Start the InventoryController
InventoryController.Start()
