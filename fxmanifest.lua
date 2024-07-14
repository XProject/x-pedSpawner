fx_version "cerulean"
use_experimental_fxv2_oal "yes"
lua54 "yes"
game "gta5"

name "x-pedSpawner"
version "0.0.0"
description "Project-X Ped Spawner"

dependencies {
    "ox_lib"
}

shared_scripts {
    "@ox_lib/init.lua",
    -- "shared/*.lua",
}

files {
    "shared.lua",
    "modules/*.lua",
    "modules/**/*.lua"
}

server_scripts {
    "server/*.lua"
}

client_scripts {
    "client/*.lua"
}
