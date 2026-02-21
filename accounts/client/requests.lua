_requestPending = false

-- Sends a request to the server. Only one request can be pending at a time.
-- requestType: either "login", "logout", "registration", or "token"
-- ...: variable number of arguments to pass along
-- Returns true if the request was sent, false otherwise
function sendRequest(requestType, ...)
    if not (requestType == "login" or requestType == "logout" or requestType == "registration" or requestType == "token") then
        error("Invalid argument(s) to sendRequest()!", 2)
    end

    -- Don't send the request if one is already pending
    if _requestPending then
        outputDebugString("sendRequest(): request not sent - another request is already pending", 2)
        return false
    end

    -- Send the request and await server response
    _requestPending = true
    addEventHandler("accounts:onServerResponse", resourceRoot, handleServerResponse, false)
    triggerServerEvent("accounts:onClientRequest", localPlayer, requestType, ...)
end

-- Triggered when a server response is received.
function handleServerResponse(responseType, ...)
    -- Stop listening for server responses
    _requestPending = false
    removeEventHandler("accounts:onServerResponse", resourceRoot, handleServerResponse)

    -- Handle the response
    if responseType == "login" then
        handleLoginResponse(...)
    elseif responseType == "logout" then
        return -- The server will trigger the onClientPlayerLogout event
    elseif responseType == "registration" then
        handleRegistrationResponse(...)
    elseif responseType == "token" then
        handleTokenResponse(...)
    else
        outputDebugString("handleServerResponse(): invalid response received ("..tostring(responseType)..")", 1)
    end
end

addEvent("accounts:onServerResponse", true)
