Character = class(User)

function Character:__init(source)
    User.__init(self, source)
    self.characters = self:fetchCharacters()
end

function Character:fetchCharacters()
    local rows = mysql:executeSync(QUERIES.GET_CHARACTERS_BY_USERID, { self.id })

    for k,v in pairs(rows) do
        rows[k].name = type(v.name) == 'string' and json.decode(v.name) or v.name
    end

    return rows or {}
end

function Character:createCharacter(data)
    if (not data or not data.name or not data.age or not data.model) then
        return false, "Invalid character data provided."
    end

    assert(type(data.name) == 'table', 'Character name must be a table containing: {first: "", last: ""}')

    local result = mysql:executeSync(QUERIES.CREATE_CHARACTER, { self.id, json.encode(data.name), data.age, data.model })[1]

    result.name = type(result.name) == 'string' and json.decode(result.name) or result.name

    print('Character created: ' .. result.charId .. ' for user: ' .. self.id)

    return result
end

function Character:deleteCharacter(characterId)
    local result = mysql:executeSync(QUERIES.DELETE_CHARACTER, { characterId })
    return result
end

RegisterCommand('character', function(source)
    local character = Character(source)

    character:createCharacter({
        name = { first = 'John', last = 'Doe' },
        age = 30,
        model = 'mp_m_freemode_01'
    })

end)