local validModels = {}
for _, validModel in ipairs(getValidPedModels()) do
    validModels[validModel] = true
end

-- Returns true if the given model ID is a valid ped model
function isValidPedModel(model)
    return validModels[model]
end

-- Creates a C-style enum
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
