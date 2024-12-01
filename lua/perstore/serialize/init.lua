local de = require("serialize.deserialize")
local se = require("serialize.serialize")

return {
	serialize = se,
	deserialize = de,
}
