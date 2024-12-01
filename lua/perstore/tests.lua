local ser = require("serialize.init")
local d = require("defines")

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

local serialized = ser.serialize("root", t)

function do_tables_match(a, b)
	return table.concat(a) == table.concat(b)
end

print("SER")
print(serialized)

local deserialized = ser.deserialize(serialized)

print(ser.serialize("root", deserialized))

print("ORIGINAL")
print(serialized)

print(do_tables_match(t, deserialized))
