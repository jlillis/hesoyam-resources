-- Sends a registration request to the server.
-- username: the requested username
-- password: the requested password
-- Returns true if the request was sent, false otherwise
function sendRegistrationRequest(username, password)
    if not (type(username) == "string" and type(password) == "string") then
        error("Invalid argument(s) to sendRegistrationRequest()!", 2)
    end

    -- Send the request
    if sendRequest("registration", username, password) then
        return true
    else
        return false
    end
end

-- Handles a registration response from the server.
-- responseCode: the response code from the server
function handleRegistrationResponse(responseCode)
    -- Trigger API event for other resources
    triggerEvent("onClientRegistrationResponse", localPlayer, responseCode)
end

addEvent("onClientRegistrationResponse")
