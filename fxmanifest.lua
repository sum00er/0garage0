fx_version 'cerulean'
game 'gta5'

author 'ESX-Framework modified by sum00er'
description 'Modified ESX Garage System for ESX Legacy'
lua54 'yes'

shared_script '@es_extended/imports.lua'

server_scripts {'@es_extended/locale.lua', 'locales/*.lua', '@oxmysql/lib/MySQL.lua', 'config.lua', 'server/main.lua'}

client_scripts {'@es_extended/locale.lua', 'locales/*.lua', 'config.lua', 'client/main.lua'}

ui_page 'html/index.html'

files {'html/index.html', 'html/listener.js', 'html/style.css',}
