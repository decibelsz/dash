RegisterCommand('createchar', function(source, args)
    local user = User(source)
    if (not user) then
        return print(('Dash: User not found for source %s.'):format(source))
    end

    local first, last = args[1], args[2]

    if (not first or not last) then
        return print('Usage: /createchar <firstName> <lastName>')
    end

    user:createCharacter({
        name = {
            first = first,
            last = last
        },
        age = 10,
        model = 'mp_f_freemode_01'
    })

    print(json.encode(user:getCharacters()))
end)