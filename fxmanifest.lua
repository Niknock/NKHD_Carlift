fx_version 'cerulean'
game 'gta5'

author 'Niknock HD'
description 'NKHD Car Lift'
version '1.0.0'

client_scripts {
    'client/main.lua',
    'config.lua'
}

server_scripts {
    'update.lua'
}

ui_page 'html/index.html'

files {
    'stream/nkhd_car_lift_01.ydr',
    'stream/nkhd_car_lift_02.ydr',
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

data_file 'DLC_ITYP_REQUEST' 'stream/nkhd_car_lift.ytyp'
