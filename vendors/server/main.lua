--  maintain a table of players that have this resource started clientside
local _readyPlayers = {}
local function playerVendingReady()
    _readyPlayers[client] = true
    addEventHandler("onPlayerQuit", client, function()
        _readyPlayers[source] = false
    end)
end
addEvent("onPlayerVendingReady", true)
addEventHandler("onPlayerVendingReady", root, playerVendingReady)

-- triggered when a player activates a vendor
function playerActivateVendor(vendor)
    -- TODO: set health, deduct money
    outputDebugString("TODO: playerActivateVendor")
    -- inform the client they have used the vendor
    triggerClientEvent(client, "onClientVendorResponse", resourceRoot, true)
    -- broadcast to all clients that this vendor has been used
    for player, _ in pairs(_readyPlayers) do
        triggerClientEvent(player, "onClientPlayerUseVendor", client, vendor)
    end
end
addEvent("onPlayerActivateVendor", true)
addEventHandler("onPlayerActivateVendor", root, playerActivateVendor)
