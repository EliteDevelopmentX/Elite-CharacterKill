local function detectFramework()
    if GetResourceState("es_extended") == "started" then
        return "esx", exports["es_extended"]:getSharedObject()
    elseif GetResourceState("qb-core") == "started" then
        return "qbcore", exports["qb-core"]:GetCoreObject()
    end
    return nil, nil
end

local Framework, Core = Config.Framework == "auto" and detectFramework() or Config.Framework, nil
if Framework == "esx" then
    Core = exports["es_extended"]:getSharedObject()
elseif Framework == "qbcore" then
    Core = exports["qb-core"]:GetCoreObject()
else
    print("[ERROR] No supported framework detected!")
    return
end

RegisterCommand('ck', function(source, args)
    local staff = Framework == "esx" and Core.GetPlayerFromId(source) or Core.Functions.GetPlayer(source)
    if not staff then return end

    local hasPermission = false
    for _, group in ipairs(Config.AllowedGroups) do
        if (Framework == "esx" and staff.getGroup() == group) or (Framework == "qbcore" and staff.PlayerData.job.name == group) then
            hasPermission = true
            break
        end
    end

    if not hasPermission then
        lib.notify({title = 'Elite Store', description = 'You can\'t use this command!', type = 'error'})
        return
    end

    local targetId = tonumber(args[1])
    if not targetId then
        lib.notify({title = 'Elite Store', description = 'Invalid ID! Usage: /ck [playerID]', type = 'error'})
        return
    end

    local targetPlayer = Framework == "esx" and Core.GetPlayerFromId(targetId) or Core.Functions.GetPlayer(targetId)
    if not targetPlayer then
        lib.notify({title = 'Elite Store', description = 'Player not found!', type = 'error'})
        return
    end

    local targetIdentifier = Framework == "esx" and targetPlayer.identifier or targetPlayer.PlayerData.citizenid

    local queries = {
        'DELETE FROM users WHERE identifier = @identifier',
        'DELETE FROM owned_vehicles WHERE owner = @identifier',
        'DELETE FROM phone_phones WHERE owner_id = @identifier'
    }

    for _, query in ipairs(queries) do
        MySQL.Async.execute(query, {['@identifier'] = targetIdentifier})
    end

    DropPlayer(targetId, 'Your character has been permanently removed [CK]')
end, false)
