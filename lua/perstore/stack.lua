local Stack = {}

function Stack.new()
	return setmetatable({ data = {}, count = 0 }, { __index = Stack })
end

function Stack:push(e)
	self.count = self.count + 1
	self.data[self.count] = e
end

function Stack:peek()
	if self.count == 0 then
		return nil
	end

	return self.data[self.count]
end

function Stack:pop()
	if self.count == 0 then
		return nil
	end

	local item = self.data[self.count]
	self.data[self.count] = nil
	self.count = self.count - 1

	return item
end

function Stack:clear()
	self.data = {}
	self.count = 0
end

function Stack:size()
	return self.count
end

return Stack
