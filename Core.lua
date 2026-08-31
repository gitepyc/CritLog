-- Retail moved GetAddOnMetadata to C_AddOns.GetAddOnMetadata; fall back to
-- the older global for clients that don't have C_AddOns yet.
local getAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata

CritLog = {
    -- Single source of truth: read from the TOC instead of duplicating the
    -- version string here.
    version = getAddOnMetadata("CritLog", "Version"),
}

-- Prints a diagnostic message when /cl debug is enabled (off by default).
-- Meant for tracing why a trigger did or didn't fire - e.g. the spell
-- ID/name a trigger actually saw, or how the level filter resolved a
-- target - not for routine user-facing output.
function CritLog:Debug(...)
    if CritLogDB and CritLogDB.DebugFlag then
        print("|cff33ff99CritLog Debug:|r", ...)
    end
end
