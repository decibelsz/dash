Cache = class()

function Cache:__init()
    self.users      = {}
    self.sources    = {}
    self.characters = {}
    self.groups = {
        users   = {},
        characters = {}
    }
end


function Cache:load(user)
    if (not user or not user.id) then
        return false, "Invalid user data."
    end
    if (self.users[user.id]) then
        return false, "User already loaded."
    end
    if (self.sources[user.source]) then
        return false, "User source already loaded."
    end
    if (not user.identifiers or not user.license) then
        return false, "User identifiers or license not found."
    end

    self.users[user.id] = {
        id            = user.id,
        source        = user.source,
        identifiers   = user.identifiers,
        license       = user.license,
        createdAt     = user.createdAt,
        banned        = user.banned,
        allowed       = user.allowed,
        maxCharacters = user.maxCharacters,
        groups        = {}
    }

    self.sources[user.source] = user.id

    for groupId in pairs(user.groups) do
        local groupData = config.groups[tonumber(groupId)]

        if (groupData) then
            local groupName = groupData.name
            self.groups.users[groupName] = self.groups.users[groupName] or {}
            self.groups.users[groupName][user.id] = true
            self.users[user.id].groups[groupName] = true
        end
    end

    for charId, charData in pairs(user.characters) do
        self.characters[charId] = {
            id          = charId,
            ownerId     = user.id,
            name        = charData.name,
            age         = charData.age,
            model       = charData.model,
            groups      = {},
            createdAt   = charData.createdAt,
        }

        for groupId in pairs(charData.groups) do
            local groupData = config.groups[tonumber(groupId)]

            if (groupData) then
                local groupName = groupData.name

                self.groups.characters[groupName]         = self.groups.characters[groupName] or {}
                self.characters[charId].groups[groupName] = true

                self.groups.characters[groupName][charId] = true
            end
        end
    end

    print(('Dash: User %s with ID %d loaded successfully.'):format(user.license, user.id))

    return true, "User loaded successfully."
end

function Cache:setGroup(type, id, groupName)
    if (not type or not id or not groupName) then
        return false, "Invalid parameters."
    end

    if (type ~= 'char' and type ~= 'user') then
        return false, "Invalid type. Use 'char' or 'user'."
    end

    local groupId = config.nameToGroupId[groupName]

    if (not groupId) then
        return false, ("Group '%s' does not exist."):format(groupName)
    end

    if (not config.groups[groupId]) then
        return false, ("Group with ID %d does not exist."):format(groupId)
    end

    if (type == 'user') then
        if (not self.users[id]) then
            return false, ("User with ID %d does not exist."):format(id)
        end

        if (not self.users[id].groups) then
            return false, ("User with ID %d has no groups defined."):format(id)
        end

        if (self.users[id].groups[groupName]) then
            return false, ("User with ID %d already has group '%s'."):format(id, groupName)
        end

        self.users[id].groups[groupName] = true
        self.groups.users[groupName]     = self.groups.users[groupName] or {}
        self.groups.users[groupName][id] = true
    end

    if (type == 'char') then
        if (not self.characters[id]) then
            return false, ("Character with ID %d does not exist."):format(id)
        end

        if (not self.characters[id].groups) then
            return false, ("Character with ID %d has no groups defined."):format(id)
        end

        if (self.characters[id].groups[groupName]) then
            return false, ("Character with ID %d already has group '%s'."):format(id, groupName)
        end

        self.characters[id].groups[groupName] = true
        self.groups.characters[groupName]     = self.groups.characters[groupName] or {}
        self.groups.characters[groupName][id] = true
    end

    -- Update the database
    local groups  = (type == 'user') and  self.users[id].groups or self.characters[id].groups

    Cache:updateGroupsDB(type, id, groups)

    -- get the source to send the update to the client
    local ownerId = (type == 'char')    and self.characters[id].ownerId or id
    local source  = self.users[ownerId] and self.users[ownerId].source  or nil
    TriggerClientEvent('dash:updateUserGroups', source, groups)

    return true, ("Successfully set group '%s' for %s with ID %d."):format(groupName, type, id)
end

function Cache:updateGroupsDB(type, id, groups)
    local sqlPayload = {}

    for groupName in pairs(groups) do
        local groupId = config.nameToGroupId[groupName]
        if groupId then
            sqlPayload[tostring(groupId)] = groupId
        end
    end

    local query = (type == 'user') and QUERIES.SET_USER_GROUP or QUERIES.SET_CHAR_GROUP
    local res   = mysql:executeSync(query, { json.encode(sqlPayload), id })
    
    if (not res) then
        return false, ("Failed to update group '%s' for %s with ID %d in the database."):format(groupName, type, id)
    end

end

Cache = Cache()



RegisterCommand('unload', function(source)
    local user = User(source)

    Cache:unload(user)
end)