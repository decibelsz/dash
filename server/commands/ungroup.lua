RegisterCommand('ungroup', function(source, args)
    local user = User(source)
    if (not user) then
        return print(('Dash: User not found for source %s.'):format(source))
    end

    local type, id, groupName = args[1], tonumber(args[2]), args[3]

    if (not type or not id or not groupName) then
        return print('Usage: /ungroup <char|user> <id> <groupName>')
    end

    if (type ~= 'char' and type ~= 'user') then
        return print('Invalid type. Use "char" or "user".')
    end

    if (not Cache:doesGroupExist(groupName)) then
        return print(('Dash: Group "%s" does not exist.'):format(groupName))
    end

    if (type == 'char') then
        local character = user:getCharacter(id)
        if (not character) then
            return print(('Dash: Character with ID %s not found for user %s.'):format(id, user.id))
        end
        if (not Cache:doesCharacterExist(id)) then
            return print(('Dash: Character with ID %s does not exist in cache.'):format(id))
        end
        local res, err = Cache:removeCharacterGroup(id, groupName)
        print(res, err)
        return
    end

    if (type == 'user') then
        if (not Cache:doesUserExist(id)) then
            return print(('Dash: User with ID %s does not exist in cache.'):format(id))
        end
        local res, err = Cache:removeUserGroup(id, groupName)
        print(res, err)
    end

end)