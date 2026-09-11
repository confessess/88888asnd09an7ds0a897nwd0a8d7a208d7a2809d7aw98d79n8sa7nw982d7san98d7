local chain = getgenv().__BLACKOUT_CHAIN
if not chain or chain.stage ~= 2 or chain.token ~= "b1a9c3e7f2d4a6e8" then
    warn("[Blackout] Access denied — invalid loader chain")
    return
end
getgenv().__BLACKOUT_CHAIN = nil

if getgenv().__BLACKOUT_LOADED then
    warn("[Blackout] Already loaded")
    return
end
getgenv().__BLACKOUT_LOADED = true