--
--  CharacterScreen: implements the character screen
--
CharacterScreen = class(Gui)

function CharacterScreen:__constructor()
    Gui.__constructor(self)

    self.guiElements.selectionMenu = CharacterSelectionMenu()
    self.guiElements.creationMenu = CharacterCreationMenu()

    self:setVisible(false)
end

function CharacterScreen:setVisible(visible, creationMode)
    local creationMode, wasVisible = creationMode and true or false, self:isVisible()

    -- Call parent function
    Gui.setVisible(self, visible)

    if not visible then
        if wasVisible then
            showCursor(false)
        end
        return
    end

    -- Setup background
    setPlayerHudComponentVisible("all", false)
    showChat(false)
    fadeCamera(false, 0)
    setCameraMatrix(0, 6, 5, 0, 0, 3, 0, 70)
    fadeCamera(true)

    -- Activate the creation menu if creationMode was requested
    self.guiElements.selectionMenu:setVisible(not creationMode)
    self.guiElements.creationMenu:setVisible(creationMode)

    -- Toggle the cursor
    showCursor(visible)
end

--
--  Character selection menu
--
CharacterSelectionMenu = class(Gui)

function CharacterSelectionMenu:__constructor()
    Gui.__constructor(self)

    -- Main window
    self.guiElements.window = GuiWindow.create(0.05, 0.3, 0.25, 0.4, "Characters", true)
    self.guiElements.window:setMovable(false)
    self.guiElements.window:setSizable(false)
    --guiSetProperty(self.guiElements.window, "CloseButtonEnabled", "False")
    --guiSetProperty(self.guiElements.window, "TitlebarEnabled", "False")

    self.guiElements.createOption = GuiLabel.create(0.1, 0.1, 0.8, 0.1, "Create new", true, self.guiElements.window)
    self.guiElements.createOption:setFont(_theme.fonts.futura)
    self.guiElements.createOption:setColor(unpack(_theme.colors.text))
    addEventHandler("onClientMouseEnter", self.guiElements.createOption, self.onButtonMouseEnter, false)
    addEventHandler("onClientMouseLeave", self.guiElements.createOption, self.onButtonMouseLeave, false)
    addEventHandler("onClientGUIClick", self.guiElements.createOption, self.onCreateButtonClick, false)

    self.guiElements.charactersGridList = GuiGridList.create(0.1, 0.2, 0.8, 0.5, true, self.guiElements.window)
    local column = self.guiElements.charactersGridList:addColumn("ID", 0.3)
    local column = self.guiElements.charactersGridList:addColumn("Name", 0.7)
    --self.guiElements.charactersGridList:addColumn("Model name", 0.75)
    --[[for _, character in ipairs(exports.characters:getPlayerCharacterData()) do
        local row = self.guiElements.charactersGridList:addRow(character.id)
        self.guiElements.charactersGridList:setItemData(row, column, character.id)
        --self.guiElements.charactersGridList:setItemData(row, column, character.name)
    end]]
    addEventHandler("onClientGUIClick", self.guiElements.charactersGridList, self.onCharactersGridListClick, false)

    self.guiElements.selectOption = GuiLabel.create(0.1, 0.75, 0.8, 0.1, "Continue", true, self.guiElements.window)
    self.guiElements.selectOption:setFont(_theme.fonts.futura)
    self.guiElements.selectOption:setColor(unpack(_theme.colors.text))
    addEventHandler("onClientMouseEnter", self.guiElements.selectOption, self.onButtonMouseEnter, false)
    addEventHandler("onClientMouseLeave", self.guiElements.selectOption, self.onButtonMouseLeave, false)
    addEventHandler("onClientGUIClick", self.guiElements.selectOption, self.onSelectButtonClick, false)

    self.guiElements.logoutOption = GuiLabel.create(0.1, 0.85, 0.8, 0.1, "Logout", true, self.guiElements.window)
    self.guiElements.logoutOption:setFont(_theme.fonts.futura)
    self.guiElements.logoutOption:setColor(unpack(_theme.colors.text))
    addEventHandler("onClientMouseEnter", self.guiElements.logoutOption, self.onButtonMouseEnter, false)
    addEventHandler("onClientMouseLeave", self.guiElements.logoutOption, self.onButtonMouseLeave, false)
    addEventHandler("onClientGUIClick", self.guiElements.logoutOption, self.onLogoutButtonClick, false)
end

function CharacterSelectionMenu:setVisible(visible)
    -- Call parent function
    Gui.setVisible(self, visible)

    if visible then
        self.guiElements.charactersGridList:clear()
        for _, character in ipairs(exports.characters:getPlayerCharacterData()) do
            local row = self.guiElements.charactersGridList:addRow(character.id, character.name)
            self.guiElements.charactersGridList:setItemData(row, 1, character.id)
            self.guiElements.charactersGridList:setItemData(row, 2, character.id)
        end
        self.guiElements.selectOption:setVisible(false)
    else
        if isElement(self.previewPed) then
            destroyElement(self.previewPed)
        end
    end

    self:setEnabled(visible)
end

function CharacterSelectionMenu:onButtonMouseEnter()
    source:setColor(unpack(_theme.colors.header))
    playSFX("genrl", 53, 4, false)
end

function CharacterSelectionMenu:onButtonMouseLeave()
    source:setColor(unpack(_theme.colors.text))
end

function CharacterSelectionMenu:onCreateButtonClick()
    playSFX("genrl", 53, 6, false)
    _characterScreen.guiElements.selectionMenu:setVisible(false)
    _characterScreen.guiElements.creationMenu:setVisible(true)
end

function CharacterSelectionMenu:onCharactersGridListClick()
    local self = _characterScreen.guiElements.selectionMenu
    if isElement(self.previewPed) then
        destroyElement(self.previewPed)
    end
    local row, column = self.guiElements.charactersGridList:getSelectedItem()
    if not (row >= 0 and column >= 0) then
        self.guiElements.selectOption:setVisible(false)
        self.guiElements.selectOption:setVisible(false)
        return
    else
        iprint(row, column)
        local characterID = self.guiElements.charactersGridList:getItemData(row, column)
        local characters = exports.characters:getPlayerCharacterData()
        local selectedCharacter
        for _, character in ipairs(characters) do
            if character.id == characterID then
                selectedCharacter = character
            end
        end
        self.previewPed = createPed(selectedCharacter.model_id, 0, 0, 3)
        self.guiElements.selectOption:setVisible(true)
    end
end

function CharacterSelectionMenu:onSelectButtonClick()
    local self = _characterScreen.guiElements.selectionMenu
    playSFX("genrl", 53, 6, false)

    local row, column = self.guiElements.charactersGridList:getSelectedItem()
    local characterID = self.guiElements.charactersGridList:getItemData(row, column)
    local characters = exports.characters:getPlayerCharacterData()
    local selectedCharacter
    for _, character in ipairs(characters) do
        if character.id == characterID then
            selectedCharacter = character
        end
    end
    self.guiElements.window:setEnabled(false)

    -- Send the spawn request and wait for server response
    addEventHandler("onClientSpawnResponse", root, self.onSpawnResponse)
    exports.characters:sendSpawnRequest(selectedCharacter.id)
end

function CharacterSelectionMenu:onLogoutButtonClick()
    playSFX("genrl", 53, 6, false)
    exports.accounts:sendLogoutRequest()
end

function CharacterSelectionMenu:onSpawnResponse(responseCode)
    -- TODO: Figure out why 'self' is overwritten by the first argument of this event
    responseCode = self
    local self = _characterScreen.guiElements.selectionMenu

    removeEventHandler("onClientSpawnResponse", root, self.onSpawnResponse)
    
    if responseCode == 1 then
        _characterScreen:setVisible(false)
        fadeCamera(false)
        setTimer(function()
            setCameraTarget(localPlayer)
            showChat(true)
            setPlayerHudComponentVisible("all", true)
            fadeCamera(true)
        end, 1000, 1, false)
    else
        self:setEnabled(true)
    end
end

--
--  Character creation menu
--
CharacterCreationMenu = class(Gui)

function CharacterCreationMenu:__constructor()
    Gui.__constructor(self)

    -- Main window
    self.guiElements.window = GuiWindow.create(0.05, 0.3, 0.25, 0.4, "Create character", true)
    self.guiElements.window:setMovable(false)
    self.guiElements.window:setSizable(false)
    --guiSetProperty(self.guiElements.window, "CloseButtonEnabled", "False")
    --guiSetProperty(self.guiElements.window, "TitlebarEnabled", "False")

    self.guiElements.nameFieldLabel = GuiLabel.create(0.1, 0.1, 0.8, 0.1, "Character name:", true, self.guiElements.window)
    self.guiElements.nameFieldLabel:setFont(_theme.fonts.futura)

    self.guiElements.nameField = GuiEdit.create(0.1, 0.2, 0.8, 0.1, "", true, self.guiElements.window)

    self.guiElements.modelFieldLabel = GuiLabel.create(0.1, 0.35, 0.8, 0.1, "Model:", true, self.guiElements.window)
    self.guiElements.modelFieldLabel:setFont(_theme.fonts.futura)

    self.guiElements.modelGridList = GuiGridList.create(0.1, 0.45, 0.8, 0.4, true, self.guiElements.window)
    local column = self.guiElements.modelGridList:addColumn("ID", 0.9)
    --self.guiElements.modelGridList:addColumn("Model name", 0.75)
    for _, modelID in ipairs(getValidPedModels()) do
        local row = self.guiElements.modelGridList:addRow(modelID)
        self.guiElements.modelGridList:setItemData(row, column, modelID)
    end
    addEventHandler("onClientGUIClick", self.guiElements.modelGridList, self.onModelGridListClick, false)

    self.guiElements.submitButton = GuiLabel.create(0.1, 0.875, 0.4, 0.1, "Create", true, self.guiElements.window)
    self.guiElements.submitButton:setHorizontalAlign("center")
    self.guiElements.submitButton:setFont(_theme.fonts.futura)
    self.guiElements.submitButton:setColor(unpack(_theme.colors.text))
    addEventHandler("onClientMouseEnter", self.guiElements.submitButton, self.onButtonMouseEnter, false)
    addEventHandler("onClientMouseLeave", self.guiElements.submitButton, self.onButtonMouseLeave, false)
    addEventHandler("onClientGUIClick", self.guiElements.submitButton, self.onCreateButtonClick, false)

    self.guiElements.cancelButton = GuiLabel.create(0.5, 0.875, 0.4, 0.1, "Cancel", true, self.guiElements.window)
    self.guiElements.cancelButton:setHorizontalAlign("center")
    self.guiElements.cancelButton:setFont(_theme.fonts.futura)
    self.guiElements.cancelButton:setColor(unpack(_theme.colors.text))
    addEventHandler("onClientMouseEnter", self.guiElements.cancelButton, self.onButtonMouseEnter, false)
    addEventHandler("onClientMouseLeave", self.guiElements.cancelButton, self.onButtonMouseLeave, false)
    addEventHandler("onClientGUIClick", self.guiElements.cancelButton, self.onCancelButtonClick, false)

    self.previewPed = false
end

function CharacterCreationMenu:setVisible(visible)
    -- Call parent function
    Gui.setVisible(self, visible)

    if visible then
        self.previewPed = createPed(0, 0, 0, 3)
    else
        if isElement(self.previewPed) then
            destroyElement(self.previewPed)
        end
    end

    self:setEnabled(visible)
end

function CharacterCreationMenu:onButtonMouseEnter()
    source:setColor(unpack(_theme.colors.header))
    playSFX("genrl", 53, 4, false)
end

function CharacterCreationMenu:onButtonMouseLeave()
    source:setColor(unpack(_theme.colors.text))
end

function CharacterCreationMenu:onCreateButtonClick()
    playSFX("genrl", 53, 6, false)
    local self = _characterScreen.guiElements.creationMenu
    self:setEnabled(false)

    local characterName = self.guiElements.nameField:getText()
    local row, column = self.guiElements.modelGridList:getSelectedItem()
    if not (row and column) then
        return
    end
    local modelID = self.guiElements.modelGridList:getItemData(row, column)

    addEventHandler("onCharacterCreationResponse", root, self.onCreationResponse)
    exports.characters:sendCreationRequest(characterName, modelID, clothingOptions, initialSpawnpoint)
end

function CharacterCreationMenu:onCancelButtonClick()
    playSFX("genrl", 53, 6, false)
    _characterScreen.guiElements.creationMenu:setVisible(false)
    _characterScreen.guiElements.selectionMenu:setVisible(true)
end

function CharacterCreationMenu:onModelGridListClick()
    local self = _characterScreen.guiElements.creationMenu
    local row, column = self.guiElements.modelGridList:getSelectedItem()
    if not (row and column) then
        return
    end
    local modelID = self.guiElements.modelGridList:getItemData(row, column)
    self.previewPed:setModel(modelID)
end

function CharacterCreationMenu:onCreationResponse(newCharacterID)
    -- TODO: Figure out why 'self' is overwritten by the first argument of this event
    local responseCode = self
    local self = _characterScreen.guiElements.creationMenu
    iprint("CLIENT ", responseCode, newCharacterID)

    if responseCode == 1 then
        fadeCamera(false, 0)
        self:setVisible(false)
        self.newCharacterID = newCharacterID
        addEventHandler("onClientCharactersLoaded", root, self.onCharactersLoaded)
    else
        self:setEnabled(true)
    end

    removeEventHandler("onCharacterCreationResponse", root, self.onCreationResponse)
end

function CharacterCreationMenu:onCharactersLoaded()
    iprint("onCharactersLoaded")
    local self = _characterScreen.guiElements.creationMenu
    removeEventHandler("onClientCharactersLoaded", root, self.onCharactersLoaded)
    addEventHandler("onClientSpawnResponse", root, self.onSpawnResponse)
    exports.characters:sendSpawnRequest(self.newCharacterID)
end

function CharacterCreationMenu:onSpawnResponse()
    local self = _characterScreen.guiElements.creationMenu
    removeEventHandler("onClientSpawnResponse", root, self.onSpawnResponse)

    _characterScreen:setVisible(false)
    fadeCamera(false)
    setTimer(function()
        setCameraTarget(localPlayer)
        showChat(true)
        setPlayerHudComponentVisible("all", true)
        fadeCamera(true)
    end, 1000, 1, false)
end