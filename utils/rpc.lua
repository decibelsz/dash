local isServer = IsDuplicityVersion()
local emitNet = isServer and TriggerClientEvent or TriggerServerEvent
local subscribe = isServer and RegisterServerEvent or RegisterNetEvent
local defaultSyncOptions = { nosync = false }

---@param options table
---@param defaults table
local function mergeOptions(options, defaults)
    options = options or {}
    for k, v in pairs(defaults) do
        if options[k] == nil then
            options[k] = v
        end
    end
    return options
end

---@class RpcClass
---@field callbacks table<string,function>
---@field pending table<number, promise>
---@field name string
---@field uuid UuidClass
rpc = { callbacks = {}, pending = {}, name = '' } -- rpc class 

---@class UuidClass
---@field max number
---@field ids table
uuid = { max = 0, ids = {} } -- id generator class

function uuid.new()
    local self = setmetatable({
        max = 0,
        ids = {}
    }, { __index = uuid })

    return self
end

function uuid:gen()
    if #self.ids > 0 then
        return table.remove(self.ids)
    end

    self.max = self.max +  1
    return self.max
end

---@param id number
function uuid:free(id)
    self.ids[#self.ids+1] = id
end

---@param name string
function rpc.new(name)
    local self = setmetatable({
        name = name,
        callbacks = {},
        pending = {},
        uuid =  uuid.new()
    }, { __index = rpc })

    self:listener()

    return self
end

---@param name string
---@param callback function
function rpc:createCallback(name, callback)
    self.callbacks[name] = callback
end

---@param syncOptions table
---@param name string
---@param ... any
function rpc:call(syncOptions, name, ...)
    if type(syncOptions) ~= "table" then
        name, syncOptions = syncOptions, {}
    end

    syncOptions = mergeOptions(syncOptions or {}, defaultSyncOptions)

    local response = promise.new()
    local uuid = self.uuid:gen()

    local params = { ... }
    local args = isServer and { params[1], uuid, name, table.unpack(params, 2) } or { uuid, name, table.unpack(params) }

    emitNet(('connection-%s:request'):format(self.name), table.unpack(args))

    if syncOptions.nosync then
        return self.uuid:free(uuid)
    end

    if syncOptions.timeout then 
        SetTimeout(syncOptions.timeout * 1000, function()
            if not self.pending[uuid] then 
                return
            end

            self.uuid:free(uuid)
            self.pending[uuid]:resolve('timeout')
            self.pending[uuid] = nil
        end)
    end

    self.pending[uuid] = response

    return table.unpack(Citizen.Await(response))
end

function rpc:listener()
    subscribe(('connection-%s:request'):format(self.name), function(uuid, name, ...)
        local source = source
        local callback = self.callbacks[name]

        if not ( callback and type(callback) == 'function' ) then
            return
        end
        
        local response = table.pack(callback(...))

        if #response == 0 then 
            return
        end

        local resume = isServer and { source, uuid, response }  or { uuid, response }

        emitNet(('connection-%s:response'):format(self.name), table.unpack(resume))
    end)

    subscribe(('connection-%s:response'):format(self.name), function(uuid, params)
        local response = self.pending[uuid]

        if not response then
            return
        end

        response:resolve(params)
        self.uuid:free(uuid)
        self.pending[uuid] = nil
    end)
end