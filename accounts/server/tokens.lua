-- Handles a token request from a client. This will fail if this client is not logged in.
function handleTokenRequest(client)
    if not isElement(client) then
        error("Invalid argument(s) to handleTokenRequest()!", 2)
    end

    -- Make sure this client is logged in
    if not isPlayerLoggedIn(client) then
        sendResponse(client, "token", false)
    end

    -- Acquire database handle - send an error response if this fails
    local database = exports.database:getDatabase()
    if not database then
        outputDebugString("handleTokenRequest(): unable to connect to database", 1)
        sendResponse(client, "token", 1)
        return
    end

    -- Query the database to delete any tokens associated with this client
    dbQuery(onTokenDeleteQuery, {client}, database, "DELETE FROM tokens WHERE account_id = ? OR serial = ? OR ip = ?", getPlayerAccountID(client), getPlayerSerial(client), getPlayerIP(client))
end

-- Triggered when the database returns the results of the token delete query.
function onTokenDeleteQuery(query, client)
    -- Check if the player is still logged in
    if not (isElement(client) and isPlayerLoggedIn(client)) then
        dbFree(query)
        return
    end

    -- Poll the query handle for results
    local result = dbPoll(query, 0)

    -- Send an error response if the query failed
    if not result then
        outputDebugString("onTokenDeleteQuery(): token delete query failed", 1)
        sendResponse(client, "token", 1)
        return
    end

    -- Generate a new token id for this client
    local token = string.random(32)

    -- Acquire database handle - send an error response if this fails
    local database = exports.database:getDatabase()
    if not database then
        outputDebugString("onTokenDeleteQuery(): unable to connect to database", 1)
        sendResponse(client, "token", 1)
        return
    end

    -- Query the database to create a token associated with this client
    dbQuery(onTokenCreateQuery, {client, token}, database, "INSERT INTO tokens (string, account_id, username, serial, ip) VALUES (?, ?, ?, ?, ?)", token, getPlayerAccountID(client), getPlayerName(client), getPlayerSerial(client), getPlayerIP(client))
end

-- Triggered when the database returns the results of the token create query.
function onTokenCreateQuery(query, client, token)
    -- Check if the player is still logged in
    if not (isElement(client) and isPlayerLoggedIn(client)) then
        dbFree(query)
        return
    end

    -- Poll the query handle for results
    local result = dbPoll(query, 0)

    -- Send an error response if the query failed
    if not result then
        outputDebugString("onTokenCreateQuery(): token create query failed", 1)
        sendResponse(client, "token", 1)
        return
    end

    -- Send the new token to the client
    sendResponse(client, "token", token)
end
