--
--  WelcomeScreen: implements the welcome screen
--
WelcomeScreen = class(Gui)

function WelcomeScreen:__constructor()
    Gui.__constructor(self)

    self.guiElements.banner = WelcomeBanner()
    self.guiElements.mainMenu = MainMenu()
    self.guiElements.loginMenu = LoginMenu()
    self.guiElements.registrationMenu = RegistrationMenu()

    self:setVisible(false)
end

-- Sets the active welcome screen menu.
-- 0 = main menu, 1 = login menu, 2 = registration menu
function WelcomeScreen:setActiveMenu(menuID)
    outputDebugString("TODO: deprecate setActiveMenu", 2)
    -- Reset the banner message
    self:setBannerMessage()

    if menuID == 0 then
        self.guiElements.loginMenu:setVisible(false)
        self.guiElements.registrationMenu:setVisible(false)
        self.guiElements.mainMenu:setVisible(true)
    elseif menuID == 1 then
        self.guiElements.mainMenu:setVisible(false)
        self.guiElements.registrationMenu:setVisible(false)
        self.guiElements.loginMenu:setVisible(true)
    elseif menuID == 2 then
        self.guiElements.mainMenu:setVisible(false)
        self.guiElements.loginMenu:setVisible(false)
        self.guiElements.registrationMenu:setVisible(true)
    else
        error("Invalid argument(s) to WelcomeScreen:setActiveMenu()!", 2)
    end
end

-- Sets the welcome banner text.
-- If message is nil, the banner will reset to the default message.
-- if isError is true, the banner will turn red.
function WelcomeScreen:setBannerMessage(message, isError)
    if message and type(message) ~= "string" then
        error("Invalid argument(s) to WelcomeScreen:setBannerMessage()!", 2)
    end

    if not message then
        message = "Login to continue."
    end

    self.guiElements.banner.guiElements.text:setText(message)
    if isError then
        self.guiElements.banner.guiElements.text:setColor(unpack(_theme.colors.error))
    else
        self.guiElements.banner.guiElements.text:setColor(unpack(_theme.colors.text))
    end
end

-- Sets the visibility of the welcome screen.
-- allowAutologin: if true, the login menu will be shown and autologin will be atttempted if autologin settings are present
function WelcomeScreen:setVisible(visible, allowAutologin)
    local wasVisible = self:isVisible()

    -- Call parent function
    Gui.setVisible(self, visible)

    if not visible then
        if wasVisible then
            showCursor(false)
        end
        return
    end

    -- Setup black background
    setPlayerHudComponentVisible("all", false)
    showChat(false)
    --fadeCamera(false, 0)

    -- Reset banner text
    self:setBannerMessage()

    -- Hide registration menu
    self.guiElements.registrationMenu:setVisible(false)

    -- Skip the main menu and show the login menu is autologin settings are present
    if allowAutologin and _settings.autologin.token then
        self.guiElements.mainMenu:setVisible(false)
        self.guiElements.loginMenu:setVisible(true, true)
    else
        self.guiElements.loginMenu:setVisible(false)
        self.guiElements.mainMenu:setVisible(true)
    end

    -- Toggle the cursor
    showCursor(visible)
end

--
--  WelcomeBanner: implements the banner at the top of the welcome screen
--
WelcomeBanner = class(Gui)

function WelcomeBanner:__constructor()
    Gui.__constructor(self)

    -- Banner header - "Welcome to San Andreas"
    self.guiElements.header = GuiLabel.create(0.05, 0.05, 1, 0.1, "Welcome to San Andreas", true)
    self.guiElements.header:setFont(_theme.fonts.diploma)
    self.guiElements.header:setColor(unpack(_theme.colors.header))

    -- Banner text - context based (login/registration errors)
    self.guiElements.text = GuiLabel.create(0.075, 0.15, 1, 0.05, "Login to continue.", true, self.guiElements.background)
    self.guiElements.text:setFont(_theme.fonts.futura)
    self.guiElements.text:setColor(unpack(_theme.colors.text))
end

--
--  MainMenu: implements the main menu of the welcome screen
--
MainMenu = class(Gui)

function MainMenu:__constructor()
    Gui.__constructor(self)

    -- Login button
    self.guiElements.loginButton = GuiLabel.create(0.25, 0.4, 0.5, 0.1, "Login", true)
    self.guiElements.loginButton:setFont(_theme.fonts.bank_gothic)
    self.guiElements.loginButton:setColor(unpack(_theme.colors.text))
    self.guiElements.loginButton:setHorizontalAlign("center", false)
    self.guiElements.loginButton:setVerticalAlign("center")
    addEventHandler("onClientMouseEnter", self.guiElements.loginButton, self.onButtonMouseEnter)
    addEventHandler("onClientMouseLeave", self.guiElements.loginButton, self.onButtonMouseLeave)
    addEventHandler("onClientGUIClick", self.guiElements.loginButton, self.onLoginButtonClick)

    -- Registration button
    self.guiElements.registerButton = GuiLabel.create(0.25, 0.5, 0.5, 0.1, "Create Account", true)
    self.guiElements.registerButton:setFont(_theme.fonts.bank_gothic)
    self.guiElements.registerButton:setColor(unpack(_theme.colors.text))
    self.guiElements.registerButton:setHorizontalAlign("center", false)
    self.guiElements.registerButton:setVerticalAlign("center")
    addEventHandler("onClientMouseEnter", self.guiElements.registerButton, self.onButtonMouseEnter)
    addEventHandler("onClientMouseLeave", self.guiElements.registerButton, self.onButtonMouseLeave)
    addEventHandler("onClientGUIClick", self.guiElements.registerButton, self.onRegisterButtonClick)
end

-- Triggered when the cursor enters a main menu button.
function MainMenu:onButtonMouseEnter()
    -- Highlight the button and play menu sound
    source:setColor(unpack(_theme.colors.header))
    playSFX("genrl", 53, 4, false)
end

-- Triggered when the cursor leaves a main menu button.
function MainMenu:onButtonMouseLeave()
    -- Reset the button's color
    source:setColor(unpack(_theme.colors.text))
end

-- Triggered when the main menu login button is clicked.
function MainMenu:onLoginButtonClick()
    -- Play menu sound and switch to the login menu
    playSFX("genrl", 53, 6, false)
    _welcomeScreen:setActiveMenu(1)
end

-- Triggered when the main menu register button is clicked.
function MainMenu:onRegisterButtonClick()
    -- Play menu sound and switch to the registration menu
    playSFX("genrl", 53, 6, false)
    _welcomeScreen:setActiveMenu(2)
end

--
--  LoginMenu: implements the login menu of the welcome screen
--
LoginMenu = class(Gui)

function LoginMenu:__constructor()
    Gui.__constructor(self)

    -- Username field
    self.guiElements.usernameField = GuiEdit.create(0.4, 0.35, 0.2, 0.05, "Username", true)
    self.guiElements.usernameField:setMaxLength(22)
    addEventHandler("onClientGUIFocus", self.guiElements.usernameField, function()
        source:setText("")
        self.autologin = false
    end)
    addEventHandler("onClientGUIBlur", self.guiElements.usernameField, function()
        if source:getText() == "" then
            source:setText("Username")
        end
    end)

    -- Password field
    self.guiElements.passwordField = GuiEdit.create(0.4, 0.425, 0.2, 0.05, "Password", true)
    addEventHandler("onClientGUIFocus", self.guiElements.passwordField, function()
        source:setText("")
        source:setMasked(true)
        self.autologin = false
    end)
    addEventHandler("onClientGUIBlur", self.guiElements.passwordField, function()
        if source:getText() == "" then
            source:setText("Password")
            source:setMasked(false)
        end
    end)

    -- Autologin checkbox
    self.guiElements.autologinCheckBox = GuiCheckBox.create(0.4, 0.5, 0.2, 0.03, "Remember me", false, true)
    self.guiElements.autologinCheckBox:setFont(_theme.fonts.futura)
    -- self.guiElements.autologinCheckBox:setColor(unpack(_theme.colors.text))

    -- Submit button
    self.guiElements.submitButton = GuiLabel.create(0.4, 0.55, 0.2, 0.05, "Submit", true)
    self.guiElements.submitButton:setFont(_theme.fonts.bank_gothic)
    self.guiElements.submitButton:setColor(unpack(_theme.colors.text))
    self.guiElements.submitButton:setHorizontalAlign("center", false)
    self.guiElements.submitButton:setVerticalAlign("center", false)
    addEventHandler("onClientMouseEnter", self.guiElements.submitButton, self.onButtonMouseEnter)
    addEventHandler("onClientMouseLeave", self.guiElements.submitButton, self.onButtonMouseLeave)
    addEventHandler("onClientGUIClick", self.guiElements.submitButton, self.onSubmitButtonClick)

    -- Cancel button
    self.guiElements.cancelButton = GuiLabel.create(0.4, 0.625, 0.2, 0.05, "Cancel", true)
    self.guiElements.cancelButton:setFont(_theme.fonts.bank_gothic)
    self.guiElements.cancelButton:setColor(unpack(_theme.colors.text))
    self.guiElements.cancelButton:setHorizontalAlign("center", false)
    self.guiElements.cancelButton:setVerticalAlign("center", false)
    addEventHandler("onClientMouseEnter", self.guiElements.cancelButton, self.onButtonMouseEnter)
    addEventHandler("onClientMouseLeave", self.guiElements.cancelButton, self.onButtonMouseLeave)
    addEventHandler("onClientGUIClick", self.guiElements.cancelButton, self.onCancelButtonClick)

    -- Autologin flag
    self.autologin = false
end

-- Sets the visibility of the login menu
-- submitAutologin: if true, a login request will be submitted using autologin settings
function LoginMenu:setVisible(visible, submitAutologin)
    -- Call parent function
    Gui.setVisible(self, visible)

    -- Reset editfields if the menu is being hidden
    if not visible then
        self.guiElements.usernameField:setText("Username")
        self.guiElements.passwordField:setText("Password")
        self.guiElements.passwordField:setMasked(false)
        self:setEnabled(true)
        self.autologin = false
    else
        -- Populate fields with autologin data
        if _settings.autologin.username then
            self.guiElements.autologinCheckBox:setSelected(_settings.autologin.username and true or false)
            self.guiElements.usernameField:setText(_settings.autologin.username)
            self.guiElements.passwordField:setMasked(true)
            self.guiElements.passwordField:setText("                                ")
            self.autologin = true
            if submitAutologin then
                self:submitAutologinRequest()
            end
        end
    end
end

-- Triggered when the cursor enters a login menu button.
function LoginMenu:onButtonMouseEnter()
    -- Highlight the button and play menu sound
    source:setColor(unpack(_theme.colors.header))
    playSFX("genrl", 53, 4, false)
end

-- Triggered when the cursor leaves a login menu button.
function LoginMenu:onButtonMouseLeave()
    -- Reset the button's color
    source:setColor(unpack(_theme.colors.text))
end

-- Triggered when the login menu submit button is clicked.
function LoginMenu:onSubmitButtonClick()
    -- TODO: Figure out why 'self' is overwritten with the first argument from an event
    local self = _welcomeScreen.guiElements.loginMenu

    -- Submit autologin request if autologin data is present
    if self.autologin then
        self:submitAutologinRequest()
        return
    end

    local username = self.guiElements.usernameField:getText()
    local password = self.guiElements.passwordField:getText()

    -- Verify all fields
    if username == "Username" or username == "" then
        _welcomeScreen:setBannerMessage("Enter your username.", true)
        playSFX("genrl", 53, 2, false)
        return
    elseif password == "Password" or password == "" then
        _welcomeScreen:setBannerMessage("Enter your password.", true)
        playSFX("genrl", 53, 2, false)
        return
    end

    -- Update banner message and disable the menu
    _welcomeScreen:setBannerMessage("Please wait...", false)
    self:setEnabled(false)

    -- Send the login request and wait for server response
    addEventHandler("onClientLoginResponse", root, self.onLoginResponse)
    exports.accounts:sendLoginRequest("password", username, password)
end

-- Submits an autologin request.
function LoginMenu:submitAutologinRequest()
    -- Update banner message and disable the menu
    _welcomeScreen:setBannerMessage("Please wait...", false)
    self:setEnabled(false)

    -- Send the login request and wait for server response
    addEventHandler("onClientLoginResponse", root, self.onLoginResponse)
    exports.accounts:sendLoginRequest("token", _settings.autologin.token)
end

-- Triggered when the login menu cancel button is clicked.
function LoginMenu:onCancelButtonClick()
    -- Play menu sound and switch to the main menu
    playSFX("genrl", 53, 0, false)
    _welcomeScreen:setActiveMenu(0)
end

-- Triggered when the server responds to a login request.
function LoginMenu:onLoginResponse()
    -- TODO: Figure out why 'self' is overwritten by the first argument of an event
    local responseCode = self
    local self = _welcomeScreen.guiElements.loginMenu

    -- Remove login response handler
    removeEventHandler("onClientLoginResponse", root, self.onLoginResponse)

    -- Update banner message
    if responseCode == 1 then
        _welcomeScreen:setBannerMessage("Login successful!")
        playSFX("genrl", 53, 6, false)

        -- If the autologin checkbox is selected, request a token from the server
        if self.guiElements.autologinCheckBox:getSelected() then
            _settings.autologin.username = self.guiElements.usernameField:getText()
            addEventHandler("onClientTokenResponse", localPlayer, self.onTokenUpdate)
            exports.accounts:sendTokenRequest()
        else
            -- Clear autologin settings
            _settings.autologin.username = false
            _settings.autologin.token = false
            writeSettings()
        end

        _welcomeScreen:setVisible(false)
        return
    elseif responseCode == 2 then
        _welcomeScreen:setBannerMessage("A server error occcured, try again later.", true)
    elseif responseCode == 3 then
        _welcomeScreen:setBannerMessage("Too many failed login attempts, try again later.", true)
    elseif responseCode == 4 then
        _welcomeScreen:setBannerMessage("Invalid username and/or password.", true)
    elseif responseCode == 5 then
        _settings.autologin.username = false
        _settings.autologin.token = false
        writeSettings()
        self.guiElements.usernameField:setText("Username")
        self.guiElements.passwordField:setText("Password")
        self.guiElements.passwordField:setMasked(false)
        self.guiElements.autologinCheckBox:setSelected(false)
        _welcomeScreen:setBannerMessage("Autologin token invalid; please try again.", true)
    end

    -- Re-enable the menu
    self:setEnabled(true)

    -- Play UI sound
    playSFX("genrl", 53, 2, false)
end

-- Triggered when a new token is recieved from the server.
function LoginMenu:onTokenUpdate(token)
    -- TODO: Figure out why 'self' is overwritten by the first argument of an event
    local token = self
    local self = _welcomeScreen.guiElements.loginMenu

    -- Remove token response handler
    removeEventHandler("onClientTokenResponse", localPlayer, self.onTokenUpdate)

    -- Update autologin settings
    if token then
        _settings.autologin.token = token
    else
        _settings.autologin.username = false
        _settings.autologin.token = false
    end
    writeSettings()
end

--
--  RegistrationMenu: implements the registration menu of the welcome screen
--
RegistrationMenu = class(Gui)

function RegistrationMenu:__constructor()
    Gui.__constructor(self)

    -- Username field
    self.guiElements.usernameField = GuiEdit.create(0.4, 0.325, 0.2, 0.05, "Username", true)
    self.guiElements.usernameField:setMaxLength(22)
    addEventHandler("onClientGUIFocus", self.guiElements.usernameField, function()
        source:setText("")
    end)
    addEventHandler("onClientGUIBlur", self.guiElements.usernameField, function()
        if source:getText() == "" then
            source:setText("Username")
        end
    end)

    -- Password field
    self.guiElements.passwordField = GuiEdit.create(0.4, 0.4, 0.2, 0.05, "Password", true)
    addEventHandler("onClientGUIFocus", self.guiElements.passwordField, function()
        source:setText("")
        source:setMasked(true)
    end)
    addEventHandler("onClientGUIBlur", self.guiElements.passwordField, function()
        if source:getText() == "" then
            source:setText("Password")
            source:setMasked(false)
        end
    end)

    -- Verification field
    self.guiElements.verificationField = GuiEdit.create(0.4, 0.475, 0.2, 0.05, "Verify Password", true)
    addEventHandler("onClientGUIFocus", self.guiElements.verificationField, function()
        source:setText("")
        source:setMasked(true)
    end)
    addEventHandler("onClientGUIBlur", self.guiElements.verificationField, function()
        if source:getText() == "" then
            source:setText("Verify Password")
            source:setMasked(false)
        end
    end)

    -- Submit button
    self.guiElements.submitButton = GuiLabel.create(0.4, 0.55, 0.2, 0.05, "Submit", true)
    self.guiElements.submitButton:setFont(_theme.fonts.bank_gothic)
    self.guiElements.submitButton:setColor(unpack(_theme.colors.text))
    self.guiElements.submitButton:setHorizontalAlign("center", false)
    self.guiElements.submitButton:setVerticalAlign("center", false)
    addEventHandler("onClientMouseEnter", self.guiElements.submitButton, self.onButtonMouseEnter)
    addEventHandler("onClientMouseLeave", self.guiElements.submitButton, self.onButtonMouseLeave)
    addEventHandler("onClientGUIClick", self.guiElements.submitButton, self.onSubmitButtonClick)

    -- Cancel button
    self.guiElements.cancelButton = GuiLabel.create(0.4, 0.625, 0.2, 0.05, "Cancel", true)
    self.guiElements.cancelButton:setFont(_theme.fonts.bank_gothic)
    self.guiElements.cancelButton:setColor(unpack(_theme.colors.text))
    self.guiElements.cancelButton:setHorizontalAlign("center", false)
    self.guiElements.cancelButton:setVerticalAlign("center", false)
    addEventHandler("onClientMouseEnter", self.guiElements.cancelButton, self.onButtonMouseEnter)
    addEventHandler("onClientMouseLeave", self.guiElements.cancelButton, self.onButtonMouseLeave)
    addEventHandler("onClientGUIClick", self.guiElements.cancelButton, self.onCancelButtonClick)
end

-- Sets the visibility of the registration menu
function RegistrationMenu:setVisible(visible)
    -- Call parent function (which actually hides the menu)
    Gui.setVisible(self, visible)

    -- Clear the editfield if the menu is being hidden
    if not visible then
        self.guiElements.usernameField:setText("Username")
        self.guiElements.passwordField:setText("Password")
        self.guiElements.passwordField:setMasked(false)
        self.guiElements.verificationField:setText("Verify Password")
        self.guiElements.verificationField:setMasked(false)
    end
end

-- Triggered when the cursor enters a registration menu button.
function RegistrationMenu:onButtonMouseEnter()
    -- Highlight the button and play menu sound
    source:setColor(unpack(_theme.colors.header))
    playSFX("genrl", 53, 4, false)
end

-- Triggered when the cursor leaves a registration menu button.
function RegistrationMenu:onButtonMouseLeave()
    -- Reset the button's color
    source:setColor(unpack(_theme.colors.text))
end

-- Triggered when the registration menu submit button is clicked.
function RegistrationMenu:onSubmitButtonClick()
    -- TODO: Figure out why 'self' is overwritten with the first argument from an event
    local self = _welcomeScreen.guiElements.registrationMenu

    local username = self.guiElements.usernameField:getText()
    local password = self.guiElements.passwordField:getText()
    local passwordVerification = self.guiElements.verificationField:getText()

    -- Verify all fields
    if username == "Username" or username == "" then
        _welcomeScreen:setBannerMessage("Enter a valid username.", true)
        playSFX("genrl", 53, 2, false)
        return
    elseif password == "Password" or password == "" then
        _welcomeScreen:setBannerMessage("Enter a valid password.", true)
        playSFX("genrl", 53, 2, false)
        return
    elseif passwordVerification ~= password then
        _welcomeScreen:setBannerMessage("Your passwords do not match.", true)
        playSFX("genrl", 53, 2, false)
        return
    end

    -- Update banner message and disable the menu
    _welcomeScreen:setBannerMessage("Please wait...", false)
    self:setEnabled(false)

    -- Send the registration request and wait for server response
    addEventHandler("onClientRegistrationResponse", root, self.onRegistrationResponse)
    exports.accounts:sendRegistrationRequest(username, password)
end

-- Triggered when the registration menu cancel button is clicked.
function RegistrationMenu:onCancelButtonClick()
    -- Play menu sound and switch to the main menu
    playSFX("genrl", 53, 0, false)
    _welcomeScreen:setActiveMenu(0)
end

-- Triggered when the server responds to a registration request.
function RegistrationMenu:onRegistrationResponse()
    -- TODO: Figure out why 'self' is overwritten by the first argument of an event
    local responseCode = self
    local self = _welcomeScreen.guiElements.registrationMenu

    -- Remove registration response handler
    removeEventHandler("onClientRegistrationResponse", root, self.onRegistrationResponse)

    -- Re-enable the menu
    self:setEnabled(true)

    -- Update banner message
    if responseCode == 1 then
        _welcomeScreen:setActiveMenu(1)
        _welcomeScreen:setBannerMessage("Registration successful! Login with your new username and password to continue.")
        playSFX("genrl", 53, 6, false)
        return
    elseif responseCode == 2 then
        _welcomeScreen:setBannerMessage("A server error occcured, try again later.", true)
    elseif responseCode == 3 then
        _welcomeScreen:setBannerMessage("Invalid username: usernames can only contain up to 22 letters and numbers.", true)
    elseif responseCode == 4 then
        _welcomeScreen:setBannerMessage("Invalid password: your password must be at least 8 characters long.", true)
    elseif responseCode == 5 then
        _welcomeScreen:setBannerMessage("An account with this username already exists.", true)
    end

    -- Play UI sound
    playSFX("genrl", 53, 2, false)
end
