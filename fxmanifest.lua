fx_version 'cerulean'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
author 'decibelsz'
game 'gta5'

shared_scripts {
    'init.lua',
    'config.lua',
    'utils/class.lua',
    'utils/rpc.lua',
}

client_scripts {}

server_scripts {
    'server/classes/**'
}