-- Default client settings
_settings = {
    autologin = {
        username = false,
        token = false,
    },
}

-- Loads settings from the local settings file. Returns true if succesful, false otherwise.
function loadSettings()
    local xml = XML.load("@settings.xml")
    if not xml then
        writeSettings()
    else
        for name, attributes in pairs(_settings) do
            local node = xml:findChild(name, 0)

            for attribute, _ in pairs(attributes) do
                local value = node:getAttribute(attribute)
                if value then
                    _settings[name][attribute] = value
                end
            end
        end

        xml:unload()
    end
end

-- Writes the settings to the client settings file. If the settings file does not exist, a new one will be created.
function writeSettings()
    local xml = XML.load("@settings.xml")
    if not xml then
        xml = XML.create("@settings.xml", "settings")
    end

    for name, attributes in pairs(_settings) do
        local node = xml:findChild(name, 0)
        if not node then
            node = xml:createChild(name)
        end

        for attribute, value in pairs(attributes) do
            if not value then
                node:setAttribute(attribute, nil)
            else
                node:setAttribute(attribute, value)
            end
        end
    end

    xml:saveFile()
    xml:unload()
end
