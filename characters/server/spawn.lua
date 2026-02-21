-- Spawn response types
enum({
    "SUCCESS",
    "FAILURE"
}, "SPAWN_RESPONSE")

function handleSpawnRequest(client, characterID)
    -- TODO: validate request

    for _, character in ipairs(_playerCharacters[client]) do
        if character.id == characterID then
            if character.account_id == exports.accounts:getPlayerAccountID(client) then
                spawnPlayer(client, character.spawn_x, character.spawn_y, character.spawn_z, character.spawn_rot, character.model_id, character.spawn_int, character.spawn_dim)
                setCameraTarget(client, client)
                sendResponse(client, "spawn", SPAWN_RESPONSE.SUCCESS)
                return
            end
        end
    end

    sendResponse(client, "spawn", SPAWN_RESPONSE.FAILURE)
    outputDebugString("spawn fail")
end
