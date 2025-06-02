Cache = class()

function Cache:__init()
    self.idFromLicenseReference = {}
    self.sourceFromIdReference = {}
    self.userData = {}
end

function Cache:createReference(license, source, id)
    if not license or not source or not id then
        return false
    end

    --[[
    create a license and a source reference in the cache for this user
    so we can easily access the user data later
    return false to indicate that we are referencing this user for the first time
    return true to indicate that we already have a reference for this user in the cache
    this will help us avoid creating updating references for the same user
    ]]
    if (self.idFromLicenseReference[license] and self.sourceFromIdReference[source]) then -- player source and license already referenced
        return true
    end

    self.idFromLicenseReference[license] = self.idFromLicenseReference[license] or id
    self.sourceFromIdReference[source]   = self.sourceFromIdReference[source] or id

    return false
end

function Cache:getIdFromLicense(license)
    return self.idFromLicenseReference[license]
end

function Cache:getIdFromSource(source)
    return self.sourceFromIdReference[source]
end

function Cache:setUserData(source, key, data)
    local id = self:getIdFromSource(source)

    if not id then
        return false
    end

    self.userData[id] = self.userData[id] or {}

    if type(key) == 'table' then
        for k, v in pairs(key) do
            self.userData[id][k] = v
        end
    else
        self.userData[id][key] = data
    end

    return true
end

function Cache:getUserData(source, key)
    if (not source or not key) then
        return false
    end

    local id = self:getIdFromSource(source)

    if not id then
        return false
    end

    if not self.userData[id] then
        return false
    end

    if not self.userData[id][key] then
        return false
    end

    return self.userData[id][key]
end

function Cache:getCachedDataFromSource(source)
    if not source then
        return false
    end

    local id = self:getIdFromSource(source)

    if not id then
        return false
    end

    return self.userData[id] or false
end

function Cache:getAllDataFromId(id)
    return self.userData[id]
end

Cache = Cache()
