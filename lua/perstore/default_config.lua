local default_config = {
	stores = {},
	store_file = vim.fn.stdpath("config") .. "/perstore",
	attach_hooks = true,
	async = true,
}

return default_config
