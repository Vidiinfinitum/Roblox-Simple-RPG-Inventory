-- Services --
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get the signal class --
local Signal = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Signals"):WaitForChild("GoodSignal"))

local InventoryView = {}
InventoryView.__index = InventoryView

local connections = {}

-- Signals --
InventoryView.UpdateShowFrame = Signal.new()

-- Functions --
local function SetImage(frame: Frame, itemId: string, itemIndex)

	local itemData = itemIndex[itemId]
	if not itemData then return end
	
	local imageToChange = frame:FindFirstChild("Image")
	imageToChange.Image = itemData.ImageId
end

-- Create the InventoryView type
export type InventoryView = {
	Gui: ScreenGui,
	Background: Frame,
	OpeningDuration: number,
	IsOpen: boolean,
	FirstPosition: UDim2,
	LastPosition: UDim2,
	PlayerName: TextLabel,
	Gold: TextLabel,
	Silhouette: ViewportFrame,
	Equipment: {
		Helmet: Frame,
		Upper: Frame,
		Lower: Frame,
		Weapon: Frame,
		Accessory1: Frame,
		Accessory2: Frame
	},
	Buttons: {
		All: TextButton,
		Armors: TextButton,
		Weapons: TextButton,
		Consumables: TextButton,
		Accessories: TextButton	
	},
	ShowFrame: ScrollingFrame,
	Template: Frame,
	Tween: Tween?,
	CurrentCharacter: Model?,
	CurrentCamera: Camera?
}

-- Constructor function 
function InventoryView.new(inventoryGUI: ScreenGui): InventoryView
	local self = setmetatable({} :: InventoryView, InventoryView)
	
	self.Gui = inventoryGUI
	self.Background = inventoryGUI.Background
	self.OpeningDuration = (inventoryGUI:GetAttribute("OpeningDuration") :: number?) or 1
	self.IsOpen = false
	self.ClosePosition = self.Background.Position
	self.OpenPosition = UDim2.new(0.5,0,0.5,0) -- Center of screen
	
	self.PlayerName = self.Background.PlayerName
	self.Gold = self.Background.Gold
	self.Silhouette = self.Background.Silhouette
	
	local equipment = self.Background.Equipment
	self.Equipment = {
		Helmet = equipment.Helmet,
		Upper = equipment.Upper,
		Lower = equipment.Lower,
		Weapon = equipment.Weapon,
		Accessory1 = equipment.Accessory1,
		Accessory2 = equipment.Accessory2,
	}
	
	local itemsFrame = self.Background.ItemsFrame
	self.Buttons = {
		All = itemsFrame.AllFrame.Button,
		Armors = itemsFrame.ArmorsFrame.Button,
		Weapons = itemsFrame.WeaponsFrame.Button,
		Consumables = itemsFrame.ConsumablesFrame.Button,
		Accessories = itemsFrame.AccessoriesFrame.Button,
	}
	self.ShowFrame = itemsFrame.ShowFrame
	self.Template = itemsFrame.Template
	self.StorageCapacity = itemsFrame.StorageCapacity
	self.SpecificationsFrame = itemsFrame.SpecificationsFrame
	self.Tween = nil
	
	self.CurrentCharacter = nil
	self.CurrentCamera = nil
	
	self.Data = nil
	
	return self
end

-- Method to handle the Tween
function InventoryView:TweenTo(goal: UDim2)
	if self.Tween then
		self.Tween:Cancel()
	end
	
	-- Creates the tween to apply to background
	self.Tween = TweenService:Create(
		self.Background,
		TweenInfo.new(self.OpeningDuration),
		{Position = goal}
	)	
	
	self.Tween:Play()
end

-- Method to handle the opening
function InventoryView:Open()
	self.IsOpen = true
	
	if not self.Gui.Enabled then
		self.Gui.Enabled = true
	end
	
	self:TweenTo(self.OpenPosition)
end

-- Method to handle the closing
function InventoryView:Close()
	self.IsOpen = false
	
	self:TweenTo(self.ClosePosition)
	
	-- Tween to see if the close tween ended correctly
	self.Tween.Completed:Once(function(playbackState)
		if playbackState ~= Enum.PlaybackState.Completed then return end
		self.Gui.Enabled = false
	end)
end

-- Method to handle the toggle process
function InventoryView:Toggle(player: Player, data)
	if self.IsOpen then
		self:Close()
	else
		self:Initialize(player, data)
		self:Open()
	end
end

-- Creates the buttons connections
function InventoryView:InitButtons()
	local allButtonConnection = self.Buttons.All.MouseButton1Click:Connect(function()
		InventoryView.UpdateShowFrame:Fire("All", self.ShowFrame, self.Template, self.Data, self.SpecificationsFrame)
	end)
	connections.AllButton = allButtonConnection

	local armorsButtonConnection = self.Buttons.Armors.MouseButton1Click:Connect(function()
		InventoryView.UpdateShowFrame:Fire("Armors", self.ShowFrame, self.Template, self.Data, self.SpecificationsFrame)
	end)
	connections.ArmorsButton = armorsButtonConnection

	local weaponsButtonConnection = self.Buttons.Weapons.MouseButton1Click:Connect(function()
		InventoryView.UpdateShowFrame:Fire("Weapons", self.ShowFrame, self.Template, self.Data, self.SpecificationsFrame)
	end)
	connections.WeaponsButton = weaponsButtonConnection

	local consumablesButtonConnection = self.Buttons.Consumables.MouseButton1Click:Connect(function()
		InventoryView.UpdateShowFrame:Fire("Consumables", self.ShowFrame, self.Template, self.Data, self.SpecificationsFrame)
	end)
	connections.ConsumablesButton = consumablesButtonConnection

	local accessoriesButtonConnection = self.Buttons.Accessories.MouseButton1Click:Connect(function()
		InventoryView.UpdateShowFrame:Fire("Accessories", self.ShowFrame, self.Template, self.Data, self.SpecificationsFrame)
	end)
	connections.AccessoriesButton = accessoriesButtonConnection
end

-- To initialize the inventory
function InventoryView:Initialize(player: Player, data)
	self.Data = data
	
	self:InitViewportFrame(player)
	self:InitPlayerInfo(player)
	self:InitEquipment()
	self:InitItems()
end

-- Initialize the ViewportFrame
function InventoryView:InitViewportFrame(player: Player)
	if self.CurrentCharacter then
		self.CurrentCharacter:Destroy()
	end
	
	local character = player.Character or player.CharacterAdded:Wait()
	if not character then warn("Character not found!") return end
	
	character.Archivable = true
	
	local newCharacter = character:Clone()
	
	self.CurrentCharacter = newCharacter

	-- Configure the newCharacter
	newCharacter:PivotTo(
		CFrame.new(0,0,0) * CFrame.Angles(math.rad(0), math.rad(180), math.rad(0))
	)
	newCharacter.Parent = self.Silhouette
	
	-- Configure the camera
	if not self.CurrentCamera then
		local camera: Camera = Instance.new("Camera")
		camera.Parent = self.Silhouette
		self.Silhouette.CurrentCamera = camera
		
		self.CurrentCamera = camera
	end

	self.CurrentCamera.CFrame = CFrame.new(0,0,5) * CFrame.Angles(math.rad(0), math.rad(0), math.rad(0))
end

function InventoryView:InitPlayerInfo(player: Player)
	-- Set the name in inventory
	local displayName = player.DisplayName
	self.PlayerName.Text = displayName
	
	-- Set the gold that player have
	self.Gold.Text = ("Gold: $%.2f"):format(self.Data.InventoryInformations.Gold)
	
	-- Set the storage capacity
	local currentAmount = 0
	for _ in pairs(self.Data.PlayerInventory) do
		currentAmount += 1
	end
	self.StorageCapacity.Text = ("Storage: %d/%d"):format(currentAmount, self.Data.InventoryInformations.StorageCapacity)
end

function InventoryView:InitEquipment()
	-- Weapon
	local weapon = self.Data.PlayerEquipment.Weapon
	if weapon then
		SetImage(self.Equipment.Weapon, weapon.Id, self.Data.ItemsIndex)
	end
	
	-- Armors
	local helmet = self.Data.PlayerEquipment.Armor.Helmet
	if helmet then
		SetImage(self.Equipment.Helmet, helmet.Id, self.Data.ItemsIndex)
	end
	
	local upper = self.Data.PlayerEquipment.Armor.Upper
	if upper then
		SetImage(self.Equipment.Upper, upper.Id, self.Data.ItemsIndex)
	end
	
	local lower = self.Data.PlayerEquipment.Armor.Lower
	if lower then
		SetImage(self.Equipment.Lower, lower.Id, self.Data.ItemsIndex)
	end

	-- Accessories
	local Accessory1 = self.Data.PlayerEquipment.Accessories.Accessory1
	if Accessory1 then
		SetImage(self.Equipment.Accessory1, Accessory1.Id, self.Data.ItemsIndex)
	end
	
	local Accessory2 = self.Data.PlayerEquipment.Accessories.Accessory2
	if Accessory2 then
		SetImage(self.Equipment.Accessory2, Accessory2.Id, self.Data.ItemsIndex)
	end
end

function InventoryView:InitItems()
	InventoryView.UpdateShowFrame:Fire("All", self.ShowFrame, self.Template, self.Data, self.SpecificationsFrame)
	print("Enviou sinal")
end

return InventoryView
