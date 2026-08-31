-- Retail moved GetAddOnMetadata to C_AddOns.GetAddOnMetadata; fall back to
-- the older global for clients that don't have C_AddOns yet.
local getAddOnMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata

CritLog = {
    -- Single source of truth: read from the TOC instead of duplicating the
    -- version string here.
    version = getAddOnMetadata("CritLog", "Version"),
}
