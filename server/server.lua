local QBCore = exports['qb-core']:GetCoreObject()

local verifyjobs = {
    'police',
    'mechanic',
    'cardealer',
}

local function IsJobVerify(JobName)
    local retval = false
    for _, name in pairs(verifyjobs) do
        if name == JobName then
            retval = true
            break
        end
    end
    return retval
end

QBCore.Functions.CreateCallback('qb-billing:server:checkFines', function(source, cb, target)
	local Player = QBCore.Functions.GetPlayer(target)
	if Player then
		local Cid = Player.PlayerData.citizenid
		exports.oxmysql:execute('SELECT amount, id, society, sender FROM phone_invoices WHERE citizenid = ?', {Cid}, function(invoices)
			cb(invoices, Cid)
		end)
	else
		cb({})
	end
end)

RegisterNetEvent('billing:server:payinvoice', function(data)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.money.bank >= data.amount then
	Player.Functions.RemoveMoney("bank", data.amount, "police-invoice-pay")
	exports.oxmysql:execute('DELETE FROM phone_invoices WHERE id = ?', {data.invoiceid})
	TriggerClientEvent('QBCore:Notify', source, 'Invoice have been paid for '..data.amount..'$', 'success')
	TriggerClientEvent('qb-billing:client:checkFines',source)
	else
		TriggerClientEvent('QBCore:Notify', source, 'You not have enough money', 'error')
		TriggerClientEvent('qb-billing:client:checkFines',source)
	end
end)

RegisterNetEvent('billing:server:addinvoice', function(playerid,amount)
	local src = source
	local Me = QBCore.Functions.GetPlayer(src)
    local Player = QBCore.Functions.GetPlayer(tonumber(playerid))
	if Player then
	--	local PlayerCID = Player.PlayerData.citizenid
		exports.oxmysql:insert('INSERT INTO phone_invoices (citizenid, amount, society, sender, sendercitizenid) VALUES (?, ?, ?, ?, ?)',
			{
			Player.PlayerData.citizenid,
			amount,
			Me.PlayerData.job.name,
			Me.PlayerData.charinfo.firstname, 
			Me.PlayerData.citizenid
		})
	TriggerClientEvent('QBCore:Notify', source, 'Invoice Send', 'success')
	TriggerClientEvent('QBCore:Notify', playerid, 'You received a $'..amount..' invoice', 'success')
	else
		TriggerClientEvent('QBCore:Notify', source, 'Did not find player', 'error')
	end
end)

QBCore.Commands.Add('invoices', 'Check Your Invoices', {}, false, function(source, _)
	local Player = QBCore.Functions.GetPlayer(source)
	if not IsJobVerify(Player.PlayerData.job.name) then
		TriggerClientEvent('qb-billing:client:checkFines',source)
	else
		TriggerClientEvent('qb-billing:client:checkFinesForPolice',source)
	end
end)