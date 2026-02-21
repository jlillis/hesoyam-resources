local _hitMarker, _activeVendor

local function resourceStart()
    -- If this resource just started, we'll be initializing all vendors so set the source to root
    if source == resourceRoot then
        source = root
        triggerServerEvent("onPlayerVendingReady", localPlayer)
    end

    -- Initialize all vending machines that are children of the source element
    for type, _ in pairs(_vendorTypes) do
        for _, element in ipairs(getElementsByType(type, source)) do
            initializeVendor(element, type)
        end
    end
end
addEventHandler("onClientResourceStart", root, resourceStart)

function createVendor()
    iprint("createVendor -> TODO")
end

function initializeVendor(element, type)
    if not (isElement(element) and _vendorTypes[type]) then
        error("Invalid argument(s) to initializeVendor", 2)
    end
    -- Setup rotation vector based on rotZ attribute (custom elements don't have proper rotations themselves)
    local rotation = Vector3(0, 0, tonumber(element:getData("rotZ")))
    local typeData = _vendorTypes[type]
    
    -- Create the vendor object (i.e vending machine or stall)
    local object = Object.create(typeData.modelID, element.position + typeData.objectOffset)
    --object:setRotation(rotation)
    object:setParent(element)
    object:setFrozen(true)

    -- Create the marker
    local marker = Marker.create(element.position + typeData.markerOffset, "cylinder", 0.5, 255, 0, 0, 198)
    marker:setParent(element)
    addEventHandler("onClientMarkerHit", marker, vendorMarkerHit)

    -- If defined, create the vendor ped (i.e ice cream clown)
    if _vendorTypes[type].pedData then
        local modelID, offset, rotZ = unpack(typeData.pedData)
        local ped = Ped.create(modelID, element.position + offset, rotZ)
        ped:setParent(element)
        ped:setFrozen(true)
        addEventHandler("onClientPedDamage", ped, cancelEvent)
    end
end

function vendorMarkerHit(player, dimensionMatch)
    if not (player == localPlayer and dimensionMatch) then
        return
    end

    -- attach handler to wait for the player to stop moving
    _hitMarker = source
    addEventHandler("onClientRender", root, waitForPlayerFreeze)
end

function waitForPlayerFreeze()
    -- if the player is no longer within the marker, remove the handler
    if not localPlayer:isWithinMarker(_hitMarker) then
        removeEventHandler("onClientRender", root, waitForPlayerFreeze)
        return
    end
    
    -- if the player has stopped moving, activate the vendor
    local velocity = localPlayer:getVelocity()
    velocity = velocity.x + velocity.y + velocity.z
    if velocity == 0 then
        removeEventHandler("onClientRender", root, waitForPlayerFreeze)
        -- freeze the player in position and await server response
        _activeVendor = _hitMarker.parent
        localPlayer:setFrozen(true)
        localPlayer:setPosition(Vector3(_hitMarker.position.x, _hitMarker.position.y, localPlayer.position.z))
        localPlayer:setRotation(_vendorTypes[_activeVendor.type].markerRotation)
        addEventHandler("onClientVendorResponse", resourceRoot, processVendorResponse)
        triggerServerEvent("onPlayerActivateVendor", localPlayer, _activeVendor)
        _hitMarker = false
    end
end

function processVendorResponse(success)
    removeEventHandler("onClientVendorResponse", resourceRoot, processVendorResponse)

    if not success then
        localPlayer:setFrozen(false)
        _activeVendor = false
    else
        -- begin playing animation sequence, if available
        -- otherwise, just unfreeze the player and move on
        if _vendorTypes[_activeVendor.type].animationSequence then
            performAnimationSequence(localPlayer, _vendorTypes[_activeVendor.type].animationSequence)
        else
            localPlayer:setFrozen(false)
            _activeVendor = false
        end
    end
end
addEvent("onClientVendorResponse", true)

function performAnimationSequence(ped, steps)
    if #steps == 1 then
        -- if there's only one step, just perform it and schedule the ped to be unfrozen
        ped:setAnimation(steps[1][1], steps[1][2], steps[1][3], false, true, false, false)
        Timer.create(setElementFrozen, steps[1][3], 1, ped, false)
        _activeVendor = false
    else
        -- otherwise, execute the first step and schedule the next
        ped:setAnimation(steps[1][1], steps[1][2], steps[1][3], false, true, false)
        Timer.create(advanceAnimationSequence, steps[1][3], 1, ped, 2, steps)
    end
end

function advanceAnimationSequence(ped, currentStep, steps)
    if currentStep < #steps then
        -- if this isn't the last step, perform it and schedule the next
        ped:setAnimation(steps[currentStep][1], steps[currentStep][2], steps[currentStep][3], false, true, false)
        Timer.create(advanceAnimationSequence, steps[currentStep][3], 1, ped, currentStep + 1, steps)
    else
        -- if this is the last step, unfreeze the player and perform it
        ped:setFrozen(false)
        ped:setAnimation(steps[currentStep][1], steps[currentStep][2], steps[currentStep][3], false, true, false, false)
        -- if there is product data for this vendor, create a product object and attach it to the ped's hand
        -- schedule the product to be deleted at the end of this step
        -- requires bone_attach by crystalmv
        if exports.bone_attach and _vendorTypes[_activeVendor.type].productData then
            local modelID, bone, x, y, z, xr, yr, zr = unpack(_vendorTypes[_activeVendor.type].productData)
            local object = Object.create(modelID, ped.position)
            exports.bone_attach:attachElementToBone(object, ped, bone, x, y, z, xr, yr, zr)
            Timer.create(destroyElement, steps[currentStep][3], 1, object)
            _activeVendor = false
        end
    end
end

-- Plays vendor sfx when a ped uses a vendor
function playVendorSFX(vendor)
    local sfx = _vendorTypes[vendor.type].sfxData
    if sfx then
        playSFX3D(sfx[1], sfx[2], sfx[3], vendor.position)
    end
end
addEvent("onClientPlayerUseVendor", true)
addEventHandler("onClientPlayerUseVendor", root, playVendorSFX)
