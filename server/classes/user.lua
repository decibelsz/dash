User = class()

function User:__init(source)
    self.source      = source
    self.identifiers = GetPlayerIdentifiers(self.source)
    self.license     = self.identifiers[1]

    if (not self.license) then
        return false, "User license not found."
    end

    local data = self:fetch()

    if (not data) then
        return false, "User not found or created."
    end

    self:load(data)
end

function User:fetch()
    local cached = Cache:getAllCachedDataFromSource(self.source)

    if (cached) then
        return cached
    end

    -- fetch user from db or create and return new user if not found
    local data = mysql:executeSync(QUERIES.GET_USER_FROM_IDENTIFIER, { self.license })[1] or mysql:executeSync(QUERIES.CREATE_USER, { json.encode(self.identifiers) })[1]

    return data
end

function User:load(data)
    -- decode any json parsed data coming from db before assigning to the user object
    data.identifiers   = type(data.identifiers) == 'string' and json.decode(data.identifiers) or data.identifiers

    self.id            = data.id
    self.createdAt     = data.createdAt
    self.banned        = data.banned
    self.allowed       = data.allowed
    self.maxCharacters = data.maxCharacters
    self.characters    = self:fetchCharacters()

    Cache:createUserReference(self.license, self.source, self.id)
    Cache:setUserData(self.source, self)
end

function User:ban()
    self.banned = 1
    mysql:executeSync(QUERIES.UPDATE_USER_BAN_STATUS, { self.banned, self.id })
    print('User ' .. self.id .. ' (' .. self.license .. ') has been banned.')
end

function User:unban()
    self.banned = 0
    mysql:executeSync(QUERIES.UPDATE_USER_BAN_STATUS, { self.banned, self.id })
    print('User ' .. self.id .. ' (' .. self.license .. ') has been unbanned.')
end

function User:allow()
    self.allowed = 1
    mysql:executeSync(QUERIES.UPDATE_USER_ALLOW_STATUS, { self.allowed, self.id })
    print('User ' .. self.id .. ' (' .. self.license .. ') has been allowed to connect.')
end

function User:disallow()
    self.allowed = 0
    mysql:executeSync(QUERIES.UPDATE_USER_ALLOW_STATUS, { self.allowed, self.id })
    print('User ' .. self.id .. ' (' .. self.license .. ') has been disallowed to connect.')
end

function User:setMaxCharacters(maxCharacters)
    self.maxCharacters = maxCharacters
    mysql:executeSync(QUERIES.UPDATE_USER_MAX_CHARACTERS, { self.maxCharacters, self.id })
    print('User ' .. self.id .. ' (' .. self.license .. ') max characters set to ' .. self.maxCharacters)
end

function User:fetchCharacters()
    local rows = mysql:executeSync(QUERIES.GET_CHARACTERS_BY_USERID, { self.id })

    local characters = {}

    for k,v in pairs(rows) do
        rows[k].name = type(v.name) == 'string' and json.decode(v.name) or v.name
        characters[v.charId] = v
    end

    return characters
end

function User:createCharacter(data)
    if (not data or not data.name or not data.age or not data.model) then
        return false, "Invalid character data provided."
    end

    assert(type(data.name) == 'table', 'Character name must be a table containing: {first: "", last: ""}')

    local result = mysql:executeSync(QUERIES.CREATE_CHARACTER, { self.id, json.encode(data.name), data.age, data.model })[1]

    result.name = type(result.name) == 'string' and json.decode(result.name) or result.name

    print('Character created: ' .. result.charId .. ' for user: ' .. self.id)

    self.characters[result.charId] = result

    return result
end

function User:deleteCharacter(characterId)
    local result = mysql:executeSync(QUERIES.DELETE_CHARACTER, { characterId })
    return result
end

function User:getCharacter(characterId)
    local character = self.characters[characterId]

    if (not character) then
        return false, "Character not found."
    end

    return character
end

RegisterCommand('user', function(source, args)
    local user = User(source)

    if not user then
        print('User not found.')
        return
    end
    print(json.encode(user))

end)