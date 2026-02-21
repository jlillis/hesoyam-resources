local failureCount = {}
local timers = {}

-- Increments the player's failed login counter.
-- player: the player that attempted to log in
-- username (optional): the username of the account the player tried to log in with; used for server logs
function recordFailedLoginAttempt(player, username)
    if not (isElement(player) and type(username) == "string") then
        error("Invalid argument(s) to recordFailedLoginAttempt()!", 2)
    end

    -- Do nothing if player lockout is disabled in server config
    if _config.lockout_threshold == -1 then
        return
    end

    -- Increment this player's failure count
    local serial = getPlayerSerial(player)
    if not failureCount[serial] then
        failureCount[serial] = 1
    else
        failureCount[serial] = failureCount[serial] + 1
    end

    -- Clear any existing timers for this player
    if isTimer(timers[serial]) then
        killTimer(timers[serial])
    end

    -- Set a new timer to clear this player's failure count
    timers[serial] = setTimer(clearFailedLoginAttempts, _config.lockout_duration * 60 * 1000, 1, serial)

    -- Log this attempt
    if _config.log_level == 2 then
        outputServerLog("LOGIN: "..getPlayerName(player).." attempted to log in as \'"..username.."\' (IP: "..getPlayerIP(player).." Serial: "..serial..")")
    end
end

-- Clear the failed login attempts for the player.
-- player: the player to clear failed attempts for - either the player element or the player's serial (string)
function clearFailedLoginAttempts(player)
    if not (isElement(player) or type(player) == "string") then
        error("Invalid argument(s) to clearFailedLoginAttempts()!", 2)
    end

    if isElement(player) then
        player = getPlayerSerial(player)
    end

    failureCount[player] = nil
end

-- Returns true if the player is locked out, false otherwise.
-- player: the player in question
function isPlayerLockedOut(player)
    if not isElement(player) then
        error("Invalid argument(s) to isPlayerLockedOut()!", 2)
    end

    local serial = getPlayerSerial(player)

    if not failureCount[serial] then
        return false
    end

    if failureCount[serial] >= _config.lockout_threshold then
        return true
    end

    return false
end
