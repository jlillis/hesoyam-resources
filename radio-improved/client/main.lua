local function playerVehicleEnter(vehicle)
    -- Set the vehicle's radio station
    local vehicleRadioStation = getElementData(vehicle, "radioStation", false)
    if not vehicleRadioStation then
        setRadioChannel(0)
    else
        setRadioChannel(vehicleRadioStation)
    end
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, playerVehicleEnter)

local function playerRadioSwitch(stationID)
    -- If the player is not in one of the front seats, don't let them change the station
    if getPedOccupiedVehicleSeat(localPlayer) > 1 then
        cancelEvent()
    end

    -- Sync the radio station over the network
    setElementData(getPedOccupiedVehicle(localPlayer), "radioStation", stationID, true)
end
addEventHandler("onClientPlayerRadioSwitch", localPlayer, playerRadioSwitch)
