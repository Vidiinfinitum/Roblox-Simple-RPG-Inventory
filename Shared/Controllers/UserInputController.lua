-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Get the Signal class --
local Signal = require(ReplicatedStorage.Shared.Signals.GoodSignal)


local UserInputController = {}

-- Signals
UserInputController.ToggleInventory = Signal.new()

-- Table to handle the connections created
local connections = {}

function UserInputController.Start()
	-- Creates the input connection
	local inputConnection = UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessedEvent: boolean)
		if gameProcessedEvent then return end
		
		local keyCode = input.KeyCode
		-- To open/close inventory
		if keyCode == Enum.KeyCode.Q then
			UserInputController.ToggleInventory:Fire()
		end
	end)
	connections.InputBegan = inputConnection
end

return UserInputController
