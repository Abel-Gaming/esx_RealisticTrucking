ESX              = nil
local truckReady = false
local playerTruck = nil
local trailerReady = false
local playerTrailer = nil
local IsTrailerConnected = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(250)
	end
end)

----- TRUCK THREAD -----
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local closestTruck = ESX.Game.GetClosestVehicle(playerCoords)
		local closestTruckModel = GetDisplayNameFromVehicleModel(ESX.Game.GetVehicleProperties(closestTruck).model)

		for k,v in pairs(Config.Trucks) do
			--Check to see if the ped is in a vehicle
			if not IsPedInAnyVehicle(PlayerPedId(), false) then
				if v == closestTruckModel then
					while #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(closestTruck)) <= 2.0 do
						Citizen.Wait(0)

						if not truckReady and not IsTrailerConnected then
							ESX.Game.Utils.DrawText3D(GetEntityCoords(closestTruck), "Press ~y~[E]~s~ to prepare truck for trailer")
						end

						-- Check for button press
						if IsControlJustReleased(0, 51) then
							if not truckReady then
								truckReady = true
								playerTruck = closestTruck
								ESX.ShowNotification("" .. closestTruckModel .. ' is prepared for trailer!', "success", 3000)
							end
						end
					end
				end
			end
		end
	end
end)

----- TRAILER THREAD -----
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local closestTrailer = ESX.Game.GetClosestVehicle(playerCoords)
		local closestTrailerModel = GetDisplayNameFromVehicleModel(ESX.Game.GetVehicleProperties(closestTrailer).model)

		for k,v in pairs(Config.Trailers) do
			--Check to see if the ped is in a vehicle
			if not IsPedInAnyVehicle(PlayerPedId(), false) then
				if v == closestTrailerModel then
					while #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(closestTrailer)) <= 5.0 do
						Citizen.Wait(0)

						if truckReady and not trailerReady and not IsTrailerConnected then
							ESX.Game.Utils.DrawText3D(GetEntityCoords(closestTrailer), "Press ~y~[E]~s~ to prepare trailer")
						elseif truckReady and not trailerReady then
							ESX.Game.Utils.DrawText3D(GetEntityCoords(closestTrailer), "~r~Please prepare truck first!")
						end

						-- Check for button press
						if IsControlJustReleased(0, 51) then
							if truckReady and not trailerReady then
								trailerReady = true
								playerTrailer = closestTrailer
								ESX.ShowNotification("" .. closestTrailerModel .. ' is prepared!', "success", 3000)
								Wait(3000)
								ESX.ShowNotification("" .. closestTrailerModel .. ' is now connecting to truck!', "info", 3000)
								Wait(3000)
								Wait(Config.AttachWaitTime * 1000)
								AttachVehicleToTrailer(playerTruck, playerTrailer, 0)
								IsTrailerConnected = true
							end
						end
					end
				end
			end
		end
	end
end)

----- TRAILER DISCONNECT THREAD -----
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerCoords = GetEntityCoords(PlayerPedId())
		local closestTrailer = ESX.Game.GetClosestVehicle(playerCoords)
		local closestTrailerModel = GetDisplayNameFromVehicleModel(ESX.Game.GetVehicleProperties(closestTrailer).model)

		for k,v in pairs(Config.Trailers) do
			--Check to see if the ped is in a vehicle
			if not IsPedInAnyVehicle(PlayerPedId(), false) then
				if v == closestTrailerModel then
					while #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(closestTrailer)) <= 5.0 do
						Citizen.Wait(0)

						if truckReady and trailerReady and IsTrailerConnected then
							ESX.Game.Utils.DrawText3D(GetEntityCoords(closestTrailer), "Press ~y~[E]~s~ to disconnect trailer")
						end

						-- Check for button press
						if IsControlJustReleased(0, 51) then
							if truckReady and trailerReady and IsTrailerConnected then
								trailerReady = false
								playerTrailer = nil
								DetachVehicleFromTrailer(playerTruck)
								ESX.ShowNotification("" .. closestTrailerModel .. ' has been disconnected!', "success", 3000)
								IsTrailerConnected = false
							end
						end
					end
				end
			end
		end
	end
end)