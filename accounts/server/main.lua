_playerAccountIDs = {}

addEvent("onPlayerLogin")
addEvent("onPlayerLogout")

-- Triggered when the resource starts.
local function resourceStart()
    -- Validate server configuration settings - if this fails, cancel resource start
    if not validateConfigurationSettings() then
        cancelEvent(true)
        return
    end

    -- Reset all players as if they had just joined the server
    resetMapInfo()
    for _, player in ipairs(getElementsByType("player")) do
        setElementFrozen(player, true)
        setElementPosition(player, 0, 0, 0)
        setElementRotation(player, 0, 0, 0)
        setElementDimension(player, 0)
        setElementInterior(player, 0)

        -- Begin listening for requests from this client
        addEventHandler("accounts:onClientRequest", player, handleClientRequest, false)

        -- Begin protecting the account ID attribute for this client
        addEventHandler("onElementDataChange", player, handlePlayerDataChange, false)
    end
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)

-- Triggered when the resource stops.
local function resourceStop()
    -- Logout all currently logged-in players
    for _, player in ipairs(getElementsByType("player")) do
        if isPlayerLoggedIn(player) then
            logoutPlayer(player)
        end
    end
end
addEventHandler("onResourceStop", resourceRoot, resourceStop)

-- Triggered when a player joins the server.
local function playerJoin()
    -- Begin listening for requests from this client
    addEventHandler("accounts:onClientRequest", source, handleClientRequest, false)

    -- Begin protecting the account ID attribute for this client
    addEventHandler("onElementDataChange", source, handlePlayerDataChange, false)
end
addEventHandler("onPlayerJoin", root, playerJoin)

-- Triggered when a player leaves the server.
local function playerQuit()
    -- If this player was logged in, log them out
    if isPlayerLoggedIn(source) then
        logoutPlayer(source)
    end
end
addEventHandler("onPlayerQuit", root, playerQuit)

-- Returns true if the player is logged in, false otherwise.
function isPlayerLoggedIn(player)
    if not isElement(player) then
        error("Invalid argument(s) to isPlayerLoggedIn()!", 2)
    end

    return _playerAccountIDs[player] and true or false
end

-- Returns the player's account ID, or false if they are not logged in.
function getPlayerAccountID(player)
    if not isElement(player) then
        error("Invalid argument(s) to getPlayerAccountID()!", 2)
    end

    return _playerAccountIDs[player]
end

-- Returns the player associated with the account ID, or false if the account ID is not in use.
function getPlayerByAccountID(accountID)
    if type(accountID) ~= "number" then
        error("Invalid argument(s) to getPlayerByAccountID()!", 2)
    end

    for player, id in pairs(_playerAccountIDs) do
        if id == accountID then
            return player
        end
    end

    return false
end

-- Handles player element data change - used to protect the account ID attribute.
function handlePlayerDataChange(key, previousValue)
    if key ~= "accounts:accountID" then
        return
    end

    -- If a client or another resource changed the account ID attribute, revert the change
    if client or sourceResource ~= resource then
        if previousValue ==  nil then
            removeElementData(source, key)
        else
            setElementData(source, key, previousValue)
        end
        outputDebugString("Account ID tampering detected, change reverted (client = "..inspect(client)..", sourceResource = "..inspect(sourceResource)..")", 2)
    end
end

-- Validates configuration settings defined in config.lua. Errors will be output to the debug console.
-- Returns true if the settings are valid, false otherwise.
function validateConfigurationSettings()
    -- Verify configuration settings exist
    if not _config then
        outputDebugString("Configuration settings missing!", 1)
        return false
    end

    -- Validate bcrypt cost factor (number >= 1)
    if not (type(_config.bcrypt_cost) == "number" and _config.bcrypt_cost >= 1) then
        outputDebugString("Invalid bcrypt cost factor!", 1)
        return false
    end
    -- Validate account lockout threshold (number >= -1)
    if not (type(_config.lockout_threshold) == "number" and _config.lockout_threshold >= -1) then
        outputDebugString("Invalid account lockout threshold!", 1)
        return false
    end
    -- Validate account lockout duration (number >= 1)
    if _config.lockout_threshold >= 0 then
        if not (type(_config.lockout_duration) == "number" and _config.lockout_duration >= 1) then
            outputDebugString("Invalid account lockout duration!", 1)
            return false
        end
    end

    -- Validate log level (number >= 0 and <= 2)
    if not (type(_config.log_level) == "number" and _config.log_level >= 0 and _config.log_level <= 2) then
        outputDebugString("Invalid log level!", 1)
        return false
    end

    return true
end
