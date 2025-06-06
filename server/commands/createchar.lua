RegisterCommand('createchar', function(source)
    local user = User(source)
    local name = {
        first = 'Raiam',
        last = 'Santos'
    }
    local age = 34
    local model = 'mp_m_freemode_01'

    Cache:createCharacter(user, name, age, model)
end)