Cache = class()

function Cache:__init()
    self.users = {}
    self.sources = {}
    self.characters = {}
    self.groups = {
        users = {},
        characters = {}
    }
end

function Cache:load(user)
    if (not user or not user.id) then
        return false, 'Invalid user data.'
    end
    if (self.users[user.id]) then
        return false, 'User already loaded.'
    end
    if (self.sources[user.source]) then
        return false, 'User source already loaded.'
    end
    if (not user.identifiers or not user.license) then
        return false, 'User identifiers or license not found.'
    end

    self.users[user.id] = user
    self.sources[user.source] = user.id

    for charId, charData in pairs(user.characters) do
        self.characters[charId] = user.id
    end

    return true, 'User loaded successfully.'
end

function Cache:createCharacter(user, name, age, model)
    if (not user.id or not name or not age or not model) then
        return false, 'User ID, name, age, or model not provided.'
    end

    if (not self.users[user.id]) then
        return false, 'User not found in cache.'
    end

    if (type(name) ~= 'table' or not name.first or not name.last) then
        return false, 'Invalid name format. Expected { first = "First", last = "Last" }.'
    end

    local res = mysql:executeSync(QUERIES.CREATE_CHARACTER, {user.id, json.encode(name), age, model})

    if (not res or not res[1]) then
        return false, 'Failed to create character.'
    end

    self.characters[res[1].charId] = user.id


    return true, 'Character created successfully.'
end

function Cache:addUserGroup(userId, group)
    if (not userId or not group) then
        return false, 'User ID or group not provided.'
    end

    if (not self.groups.users[userId]) then
        self.groups.users[userId] = {}
    end

    if (self.groups.users[userId][group]) then
        return false, 'Group already exists for this user.'
    end

    self.users[userId].groups[group] = true
    self.groups.users[group] = self.groups.users[groupId] or {}
    self.groups.users[group][userId] = self.users[userId].source

    return true, 'Group added successfully.'
end

function Cache:removeUserGroup(userId, group)
    if (not userId or not group) then
        return false, 'User ID or group not provided.'
    end

    if (not self.groups.users[userId] or not self.groups.users[userId][group]) then
        return false, 'Group not found for this user.'
    end

    self.users[userId].groups[group] = nil
    self.groups.users[group][userId] = nil

    if (not next(self.groups.users[group])) then
        self.groups.users[group] = nil
    end

    return true, 'Group removed successfully.'
end

function Cache:addCharacterGroup(charId, group)
    local characterOwnerId = self.characters[charId]

    if (not characterOwnerId or not group) then
        return false, 'Character ID or group not provided.'
    end

    if (not self.users[characterOwnerId].characters[charId]) then
        return false, 'Character not found for this user.'
    end

    self.users[characterOwnerId].characters[charId].groups[group] = true
    self.groups.characters[group] = self.groups.characters[group] or {}
    self.groups.characters[group][charId] = self.users[characterOwnerId].source

    local groupsJson = json.encode(self.users[characterOwnerId].characters[charId].groups)
    mysql:executeSync(QUERIES.UPDATE_CHAR_GROUP, {groupsJson, charId})

    return true, 'Group added successfully.'
end

function Cache:removeCharacterGroup(charId, group)
    local characterOwnerId = self.characters[charId]

    if (not characterOwnerId or not group) then
        return false, 'Character ID or group not provided.'
    end

    if (not self.users[characterOwnerId].characters[charId]) then
        return false, 'Character not found for this user.'
    end

    if (not self.users[characterOwnerId].characters[charId].groups[group]) then
        return false, 'Group not found for this character.'
    end

    self.users[characterOwnerId].characters[charId].groups[group] = nil
    self.groups.characters[group][charId] = nil

    if (not next(self.groups.characters[group])) then
        self.groups.characters[group] = nil
    end

    return true, 'Group removed successfully.'
end

function Cache:getAllCharactersInGroup(group)
    if (not group) then
        return false, 'Group not provided.'
    end

    return self.groups.characters[group]
end

function Cache:getAllUsersInGroup(group)
    if (not group) then
        return false, 'Group not provided.'
    end

    return self.groups.users[group]
end

function Cache:setGroup(id, type, group)
    if (not id or not type or not group) then
        return false, 'ID, type, or group not provided.'
    end

    if (type == 'user') then
        return self:addUserGroup(id, group)
    elseif (type == 'character') then
        return self:addCharacterGroup(id, group)
    else
        return false, "Invalid type provided. Use 'user' or 'character'."
    end
end

function Cache:fetch(source)
    if (not source) then
        return false, 'Source not provided.'
    end

    local userId = self.sources[source]

    if (not userId) then
        return false, 'User not found in cache.'
    end

    return self.users[userId]
end

Cache = Cache()

RegisterCommand(
    'unload',
    function(source)
        local user = User(source)

        Cache:unload(user)
    end
)
