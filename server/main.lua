ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent("esx_BodyLoot:TakeItem")
AddEventHandler('esx_BodyLoot:TakeItem', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local randomNumber = math.random(1, #Config.LootItems)
	local randomItem = Config.LootItems[randomNumber]

	if xPlayer.canCarryItem(randomItem, 1) then
		xPlayer.addInventoryItem(randomItem, 1)
		local itemLabel = ESX.GetItemLabel(randomItem)
		xPlayer.showNotification('You found 1 ' .. itemLabel)
	else
		xPlayer.showNotification('[ERROR] You do not have space for this item!')
	end
end)