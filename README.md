# Perstore
## A simple yaml like persistent store for neovim

Out of the box it doesn't really do anything, it up to the consumer to use it, or other plugins can also integrate it
## Installation
#### Via lazy
```lua 
{
    "stojanov/perstore",
    lazy = false, -- has to be set
    opts = {},
    dependencies = { "nvim-neotest/nvim-nio" }, -- this is optional, if the opts.async is set to true then this is required
}
```

#### Options to be passed into opts
Default options, can be passed into `opts`
```lua
{
	store_file = vim.fn.stdpath("config") .. "/perstore",
	attach_hooks = true, -- will attach hooks to save the store on VimLeave
	async = false, -- if parsing and loading the file is taking too long this is an option
}
```
## Usage example:
##### Once loaded, make sure you call `add_store` only after the plugin has be loaded, for example after you initialize `lazy` to load all the plugins
#### state.lua

```lua
local state = {
    format_on_save = true,
    current_colorscheme = "obscure",
}

local perstore = require "perstore"

return perstore.add_store {
    name = "state", -- has to be set
    data_ref = state, -- has to be set
    on_loaded = function(got_state) -- optional
        vim.cmd("colorscheme " .. got_state.current_colorscheme)

        local format_state = "enabled"

        if not got_state.format_on_save then
            format_state = "disabled"
        end

        vim.notify("Autoformatting " .. format_state)
    end, 
    load_on_close = true, -- optional
    save_on_close = true, -- optional
}
```
#### Using it in conform
```lua
local state = require('state')
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function(args)
        if state().format_on_save then
            conform.format { bufnr = args.buf }
        end
    end,
})
```
#### Modifing the store object
```lua
local state = require('state')
vim.api.nvim_create_autocmd("ColorSchemePre", {
    callback = function(args)
        local s = state()

        if s then
            s.current_colorscheme = args.match
        end
    end,
})
```

That's all folks
## License
MIT
