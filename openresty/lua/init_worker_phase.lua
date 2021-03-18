local subzero = require('subzero')
local pgmoon = require("pgmoon")
local db_channel = os.getenv('PGRST_DB_CHANNEL')
local db_conection_info = {
    host = os.getenv('DB_HOST'),
    port = os.getenv('DB_PORT'),
    database = os.getenv('DB_NAME'),
    password = os.getenv('DB_PASS'),
    user = os.getenv('DB_USER'),
    ssl = true
}


local function listen_db_schema_change()
    local db = pgmoon.new(db_conection_info)
    db:settimeout(1000 * 3600 * 24) -- 1 day
    while not db:connect() do
        ngx.sleep(1)
    end
    db:query('LISTEN '..db_channel)
    print('listening on '..db_channel)
    local message = nil
    while true do
        message = db:wait_for_notification()
        if message then
            if message.payload == '' then
                subzero.clear_cache()
                print('cleared schema cache')
            end
        else
            -- probably a connection timeout
            subzero.clear_cache()
            local ok, err = ngx.timer.at(10, listen_db_schema_change)
            break;
        end
    end
end



local ok, err = ngx.timer.at(0, listen_db_schema_change)


