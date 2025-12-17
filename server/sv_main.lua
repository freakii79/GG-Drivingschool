	--[[
	local QBCore = exports['qb-core']:GetCoreObject() 

	lib.callback.register('gg-drivingschool:payment', function(source)
		local src = source
		local xPlayer = QBCore.Functions.GetPlayer(src)
		local bankamount = xPlayer.PlayerData.money["bank"]
		local amount = Config.TestCost

		if bankamount >= amount then
			xPlayer.Functions.RemoveMoney('bank', Config.TestCost)
			TriggerClientEvent('gg-drivingschool:paymentSuccess', src)
		else
			TriggerClientEvent('QBCore:Notify', src, "Not enough money", "error")
		end
	end)


	lib.callback.register('gg-drivingschool:server:GetLicense', function()
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)


		local info = {}
			info.firstname = Player.PlayerData.charinfo.firstname
			info.lastname = Player.PlayerData.charinfo.lastname
			info.birthdate = Player.PlayerData.charinfo.birthdate
			info.type = "A1-A2-A | AM-B | C1-C-CE"

		if Config.Inventory == 'qb' then
			Player.Functions.AddItem('driver_license', 1, nil, info)
			TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['driver_license'], 'add')
		elseif Config.Inventory == 'ox' then
			exports.ox_inventory:AddItem(src, 'driver_license', 1)
		end

	end)
	]]--


			local QBCore = exports['qb-core']:GetCoreObject() 

	-- Payment & Cooldown Check 
	lib.callback.register('gg-drivingschool:payment', function(source)
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		local licenses = Player.PlayerData.metadata["licences"] or {}
		
		-- 1. DETECT EXISTING DRIVERS (Physical Item or Database Metadata)
		local hasItem = Player.Functions.GetItemByName("driver_license") ~= nil
		local isDriver = licenses["driver"] == true

		if hasItem or isDriver then
			-- Sync metadata if they have the item but database is empty
			if hasItem and not isDriver then
				licenses["theory"] = true
				licenses["driver"] = true
				Player.Functions.SetMetaData("licences", licenses)
			end
			
			-- Stop them from buying a new test if they are already licensed
			if hasItem then
				TriggerClientEvent('QBCore:Notify', src, "You already have your license!", "error")
			else
				TriggerClientEvent('QBCore:Notify', src, "You already passed! Use 'Reprint' to get a new card.", "primary")
			end
			return false 
		end

		-- 2. COOLDOWN CHECK
		local cooldown = Player.PlayerData.metadata["licence_cooldown"] or 0
		local currentTime = os.time()
		if currentTime < cooldown then
			local remaining = math.ceil((cooldown - currentTime) / 60)
			TriggerClientEvent('QBCore:Notify', src, "You must wait " .. remaining .. " more minutes before retrying.", "error")
			return false
		end

		-- 3. PAYMENT & THEORY SKIP
		local amount = Config.TestCost
		if Player.PlayerData.money["bank"] >= amount then
			Player.Functions.RemoveMoney('bank', amount)
			
			if licenses["theory"] then
				TriggerClientEvent('QBCore:Notify', src, "Skipping theory: Previous pass found!", "success")
				TriggerClientEvent('gg-drivingschool:paymentSuccess', src, true) -- true = skip theory
			else
				TriggerClientEvent('gg-drivingschool:paymentSuccess', src, false) -- false = take theory
			end
			return true
		else
			TriggerClientEvent('QBCore:Notify', src, "Not enough money", "error")
			return false
		end
	end)

	-- Set Cooldown on Failure
	RegisterNetEvent('gg-drivingschool:server:setCooldown', function()
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		local cooldownTime = os.time() + (20 * 60)
		Player.Functions.SetMetaData("licence_cooldown", cooldownTime)
	end)

	-- Save Theory Progress
	RegisterNetEvent('gg-drivingschool:server:passTheory', function()
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		local licenses = Player.PlayerData.metadata["licences"] or {}
		licenses["theory"] = true
		Player.Functions.SetMetaData("licences", licenses)
	end)

	-- Grant License and Save "Driver" status
	lib.callback.register('gg-drivingschool:server:GetLicense', function(source)
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		
		local licenses = Player.PlayerData.metadata["licences"] or {}
		licenses["driver"] = true
		Player.Functions.SetMetaData("licences", licenses)

		local info = {
			firstname = Player.PlayerData.charinfo.firstname,
			lastname = Player.PlayerData.charinfo.lastname,
			birthdate = Player.PlayerData.charinfo.birthdate,
			type = "A1-A2-A | AM-B | C1-C-CE"
		}

		if Config.Inventory == 'qb' then
			Player.Functions.AddItem('driver_license', 1, nil, info)
			TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['driver_license'], 'add')
		elseif Config.Inventory == 'ox' then
			exports.ox_inventory:AddItem(src, 'driver_license', 1, info)
		end
	end)

	-- Reprint Logic (75% Cost) with Inventory Check
	lib.callback.register('gg-drivingschool:server:ReprintLicense', function(source)
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		local reprintCost = math.floor(Config.TestCost * 0.75)

		if Player.PlayerData.metadata["licences"] and Player.PlayerData.metadata["licences"]["driver"] then
			-- Server side check to prevent double-buy even if UI fails
			local hasItem = Player.Functions.GetItemByName("driver_license") ~= nil
			if hasItem then
				TriggerClientEvent('QBCore:Notify', src, "You already have your license card.", "error")
				return false
			end

			if Player.PlayerData.money["bank"] >= reprintCost then
				Player.Functions.RemoveMoney('bank', reprintCost)
				
				local info = {
					firstname = Player.PlayerData.charinfo.firstname,
					lastname = Player.PlayerData.charinfo.lastname,
					birthdate = Player.PlayerData.charinfo.birthdate,
					type = "A1-A2-A | AM-B | C1-C-CE"
				}

				if Config.Inventory == 'qb' then
					Player.Functions.AddItem('driver_license', 1, nil, info)
					TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['driver_license'], 'add')
				elseif Config.Inventory == 'ox' then
					exports.ox_inventory:AddItem(src, 'driver_license', 1, info)
				end
				TriggerClientEvent('QBCore:Notify', src, "License reprinted for $"..reprintCost, "success")
			else
				TriggerClientEvent('QBCore:Notify', src, "You need $"..reprintCost.." for a reprint.", "error")
			end
		else
			TriggerClientEvent('QBCore:Notify', src, "No license record found.", "error")
		end
	end)

	-- Status Command: /checklicense
	QBCore.Commands.Add("checklicense", "Check your driving school status", {}, false, function(source)
		local src = source
		local Player = QBCore.Functions.GetPlayer(src)
		local licenses = Player.PlayerData.metadata["licences"] or {}
		local cooldown = Player.PlayerData.metadata["licence_cooldown"] or 0
		local currentTime = os.time()

		local theoryStatus = licenses["theory"] and "✅ Passed" or "❌ Not Passed"
		local driverStatus = licenses["driver"] and "✅ Passed" or "❌ Not Passed"
		
		TriggerClientEvent('QBCore:Notify', src, "Theory: " .. theoryStatus, "primary")
		TriggerClientEvent('QBCore:Notify', src, "Practical: " .. driverStatus, "primary")

		if currentTime < cooldown then
			local remaining = math.ceil((cooldown - currentTime) / 60)
			TriggerClientEvent('QBCore:Notify', src, "Cooldown: " .. remaining .. " minutes left", "error")
		end
	end)

	-- Admin Grant Command: /grantlicense [ID]
	QBCore.Commands.Add("grantlicense", "Give a player license metadata (Admin Only)", {{name="id", help="Player ID"}}, true, function(source, args)
		local src = source
		local targetId = tonumber(args[1])
		local TargetPlayer = QBCore.Functions.GetPlayer(targetId)

		if TargetPlayer then
			local licenses = TargetPlayer.PlayerData.metadata["licences"] or {}
			licenses["theory"] = true
			licenses["driver"] = true
			TargetPlayer.Functions.SetMetaData("licences", licenses)
			
			TriggerClientEvent('QBCore:Notify', targetId, "Admin granted you license status.", "success")
			TriggerClientEvent('QBCore:Notify', src, "Granted license to ID: "..targetId, "success")
		else
			TriggerClientEvent('QBCore:Notify', src, "Player not found", "error")
		end
	end, "admin")