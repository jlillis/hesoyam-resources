--
--  GuiManager.lua: implements the Gui manager class.
--
GuiManager = class()

function GuiManager:__constructor()
    self.queue = {}
    --addEventHandler("onClientRender", root, self.render)
end

function GuiManager:__deconstructor()
    return
end

function GuiManager:registerGui(gui)
    if not instanceof(gui, Gui) then
        error("Invalid argument(s) to GuiManager:registerGui()!", 2)
    end

    -- Check if this Gui is already registered
    for i, registeredGui in ipairs(self.queue) do
        if gui == registeredGui then
            outputDebugString("GUIManager:registerGui(): this Gui is already registered.", 2)
            return
        end
    end

    -- Insert this Gui at the top of the queue
    table.insert(self.queue, 1, gui)
end

function GuiManager:removeGui(gui)
    if not instanceof(gui, Gui) then
        error("Invalid argument(s) to GuiManager:removeGui()!", 2)
    end

    -- Remove this Gui from the queue
    for i, registeredGui in ipairs(self.queue) do
        if gui == registeredGui then
            table.remove(self.queue, i)
            return
        end
    end

    -- This Gui isn't registered - output a warning
    outputDebugString("GuiManager:removeGUI(): this Gui isn't registered.", 2)
end

--[[function GuiManager:render()
    return
end]]
