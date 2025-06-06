User = class()

function User:__init(source)
    self.source      = source
    self.identifiers = GetPlayerIdentifiers(self.source)
    self.license     = GetPlayerIdentifierByType(self.source, 'license')

    if (not self.license) then
        return false, "User license not found."
    end

    local data, cached = self:fetch()

    if (not data) then
        return false, "User not found or created."
    end

    -- preparing user data so we can send it to cache
    self.id            = data.id
    self.createdAt     = data.createdAt
    self.banned        = data.banned
    self.allowed       = data.allowed
    self.maxCharacters = data.maxCharacters
    self.characters    = data.characters
    self.groups        = data.groups

    if (cached) then
        return
    end

    local res, err = Cache:load(self)

    if (not res) then
        return false, err or "Failed to load user into cache."
    end

    print(('Dash: User %s (%s) loaded into cache.'):format(self.id, self.license))
end

function User:fetch()
    local cached = Cache:fetch(self.source)

    if (cached) then
        return cached, true
    end

    local data       = mysql:executeSync(QUERIES.GET_USER_FROM_IDENTIFIER, { self.license })[1] or mysql:executeSync(QUERIES.CREATE_USER, { json.encode(self.identifiers) })[1]
    local characters = mysql:executeSync(QUERIES.GET_CHARACTERS_BY_USERID, { data.id })

    data.identifiers = json.decode(data.identifiers)
    data.groups      = json.decode(data.groups)

    data.characters  = {}

    for _, v in pairs(characters) do
        v.name = json.decode(v.name)
        v.groups = json.decode(v.groups)

        data.characters[v.charId] = v
    end

    return data
end

RegisterCommand('user', function(source)
    User(source)
end)
