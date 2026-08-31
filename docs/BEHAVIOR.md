# Verhalten und Auslöser

Diese Seite beschreibt, wann CritLog aktiv wird und welche Sounddateien der
aktuelle Code anfordert. „Normal“ bezeichnet `CritLog/sounds/`, „Toni“ das mit
`/cl toni` aktivierte Verzeichnis `CritLog/sounds/assi/`.

## Ereignisfluss

```text
WoW-Event
  -> registrierter CritLog-Handler
  -> Konfigurationsschalter und fest codierte Bedingung
  -> Datenbankänderung und/oder Chat-Ausgabe
  -> PlaySoundFile(<aktiver Soundpfad>/<Dateiname>, "Master")
```

Alle Sounds werden über den `Master`-Audiokanal abgespielt. CritLog regelt keine
eigene Lautstärke.

## Login und Ready Check

| Event | Bedingung | Wirkung | Sound normal | Sound Toni |
| --- | --- | --- | --- | --- |
| `PLAYER_LOGIN` | Immer | Initialisiert/migriert `CritLogDB` und zeigt Rekorde. | Kein Sound; Code für `Login.mp3` ist auskommentiert und die Datei fehlt im normalen Set. | Kein Sound; `Login.mp3` existiert, der Code ist aber auskommentiert. |
| `READY_CHECK` | `ReadySoundFlag = true` | Keine Datenänderung. | `Ready.mp3` | `Ready.mp3` (inhaltlich identisch) |

## Kritische Treffer und Heilungen

Die Erkennung läuft über `COMBAT_LOG_EVENT_UNFILTERED`. Schadensereignisse
müssen vom eigenen Spieler stammen. Der Level-Filter vergleicht allerdings das
aktuell ausgewählte Ziel und nicht zuverlässig das Ziel des Combat-Log-Events.

| Combat-Log-Typ | Bedingung | Datenänderung | Soundbedingung | Sound |
| --- | --- | --- | --- | --- |
| `SPELL_DAMAGE` | Eigener Spieler, kritischer Treffer, Level-Filter erfüllt | Aktualisiert höchsten Fähigkeits-Crit, Fähigkeit und Ziel. | Bei jedem Crit, wenn `/cl allcrits` aktiv ist; zusätzlich bei neuem Rekord. | `at_bam_babam.mp3` |
| `SWING_DAMAGE` | Eigener Spieler, kritischer Treffer, Level-Filter erfüllt | Aktualisiert höchsten White-Hit-Crit und Ziel. | Bei jedem Crit, wenn `/cl allcrits` und `/cl whitehit` aktiv sind; bei neuem Rekord, wenn `/cl whitehit` aktiv ist. | `at_bam_babam.mp3` |
| `RANGE_DAMAGE` | Eigener Spieler, kritischer Treffer, Level-Filter erfüllt | Wird im White-Hit-Rekord gespeichert. | Bei jedem Crit mit `/cl allcrits`; bei neuem Rekord mit `/cl whitehit`. | `at_bam_babam.mp3` |
| `SPELL_HEAL` | Kritische Heilung; aufgrund der aktuellen Verzweigung potenziell vom Ziellevel abhängig | Aktualisiert höchsten Heil-Crit, Fähigkeit und Ziel. | Bei jedem Crit mit `/cl allcrits`; zusätzlich bei neuem Rekord. | `at_bam_babam.mp3` |

`/cl sound` ist der Hauptschalter für `at_bam_babam.mp3`. Er unterdrückt den
Clip auch dann, wenn die oben genannten Einzelbedingungen erfüllt sind.

## Auren und Fähigkeiten

Diese Gruppe ist nur aktiv, wenn `/cl aura` eingeschaltet ist. Der Code erkennt
ausgeschriebene deutsche oder englische Zaubernamen, keine Spell-IDs.

| Auslöser | Ziel-/Quellenbedingung | Erkannte Namen | Gewählter Sound |
| --- | --- | --- | --- |
| Mana Tide Totem beschworen (`SPELL_SUMMON`) | Quelle wird als Gruppen- oder Raidmitglied erkannt. | `Mana Tide Totem`, `Totem der Manaflut` | `Manatide.mp3` |
| Bloodlust/Heroism erhalten (`SPELL_AURA_APPLIED`) | Ziel ist der eigene Spieler. | `Bloodlust`, `Heroism`, `Blutrausch`, `Heldentum` | `Bloodlust.mp3` |
| Innervate erhalten | Ziel ist der eigene Spieler. | `Innervate`, `Anregen` | Zufällig `Inervate1.mp3` oder `Inervate2.mp3` |
| Power Infusion erhalten | Ziel ist der eigene Spieler. | `Power Infusion`, `Seele der Macht` | Zufällig `Surprise.mp3`, `Surprise2.mp3` oder `Surprise3.mp3` |
| Blessing of Protection erhalten | Ziel ist der eigene Spieler. | `Blessing of Protection`, `Segen des Schutzes` | `Bubble.mp3` |
| Divine Intervention erhalten | Ziel ist der eigene Spieler. | `Divine Intervention`, `Göttliches Eingreifen` | Zufällig `divineInt.mp3` oder das fehlende `divineInt2.mp3` |
| Soulstone Resurrection erhalten | Ziel ist der eigene Spieler. | `Soulstone Resurrection`, `Seelenstein Auferstehung` | Zufällig `soulstone.mp3` oder `soulstone2.mp3`; `soulstone3.mp3` steht zwar in der Liste, wird wegen `math.random(1, 2)` nie gewählt. |

## Todesfälle

Alle folgenden Reaktionen benötigen `DeadSoundFlag = true` (`/cl dead`). Die
jeweilige Untergruppe hat zusätzlich einen eigenen Schalter.

| Verstorbenes Ziel | Weitere Bedingung | Sound normal | Sound Toni |
| --- | --- | --- | --- |
| Eigener Spieler | `/cl player` aktiv | `MarioDeath.mp3` | `MarioDeath.mp3` |
| Charakter `Schnutz` | `/cl melee` aktiv | `schnutz.mp3` | `schnutz.mp3` |
| Anderer Name aus `MELEE_NAMES` | `/cl melee` aktiv | `wilhelm.ogg` | `wilhelm.ogg` |
| Englischer/deutscher Name aus der TBC-Bossliste | `/cl boss` aktiv | Zufällig `FFX.mp3` oder `Zelda.mp3` | Dieselben Dateien |
| Name aus `TANK_NAMES` | `/cl tank` aktiv | Zufällig `Tank.mp3` oder `Tank2.mp3` | `Tank2.mp3` funktioniert; `Tank.mp3` fehlt, weil dort nur `Tank1.mp3` vorhanden ist. |
| Name aus `HEALPRIEST_NAMES` | `/cl priest` aktiv | Zufällig `Angels1.mp3` oder `Angels2.mp3` | Dieselben Dateien |

Die Namenslisten sind fest im Lua-Code hinterlegt. Rollen werden nicht aus der
Gruppe oder dem Raid ermittelt.

## Raidleiter-Chat

Der Absender muss lediglich über `CHAT_MSG_RAID_LEADER` eintreffen. Eine früher
vorgesehene Prüfung auf einen bestimmten Namen ist auskommentiert.

| Nachricht, ohne Beachtung der Groß-/Kleinschreibung | Reaktion |
| --- | --- |
| `raid ende` oder `raid end` | Startet unmittelbar nacheinander `bye.mp3` und `end.mp3`. Die Clips können sich überlagern. |
| `shit show` oder `wipe` | Spielt `wipe.mp3`. |

Diese Chat-Sounds haben keinen eigenen Konfigurationsschalter und werden auch
nicht durch `/cl sound` oder `/cl dead` deaktiviert.

## Sonstige Codepfade

| Funktion | Status |
| --- | --- |
| Boss-Killing-Blow-Ausgabe | Bei einem passenden Bossnamen und einem `_DAMAGE`-Event mit positivem fünften Payload-Wert wird eine Chatzeile ausgegeben. Die positionsabhängige Auswertung ist je nach Eventtyp fragil. |
| Login-Sound | Auskommentiert. |
| „Über 9k“-Sound `Xtreme.mp3` | Vollständig auskommentiert; im normalen Soundset fehlt die Datei. |
| Zone-Logging | Handler vorhanden, Event nicht registriert. |
| Spirit of Redemption | Testcode auskommentiert und als nicht funktionierend kommentiert. |

## Gespeicherte Daten

`CritLogDB` wird pro Charakter gespeichert:

- höchster Fähigkeits-Schadens-Crit mit Fähigkeit und Ziel
- höchster White-Hit-/Distanz-Crit mit Ziel
- höchster Heil-Crit mit Fähigkeit und Ziel
- alle Command-Schalter
- aktiver Soundpfad
- interne Addon-Version

Die aktuellen Probleme bei Reset, Versionswechsel und Ausgabe sind in der
[Projekt-README](../README.md#bekannte-technische-probleme-und-risiken)
inventarisiert.
