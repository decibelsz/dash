RegisterCommand('nc', function(source, args)
    local user = User(source)
    if (not user) then
        return print(('Dash: User not found for source %s.'):format(source))
    end

    local access = Cache:doesCharacterHaveGroup(user.id, 'Ceo')

    if (not access) then
        return print(('Dash: User %s does not have access to noclip.'):format(user.id))
    end

    TriggerClientEvent('dash:client:noclip', source)
end)