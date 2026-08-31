# CritLog-Wiki

Diese Dokumentation beschreibt den vorhandenen Stand von CritLog `0.1.1`. Sie
trennt bestätigtes Laufzeitverhalten, statisch aus dem Code abgeleitetes
Verhalten und noch offene Prüfungen.

## Zielsystem

- **Spielmodus:** Season of Discovery
- **Clientfamilie:** WoW Classic Era
- **Clientstand:** `1.15.9`
- **TOC-Interface:** `11509`
- **Praxistest:** Das Addon funktioniert nach Angabe des aktuellen Nutzers in
  diesem Client.

Die Interface-Nummer verhindert primär die Einstufung als „veraltet“. Sie ist
für sich allein kein Nachweis, dass jede verwendete API korrekt arbeitet.

### Verifikation des Interface-Stands

Der Stand `11509` wurde am 31. August 2026 gegen mehrere aktuell gepflegte
Classic-Era-Addons abgeglichen:

- [MoveAny `MoveAny_Vanilla.toc`](https://github.com/d4kir92/MoveAny/blob/main/MoveAny_Vanilla.toc)
- [ApogeePartyHealthBars-Kompatibilitätsangabe](https://github.com/notify353/ApogeePartyHealthBars)
- [BetterBags-Fehlerbericht mit Classic Era/SoD 1.15.9](https://github.com/Cidan/BetterBags/issues/1053)

Für künftige Client-Patches muss der Wert erneut gegen den installierten Client
oder aktuelle Classic-Era-TOCs geprüft werden.

## Seiten

| Seite | Inhalt |
| --- | --- |
| [Verhalten und Auslöser](BEHAVIOR.md) | Was passiert bei welchem Event, welche Bedingungen gelten und welche Sounds können abgespielt werden? |
| [Soundkatalog](SOUNDS.md) | Alle 68 Audiodateien, Code-Verwendung, Varianten, Lücken und Dubletten. |
| [Refactoring-Plan](REFACTORING.md) | Empfohlene Reihenfolge, Modulgrenzen und Abnahmekriterien. |
| [Projekt-README](../README.md) | Installation, Commands, Struktur und bekannte Risiken. |

## Dokumentationsstatus

| Bereich | Status |
| --- | --- |
| Events und registrierte Handler | Aus Code inventarisiert |
| Slash-Commands | Aus Code inventarisiert |
| Sounddateien und technische Metadaten | Vollständig inventarisiert |
| Dateidubletten | Per SHA-256-Inhaltsvergleich geprüft |
| Tatsächliche Wiedergabe aller Trigger in SoD | Noch nicht als Testmatrix protokolliert |
| Inhaltliche Hörprüfung jedes Clips | Offen |
| Urheber- und Nutzungsrechte aller Clips | Offen |

## Pflegegrundsatz

Bei Verhaltensänderungen müssen die betreffende Matrix in `BEHAVIOR.md` und der
Katalog in `SOUNDS.md` im selben Commit aktualisiert werden. Beobachtetes
Verhalten im Spiel sollte mit Clientversion, Charakterklasse und Testschritten
dokumentiert werden.
