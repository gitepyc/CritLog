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

-- Colored variant, shared between the main options panel's own highscore
-- display (UI/MainPanel.lua) and the TitanPanel tooltip (UI/TitanButton.lua)
-- - both want the same "spell/target/amount stand out" styling, in-game
-- requested to apply it in both places rather than just Titan. Kept as a
-- second function (not a parameter on formatRecordText) so chat's plain
-- /cl output and the Help panel stay untouched - nobody asked those to
-- look different.
--
-- Still being iterated on in-game ("sieht besser aus jetzt aber noch
-- nicht gut") - these hex values are not final, expect further tweaks.
CritLog.Records.NORMAL_COLOR = "|cffcc9900"
CritLog.Records.SPELL_COLOR = "|cff3399ff"
CritLog.Records.TARGET_COLOR = "|cff339933"

local function colored(color, text)
    return color..text.."|r"
end
CritLog.Records.colored = colored

-- Amount colored by a rough "hotter = bigger" heat scale (green -> yellow ->
-- amber -> orange -> orange-red -> red -> dark red). Thresholds are a
-- reasonable guess, not measured against real data. The top tier reuses
-- 9000 - the same "extreme hit" threshold XtremeSoundFlag already sounds
-- on - so the color scale's hottest step lines up with that existing
-- concept instead of being an arbitrary new number.
-- Same threshold as the heat scale's top tier (also the existing Xtreme-hit
-- sound threshold) - exposed separately so UI code can bold just the amount
-- text without duplicating the magic number. Bold can't be embedded in the
-- colored string itself (no inline bold escape code in WoW's text engine,
-- unlike |cAARRGGBB...|r for color) - it's a FontString-level font property,
-- so callers need this as a plain boolean to decide whether to switch that
-- FontString to an outlined font, not something Records.lua (no WoW API
-- calls) can do itself.
function CritLog.Records.isExtremeAmount(amount)
    return amount >= 9000
end

function CritLog.Records.amountColor(amount)
    if amount >= 9000 then
        return "|cffcc0000" -- dark red
    elseif amount >= 7000 then
        return "|cffff4040" -- red
    elseif amount >= 6000 then
        return "|cffff5020" -- orange-red
    elseif amount >= 4500 then
        return "|cffff8000" -- orange
    elseif amount >= 3000 then
        return "|cffffbf00" -- amber
    elseif amount >= 1500 then
        return "|cffffff00" -- yellow
    end
    return "|cff40ff40" -- green
end

function CritLog.Records.formatRecordTextColored(kind, index)
    local fields = CritLog.Constants.recordKinds[kind]
    local entry = CritLogDB.records[kind][index]

    if not entry then
        return colored(CritLog.Records.NORMAL_COLOR, fields.label..": no record yet")
    end

    local amountText = colored(CritLog.Records.amountColor(entry.amount), tostring(entry.amount))
    local targetText = colored(CritLog.Records.TARGET_COLOR, entry.target)

    if fields.hasName then
        local spellText = colored(CritLog.Records.SPELL_COLOR, entry.name)
        return colored(CritLog.Records.NORMAL_COLOR, fields.label.." (")..spellText
            ..colored(CritLog.Records.NORMAL_COLOR, "): ")..amountText
            ..colored(CritLog.Records.NORMAL_COLOR, " (")..targetText
            ..colored(CritLog.Records.NORMAL_COLOR, ")")
    end
    return colored(CritLog.Records.NORMAL_COLOR, fields.label..": ")..amountText
        ..colored(CritLog.Records.NORMAL_COLOR, " (")..targetText
        ..colored(CritLog.Records.NORMAL_COLOR, ")")
end
