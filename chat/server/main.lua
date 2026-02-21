local playerChatHistory = {}

-- Triggered on resource start.
local function resourceStart()
    -- Validate chat configuration settings - if this fails, cancel resource start
    if not validateConfigurationSettings() then
        cancelEvent(true)
        return
    end

    -- Bind the 'u' key to open the chatbox with /Globalsay
    for _, player in ipairs(getElementsByType("player")) do
        bindKey(player, "u", "down", "chatbox", "Globalsay")

        -- Init player chat history
        playerChatHistory[player] = {
            lastMessage= "",
            lastMessageTime = 0,
            messageCount = 0
        }
    end
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)

-- Triggered when a player joins the server.
local function playerJoin()
    -- Bind the 'u' key to open the chatbox with /Globalsay
    bindKey(source, "u", "down", "chatbox", "Globalsay")

    -- Init player chat history
    playerChatHistory[source] = {
        lastMessage= "",
        lastMessageTime = 0,
        messageCount = 0
    }
end
addEventHandler("onPlayerJoin", root, playerJoin)

-- Triggered when a player leaves the server.
local function playerQuit()
    -- Cleanup player chat history
    playerChatHistory[source] = nil
end
addEventHandler("onPlayerQuit", root, playerQuit)

-- Triggered when a player uses the /Globalsay command.
local function globalSay(player, _, ...)
    triggerEvent("onPlayerChat", player, table.concat({...}, " "), 3)
end
addCommandHandler("Globalsay", globalSay)

-- Triggered when a player says something in chat.
local function playerChat(message, type)
    -- Cancel the event
    cancelEvent(true)

    -- Cancel action messages (/me, type 1)
    if type == 1 then
        return
    end

    -- Block messages from muted players
    if isPlayerMuted(source) then
        outputChatBox(_config.error_color.."* You are muted.", source, 0, 0, 0, true)
        return
    end

    -- Block messages from players that are not logged in
    if not exports.accounts:isPlayerLoggedIn(source) then
        outputChatBox(_config.error_color.."* You must login to chat.", source, 0, 0, 0, true)
        return
    end

    -- Antispam
    local now = getTickCount()
    if now - playerChatHistory[source].lastMessageTime < _config.spam_cooldown * 1000 then
        if playerChatHistory[source].messageCount >= _config.spam_threshold then
            setPlayerMuted(source, true)
            playerChatHistory[source].messageCount = 0
            setTimer(setPlayerMuted, _config.mute_duration * 1000, 1, source, false)
            return
        else
            playerChatHistory[source].messageCount = playerChatHistory[source].messageCount + 1
        end
    else
        playerChatHistory[source].messageCount = 0
    end
    playerChatHistory[source].lastMessage = message
    playerChatHistory[source].lastMessageTime = now

    -- Globalsay
    if type == 3 then
        outputChatBox((_config.info_color).."[GLOBAL] "..(_config.chat_color)..getPlayerName(source)..": "..message, root, 0, 0, 0, true)
        return
    end

    -- Teamsay
    if type == 2 then
        outputDebugString("teamsay")
        local team = getPlayerTeam(source)
        if not team then
            outputDebugString("not team")
            outputChatBox((_config.error_color).."* You are not on a team.", source, 0, 0, 0, true)
            return
        else
            outputDebugString("team")
            local teammates = getPlayersInTeam(team)
            for _, player in ipairs(teammates) do
                outputChatBox((_config.info_color).."[TEAM] "..(_config.chat_color)..getPlayerName(source)..": "..message, root, 0, 0, 0, true)
            end
            return
        end
    end

    -- Localsay
    if type == 0 then
        local x, y, z = getElementPosition(source)
        local sphere = createColSphere(x, y, z, _config.say_radius)
        setElementInterior(sphere, getElementInterior(source))
        setElementDimension(sphere, getElementDimension(source))
        local players = getElementsWithinColShape(sphere, "player")
        destroyElement(sphere)
        for _, player in ipairs(players) do
            outputChatBox((_config.chat_color)..getPlayerName(source)..": "..message, root, 0, 0, 0, true)
        end
        return
    end
end
addEventHandler("onPlayerChat", root, playerChat)

-- Validates configuration settings defined in config.lua. Errors will be output to the debug console.
-- Returns true if the settings are valid, false otherwise.
function validateConfigurationSettings()
    -- Verify configuration settings exist
    if not _config then
        outputDebugString("Configuration settings missing!", 1)
        return false
    end

    -- Verify color settings (string)
    if not (type(_config.error_color) == "string" and type(_config.info_color) == "string" and type(_config.chat_color) == "string") then
        outputDebugString("Invalid color settings!", 1)
        return false
    end

    -- Validate nametag colors flag (boolean)
    if not (type(_config.use_nametag_colors) == "boolean") then
        outputDebugString("Invalid nametag colors flag!", 1)
        return false
    end

    -- Validate say distance (number >= 0)
    if not (type(_config.say_radius) == "number" and _config.say_radius >= 0) then
        outputDebugString("Invalid say radius!", 1)
        return false
    end

    -- Validate spam threshold (number >= -1)
    if not (type(_config.spam_threshold) == "number" and _config.spam_threshold >= -1) then
        outputDebugString("Invalid spam threshold!", 1)
        return false
    end

    -- Validate mute duration (number >= 0)
    if _config.spam_threshold >= 0 and not (type(_config.mute_duration) == "number" and _config.mute_duration >= 0) then
        outputDebugString("Invalid mute duration!", 1)
        return false
    end

    return true
end
