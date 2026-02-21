-- Sends an token request to the server. This will fail if the player is not logged in.
-- Returns true if the request was sent, false otherwise
function sendTokenRequest()
    -- Cancel this request if the client is not logged in
    if not isPlayerLoggedIn(localPlayer) then
        outputDebugString("sendTokenRequest(): request cancelled; client is not logged in", 2)
        return false
    end

    -- Send the request
    if sendRequest("token") then
        return true
    else
        return false
    end
end

-- Handles a token response from the server.
-- token: the new token assigned to this client, or false if the request failed
function handleTokenResponse(token)
    -- Trigger API event for other resources
    triggerEvent("onClientTokenResponse", localPlayer, token)
end

addEvent("onClientTokenResponse")
