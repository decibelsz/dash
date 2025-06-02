local onPlayerConnecting = function(name, setKickReason, deferrals)
    local source = source

    deferrals.defer()
    deferrals.update(config.server.messages.checkingLicense)

    local user = User(source)

    if (not user) then
        return deferrals.done(config.server.messages.error)
    end

    if (config.server.allowList) then -- allowlist ativada
        if (user.allowed == 0) then
            return deferrals.done(config.server.messages.notAllowed)
        end
    end

    if (user.banned == 1) then
        return deferrals.done(config.server.messages.banned)
    end

    deferrals.done()
end
AddEventHandler('playerConnecting', onPlayerConnecting)
