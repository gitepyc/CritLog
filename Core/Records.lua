-- Pure highscore-record rules: no WoW API calls, no CritLogDB writes - just
-- reading/comparing already-known values. Same reasoning as Filters.lua.
CritLog.Records = {}

function CritLog.Records.isNewHighscore(amount, current)
    return amount > current
end

-- One line of "<label> (<ability>): <amount> (<target>)" for the entry at
-- `index` (1 = highest) in a category's list, or without the ability part
-- for white-hit crits (no named ability to show). Reads CritLogDB
-- directly, but makes no WoW API calls and writes nothing - used by both
-- Commands.lua's chat printout and the options panel so both describe a
-- record the same way.
--
-- A slot with no entry yet (e.g. index 3 before a character has 3 crits of
-- that kind recorded) gets a placeholder line instead of erroring on a nil
-- table index.
function CritLog.Records.formatRecordText(kind, index)
    local fields = CritLog.Constants.recordKinds[kind]
    local entry = CritLogDB.records[kind][index]

    if not entry then
        return fields.label..": no record yet"
    end

    if fields.hasName then
        return fields.label.." ("..entry.name.."): "..entry.amount.." ("..entry.target..")"
    end
    return fields.label..": "..entry.amount.." ("..entry.target..")"
end
