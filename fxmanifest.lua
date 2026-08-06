fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'botea'
description 'Droxen Hunger Games'
version '2.6.0'

shared_scripts {
    'config.lua',

    'shared/utils.lua',
    'shared/zones.lua'
}

server_scripts {
    'server/main.lua',
    'server/players.lua',
    'server/lobby.lua',
    'server/event.lua',
    'server/spawn.lua',
    'server/circle.lua',
    'server/loot.lua'
}

client_scripts {
    'client/main.lua',
    'client/hud.lua',
    'client/spawn.lua',
    'client/circle.lua',
    'client/protection.lua',
    'client/loot.lua'
}

ui_page 'html/index.html'

files {
    'html/*.*',
    'html/img/*.*'
}