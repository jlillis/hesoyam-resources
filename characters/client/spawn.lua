addEvent("onClientSpawnResponse", false)

function sendSpawnRequest(characterID)
    if not exports.accounts:isPlayerLoggedIn(localPlayer) then
        return
    end

    local valid = false
    for _, character in ipairs(_characters) do
        if character.id == characterID then
            valid = true
        end
    end

    if valid then
        sendRequest("spawn", characterID)
    else
        return
    end
end

function handleSpawnResponse(responseCode)
    triggerEvent("onClientSpawnResponse", root, responseCode)
end
