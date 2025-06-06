RegisterCommand('group', function(source, args)
    local id    = tonumber(args[1])
    local type  = args[2]
    local group = args[3]
    if (not id or not type or not group) then
        return print('Usage: /group <id> <type> <group>')
    end

    local success, message = Cache:setGroup(id, type, group)

    if (success) then
        print(('Group %s added to %s with ID %d.'):format(group, type, id))
    else
        print(('Error: %s'):format(message))
    end
end)

