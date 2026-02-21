-- Sends an login request to the server.
-- loginMethod: the login method being used: either "password" or "token"
-- usernameOrToken: for password-based logins, the account username; for token-based logins, the client token
-- password (optional): for password-based logins, the account password
-- Returns true if the request was sent, false otherwise.
function sendLoginRequest(loginMethod, usernameOrToken, password)
    -- Make sure the request is valid
    if (not (loginMethod == "password" or loginMethod == "token")) or
        type(usernameOrToken) ~= "string" or
        (loginMethod == "password" and type(password) ~= "string") then
        error("Invalid argument(s) to sendLoginRequest()!", 2)
        return
    end

    -- Cancel this request if the client is already logged in
    if isPlayerLoggedIn(localPlayer) then
        outputDebugString("sendLoginRequest(): request cancelled; client is already logged in", 2)
        return false
    end

    -- Send the request
    if sendRequest("login", loginMethod, usernameOrToken, password) then
        return true
    else
        return false
    end
end

-- Handles an login response from the server.
-- responseCode: the response code from the server
function handleLoginResponse(responseCode)
    -- Trigger API event for other resources
    triggerEvent("onClientLoginResponse", localPlayer, responseCode)
end

addEvent("onClientLoginResponse")
