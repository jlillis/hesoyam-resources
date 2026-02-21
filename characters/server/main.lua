_playerCharacters = {}

-- Triggered when the resource starts
local function resourceStart()
    -- Load characters for all logged-in players
    for _, player in ipairs(getElementsByType("player")) do
        if exports.accounts:isPlayerLoggedIn(player) then
            loadPlayerCharacters(player)
        end
    end
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)

-- Triggered when a player logs in
local function playerLogin(triggeredByMTA)
    -- Ignore MTA account activity
    if triggeredByMTA then
        return
    end

    -- Load the player's characters
    loadPlayerCharacters(source)
end
addEventHandler("onPlayerLogin", root, playerLogin)

-- Triggered when a player logs out
local function playerLogout(triggeredByMTA)
    -- Ignore MTA account activity
    if triggeredByMTA then
        return
    end

    -- Unload the player's characters
    _playerCharacters[source] = nil

    -- Stop listening for requests
    removeEventHandler("characters:onClientRequest", source, handleClientRequest)
end
addEventHandler("onPlayerLogout", root, playerLogout)

-- Loads a player's characters from the database
function loadPlayerCharacters(player)
    if not isElement(player) then
        error("Bad arguments @ 'loadPlayerCharacters' [expected player]", 2)
    end

    -- Make sure player is logged in
    if not exports.accounts:isPlayerLoggedIn(player) then
        outputDebugString("loadPlayerCharacters: player is not logged in", 1)
        return
    end

    -- Acquire database handle
    local database = exports.database:getDatabase()
    if not database then
        outputDebugString("loadPlayerCharacters: unable to connect to database", 1)
        return
    end

    -- Load characters associated with this account from the databse
    local accountID = exports.accounts:getPlayerAccountID(player)
    dbQuery(onCharactersQuery, {player, accountID}, database, "SELECT * FROM characters WHERE account_id = ?", accountID)
end

-- Triggered when the database returns the results of the characters query
function onCharactersQuery(query, player, accountID)
    -- Make sure the player is still conected
    if not isElement(player) then
        dbFree(query)
        return
    end

    -- Make sure player is still logged in
    if not exports.accounts:isPlayerLoggedIn(player) then
        outputDebugString("onCharactersQuery: player is not logged in", 2)
        dbFree(query)
        return
    end

    -- Poll the query handle for results
    local result, numRows = dbPoll(query, 0)

    -- Send an error response if the query failed
    if not result then
        outputDebugString("onCharactersQuery: characters query failed", 1)
        return
    end

    -- Store character data locally
    _playerCharacters[player] = result

    -- Begin listening for character related requests from this player
    addEventHandler("characters:onClientRequest", player, handleClientRequest, false)

    -- Send character data to the client
    triggerClientEvent(player, "characters:onCharactersLoaded", resourceRoot, result)
end
