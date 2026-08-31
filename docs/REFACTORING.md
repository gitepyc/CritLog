# Refactoring-Plan

## Empfehlung

Ja, CritLog sollte in mehrere Dateien aufgeteilt werden – aber nicht als erster
isolierter Schritt. Vorher brauchen wir eine kleine Verhaltenssicherung und
einen zentralen Datenkatalog. Sonst verteilen wir dieselben Hardcodings und
unbemerkten Fehler nur auf mehrere Dateien.

## Empfohlene Reihenfolge

### 1. Verhalten einfrieren

- Die Matrix aus [BEHAVIOR.md](BEHAVIOR.md) als manuelle SoD-Testcheckliste
  verwenden.
- Mindestens Crit-Rekorde, Ready Check, jede Aura-Gruppe, Todesgruppen,
  Raidleiter-Phrasen und beide Soundsets einmal im Spiel prüfen.
- Lua-Fehler mit aktivierter Fehleranzeige protokollieren.
- Entscheiden, welche historischen Sonderfälle erhalten, konfigurierbar gemacht
  oder entfernt werden sollen.

**Abnahme:** Für jeden erwünschten Trigger ist dokumentiert, ob er in Classic
Era `1.15.9` funktioniert und welcher Clip hörbar ist.

### 2. Offensichtliche Defekte in kleinen Commits reparieren

- `divineInt2.mp3`-Auswahl absichern oder fehlenden Clip ergänzen.
- `Tank.mp3`/`Tank1.mp3` und fehlendes `soulstone2.mp3` im Toni-Set klären.
- Soulstone-Zufallsauswahl korrigieren.
- Reset mit `Version` und echter Migration versehen.
- Zielnamen in der Rekordausgabe korrigieren.
- temporäre Variablen lokal machen.

**Abnahme:** Keine Soundauswahl zeigt auf eine fehlende Datei; Reset behält
Einstellungen auch nach `/reload`.

### 3. Daten aus der Logik ziehen

Noch in derselben funktionierenden Ein-Datei-Version zentrale Tabellen
einführen:

```lua
CritLogData = {
  sounds = { ... },
  spells = { ... },
  bosses = { ... },
  playerGroups = { ... },
  chatTriggers = { ... },
}
```

Anschließend sichtbare Namen schrittweise durch Spell- und NPC-IDs ersetzen.
Spielerlisten sollten SavedVariables-Konfiguration statt Quellcode sein.

**Abnahme:** Event-Handler enthalten keine langen Namens- oder
Dateinamenslisten mehr.

### 4. Entlang stabiler Verantwortlichkeiten aufteilen

Empfohlene Zielstruktur:

```text
CritLog/
├── CritLog.toc
├── Core.lua          # Addon-Namespace, Initialisierung, Event-Dispatch
├── Data.lua          # Spell-/NPC-IDs, Defaults, Soundkatalog
├── Database.lua      # Defaults, Schema und Migrationen
├── Sounds.lua        # Auflösen und Abspielen von Sound-IDs
├── CombatLog.lua     # Crits, Auren und Todesfälle
├── ChatTriggers.lua  # Raidleiter-Phrasen
├── Commands.lua      # Slash-Commands
└── Options.lua       # Spätere Einstellungsoberfläche
```

Die Dateien werden in dieser Reihenfolge in `CritLog.toc` geladen. Gemeinsamer
Zustand gehört in einen Addon-Namespace, nicht in neue globale Variablen.

**Abnahme:** Jede Datei hat eine klar benennbare Verantwortung; das beobachtete
Verhalten aus Schritt 1 bleibt gleich.

### 5. Konfiguration professionalisieren

- versioniertes SavedVariables-Schema
- UI für globale Soundgruppen, Lautstärke/Kanal und Spielerrollen
- Auswahl beziehungsweise Vorschau der Clips
- konfigurierbare Chat-Trigger
- sinnvolle Profile: Standard und Toni statt Pfadumschaltung

### 6. Qualität und Release-Prozess

- Lua-Linter und Formatierung
- kleine Tests für reine Funktionen, Migrationen und Trigger-Matching
- Paketierung, die nur tatsächlich benötigte Assets ausliefert
- Versionsnummer aus einer Quelle ableiten
- Changelog und versionierte Releases

## Erster Refactoring-Branch

Der erste Code-Branch sollte daher nicht „Datei aufteilen“, sondern
`refactor/catalog-and-safety` heißen und ausschließlich Folgendes enthalten:

1. zentrale Sound-/Triggertabellen,
2. Schutz vor fehlenden Sounddateien,
3. lokale temporäre Variablen,
4. Reset-/Ausgabefehler,
5. keine bewusst sichtbare Funktionsänderung.

Danach ist das mechanische Aufteilen deutlich sicherer und reviewbarer.
