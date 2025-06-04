fx_version 'cerulean'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
author 'decibelsz'
game 'gta5'

shared_scripts {
    'init.lua',
    'config/config.lua',
    'utils/class.lua',
    'utils/rpc.lua',
}

client_scripts {
    'client/**',
}

server_scripts {
    'server/queries.lua',
    'server/classes/cache.lua',
    'server/classes/user.lua',
    'server/classes/characters.lua',
    'server/functions/**',
    'server/commands/**'
}