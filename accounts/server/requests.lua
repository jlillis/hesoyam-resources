-- Sends a response to a client.
-- client: the client to respond to
-- responseType: either "login", "logout", "registration", or "token"
-- ...: variable number of arguments to send with the response
function sendResponse(client, responseType, ...)
    if not (isElement(client) and (responseType == "login" or responseType == "logout" or responseType == "registration" or responseType == "token")) then
        error("Invalid argument(s) to sendResponse()!", 2)
    end

    -- Send the response
    triggerClientEvent(client, "accounts:onServerResponse", resourceRoot, responseType, ...)

    -- Listen for future requests from this client
    addEventHandler("accounts:onClientRequest", client, handleClientRequest, false)
end

-- Triggered when a client request is received.
function handleClientRequest(requestType, ...)
    -- Stop listening for further requests from this client
    removeEventHandler("accounts:onClientRequest", client, handleClientRequest)

    -- Handle the request
    if requestType == "login" then
        handleLoginRequest(client, ...)
    elseif requestType == "logout" then
        handleLogoutRequest(client)
    elseif requestType == "registration" then
        handleRegistrationRequest(client, ...)
    elseif requestType == "token" then
        handleTokenRequest(client, ...)
    else
        outputDebugString("handleClientRequest(): invalid request received ("..tostring(requestType)..")", 1)
    end
end

addEvent("accounts:onClientRequest", true)
