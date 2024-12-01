local Plugin = require("Plugin")

local Perstore = {}
local private = {}

Perstore.config = {
	stores = {},
}

Perstore.setup = function(config)
	_G.Perstore = Perstore

	private.plugin = Plugin.new(config)
	private.plugin:setup()
end

Perstore.add_store = function(opts)
	private.plugin:add_store(opts)
end

Perstore.save = function()
	private.plugin:save()
end

Perstore.load = function(call_callback)
	local data = private.plugin:load()

	private.plugin:on_load(data, false, true)
end

return Perstore
