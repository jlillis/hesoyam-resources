-- Login response types
enum({
    "SUCCESS",
    "FAILURE",
    "LOCKOUT",
    "INVALID_CREDENTIALS",
    "INVALID_TOKEN"
}, "LOGIN_RESPONSE")

-- Logs a player into an account. This will fail if the player is already logged in. If the account is already in use, the other player will be logged out.
-- player: the player to log in
-- accountID: the ID of the account
-- username: the username (case-sensitive)
-- Returns true if successful, false otherwise.
function loginPlayer(player, accountID, username)
    if not (isElement(player) and type(accountID) == "number" and type(username) == "string") then
        error("Invalid arguments to loginPlayer()!", 2)
    end

    -- Make sure this player isn't already logged in
    if isPlayerLoggedIn(player) then
        outputDebugString("loginPlayer(): login failed, player is already logged in", 2)
        return false
    end

    -- If this account is already in use, logout the other player
    local otherPlayer = getPlayerByAccountID(accountID)
    if otherPlayer then
        logoutPlayer(otherPlayer)
        -- Change the other player's name to avoid conflicts
        setPlayerName(otherPlayer, "_"..getPlayerName(otherPlayer))
    end

    -- Set the player's account ID
    _playerAccountIDs[player] = accountID
    setElementData(player, "accounts:accountID", accountID, true)

    -- Update the player's name
    local name = getPlayerName(player)
    if name ~= username then
        setPlayerName(player, username)
    end

    -- Clear any previous login attempts
    clearFailedLoginAttempts(player)

    -- Send a response to the client
    sendResponse(player, "login", LOGIN_RESPONSE.SUCCESS)

    -- Trigger API event for other resources
    triggerEvent("onPlayerLogin", player)

    -- Trigger remote API event for other resources
    triggerClientEvent(root, "onClientPlayerLogin", player)

    -- Log the event
    if _config.log_level >= 1 then
        outputServerLog("LOGIN: "..(name == username and username.." logged in" or name.." logged in as "..username).." (IP: "..getPlayerIP(player).." Serial: "..getPlayerSerial(player)..")")
    end

    return true
end

-- Handles a login request from a player.
-- player: the client to respond to
-- loginMethod: the login method being used: either "password" or "token"
-- usernameOrToken: for password-based logins, the account username; for token-based logins, the client token
-- password (optional): for password-based logins, the account password
function handleLoginRequest(client, loginMethod, usernameOrToken, password)
    if not isElement(client) then
        error("Invalid argument(s) to handleLoginRequest()!", 2)
    end

    -- Make sure the request is valid
    if (not (loginMethod == "password" or loginMethod == "token")) or
        type(usernameOrToken) ~= "string" or
        (loginMethod == "password" and type(password) ~= "string") then
        outputDebugString("handleLoginRequest(): invalid login request received", 1)
        sendResponse(client, "login", LOGIN_RESPONSE.FAILURE)
        return
    end

    -- Reject the request if the client is locked out
    if isPlayerLockedOut(client) then
        sendResponse(client, "login", LOGIN_RESPONSE.LOCKOUT)
        return
    end

    -- Acquire database handle - send an error response if this fails
    local database = exports.database:getDatabase()
    if not database then
        outputDebugString("handleLoginRequest(): unable to connect to database", 1)
        sendResponse(client, "login", LOGIN_RESPONSE.FAILURE)
        return
    end

    if loginMethod == "password" then
        -- Query the database for an account with this username
        dbQuery(onLoginUsernameQuery, {client, usernameOrToken, password}, database, "SELECT id, password_hash FROM accounts WHERE username = ? LIMIT 1", string.lower(usernameOrToken))
    elseif loginMethod == "token" then
        -- Query the database for a token with this string
        dbQuery(onLoginTokenQuery, {client}, database, "SELECT * FROM tokens WHERE string = ? LIMIT 1", usernameOrToken)
    end
end

--
--  Password login method
--

-- Triggered when the database returns the results of a login username query.
function onLoginUsernameQuery(query, client, username, password)
    -- Check if the client is still connected
    if not isElement(client) then
        dbFree(query)
        return
    end

    -- Poll the query handle for results
    local result, numRows = dbPoll(query, 0)

    -- Send an error response if the query failed
    if not result then
        outputDebugString("onLoginQuery(): login query failed", 1)
        sendResponse(client, "login", LOGIN_RESPONSE.FAILURE)
        return
    end

    -- An account with this username does not exist - send failure response and record the failed login attempt
    if numRows == 0 then
        sendResponse(client, "login", LOGIN_RESPONSE.INVALID_CREDENTIALS)
        recordFailedLoginAttempt(client, username)
        return
    end

    -- Verify the password
    passwordVerify(password, result[1].password_hash, function(passwordsMatch)
        onPasswordVerification(client, passwordsMatch, result[1].id, username)
    end)
end

-- Triggered when the passwordVerify function finishes verifying a password.
function onPasswordVerification(client, passwordsMatch, accountID, username)
    -- Check if the client is still connected
    if not isElement(client) then
        return
    end

    if passwordsMatch then
        loginPlayer(client, accountID, username)
    else
        sendResponse(client, "login", LOGIN_RESPONSE.INVALID_CREDENTIALS)
        recordFailedLoginAttempt(client, username)
    end
end

--
--  Token login method
--

-- Triggered when the database returns the results of a login token query.
function onLoginTokenQuery(query, client, token)
    -- Check if the client is still connected
    if not isElement(client) then
        dbFree(query)
        return
    end

    -- Poll the query handle for results
    local result, numRows = dbPoll(query, 0)

    -- Send an error response if the query failed
    if not result then
        outputDebugString("onLoginTokenQuery(): login query failed", 1)
        sendResponse(client, "login", LOGIN_RESPONSE.FAILURE)
        return
    end

    -- An token with this string does not exist - send failure response
    if numRows == 0 then
        sendResponse(client, "login", LOGIN_RESPONSE.INVALID_TOKEN)
        --recordFailedLoginAttempt(client)
        return
    end

    -- Verify the client's IP and serial match the token
    if result[1].serial == getPlayerSerial(client) and result[1].ip == getPlayerIP(client) then
        loginPlayer(client, result[1].account_id, result[1].username)
    else
        sendResponse(client, "login", LOGIN_RESPONSE.INVALID_TOKEN)
        recordFailedLoginAttempt(client, result[1].username)
    end

    -- Delete this token
    local database = exports.database:getDatabase()
    if not database then
        outputDebugString("onLoginTokenQuery(): unable to connect to database", 1)
        return
    end

    -- Query the database to delete this token associated with this client
    dbExec(database, "DELETE FROM tokens WHERE string = ? OR serial = ? OR ip = ?", result[1].string, getPlayerSerial(client), getPlayerIP(client))
end
