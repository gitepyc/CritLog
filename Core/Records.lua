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
--
-- Before any crit of that kind has ever been recorded, the value is DEFAULTS'
-- 0 and the name/target fields are "" - showing those raw would print
-- "Damage crit (): 0 ()", empty parens and all. A placeholder line reads
-- better than that for every kind, not just the two with a name field.
function CritLog.Records.formatRecordText(kind)
    local fields = CritLog.Constants.records[kind]
    local amount = CritLogDB[fields.value]

    if amount == 0 then
        return fields.label..": no crit recorded yet"
    end

    if fields.name then
        return fields.label.." ("..CritLogDB[fields.name].."): "
            ..amount.." ("..CritLogDB[fields.target]..")"
    end
    return fields.label..": "..amount.." ("..CritLogDB[fields.target]..")"
end
