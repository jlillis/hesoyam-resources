--
-- Lua object model implementation
-- Based on https://github.com/ShiraNai7/lua-object-model
--

--- Class table factory
--
-- @param parent class definition to inherit from
-- @return class table
function class(parent)
    local class = {}

    -- process the parent
    if parent then
        -- create a shallow copy of the parent class
        for i, v in pairs(parent) do
            class[i] = v
        end

        class.__parent = parent
    end

    -- the class will be the metatable for all its instances
    -- and they will look up their methods in it
    class.__index = class

    if not parent then
        class.__gc = objectGarbageCollect
    end

    if parent then
        class.super = super
    end

    -- create a meta table for the class
    -- too hook the <class>(<args>) mechanism
    local meta = {
        __call = new
    }
    setmetatable(class, meta)

    return class
end

--- Create an instance of the given class
--
-- @param class the class being constructed
-- @param ...   constructor arguments
-- @return table the object
function new(class, ...)
    local object = {}

    setmetatable(object, class)

    -- invoke constructor of the class
    if class.__constructor then
        class.__constructor(object, ...)
    end

    return object
end

--- See if an object is an instance of the given class
--
-- @param object         the object to verify
-- @param classToCompare the class to compare against
-- @return boolean
function instanceof(object, classToCompare)
    local class = getmetatable(object)

    while class do
        if class == classToCompare then
            return true
        end

        class = class.__parent
    end

    return false
end

--- Invoke a parent method
--
-- @param object     the current object
-- @param methodName the parent method name
-- @param ...        arguments for the parent method
-- @return the return value(s) of the parent method
function super(object, methodName, ...)
    -- init super call scope table on first use
    if nil == object.__superScope then
        object.__superScope = {}
    end

    -- switch to the next parent class
    local currentParent = object.__superScope[methodName]
    local nextParent

    if nil ~= currentParent then
        nextParent = currentParent.__parent;
    else
        nextParent = object.__parent;
    end

    object.__superScope[methodName] = nextParent

    -- call the parent method
    local results = {pcall(nextParent[methodName], object, ...)}
    local success = table.remove(results, 1)

    -- restore previous parent class
    object.__superScope[methodName] = currentParent

    -- handle call results
    if not success then
        error(results[1])
    end

    return unpack(results)
end

--- Object destructor handler
--
-- This is the __gc implementation and should not be called manually.
--
-- @param object instance that is being destructed
local function objectGarbageCollect(object)
    if object.__destructor then
        object:__destructor()
    end
end
