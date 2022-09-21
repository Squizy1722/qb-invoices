local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

local function IsJobVerify(JobName)
    local retval = false
    for _, name in pairs(Config.verifyjobs) do
        if name == JobName then
            retval = true
            break
        end
    end
    return retval
end

RegisterNetEvent('qb-billing:client:checkFinesForPolice', function()
    local PlayerId = GetPlayerServerId(PlayerId())
    local InvoiceOptions = {
        {
            header = 'Invoice Menu',
            isMenuHeader = true,
            icon = 'fas fa-file-invoice-dollar',
        },
        {
            header = 'Give Invoice To Player',
            icon = 'fas fa-dollar-sign',
            txt    = '',
            params = { event = 'qb-billing:client:dialog',}  --You can trigger to go back in main menu
        },
        {
            header = 'Closest Person Unpaid Invoices',
            icon = 'fas fa-dollar-sign',
            txt    = '',
            params = { event = 'qb-billing:client:checkFinesCLP',}  --You can trigger to go back in main menu
        },
        {
            header = 'Your Unpaid Invoices',
            icon = 'fas fa-dollar-sign',
            txt    = '',
            params = { event = 'qb-billing:client:checkFines',}  --You can trigger to go back in main menu
        },
        {
            header = 'Close',
            icon   = 'fa-solid fa-circle-xmark',
            txt    = '',
            params = { event = 'qb-menu:closeMenu', }
        },
    }
    exports['qb-menu']:openMenu(InvoiceOptions)
end)

RegisterNetEvent('qb-billing:client:checkFines', function()
  --  local player, distance = QBCore.Functions.GetClosestPlayer()
  --  if player ~= -1 and distance < 2.5 then
  --local player = me
        local PlayerId = GetPlayerServerId(PlayerId())
        QBCore.Functions.TriggerCallback('qb-billing:server:checkFines', function(invoices, Cid)
            local InvoiceShow = {
                {
                    header = 'Unpaid Invoices | ID: ' .. PlayerId,
                    isMenuHeader = true,
                    icon = 'fas fa-file-invoice-dollar',
                },
                {
                    header = 'Citizen ID: ' .. Cid,
                    isMenuHeader = true,
                    icon = 'fas fa-id-card-clip',
                },
            }

    --[[        if PlayerJob.name == 'police' then
                InvoiceShow[#InvoiceShow + 1] = {
                header = 'Give Fine',
                icon = 'fas fa-dollar-sign',
                txt = 'give player fine',
                params = { event = 'qb-billing:client:payfinvoice',}  --You can trigger to go back in main menu
                }
            end ]]

            for _, v in ipairs(invoices) do
             --   local invoiceid = v.id
                InvoiceShow[#InvoiceShow + 1] = {
                    header = 'Amount: ' .. v.amount .. '$',
                    icon = 'fas fa-dollar-sign',
                    txt = 'Sender: ' .. v.sender .. ' | Society: ' .. v.society,
                    params = { event = 'qb-billing:client:payinvoice', args = {sender = v.sender, amount = v.amount, invoiceid = v.id,} } --You can trigger to go back in main menu
                }
            end

            if not IsJobVerify(PlayerJob.name) then
            InvoiceShow[#InvoiceShow + 1] = {
                header = 'Close',
                icon   = 'fa-solid fa-circle-xmark',
                txt    = '',
                params = { event = 'qb-menu:closeMenu', }
            }
        else
            InvoiceShow[#InvoiceShow + 1] = {
                header = 'Back',
                icon   = 'fa-solid fa-circle-xmark',
                txt    = '',
                params = { event = 'qb-billing:client:checkFinesForPolice', }
            }
        end

            exports['qb-menu']:openMenu(InvoiceShow)
        end, PlayerId)
 --   else
   --     QBCore.Functions.Notify('No one around!', 'error')
  --  end
end)

RegisterNetEvent('qb-billing:client:payinvoice', function(data)
TriggerServerEvent('billing:server:payinvoice', data)
end)

-- Give Invoice --

RegisterNetEvent('qb-billing:client:dialog', function()
    local dialog = exports['qb-input']:ShowInput({
        header = "Create Invoice",
        submitText = "Bill",
        inputs = {
            {
                text = "PlayerID", -- text you want to be displayed as a place holder
                name = "playerid", -- name of the input should be unique otherwise it might override
                type = "number", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                isRequired = false, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                -- default = 1, -- Default number option, this is optional
            },
            {
                text = "Bill Price ($)", -- text you want to be displayed as a place holder
                name = "billprice", -- name of the input should be unique otherwise it might override
                type = "number", -- type of the input - number will not allow non-number characters in the field so only accepts 0-9
                isRequired = false, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                -- default = 1, -- Default number option, this is optional
            },
        }
})

if dialog == "" then return QBCore.Functions.Notify("you didn't write anything", 'error') end
if dialog.playerid == "" then return QBCore.Functions.Notify("you didn't write the player id", 'error') end
if dialog.billprice == "" then return QBCore.Functions.Notify("you didn't write the bill price", 'error') end
--if dialog.playerid == "" or dialog.billprice == "" then return QBCore.Functions.Notify('Something went Wrong', 'error') end

--print(dialog.playerid)
--print(dialog.billprice)

TriggerServerEvent('billing:server:addinvoice', dialog.playerid, dialog.billprice)

end, false)

--[[RegisterCommand("checkvj",function()
    if not IsJobVerify(PlayerJob.name) then
    print('false')
    else
        print('true')
    end
end)]]

RegisterNetEvent('qb-billing:client:checkFinesCLP', function()
    local player, distance = QBCore.Functions.GetClosestPlayer()
    if player ~= -1 and distance < 2.5 then
        local PlayerId = GetPlayerServerId(player)
        QBCore.Functions.TriggerCallback('qb-billing:server:checkFines', function(invoices, Cid)
            local InvoiceShow = {
                {
                    header = 'Unpaid Invoices | ID: ' .. PlayerId,
                    isMenuHeader = true,
                    icon = 'fas fa-file-invoice-dollar',
                },
                {
                    header = 'Citizen ID: ' .. Cid,
                    isMenuHeader = true,
                    icon = 'fas fa-id-card-clip',
                },
            }
            for _, v in ipairs(invoices) do
                InvoiceShow[#InvoiceShow + 1] = {
                    header = 'Amount: ' .. v.amount .. '$',
                    icon = 'fas fa-dollar-sign',
                    txt = 'Sender: ' .. v.sender .. ' | Society: ' .. v.society,
                    params = { event = 'qb-billing:open:invoiceMainmenu', } --You can trigger to go back in main menu
                }
            end
            if not IsJobVerify(PlayerJob.name) then
                InvoiceShow[#InvoiceShow + 1] = {
                    header = 'Close',
                    icon   = 'fa-solid fa-circle-xmark',
                    txt    = '',
                    params = { event = 'qb-menu:closeMenu', }
                }
            else
                InvoiceShow[#InvoiceShow + 1] = {
                    header = 'Back',
                    icon   = 'fa-solid fa-circle-xmark',
                    txt    = '',
                    params = { event = 'qb-billing:client:checkFinesForPolice', }
                }
            end
            exports['qb-menu']:openMenu(InvoiceShow)
        end, PlayerId)
    else
        QBCore.Functions.Notify('No one around!', 'error')
    end
end)