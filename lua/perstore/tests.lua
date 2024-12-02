local serialize = require("perstore.serialize")
local deserialize = require("perstore.deserialize")
local d = require("perstore.defines")

local t = {
	test = "woo",
	test3 = {
		nestedargument = "ans",
		nested2 = "",
		double_nested = {
			nesteddouble = 1,
			nestedtriple = 4,
		},
		double_nesteda = {
			nesteddouble = 2,
			nestedtriple = 3,
			double_nested = {
				nesteddouble = 2,
				nestedtriple = 3,
			},
			double_nesteda = {
				nesteddouble = 5,
				nestedtriple = 6,
			},
		},
	},
}

local serialized = serialize("root", t)

function do_tables_match(a, b)
	return table.concat(a) == table.concat(b)
end

-- print("SER")
-- print(serialized)
--
-- local deserialized = deserialize(serialized)
--
-- print(serialize("root", deserialized))
--
-- print("ORIGINAL")
-- print(serialized)
--
-- print(do_tables_match(t, deserialized))

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

			-- read = vim.trim(read)

			return read
		else
			return nil
		end
	end,
}

local read = fileio.read("./perstorea")

print("FILE CONTENTS ")
print(read)

local object = deserialize(read)
local got = serialize("root", object)

print("GOT")
print(got)
