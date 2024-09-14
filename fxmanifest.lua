fx_version 'cerulean'
games { 'gta5' }

author 'KnowGoodVision'
description 'NPC Waypoint and Shop Script'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'locale/en.lua',  -- Updated to point to the correct locale folder
    'client.lua'
}

server_scripts {
    'locale/en.lua',  -- Updated to point to the correct locale folder
    '@mysql-async/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'ox_inventory'
}
