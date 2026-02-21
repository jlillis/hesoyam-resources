-- Creation response types
enum({
    "SUCCESS",
    "FAILURE",
    "NAME_IN_USE"
}, "CREATION_RESPONSE")

-- Handles a character creation request from a client
function handleCreationRequest(client, characterName, modelID, clothingOptions, initialSpawnpoint)
    if not isElement(client) then
        error("Bad argument @ 'handleCreationRequest' [invalid client]", 2)
    end

    -- Make sure client is logged in
    if not exports.accounts:isPlayerLoggedIn(client) then
        outputDebugString("handleCreationRequest: invalid request; client is not logged in", 1)
        sendResponse(client, "creation", CREATION_RESPONSE.FAILURE)
        return
    end

    -- Make sure character name is valid
    if not (type(characterName) == "string" and characterName:gsub(" ", "") ~= "") then
        outputDebugString("handleCreationRequest: invalid request; character name is invalid", 1)
        sendResponse(client, "creation", CREATION_RESPONSE.FAILURE)
        return
    end

    -- Make sure model is valid
    if not isValidPedModel(modelID) then
        outputDebugString("handleCreationRequest: invalid request; character model is invalid", 1)
        sendResponse(client, "creation", CREATION_RESPONSE.FAILURE)
        return
    end

    -- Make sure clothing options are valid
    if modelID == 0 and (#clothingOptions ~= 18) then
        outputDebugString("handleCreationRequest: invalid request; character clothing options are invalid", 1)
        sendResponse(client, "creation", CREATION_RESPONSE.FAILURE)
        return
    end
    if modelID ~= 0 then
        clothingOptions = {}
    end

    -- Pick a random intial spawnpoint if one wasn't provided
    if not isElement(initialSpawnpoint) then
        local spawnpoints = getElementsByType("initial-spawnpoint")
        if #spawnpoints == 0 then
            outputDebugString("handleCreationRequest: no initial-spawnpoints on map, unable to spawn new characters", 2)
            sendResponse(client, "creation", CREATION_RESPONSE.FAILURE)
            return
        else
            initialSpawnpoint = spawnpoints[math.random(1, #spawnpoints)]
        end
    end

    -- Acquire database handle - send an error response if this fails
    local database = exports.database:getDatabase()
    if not database then
        outputDebugString("handleCreationRequest: unable to connect to database", 1)
        sendResponse(client, "creation", CREATION_RESPONSE.FAILURE)
        return
    end

    -- Query the database for characters with the same name
    dbQuery(onNameCheckQuery, {client, characterName, modelID, clothingOptions, initialSpawnpoint}, database, "SELECT id FROM characters WHERE LOWER(name) = LOWER(?) LIMIT 1", characterName)
end

-- Triggered when the database returns the results of the name check query
function onNameCheckQuery(query, client, characterName, modelID, clothingOptions, initialSpawnpoint)
    -- Make sure the client is still connected
    if not isElement(client) then
        dbFree(query)
        return
    end

    -- Poll the query handle for results
    local result, numRows = dbPoll(query, 0)

    -- Send an error response if the query failed
    if not result then
        outputDebugString("onNameCheckQuery: name check query failed", 1)
        sendResponse(client, "creation", CREATION_RESPONSE.FAILURE)
        return
    end

    -- Send an error response if a character with this name already exists
    if #result ~= 0 then
        sendResponse(client, "creation", CREATION_RESPONSE.NAME_IN_USE)
        return
    end

    -- Acquire database handle - send an error response if this fails
    local database = exports.database:getDatabase()
    if not database then
        outputDebugString("onNameCheckQuery: unable to connect to database", 1)
        sendResponse(client, "creation", CREATION_RESPONSE.FAILURE)
        return
    end

    -- Get the initial spawnpoint position
    local spawnX, spawnY, spawnZ = getElementPosition(initialSpawnpoint)
    local spawnRotation = getElementRotation(initialSpawnpoint)
    local spawnInterior, spawnDimension = getElementInterior(initialSpawnpoint), getElementDimension(initialSpawnpoint)

    -- Query the database to create the character
    local accountID = exports.accounts:getPlayerAccountID(client)
    dbQuery(onCreationQuery, {client, characterName, accountID, modelID}, database, "INSERT INTO characters (name, account_id, model_id, spawn_x, spawn_y, spawn_z, spawn_rot, spawn_int, spawn_dim) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", characterName, accountID, modelID, spawnX, spawnY, spawnZ, spawnRotation, spawnInterior, spawnDimension)
end

-- Triggered when the database returns the results of the character creation query
function onCreationQuery(query, client, characterName, accountID, modelID)
    -- Make sure the client is still connected
    if not isElement(client) then
        dbFree(query)
        return
    end

    -- Poll the query handle for results
    local result, numRows, newCharacterID = dbPoll(query, 0)

    -- Send an error response if the query failed
    if (not result) or (numRows ~= 1) then
        outputDebugString("onCreationQuery: creation query failed", 1)
        sendResponse(client, "creation", CREATION_RESPONSE.FAILURE)
        return
    end

    ---- Send a success response
    sendResponse(client, "creation", CREATION_RESPONSE.SUCCESS, newCharacterID)

    -- Add new character to characters cache
    --table.insert(_playerCharacters[client], {id = newCharacterID, name = characterName, account_id = accountID, model_id = modelID})
    loadPlayerCharacters(client)
end
