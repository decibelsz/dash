local server = IsDuplicityVersion()

dash = {}

exports(
    'getObject',
    function()
        return dash
    end
)

if (server) then
    mysql = exports['oxmysql']
end

repeat
    Wait(1)
until config.groups

config.nameToGroupId = {}

for id, groupData in pairs(config.groups) do
    if (not groupData.name) then
        print(('Dash: Group %s is missing a name.'):format(id))
    else
        config.nameToGroupId[groupData.name] = id
    end
end
