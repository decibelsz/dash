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

    self.idFromLicenseReference[license] = self.idFromLicenseReference[license] or id
    self.sourceFromIdReference[source] = self.sourceFromIdReference[source] or id

    return true
end

function Cache:getIdFromLicense(license)
    return self.idFromLicenseReference[license]
end

function Cache:getSourceFromId(id)
    return self.sourceFromIdReference[id]
end

Cache = Cache()
