-- Pure highscore-record rules: no WoW API calls, no CritLogDB writes - just
-- reading/comparing already-known values. Same reasoning as Filters.lua.
CritLog.Records = {}

function CritLog.Records.isNewHighscore(amount, current)
    return amount > current
end

-- One line of "<label> (<ability>): <amount> (<target>)", or without the
-- ability part for white-hit crits (no named ability to show). Reads
-- CritLogDB directly (the current stored value), but makes no WoW API calls
-- and writes nothing - used by both the options panel and could be reused
-- anywhere else that needs the same display text.
function CritLog.Records.formatRecordText(kind)
    local fields = CritLog.Constants.records[kind]
    if fields.name then
        return fields.label.." ("..CritLogDB[fields.name].."): "
            ..CritLogDB[fields.value].." ("..CritLogDB[fields.target]..")"
    end
    return fields.label..": "..CritLogDB[fields.value].." ("..CritLogDB[fields.target]..")"
end
