local d = require("defines")
local util = require("util")
local stack = require("stack")

local function parse_indent(buffer, pos)
	local count = 0

	for i = pos, #buffer do
		local c = buffer:sub(i, i)

		if c ~= " " then
			break
		end

		count = count + 1
	end

	return {
        indent_count = math.ceil(count / d.indent),
		pos = pos + count,
	}
end

local function try_number(input)
    local num = tonumber(input)

    if num ~= nil then
        return num
    end

    return input
end

local function try_boolean(input)
    if input == "true" or input == "1" then
        return true
    else
        if input == "false" or input == "0" then
            return false
        end
    end

    return input
end

local function try_nil(input)
    if input == d.empty then
        return ""
    end

    return input
end

local function parse_line(input, pos, stck)
	local finished = pos

	local line_data = parse_indent(input, pos)

    if stck:peek().indentation > line_data.indent_count then
        local prev_element = stck:pop()

        local current = stck:peek()

        if current == nil then
            return -1
        end


        if current.active_table_name ~= "" then
            current.data[current.active_table_name] = prev_element.data
            current.active_table_name = ""
        end
    end

	local buffer = ""
    local name = ""

	for i = line_data.pos, #input do
		local c = input:sub(i, i)

		if c == "\n" then
			finished = i + 1

            if util.contains_value(buffer) ~= nil then
                if #name == 0 then
                    print("no name, invalid file")
                    return -1
                end

                local value = buffer:gsub("%s+", "")

                value = try_number(input)
                value = try_nil(input)
                value = try_boolean(input)

                stck:peek().data[name] = value

                name = ""
                buffer = ""
            else
                stck:peek().active_table_name = name
                stck:push({
                    data = {},
                    active_table_name = "",
                    indentation = line_data.indent_count + 1
                })
            end

			break
		end

		if c == ":" then
            name = buffer:gsub("%s+", "")
            buffer = ""
            goto continue
		end

		buffer = buffer .. c
	    ::continue::
	end

	if finished == pos then
		return -1
	end

	return finished
end

local function deserialize(input)
	local stck = stack.new()

    stck:push({
        data = {},
        active_table_name = "root",
        indentation = 0,
    })

	local pos = 0
	while true do
		pos = parse_line(input, pos, stck)

		if pos == -1 then
			break
		end
	end

    if stck:peek() == nil then
        print("ERROR no data available")
        return nil
    end

    while stck:size() > 1 do
        local prev = stck:pop()
        local curr = stck:peek()

        if curr.active_table_name ~= "" then
            curr.data[curr.active_table_name] = prev.data
        end
    end

	return stck:pop().data
end

return deserialize
