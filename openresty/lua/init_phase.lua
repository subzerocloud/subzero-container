require 'prelude'()
require 'pl.stringx'.import()

local cjson = require('cjson')
local utils = require('utils')
local hooks = require("hooks")
local subzero = require('subzero')
local postgrest = require('postgrest.handle')
local stringx = require 'pl.stringx'
local tablex = require 'pl.tablex'


if type(hooks.on_init) == 'function' then
    hooks.on_init()
end


auto_ssl = (require "resty.auto-ssl").new()

-- Define a function to determine which SNI domains to automatically handle
-- and register new certificates for. Defaults to not allowing any domains,
-- so this must be configured.
auto_ssl:set(
    "allow_domain",
    function(domain, auto_ssl, ssl_options, renewal)
        local allowed_domains = os.getenv('SSL_ALLOWED_DOMAINS')
        allowed_domains = totable(map(stringx.strip, stringx.split(allowed_domains, ',')))
        if tablex.find(allowed_domains, domain) then
            return true
        else
            return false
        end
    end
)

auto_ssl:set("dir", "/etc/resty-auto-ssl")

-- auto_ssl:set("storage_adapter", "resty.auto-ssl.storage_adapters.redis")
-- auto_ssl:set(
--     "redis",
--     {
--         host = redis_host,
--         port = redis_port
--         -- auth = redis_pass
--     }
-- )

auto_ssl:init()
