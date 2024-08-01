fx_version 'cerulean'
game 'gta5'

client_scripts {
    'config.lua',
    'client.lua' -- Your main client script
}

server_scripts {
    'server.lua',
    -- other server scripts...
}


shared_script {
'config.lua',
'@es_extended/imports.lua'
}