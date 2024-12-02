local default_config = require("perstore.default_config")
local serialize = require("perstore.serialize")
local deserialize = require("perstore.deserialize")
local nio = require("nio")

local Plugin = {}

local fileio = {
	write_sync = function(path, data)
		local file = io.open(path, "w")

		if file then
			file:write(data)
			file:close()
			return true
		else
			return false
		end
	end,

	read_sync = function(path)
		local file = io.open(path, "r")

		if file then
			local read = file:read("*all")
			file:close()

			return read
		else
			return nil
		end
	end,

	write = function(path, data)
		local file = nio.file.open(path, "w")

		if file then
			file.write(data)
			file.close()
			return true
		else
			return false
		end
	end,

	read = function(path)
		local file = nio.file.open(path, "r")

		if file then
			local read = file.read(nil, 0)

			file:close()

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
		stores = {},
		hooks_attached = false,
	}, { __index = Plugin })
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

	if self.stores[opts.name] then
		local store = self.stores[opts.name]

		if store.from_loaded then
			opts.data_ref = store.data_ref
			opts.on_loaded(opts.data_ref)
		end
	end

	self.stores[opts.name] = opts

	return function()
		return self:query_store(opts.name)
	end
end

function Plugin:save()
	local store = {}

	for key, value in pairs(self.stores) do
		store[key] = value.data_ref
	end

	local serialized = serialize("store", store)

	return fileio.write_sync(self.config.store_file, serialized)
end

function Plugin:query_store(name)
	local store = self.stores[name]

	if store then
		return store.data_ref
	else
		return nil
	end
end

function Plugin:load()
	local data = nil

	if self.config.async then
		data = fileio.read(self.config.store_file)
	else
		data = fileio.read_sync(self.config.store_file)
	end

	if data then
		return deserialize(data)
	end

	return nil
end

function Plugin:on_load(data, is_open, call)
	for key, value in pairs(data) do
		local store = self.stores[key]

		if store then
			local should_call = is_open and store.load_on_open
			should_call = should_call or (not is_open and call)

			store.data_ref = value

			if should_call then
				if self.config.async then
					vim.schedule(function()
						store.on_loaded(store.data_ref)
					end)
				else
					store.on_loaded(store.data_ref)
				end
			end
		else
			self.stores[key] = {
				data_ref = value,
				from_loaded = true,
			}
		end
	end
end

function Plugin:full_load()
	local data = self:load()

	if data then
		self:on_load(data, true, true)
	else
		vim.notify("Perstore: Cannot read file", vim.log.ERROR)
	end
end

function Plugin:setup(config)
	config = vim.tbl_deep_extend("force", self.config, config or {})

	if self.config.attach_hooks and not self.hooks_attached then
		vim.api.nvim_create_autocmd("VimLeavePre", {
			callback = function()
				self:save()
			end,
		})

		self.hooks_attached = true
	end

	if self.config.async then
		nio.run(function()
			self:full_load()
		end)
	else
		self:full_load()
	end
end

return Plugin
