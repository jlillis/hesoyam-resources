-- Sends an logout request to the server. Will fail if the client is not logged in.
-- Returns true if the request was sent, false otherwise.
function sendLogoutRequest()
    -- Cancel this request if the client is not logged in
    if not isPlayerLoggedIn(localPlayer) then
        outputDebugString("sendLogoutRequest(): request cancelled; client is not logged in", 2)
        return false
    end

    -- Send the request
    if sendRequest("logout") then
        return true
    else
        return false
    end
end
