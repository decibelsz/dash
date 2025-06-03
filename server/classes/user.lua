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

-- Register a command to test the User class
RegisterCommand('user', function(source, args)
    local user = User(source)
end)