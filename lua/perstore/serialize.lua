local d = require("perstore.defines")

local function create_indent(count)
	local rtn = ""

	if count == 0 then
		return rtn
	end

	if count == 1 then
		for j = 1, d.indent do
			rtn = rtn .. " "
		end

		return rtn
	end

	for i = 1, count do
		for j = 1, d.indent do
			rtn = rtn .. " "
		end
	end

	return rtn
end

local function serialize_field(name, value, offset)
	local tosave = tostring(value)

	if tosave == "" then
		tosave = d.empty
	end

	return create_indent(offset) .. name .. ": " .. tostring(value)
end

local function serialize_table(t, offset)
	local serialized = ""

	for key, value in pairs(t) do
		local out = ""

		local isTable = false
		if type(value) == "table" then
			out = create_indent(offset) .. key .. ":\n"
			out = out .. serialize_table(value, offset + d.indent)
			isTable = true
		else
			out = serialize_field(key, value, offset)
		end

		if isTable then
			serialized = serialized .. out
		else
			serialized = serialized .. out .. "\n"
		end
	end

	return serialized .. "\n"
end

local function serialize(name, v)
	local serialized = ""

	if type(v) == "table" then
		serialized = serialize_table(v, 0)
	else
		serialized = serialize_field(name, v, 0)
	end

	return serialized
end

return serialize
