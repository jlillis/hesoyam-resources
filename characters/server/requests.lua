-- Sends a response to a client.
-- client: the client to respond to
-- responseType: either "login", "logout", "registration", or "token"
-- ...: variable number of arguments to send with the response
function sendResponse(client, responseType, ...)
    if not (isElement(client) and (responseType == "creation" or responseType == "spawn")) then
        error("Invalid argument(s) to sendResponse()!", 2)
    end

    -- Send the response
    triggerClientEvent(client, "characters:onServerResponse", resourceRoot, responseType, ...)

    -- Listen for future requests from this client
    addEventHandler("characters:onClientRequest", client, handleClientRequest, false)
end

-- Triggered when a client request is received.
function handleClientRequest(requestType, ...)
    -- Stop listening for further requests from this client
    removeEventHandler("characters:onClientRequest", client, handleClientRequest)

    -- Handle the request
    if requestType == "creation" then
        handleCreationRequest(client, ...)
    elseif requestType == "spawn" then
        handleSpawnRequest(client, ...)
    else
        outputDebugString("handleClientRequest(): invalid request received ("..tostring(requestType)..")", 1)
    end
end

addEvent("characters:onClientRequest", true)
