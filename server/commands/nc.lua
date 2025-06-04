RegisterCommand('nc', function(source, args)
    print('oi')
    TriggerClientEvent('dash:client:noclip', source)
end)