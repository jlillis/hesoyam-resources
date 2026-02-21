-- Generates a random ASCII string.
-- len: length of the string to generate
function string.random(len)
    if type(len) ~= "number" then
        error("Invalid argument(s) to string.random()!", 2)
    end

    local chars = {}
    for i=1,len do
        -- Pick a random ASCII character (excluding control characters)
        chars[i] = string.char(math.random(33, 126))
    end

    return table.concat(chars)
end

-- Creates a C-style enum.
function enum(names, prefix)
    if prefix then
        _G[prefix] = {}
    end

    for i, name in ipairs(names) do
		if prefix then
            _G[prefix][name] = i
        else
            _G[name] = i
        end
	end
end
