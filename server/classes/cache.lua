Cache = class()

function Cache:__init()
    self.users      = {}
    self.sources    = {}
    self.characters = {}
    self.permissions  = {
        users      = {},
        characters = {}
    }
end

function Cache:load(user)
    if (not user or not user.id) then
        return false, "Invalid user reference."
    end

    self.users[user.id]       = user
    self.sources[user.source] = user.id

    for _, v in pairs(user.characters) do -- indexing character objects by charId for quick access
        self.characters[v.charId] = v
    end

    print(json.encode(self))

    return true
end

function Cache:fetch(source)
    if (not source) then
        return false, "Invalid source."
    end

    local id = self.sources[source]

    if (not id) then
        return false, "User not found in cache."
    end

    return self.users[id]
end

function Cache:getUserById(id)
    return self.users[id]
end

function Cache:getUserBySource(source)
    return self.sources[source]
end

function Cache:getCharacterById(charId)
    return self.characters[charId]
end

function Cache:getCharacterOwner(charId)
    if (not self.characters[charId]) then
        return false
    end

    return self.characters[charId].ownerId
end

Cache = Cache()