User = class()

function User:__init(source)
    self.source      = source
    self.identifiers = GetPlayerIdentifiers(self.source)
    self.license     = self.identifiers[1]

    if (not self.license) then
        return false
    end

    local data = mysql:executeSync(QUERIES.GET_USER_FROM_IDENTIFIER, { self.license })[1] or mysql:executeSync(QUERIES.CREATE_USER, { json.encode(self.identifiers) })[1]

    -- decode any json parsed data coming from db before assinging to the user object
    data.identifiers = json.decode(data.identifiers)

    self.id            = data.id
    self.createdAt     = data.createdAt
    self.banned        = data.banned
    self.allowed       = data.allowed
    self.maxCharacters = data.maxCharacters

    -- create a reference in the cache for this user
    Cache:createReference(self.license, self.source, self.id)
end

function User:deleteDB(id)
    mysql:executeSync(QUERIES.DELETE_USER, { id })
end

function User:getUserId(id)
    local query  = "SELECT * FROM `users` WHERE id = ?"
    local result = mysql:executeSync(query, { id })
    return result
end
