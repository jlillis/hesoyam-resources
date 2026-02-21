SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()

-- Resource start callback
local function resourceStart()
    outputDebugString("t")
    -- Load custom fonts
    loadFonts()

    -- Load client settings
    loadSettings()

    -- Initialize the Gui
    _guiManager = GuiManager()
    _welcomeScreen = WelcomeScreen()
    _characterScreen = CharacterScreen()

    -- Show the welcome screen if the client is not logged in
    if not exports.accounts:isPlayerLoggedIn(localPlayer) then
        _welcomeScreen:setVisible(true, true)
        -- TODO fix this cursor bullshit
        showCursor(true)
    else
        _characterScreen:setVisible(true)
    end
end
addEventHandler("onClientResourceStart", resourceRoot, resourceStart)

addCommandHandler("logout2", function()
    exports.accounts:sendLogoutRequest()
end)

function onClientLogout()
    if source == localPlayer then
        if _characterScreen:isVisible() then 
            _characterScreen:setVisible(false)
        end
        _welcomeScreen:setVisible(true)
    end
end
addEventHandler("onClientPlayerLogout", root, onClientLogout)

function onClientLogin()
    showChat(true)
end
addEventHandler("onClientPlayerLogin", localPlayer, onClientLogin)

function onCharactersLoaded()
    -- Show character screen if not currently visible
    -- Character screen may already be visible if the player just created a new character
    if not _characterScreen:isVisible() then
        _characterScreen:setVisible(true)
    end
end
addEventHandler("onClientCharactersLoaded", localPlayer, onCharactersLoaded)
