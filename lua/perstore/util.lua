local function contains_value(input)
	for i = 1, #input do
		local c = input:sub(i, i)

		if c == "\n" then
			return nil
		end

		if c ~= " " then
			return i
		end
	end

	return nil
end

return {
	contains_value = contains_value,
}
