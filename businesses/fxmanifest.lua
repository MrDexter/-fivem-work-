fx_version 'cerulean'
game 'gta5'
--lua54 'yes'

shared_scripts {
	'config.lua'
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@async/async.lua',
	'server/*.lua'
}

client_scripts {
	'client/*.lua'
}

ui_page 'html/index.html'

files {
	'html/*',
}