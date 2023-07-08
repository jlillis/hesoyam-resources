-- Connects the server to the database.
function connectDatabase()
    -- Validate configuration settings - if this fails, cancel resource start
    if not validateConfigurationSettings() then
        cancelEvent(true)
        return
    end

    -- Attempt to connect to the database
    if _config.type == "mysql" then
        local host = string.format("dbname=%s;host=%s;port=%d", _config.name, _config.host, _config.port)
        _database = dbConnect(_config.type, host, _config.username, _config.password)
    else
        _database = dbConnect(_config.type, _config.host)
    end

    -- Check if the connection was successful
    if not _database then
        outputDebugString("Unable to connect to the database - check database settings and restart the database resource.", 1)
    end
end
addEventHandler("onResourceStart", resourceRoot, connectDatabase)

-- Validates the configuration settings defined in config.lua. Errors will be output to the debug console.
-- Returns true if the settings are valid, false otherwise.
function validateConfigurationSettings()
    -- Verify configuration settings exist
    if not _config then
        outputDebugString("Configuration settings missing!", 1)
        return false
    end

    -- Validate database type (either 'sqlite' or 'mysql')
    if not (_config.type == "sqlite" or _config.type == "mysql") then
        outputDebugString("Invalid database type!", 1)
        return false
    end

    -- Validate database host (string)
    if not (type(_config.host) == "string") then
        outputDebugString("Invalid database host!", 1)
        return false
    end

    -- Validate MySQL-specific settings
    if _config.type == "mysql" then
        -- Validate server port (number)
        if not (type(_config.port) == "number") then
            outputDebugString("Invalid database server port!", 1)
            return false
        end
        -- Validate database schema name (string)
        if not (type(_config.name) == "string") then
            outputDebugString("Invalid database schema name!", 1)
            return false
        end
        -- Validate server username and password (string)
        if not (type(_config.username) == "string" and type(_config.password) == "string") then
            outputDebugString("Invalid database credentials!", 1)
            return false
        end
    end

    return true
end

-- Returns the database handle, or false if the database is not connected.
function getDatabase()
    return isElement(_database) and _database or false
end
