-- Logs a player out their current account.
-- player: the player to log out
-- Returns true if successful, false otherwise (i.e if they weren't logged in).
function logoutPlayer(player)
    if not isElement(player) then
        error("Invalid argument(s) to logoutPlayer()!", 2)
    end

    -- Check if this player is currently logged in
    if not isPlayerLoggedIn(player) then
        outputDebugString("logoutPlayer(): player is not logged in", 2)
        return false
    end

    -- Clear the player's account ID
    _playerAccountIDs[player] = nil
    removeElementData(player, "accounts:accountID")

    -- Trigger API event for other resources
    triggerEvent("onPlayerLogout", player)

    -- Trigger remote API event for other resources (unless this resource is stopping)
    if getResourceState(resource) ~= "stopping" then
        triggerClientEvent(root, "onClientPlayerLogout", source)
    end

    -- Log the event
    if _config.log_level >= 2 then
        outputServerLog("LOGOUT: "..getPlayerName(player).." logged out (IP: "..getPlayerIP(player).." Serial: "..getPlayerSerial(player)..")")
    end

    return true
end

-- Handles a logout request from a client.
-- client: the client to respond to
function handleLogoutRequest(client)
    if not isElement(client) then
        error("Invalid argument(s) to handleLogoutRequest()!", 2)
    end

    if isPlayerLoggedIn(client) then
        logoutPlayer(client)
    end

    sendResponse(client, "logout")
end
