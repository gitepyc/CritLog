# WoW Addons

Dieses Repository enthält private World-of-Warcraft-Addons. Derzeit ist nur
**CritLog** enthalten.

> **Projektstatus:** Funktionierender Legacy-Code / Bestandsaufnahme. CritLog
> wird aktuell mit Season of Discovery im Classic-Era-Client getestet. Version
> `0.1.1` deklariert nun Classic Era `1.15.9` (Interface `11509`).

## Dokumentation

- [Wiki-Startseite](docs/README.md)
- [Verhalten und Auslöser](docs/BEHAVIOR.md)
- [Vollständiger Soundkatalog](docs/SOUNDS.md)
- [Refactoring-Plan](docs/REFACTORING.md)

## Enthaltene Addons

| Addon | Zweck | Status |
| --- | --- | --- |
| [CritLog](CritLog/) | Protokolliert persönliche Höchstwerte für kritische Treffer und Heilungen und spielt ereignisabhängige Sounds ab. | Legacy, Refactoring geplant |

## CritLog installieren

Es gibt aktuell keinen Build- oder Release-Prozess. Für eine manuelle
Installation muss der Ordner `CritLog` direkt im Addon-Verzeichnis des
verwendeten WoW-Clients liegen:

```text
World of Warcraft/
└── <Client>/
    └── Interface/
        └── AddOns/
            └── CritLog/
                ├── CritLog.toc
                ├── CritLog.lua
                └── sounds/
```

Anschließend CritLog in der Addon-Auswahl des Charakters aktivieren. Der aktuell
bestätigte Zielclient ist Season of Discovery auf Classic Era `1.15.9`.

## Aktuelles Verhalten (Kurzfassung)

CritLog registriert vier Ereignisse:

| WoW-Ereignis | Reaktion |
| --- | --- |
| `PLAYER_LOGIN` | Initialisiert die charakterbezogenen Einstellungen und zeigt die gespeicherten Rekorde an. |
| `COMBAT_LOG_EVENT_UNFILTERED` | Erkennt kritischen Zauber-, Distanz- und Nahkampfschaden, kritische Heilungen, ausgewählte Auren sowie Todesfälle. |
| `READY_CHECK` | Spielt bei aktiviertem Schalter einen Sound ab. |
| `CHAT_MSG_RAID_LEADER` | Reagiert auf fest definierte Raidleiter-Phrasen wie `raid end`, `raid ende`, `wipe` und `shit show`. |

Die Höchstwerte und Einstellungen werden pro Charakter in `CritLogDB`
gespeichert (`SavedVariablesPerCharacter`). Standardmäßig sind die meisten
Soundgruppen aktiv. Kritischer Schaden wird nur für das aktuelle Ziel in einem
bestimmten Levelbereich berücksichtigt; `/cl level` deaktiviert diesen Filter.
Die vollständige Matrix aus Ereignis, Bedingung, Einstellung und möglicher
Sounddatei steht unter [Verhalten und Auslöser](docs/BEHAVIOR.md).

### Slash-Commands

Beide Präfixe sind gleichwertig: `/cl` und `/critlog`.

| Command | Aktuelles Verhalten |
| --- | --- |
| `/cl` | Zeigt die gespeicherten Höchstwerte an. |
| `/cl help` | Listet die verfügbaren Befehle im Chat auf. |
| `/cl config` | Zeigt die aktuellen Schalter an. |
| `/cl reset` | Setzt die gespeicherten Höchstwerte zurück und versucht, die Schalter beizubehalten. Siehe bekannte Probleme. |
| `/cl sound` | Schaltet den Sound bei einem neuen Höchstwert um. |
| `/cl allcrits` | Schaltet Sounds für jeden kritischen Treffer um. |
| `/cl whitehit` | Schaltet die Behandlung kritischer Auto-/Distanzangriffe um. |
| `/cl level` | Schaltet den Level-Filter für Schadensrekorde um. |
| `/cl login` | Schaltet den Login-Sound um; die Wiedergabe ist im Code derzeit auskommentiert. |
| `/cl ready` | Schaltet den Ready-Check-Sound um. |
| `/cl aura` | Schaltet Sounds für ausgewählte Auren und Fähigkeiten um. |
| `/cl dead` | Hauptschalter für Todes-Sounds. |
| `/cl player` | Schaltet den Sound beim eigenen Tod um. |
| `/cl melee` | Schaltet Todes-Sounds für hart codierte Nahkämpfer um. |
| `/cl tank` | Schaltet Todes-Sounds für hart codierte Tanks um. |
| `/cl priest` | Schaltet Todes-Sounds für hart codierte Heilpriester um. |
| `/cl boss` | Schaltet Todes-Sounds für hart codierte Bosse um. |
| `/cl toni` | Wechselt auf ein alternatives Sound-Verzeichnis. Die vorhandenen Dateien sind dort nicht vollständig deckungsgleich. |

## Repository-Struktur

```text
wow-addons/
├── README.md
├── docs/                # Wiki: Verhalten, Sounds und Refactoring
└── CritLog/
    ├── CritLog.toc       # WoW-Metadaten und SavedVariables-Deklaration
    ├── CritLog.lua       # Gesamte Ereignis-, Speicher- und Command-Logik
    ├── README.txt        # Historischer Minimalhinweis
    └── sounds/
        ├── assi/         # Alternative Soundauswahl
        └── more sounds/  # Derzeit nicht vom Code verwendete Sounddateien
```

## Inventar der fest verdrahteten Daten

Die folgenden Informationen stehen derzeit direkt in `CritLog.lua` und können
nicht über eine Benutzeroberfläche oder Konfigurationsdatei gepflegt werden:

- Installationspfade und Dateinamen aller verwendeten Sounds
- englische und deutsche Namen ausgewählter Fähigkeiten und Auren
- englische und deutsche Bossnamen aus The Burning Crusade
- Charakternamen für Nahkämpfer, Tanks und Heilpriester
- Sonderbehandlung für den Charakter `Schnutz`
- Raidleiter-Phrasen, die Sounds auslösen
- Grenzwert von neun Leveln für relevante Schadensziele
- Standardwerte aller Funktionsschalter
- Addon-Version, zusätzlich und unabhängig von der TOC-Version

## Bekannte technische Probleme und Risiken

Diese Liste ist eine statische Bestandsaufnahme des aktuellen Codes, keine
vollständige Laufzeitprüfung:

1. **Legacy-Implementierung:** Das Addon funktioniert laut aktuellem Praxistest
   in Season of Discovery. Die Combat-Log-Auswertung stammt dennoch aus einem
   älteren Entwicklungsstand und ist noch nicht systematisch gegen alle
   relevanten SoD-Ereignisse geprüft.
2. **Fehlende Sounddatei:** `divineInt2.mp3` wird in beiden Soundvarianten
   referenziert, ist im Repository aber nicht vorhanden.
3. **Unvollständige alternative Soundauswahl:** `/cl toni` ändert den Basispfad
   für alle Sounds. Im alternativen Ordner fehlen jedoch mehrere der erwarteten
   Dateinamen, darunter `Tank.mp3`, `soulstone2.mp3` und
   `divineInt2.mp3`.
4. **Reset verliert die Schema-Version:** `/cl reset` erstellt `CritLogDB` ohne
   `Version`. Beim nächsten Login erkennt `SetDefaults()` die Daten deshalb als
   veraltet und setzt auch die Konfiguration auf Standardwerte zurück.
5. **Falsche Rekordausgabe:** Bei Zauberschaden und Heilung wird in der
   Zusammenfassung der Fähigkeitsname auch an der Stelle des Zielnamens
   ausgegeben, obwohl separate Zielfelder gespeichert werden.
6. **Zielprüfung ist fragil:** Der Level-Filter verwendet immer das aktuell
   ausgewählte `target`, nicht zwingend das Ziel des Combat-Log-Ereignisses.
   Ohne gültiges Ziel sind außerdem ungültige oder fehlende Levelwerte möglich.
7. **Heilungszweig ist strukturell verdächtig:** Der `SPELL_HEAL`-Zweig hängt
   syntaktisch am Level-Filter statt an der Ereignistyp-Verzweigung. Dadurch
   kann die Erfassung kritischer Heilungen vom aktuellen Ziellevel abhängen.
8. **Globale temporäre Variablen:** Mehrere Hilfswerte (`tmpRNDM`, `result` und
   Reset-Zwischenwerte) werden unbeabsichtigt global angelegt und können mit
   anderem Addon-Code kollidieren.
9. **Lokalisierung über sichtbare Namen:** Fähigkeiten und Bosse werden anhand
   ausgeschriebener deutscher/englischer Namen erkannt. Andere Sprachen,
   Schreibweisen und Clientänderungen werden nicht abgedeckt; Spell-/NPC-IDs
   wären robuster.
10. **Versionsmigration löscht Daten:** Jede Änderung von `CRITLOG_VERSION`
    ersetzt die komplette charakterbezogene Datenbank, statt ein Schema zu
    migrieren.
11. **Unbenutzte und deaktivierte Bestandteile:** Der Login-Sound, Zone-Handler
    und „über 9k“-Sound sind deaktiviert; `more sounds/` wird nicht verwendet.
12. **Keine Qualitätssicherung:** Es existieren bislang keine automatisierten
    Tests, Linter, Paketierung, Releases oder CI-Prüfungen.
13. **Asset-Rechte ungeklärt:** Herkunft und Nutzungsrechte der mitgelieferten
    Audio-Dateien sind nicht dokumentiert. Vor einer öffentlichen
    Veröffentlichung sollte das geklärt werden.

## Sinnvolle nächste Schritte

Der empfohlene Ablauf steht im [Refactoring-Plan](docs/REFACTORING.md). Kurz:
Zuerst Verhalten mit Tests beziehungsweise reproduzierbaren Checks absichern,
dann Daten und Soundkatalog aus dem Code ziehen, anschließend entlang dieser
Grenzen in Module aufteilen. Nur die bestehende 758-Zeilen-Datei mechanisch zu
zerlegen würde die Hardcodings und Fehler lediglich auf mehrere Dateien
verteilen.

## Entwicklung

Es gibt aktuell keine externen Abhängigkeiten und keinen Build-Schritt. Änderungen
werden direkt in `CritLog/CritLog.lua` vorgenommen und müssen im Zielclient
getestet werden. Vor einem Release müssen die Versionen in `CritLog.lua` und
`CritLog.toc` derzeit manuell synchron gehalten werden.

## Lizenz

Für Quellcode und Audio-Assets ist derzeit keine Lizenz angegeben. Bis dies
geklärt ist, dürfen daraus keine Nutzungsrechte abgeleitet werden.
