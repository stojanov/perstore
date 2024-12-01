local default_config = require("default_config")
local serialize = require("serialize.serialize")

local Plugin = {}

local fileio = {
	write = function(path, data)
		local file = io.open(path, "w")

		if file then
			file:write(data)
			file:close()
			return true
		else
			return false
		end
	end,

	read = function(path)
		local file = io.open(path, "r")

		if file then
			local read = file:read("*all")
			file:close()

			read = vim.trim(read)

			return read
		else
			return nil
		end
	end,
}

function Plugin.new(config)
	config = vim.tbl_deep_extend("force", default_config, config or {})

	return setmetatable({
		config = config,
	})
end

function Plugin:add_store(opts)
	local option = {
		on_loaded = nil,
		load_on_open = true,
		save_on_close = true,
	}

	vim.validate({
		name = { opts.name, "string" },
		data_ref = { opts.data_ref, "table" },
	})

	opts = vim.tbl_deep_extend("force", option, opts)

	self.config.stores[opts.name] = {
		data_ref = opts.data_ref,
		on_loaded = opts.on_loaded,
	}
end

function Plugin:save()
	local store = {}

	for key, value in pairs(self.config.stores) do
		self.store[key] = value.data_ref
	end

	local serialized = serialize.serialize("store", store)

	return fileio.write(self.config.store_file, serialized)
end

function Plugin:load()
	local data = fileio.read(self.config.store_file)

	return serialize.deserialize(data)
end

function Plugin:on_load(data, is_open, call)
	for key, value in pairs(data) do
		local store = self.config.stores[key]

		if store then
			if is_open and store.load_on_open and call then
				store.on_loaded(value)
				store.data_ref = value
			end

			if ~is_open and call then
				store.on_loaded(value)
				store.data_ref = value
			end
		else
			vim.notify("Wasn't able to load store " .. key)
		end
	end
end

function Plugin:setup()
	local data = self:load()
	self:on_load(data, true, true)

	if self.config.attach_hooks then
		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				self:save()
			end,
		})
	end
end

return Plugin
