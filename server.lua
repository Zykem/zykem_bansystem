-- ESX Initialization
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


-- BanSystem class
groups = {}
banlist = {}
-- timeunits table to convert user argument 
timeUnits = {
    {unit = "s", calculator = 1},
    {unit = "h", calculator = 3600},
    {unit = "d", calculator = 86400},
    {unit = "w", calculator = 604800},
    {unit = "m", calculator = 2592000},
    {unit = "y", calculator = 31536000},
}

local chars, str = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
bansystem = {
    sendBanroom = function(banner, targetT, expiration, reason, banid)
        -- embed in polish - need to update for locales
        local embed = {
            {
            ["title"] = "BanSystem",
            ["description"] = "Gracz " .. targetT.name .. ' (<@' .. targetT.discord ..'>) został zbanowany!',
            ["color"] = 53380,
            ["fields"] = {
                [1] = {
                    ['name'] = "Powód Bana",
                    ['value'] = reason,
                    ["inline"] = true,
                },
                [2] = {
                    ['name'] = 'Ban wygasa',
                    ['value'] = expiration,
                    ["inline"] = true,
                },
                [3] = {
                    ['name'] = 'Banujący',
                    ['value'] = banner.name
                },
                [4] = {
                    ['name'] = 'ID Bana',
                    ['value'] = banid,
                    ['inline'] = true
                }
             },
            ["footer"] = {
                ["text"] = "Bansystem | " .. os.date("%Y-%m-%d %H:%M:%S"),
            },
            }
        }
        PerformHttpRequest(svcfg.logs.webhook, function(err,res,headers)
            print('Sent banroom message')
        end, 'POST', json.encode({username = "BANROOM", embeds = embed}), {['Content-Type'] = 'application/json'})

    end,
    
    genBanId = function()

        math.randomseed(os.time())
        str = ""

        for i = 1, 7 do

            randindex = math.random(1,#chars)
            randchar = chars:sub(randindex, randindex)
            str = str .. randchar

        end
        return str
    end,
    initGroups = function()

        for k,v in pairs(svcfg.permissions) do
            groups[#groups + 1] = k
        end

    end,
    hasPerms = function(playerGroup, perm)

        if not table.concat(groups, ','):match(playerGroup) then return false end;
        for k,v in pairs(svcfg.permissions[playerGroup]) do

            if (k == perm) then
                return v
            end

        end

    end,
    kickPlayer = function(kicker, target, reason)

        if not (hasPerms(kicker.group, "kick")) then return end;
        DropPlayer(target, svcfg.prefix .. reason)

    end,
    unbanPlayer = function(admin, target)


        if not (bansystem.hasPerms(admin.group, "unban")) then return end;

        MySQL.query('DELETE FROM zykem_bans WHERE banid = ?', {target}, function(result)
            if(result.affectedRows < 1) then print('Something went wrong unbanning an User! [BanID: ' .. target .. ']') return end;
            
            for k,v in pairs(banlist) do
                if(v.banid == target) then
                    banlist[k] = nil
                    if (admin.type == "console") then print('Unbanned User!') return end;
                    admin.esxplayer.showNotification('Unbanned User!')
                    return
                end
            end
            player.showNotification('This user isnt banned!')
        end)

    end,
    banPlayer = function(banner, target, duration, reason)
        local targetsrc = target
        if not (bansystem.hasPerms(banner.group, "ban")) then return end;
        -- ban logic
        local durationString = string.match(duration, "%d+[shdwmy]")
        local timeUnit = string.match(durationString, "(%a)$")
        local duration = tonumber(string.match(durationString, "%d+"))
        print('1')
        local unit, calculator, found, banreason
        for k,v in pairs(timeUnits) do
            if (timeUnit == v.unit) then
                unit = v.unit
                calculator = v.calculator
                found = true
                break
            end
        end
        if not found then return end;

        duration = duration * calculator
        banExpiration = os.time() + duration
        formattedDate = os.date("%Y-%m-%d %H:%M:%S", banExpiration)
        preformattedIdentifiers = bansystem.getIdentifiers(target)
        banid = bansystem.genBanId()

        MySQL.query('INSERT INTO zykem_bans (identifiers,admin, reason, expiration,banid) VALUES (?,?,?,?,?)', {json.encode(preformattedIdentifiers), banner.name, reason, formattedDate, banid}, function(result)
                
            if (result.affectedRows == 0) then print('Something went wrong banning a player, returning.') return end;
            banreason = string.format(locales[svcfg.locale].banmsg, reason)
            DropPlayer(target, svcfg.prefix .. banreason)
            banlistformat = {
                reason = banreason,
                expiration = banExpiration,
                admin = banner.name,
                banmsg = string.format(locales[svcfg.locale].banprompt, reason, formattedDate, banid),
                identifiers = preformattedIdentifiers,
                banid = banid
            }

            banlist[#banlist + 1] = banlistformat
            targetTable = {
                name = preformattedIdentifiers.name,
                discord = preformattedIdentifiers.discord
            }
            if (svcfg.logs.enabled) then
                bansystem.sendBanroom(banner,targetTable, formattedDate, reason, banid)
            end
        end)

    end,
    getIdentifiers = function(src)
        local identifiers= {hwid = {}, name = GetPlayerName(src), license = "brak", steam = "brak", liveid = "brak", xblid = "brak", discord = "brak", ip = "brak"}
        for k,v in ipairs(GetPlayerIdentifiers(src)) do
            
            if string.sub(v, 1, string.len("license:")) == "license:" then
                identifiers.license = v
            elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
                identifiers.steam = v
            elseif string.sub(v, 1, string.len("live:")) == "live:" then
                identifiers.liveid = v
            elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
                identifiers.xblid  = v
            elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                identifiers.discord = v
            elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
                identifiers.ip = v
            end
    
        end
        if GetNumPlayerTokens(src) == 0 or GetNumPlayerTokens(src) == nil or GetNumPlayerTokens(src) < 0 or GetNumPlayerTokens(src) == "null" or GetNumPlayerTokens(src) == "**Invalid**" or not GetNumPlayerTokens(src) then hwid = "Invalid" end;
        for i = 0, GetNumPlayerTokens(src) do
    
            identifiers.hwid[#identifiers.hwid + 1] = GetPlayerToken(src, i)
    
        end
        print(identifiers.license, 'license getter')
        while (identifiers.license == "brak") do Wait(100) end;
        return identifiers;
    end

}
exports('getIdentifiers', bansystem.getIdentifiers)
exports('banPlayer', bansystem.banPlayer)
exports('unbanPlayer', bansystem.unbanPlayer)
exports('kickPlayer', bansystem.kickPlayer)

MySQL.ready(function()

    bansystem.initGroups()
    MySQL.query('SELECT * FROM zykem_bans', function(result)
        for i = 1, #result do
            
            banlistformat = {
                banid = result[i].banid,
                reason = result[i].reason,
                expiration = result[i].expiration,
                admin = result[i].admin,
                identifiers = json.decode(result[i].identifiers),
                banmsg = string.format(locales[svcfg.locale].banprompt, result[i].reason, os.date("%Y-%m-%d %H:%M:%S", result[i].expiration / 1000), result[i].banid),
            }
            banlist[#banlist + 1] = banlistformat
             
        end
        print(json.encode(banlist))
    end)

    
end)

function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces>0 then
      local mult = 10^numDecimalPlaces
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

RegisterCommand('identifiers', function(source,args)

    local player = ESX.GetPlayerFromId(source)
    player.showNotification(json.encode(bansystem.getIdentifiers(source)))

end)

RegisterCommand('zban', function(source,args)
    
    local target = tonumber(args[1])
    local admin
    if target == nil then print('target is null! usage: /zban target time reason') return end;
    if (source == nil or source == 0) then
        adminTable = {
            group = "best",
            name = "console"
        }
    else
        admin = ESX.GetPlayerFromId(source)
        adminTable = {
            group = admin.getGroup(),
            name = GetPlayerName(source)
        }
    end


    bansystem.banPlayer(adminTable, target, args[2], table.concat(args, " ", 3))
end)

function checkHwid(hwidtable, playerhwid) 

    local temporarytable = {}
    for _, hwid in ipairs(hwidtable) do
        temporarytable[hwid] = true
    end

    for _, hwid in ipairs(playerhwid) do
        if temporarytable[hwid] then
            return true;
        end
    end

    return false;
    
end

function isBanned(player)

    local playerids = bansystem.getIdentifiers(player)

    for k,v in pairs(banlist) do
        if  (v.identifiers.steam ~= nil and v.identifiers.steam == playerids.steam) or
            (v.identifiers.license ~= nil and v.identifiers.license == playerids.license) or
            (v.identifiers.xblid ~= nil and v.identifiers.xblid == playerids.xblid) or
            (v.identifiers.liveid ~= nil and v.identifiers.liveid == playerids.liveid) or
            (#v.identifiers.hwid ~= 0 and checkHwid(v.identifiers.hwid, playerids.hwid)) or
            (v.identifiers.discord ~= nil and v.identifiers.discord == playerids.discord) or
            (v.identifiers.ip == playerids.ip) or
            (v.identifiers.playerip ~= nil and v.identifiers.playerip == playerids.playerip) then
                
                return {banned = true, banmsg = v.banmsg, banid = v.banid};

        else
                return {banned = false};
        end
    end
    
end

RegisterCommand('zunban', function(source,args)

    if (args[1] == nil) then return end;
    local target, admin = args[1], nil

    if(source == nil or source == 0) then admin = {group = "best", name = "console", type = "console"} else player = ESX.GetPlayerFromId(source) admin = {group = player.getGroup(), name = GetPlayerName(source)} end;

    bansystem.unbanPlayer(admin, target)

end)

AddEventHandler('playerConnecting', function(plyname, prompt)

    local isbanned = isBanned(source)
    if (isbanned ~= nil and isbanned.banned) then
        prompt(isbanned.banmsg)
        CancelEvent()
    end

end)

Citizen.CreateThread(function()
    while (#banlist == 0) do print(#banlist) Citizen.Wait(5000) end;
    
    local expirationTable, year, month, day, hour, min, sec

    while true do
        Wait(3000)
        for k,v in pairs(banlist) do
            if (tonumber(v.expiration) < os.time()) then
                bansystem.unbanPlayer({type = "console", group = "best", name = "console"}, v.banid)
            end
        end
        Citizen.Wait(1000 * 60 * 5)
    end

end)