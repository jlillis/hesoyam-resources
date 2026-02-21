--
--  Gui: Implements a generic gui class
--
Gui = class()

function Gui:__constructor()
    self.guiElements = {}
    self.visible = true
    _guiManager:registerGui(self)
end

function Gui:__deconstructor()
    _guiManager:removeGui(self)
end

-- Toggles the visibility of the Gui and all GuiElements belonging to it
function Gui:setVisible(visible)
    if self.visible == visible then
        return
    end

    for _, guiElement in pairs(self.guiElements) do
        guiElement:setVisible(visible)
    end

    self.visible = visible
end

-- Returns true if the Gui is visible, false otherwise.
function Gui:isVisible()
    return self.visible
end

-- Enables/disables the Gui and all GuiElements belonging to it
function Gui:setEnabled(enabled)
    if self.enabled == enabled then
        return
    end

    for _, guiElement in pairs(self.guiElements) do
        guiElement:setEnabled(enabled)
    end

    self.enabled = enabled
end

-- Returns true if the Gui is enabled, false otherwise.
function Gui:isEnabled()
    return self.enabled
end
