fx_version 'cerulean'
author 'zykem#0643'
description 'Advanced Ban-System'
game 'gta5'

client_scripts {

    'cl_config.lua',
    'client.lua'

}

server_scripts {

    '@oxmysql/lib/MySQL.lua',
    'locales.lua',
    'sv_config.lua',
    'server.lua'

}
