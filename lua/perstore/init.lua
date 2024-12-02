local plugin = require("perstore.plugin")

local private = {
	plugin = plugin.new(),
}

local Perstore = {}

Perstore.config = {
	stores = {},
}

Perstore.setup = function(opts)
	opts = opts or {}

	private.plugin:setup(opts)
end

Perstore.add_store = function(opts)
	return private.plugin:add_store(opts)
end

Perstore.save = function()
	private.plugin:save()
end

Perstore.load = function(call_callback)
	local data = private.plugin:load()

	private.plugin:on_load(data, false, call_callback)
end

_G.Perstore = Perstore

return Perstore
