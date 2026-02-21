_requestPending = false

-- Sends a request to the server. Only one request can be pending at a time.
-- requestType: either "login", "logout", "registration", or "token"
-- ...: variable number of arguments to pass along
-- Returns true if the request was sent, false otherwise
function sendRequest(requestType, ...)
    if not (requestType == "creation" or requestType == "spawn") then
        error("Invalid argument(s) to sendRequest()!", 2)
    end

    -- Don't send the request if one is already pending
    if _requestPending then
        outputDebugString("sendRequest(): request not sent - another request is already pending", 2)
        return false
    end

    -- Send the request and await server response
    _requestPending = true
    addEventHandler("characters:onServerResponse", resourceRoot, handleServerResponse, false)
    triggerServerEvent("characters:onClientRequest", localPlayer, requestType, ...)
end

-- Triggered when a server response is received.
function handleServerResponse(responseType, ...)
    -- Stop listening for server responses
    _requestPending = false
    removeEventHandler("characters:onServerResponse", resourceRoot, handleServerResponse)

    -- Handle the response
    if responseType == "creation" then
        handleCreationResponse(...)
    elseif responseType == "spawn" then
        handleSpawnResponse(...)
    else
        outputDebugString("handleServerResponse(): invalid response received ("..tostring(responseType)..")", 1)
    end
end

addEvent("characters:onServerResponse", true)
