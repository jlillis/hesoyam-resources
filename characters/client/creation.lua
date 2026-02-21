-- Sends a creation request to the server.
-- characterName: the name of the new character
-- modelID: the model ID of the new character
-- clothingOptions: an array of clothing options for the new character - ignored if modelID is not zero
-- initialSpawnpoint: the initial-spawnpoint to spawn the new character at
-- Returns true if the request was sent, false otherwise
function sendCreationRequest(characterName, modelID, clothingOptions, initialSpawnpoint)
    --[[if not (type(username) == "string" and type(password) == "string") then
        error("Invalid argument(s) to sendRegistrationRequest()!", 2)
    end]]

    -- Send the request
    if sendRequest("creation", characterName, modelID, clothingOptions, initialSpawnpoint) then
        return true
    else
        return false
    end
end

-- Handles a registration response from the server.
-- responseCode: the response code from the server
function handleCreationResponse(responseCode, newCharacterID)
    iprint("handleCreationResponse -> ", responseCode, newCharacterID)

    -- Trigger API event for other resources
    triggerEvent("onCharacterCreationResponse", localPlayer, responseCode, newCharacterID)
end

addEvent("onCharacterCreationResponse")
