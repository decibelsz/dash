local server = IsDuplicityVersion()

dash = {}



exports('getObject', function()
    return dash
end)

if (server) then
    mysql = exports['oxmysql']
end