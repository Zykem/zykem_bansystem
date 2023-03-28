-- ESX Initialization
ESX = nil
PlayerData = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

        Citizen.Wait(250)
    end

    Citizen.Wait(2500)
    PlayerData = ESX.GetPlayerData()
end)
