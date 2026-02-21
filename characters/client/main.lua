_characters = nil
addEvent("onClientCharactersLoaded", false)

-- Triggered when the server loads the player's characters
local function charactersLoaded(data)
    -- Store character data locally
    _characters = data

    -- Trigger API event for other resources
    triggerEvent("onClientCharactersLoaded", localPlayer)
end
addEvent("characters:onCharactersLoaded", true)
addEventHandler("characters:onCharactersLoaded", resourceRoot, charactersLoaded)

-- Returns the player's character data
function getPlayerCharacterData()
    if not _characters then
        outputDebugString("getPlayerCharacterData: character data not available", 2)
    end

    return _characters
end
