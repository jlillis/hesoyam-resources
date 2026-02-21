addEvent("onClientPlayerLogin", true)
addEvent("onClientPlayerLogout", true)

-- Triggered when the resource stops.
local function resourceStop()
    -- Trigger the onClientPlayerLogout API event locally for all logged-in clients.
    for _, player in ipairs(getElementsByType("player")) do
        if isPlayerLoggedIn(player) then
            triggerEvent("onClientPlayerLogout", player)
        end
    end
end
addEventHandler("onClientResourceStop", resourceRoot, resourceStop)

-- Returns true if the player is logged in, false otherwise.
function isPlayerLoggedIn(player)
    if not isElement(player) then
        error("Invalid arguments to isPlayerLoggedIn()!", 2)
    end

    return getElementData(player, "accounts:accountID", false) and true or false
end

-- Returns the player's account ID, or false if they are not logged in.
function getPlayerAccountID(player)
    if not isElement(player) then
        error("Invalid argument(s) to getPlayerAccountID()!", 2)
    end

    return getElementData(player, "accounts:accountID", false)
end
