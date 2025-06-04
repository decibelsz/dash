dash.user = {}

dash.user.getUser = function(source)
    local user = User(source)
    if not user then
        return false, 'User not found'
    end
    return user
end