-- Registration response types
enum({
    "SUCCESS",
    "FAILURE",
    "USERNAME_INVALID",
    "PASSWORD_INVALID",
    "USERNAME_IN_USE"
}, "REGISTRATION_RESPONSE")

-- Handles a registration request from a client.
function handleRegistrationRequest(client, username, password)
    if not isElement(client) then
        error("Bad argument @ 'handleRegistrationRequest' [invalid client]", 2)
    end

    -- Make sure username and password are valid
    if not (type(username) == "string" and type(password) == "string") then
        outputDebugString("handleRegistrationRequest: invalid request", 1)
        sendResponse(client, "registration", REGISTRATION_RESPONSE.FAILURE)
        return
    end

    -- Verify the username meets requirements (1-22 alphanumeric characters)
    username = string.lower(username)
    if string.len(username) == 0 or string.len(username) > 22 or string.find(username, "[^%w]") then
        sendResponse(client, "registration", REGISTRATION_RESPONSE.USERNAME_INVALID)
        return
    end

    -- Verify the password meets requirements (at least 8 characters)
    if string.len(password) < 8 then
        sendResponse(client, "registration", REGISTRATION_RESPONSE.PASSWORD_INVALID)
        return
    end

    -- Acquire database handle - send an error response if this fails
    local database = exports.database:getDatabase()
    if not database then
        outputDebugString("handleRegistrationRequest: unable to connect to database", 1)
        sendResponse(client, "registration", REGISTRATION_RESPONSE.FAILURE)
        return
    end

    -- Query the database for an account with this username
    dbQuery(onUsernameCheckQuery, {client, username, password}, database, "SELECT id FROM accounts WHERE username = ? LIMIT 1", string.lower(username))
end

-- Triggered when the database returns the results of the username query
function onUsernameCheckQuery(query, client, username, password)
    -- Make sure the client is still connected
    if not isElement(client) then
        dbFree(query)
        return
    end

    -- Poll the query handle for results
    local result, numRows = dbPoll(query, 0)

    -- Send an error response if the query failed
    if not result then
        outputDebugString("onUsernameCheckQuery: username check query failed", 1)
        sendResponse(client, "registration", REGISTRATION_RESPONSE.FAILURE)
        return
    end

    -- Send an error response if an account with this username already exists
    if #result ~= 0 then
        sendResponse(client, "registration", REGISTRATION_RESPONSE.USERNAME_IN_USE)
        return
    end

    -- Generate the password hash
    passwordHash(password, "bcrypt", {cost = _config.bcrypt_cost}, function(hash)
        onPasswordHash(client, username, hash)
    end)
end

-- Triggered when the password hash is generated
function onPasswordHash(client, username, hash)
    -- Make sure the client is still conected
    if not isElement(client) then
        return
    end

    -- Acquire database handle - send an error response if this fails
    local database = exports.database:getDatabase()
    if not database then
        outputDebugString("onPasswordHash: unable to connect to database", 1)
        sendResponse(client, "registration", REGISTRATION_RESPONSE.FAILURE)
        return
    end

    -- Query the database to create the account
    dbQuery(onRegistrationQuery, {client, username}, database, "INSERT INTO accounts (username, password_hash) VALUES (?, ?)", string.lower(username), hash)
end

-- Triggered when the database returns the results of the registration query.
function onRegistrationQuery(query, client, username)
    -- Make sure the client is still conected
    if not isElement(client) then
        dbFree(query)
        return
    end

    -- Poll the query handle for results
    local result, numRows = dbPoll(query, 0)

    -- Send an error response if the query failed
    if (not result) or (numRows ~= 1) then
        outputDebugString("onRegistrationQuery: registration query failed", 1)
        sendResponse(client, "registration", REGISTRATION_RESPONSE.FAILURE)
        return
    end

    -- Send a success response
    sendResponse(client, "registration", REGISTRATION_RESPONSE.SUCCESS)

    -- Log the registration
    if _config.log_level >= 1 then
        outputServerLog("REGISTER: "..getPlayerName(client).." registered account \'"..username.."\' (IP: "..getPlayerIP(client)..", Serial: "..getPlayerSerial(client)..")")
    end
end
