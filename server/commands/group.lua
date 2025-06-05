RegisterCommand('group', function(source, args)
    local user = User(source)

    if (not user) then
        return print(('Dash: User not found for source %s.'):format(source))
    end

    local type, id, groupName = args[1], tonumber(args[2]), args[3]

    if (not type or not id or not groupName) then
        return print('Usage: /group <char|user> <id> <groupName>')
    end

    if (type ~= 'char' and type ~= 'user') then
        return print('Invalid type. Use "char" or "user".')
    end

    local res, err = Cache:setGroup(type, id, groupName)

    if (not res) then
        return print(('Dash: Failed to set group type for %s with ID %d: %s'):format(type, id, err))
    end

    print(('Dash: Successfully set group "%s" for %s with ID %d.'):format(groupName, type, id))
end)