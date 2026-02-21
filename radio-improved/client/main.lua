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

--[[local radioStations = {
    "Adverts",
    --"Ambience",
    --"Police",
    "Playback FM",
    "K-Rose",
    "K-DST",
    --"Cutscene",
    "Beats",
    "Bounce FM",
    "SF-UR",
    "Radio Los Santos",
    "Radio X",
    "CSR 103.9",
    "K-Jah West",
    "Master Sounds 98.3",
    "WCTR"
}
local trackIDs = {}
local currentTrack = 50
local currentSFX
function enumerateRadioTrackIDs()
    if isElement(currentSFX) then
        destroyElement(currentSFX)
    end

    currentSFX = playSFX("radio", "Playback FM", currentTrack, false) 
    if isElement(currentSFX) then
        trackIDs[currentTrack] = true
        currentTrack = currentTrack + 1
        outputDebugString("Playing track ID: "..currentTrack)
        outputDebugString(getSoundLength(currentSFX))
    else
        outputDebugString("Invalid/max track ID: "..currentTrack)
        outputDebugString(toJSON(trackIDs))
    end
end


setTimer(enumerateRadioTrackIDs, 15000, 100)]]
