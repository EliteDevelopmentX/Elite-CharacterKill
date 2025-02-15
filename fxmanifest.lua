fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Elite Development'
description 'Character Kill'
version '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}
shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua',
    'config.lua'
}


dependency '/assetpacks'