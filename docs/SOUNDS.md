# Soundkatalog

## Überblick

Der Katalog umfasst **68 Dateien** mit insgesamt rund **5,58 MB**:

| Verzeichnis | Zweck im aktuellen Code |
| --- | --- |
| `CritLog/sounds/` | Standard-Soundset |
| `CritLog/sounds/assi/` | Alternatives „Toni“-Soundset, aktiviert mit `/cl toni` |
| `CritLog/sounds/more sounds/` | Reserve; keine Datei wird aktuell referenziert |

Technisch vorhanden sind 66 MP3- und 2 OGG-Dateien. Dauer und Bitrate stammen
aus den Windows-Audiometadaten; leere Werte bedeuten, dass Windows für die Datei
keine Metadaten geliefert hat. „Verwendet“ beschreibt ausschließlich die
Erreichbarkeit im aktuellen Code, nicht eine bestätigte Hörprobe.

## Vom Code angeforderte Sounds

| Logische Funktion | Dateiname | Auslöser | Auswahl |
| --- | --- | --- | --- |
| Crit/Rekord | `at_bam_babam.mp3` | Kritischer Treffer oder neue Bestleistung | Fest |
| Ready Check | `Ready.mp3` | `READY_CHECK` | Fest |
| Mana Tide | `Manatide.mp3` | Mana Tide Totem eines Gruppenmitglieds | Fest |
| Bloodlust | `Bloodlust.mp3` | Bloodlust/Heroism auf dem Spieler | Fest |
| Innervate | `Inervate1.mp3`, `Inervate2.mp3` | Innervate auf dem Spieler | Zufällig 1/2 |
| Power Infusion | `Surprise.mp3` bis `Surprise3.mp3` | Power Infusion auf dem Spieler | Zufällig 1/3 |
| Blessing of Protection | `Bubble.mp3` | Blessing of Protection auf dem Spieler | Fest |
| Divine Intervention | `divineInt.mp3`, `divineInt2.mp3` | Divine Intervention auf dem Spieler | Zufällig 1/2; zweite Datei fehlt |
| Soulstone | `soulstone.mp3`, `soulstone2.mp3` | Soulstone Resurrection auf dem Spieler | Zufällig 1/2; `soulstone3.mp3` wird nie gewählt |
| Eigener Tod | `MarioDeath.mp3` | Spieler stirbt | Fest |
| Bestimmter Nahkämpfer | `schnutz.mp3` | `Schnutz` stirbt | Fest |
| Andere Nahkämpfer | `wilhelm.ogg` | Name aus fester Nahkämpferliste stirbt | Fest |
| Tanktod | `Tank.mp3`, `Tank2.mp3` | Name aus fester Tankliste stirbt | Zufällig 1/2 |
| Heilpriestertod | `Angels1.mp3`, `Angels2.mp3` | Name aus fester Priesterliste stirbt | Zufällig 1/2 |
| Bosstod | `FFX.mp3`, `Zelda.mp3` | Name aus fester Bossliste stirbt | Zufällig 1/2 |
| Raidende | `bye.mp3`, danach `end.mp3` | Passende Raidleiter-Nachricht | Beide unmittelbar |
| Wipe | `wipe.mp3` | Passende Raidleiter-Nachricht | Fest |
| Login | `Login.mp3` | Login | Deaktivierter Code |
| Extremhit | `Xtreme.mp3` | Schaden über 9.000 | Deaktivierter Code |

Details zu sämtlichen Bedingungen stehen in [BEHAVIOR.md](BEHAVIOR.md).

## Standard-Soundset

| Datei | Dauer | Bitrate | Größe | Status |
| --- | ---: | ---: | ---: | --- |
| `Angels1.mp3` | 5 s | 178 kbps | 121.680 B | Verwendet: Heilpriestertod |
| `Angels2.mp3` | 6 s | 192 kbps | 161.568 B | Verwendet: Heilpriestertod |
| `at_bam_babam.mp3` | 1 s | 128 kbps | 17.553 B | Verwendet: Crit/Rekord |
| `Bloodlust.mp3` | 2 s | 128 kbps | 38.496 B | Verwendet: Bloodlust/Heroism |
| `Bubble.mp3` | 3 s | 128 kbps | 60.247 B | Verwendet: Blessing of Protection |
| `bye.mp3` | 1 s | 128 kbps | 20.925 B | Verwendet: Raidende, erster Clip |
| `divineInt.mp3` | 4 s | 128 kbps | 66.486 B | Verwendet: Divine Intervention |
| `end.mp3` | 15 s | 128 kbps | 247.766 B | Verwendet: Raidende, zweiter Clip |
| `FFX.mp3` | 4 s | 128 kbps | 67.495 B | Verwendet: Bosstod |
| `Inervate1.mp3` | 1 s | 64 kbps | 17.052 B | Verwendet: Innervate |
| `Inervate2.mp3` | <1 s | 320 kbps | 36.745 B | Verwendet: Innervate |
| `Manatide.mp3` | 4 s | 128 kbps | 77.321 B | Verwendet: Mana Tide Totem |
| `MarioDeath.mp3` | 9 s | 192 kbps | 250.524 B | Verwendet: eigener Tod |
| `Ready.mp3` | 1 s | 128 kbps | 30.336 B | Verwendet: Ready Check |
| `schnutz.mp3` | 1 s | 128 kbps | 120.496 B | Verwendet: Sonderfall `Schnutz` |
| `soulstone.mp3` | 1 s | 128 kbps | 26.487 B | Verwendet: Soulstone |
| `soulstone2.mp3` | 6 s | 128 kbps | 97.939 B | Verwendet: Soulstone |
| `soulstone3.mp3` | 2 s | 192 kbps | 52.402 B | Geladen in Liste, durch Zufallsgrenze nie ausgewählt |
| `Surprise.mp3` | 3 s | 128 kbps | 58.180 B | Verwendet: Power Infusion |
| `Surprise2.mp3` | 2 s | 128 kbps | 32.181 B | Verwendet: Power Infusion |
| `Surprise3.mp3` | 2 s | 128 kbps | 37.632 B | Verwendet: Power Infusion |
| `Tank.mp3` | 1 s | 184 kbps | 28.267 B | Verwendet: Tanktod |
| `Tank2.mp3` | 3 s | 74 kbps | 29.950 B | Verwendet: Tanktod |
| `wilhelm.ogg` | n/a | n/a | 12.524 B | Verwendet: Nahkämpfertod |
| `wipe.mp3` | 10 s | 234 kbps | 298.605 B | Verwendet: Wipe-Chatphrase |
| `Zelda.mp3` | 2 s | 128 kbps | 42.630 B | Verwendet: Bosstod |

Im Standardset fehlen `divineInt2.mp3` und das nur in deaktiviertem Code
vorgesehene `Login.mp3`. `Xtreme.mp3` fehlt ebenfalls, ist aber nur in
auskommentiertem Code referenziert.

## Alternatives „Toni“-Soundset (`assi/`)

| Datei | Dauer | Bitrate | Größe | Status |
| --- | ---: | ---: | ---: | --- |
| `Angels1.mp3` | 5 s | 178 kbps | 121.680 B | Verwendet; identisch zum Standard |
| `Angels2.mp3` | 6 s | 192 kbps | 161.568 B | Verwendet; identisch zum Standard |
| `at_bam_babam.mp3` | 1 s | 128 kbps | 17.553 B | Verwendet; identisch zum Standard |
| `Bloodlust.mp3` | 3 s | 128 kbps | 56.134 B | Verwendet; alternative Datei |
| `Bubble.mp3` | 1 s | 128 kbps | 27.305 B | Verwendet; alternative Datei |
| `bye.mp3` | 4 s | 128 kbps | 66.980 B | Verwendet; alternative Datei |
| `divineInt.mp3` | 4 s | 128 kbps | 66.486 B | Verwendet; identisch zum Standard |
| `end.mp3` | 9 s | 160 kbps | 183.508 B | Verwendet; alternative Datei |
| `FFX.mp3` | 4 s | 128 kbps | 67.495 B | Verwendet; identisch zum Standard |
| `Inervate1.mp3` | 2 s | 128 kbps | 37.305 B | Verwendet; alternative Datei |
| `Inervate2.mp3` | 2 s | 128 kbps | 47.754 B | Verwendet; alternative Datei |
| `Login.mp3` | 3 s | 192 kbps | 77.574 B | Vorhanden, Wiedergabe auskommentiert |
| `Manatide.mp3` | 2 s | 320 kbps | 82.684 B | Verwendet; alternative Datei |
| `MarioDeath.mp3` | 2 s | 128 kbps | 37.305 B | Verwendet; alternative Datei |
| `Ready.mp3` | 1 s | 128 kbps | 30.336 B | Verwendet; identisch zum Standard |
| `schnutz.mp3` | 1 s | 128 kbps | 22.676 B | Verwendet; alternative Datei |
| `soulstone.mp3` | 1 s | 128 kbps | 26.487 B | Verwendet; identisch zum Standard |
| `soulstone3.mp3` | 2 s | 192 kbps | 52.402 B | Vorhanden, durch Zufallsgrenze nie ausgewählt |
| `Surprise.mp3` | 5 s | 128 kbps | 83.280 B | Verwendet; identisch zu den beiden folgenden Dateien |
| `Surprise2.mp3` | 5 s | 128 kbps | 83.280 B | Verwendet; Dublette |
| `Surprise3.mp3` | 5 s | 128 kbps | 83.280 B | Verwendet; Dublette |
| `Tank1.mp3` | 1 s | 128 kbps | 31.763 B | Nicht erreichbar: Code fordert `Tank.mp3` an |
| `Tank2.mp3` | 1 s | 128 kbps | 31.763 B | Verwendet; identisch zu `Tank1.mp3` |
| `wilhelm.ogg` | n/a | n/a | 12.524 B | Verwendet; identisch zum Standard |
| `wipe.mp3` | 10 s | 234 kbps | 298.605 B | Verwendet; identisch zum Standard und zur Reservekopie |
| `Xtreme.mp3` | 2 s | 128 kbps | 42.214 B | Vorhanden, Codepfad auskommentiert |
| `Zelda.mp3` | 2 s | 128 kbps | 42.630 B | Verwendet; identisch zum Standard |

Im Toni-Set fehlen die vom aktiven Code angeforderten Dateien `Tank.mp3`,
`divineInt2.mp3` und `soulstone2.mp3`.

## Reserve (`more sounds/`)

Keine dieser Dateien wird im aktuellen Lua-Code referenziert.

| Datei | Dauer | Bitrate | Größe |
| --- | ---: | ---: | ---: |
| `Bloodlust2.mp3` | 2 s | 102 kbps | 35.564 B |
| `Bloodlust3.mp3` | 3 s | 192 kbps | 84.774 B |
| `Bloodlust4.mp3` | 14 s | 128 kbps | 233.358 B |
| `jok.mp3` | n/a | n/a | 88.770 B |
| `knock.mp3` | 5 s | 128 kbps | 92.984 B |
| `Login2.mp3` | 9 s | 192 kbps | 237.653 B |
| `Login3.mp3` | 1 s | 128 kbps | 19.296 B |
| `Login4.mp3` | 8 s | 163 kbps | 164.928 B |
| `Login5.mp3` | 7 s | 128 kbps | 115.806 B |
| `Login6.mp3` | 3 s | 192 kbps | 75.996 B |
| `luffy-senpai.mp3` | 3 s | 320 kbps | 129.611 B |
| `m1.mp3` | <1 s | 128 kbps | 9.957 B |
| `m2.mp3` | 1 s | 132 kbps | 20.863 B |
| `wipe.mp3` | 10 s | 234 kbps | 298.605 B |
| `Wololooo.mp3` | 1 s | 128 kbps | 26.330 B |

## Inhaltsgleiche Dateien

Per SHA-256 wurden folgende identische Inhalte gefunden:

- Standard und Toni: `Angels1.mp3`, `Angels2.mp3`, `at_bam_babam.mp3`,
  `divineInt.mp3`, `FFX.mp3`, `Ready.mp3`, `soulstone.mp3`,
  `soulstone3.mp3`, `wilhelm.ogg` und `Zelda.mp3`
- `wipe.mp3` ist in Standard, Toni und Reserve identisch.
- Im Toni-Set sind `Surprise.mp3`, `Surprise2.mp3` und `Surprise3.mp3`
  untereinander identisch.
- Im Toni-Set sind `Tank1.mp3` und `Tank2.mp3` identisch.

## Noch erforderlicher menschlicher Review

Die technische und codebezogene Inventur ist abgeschlossen. Vor Bereinigung
oder Veröffentlichung müssen alle Clips noch tatsächlich angehört und je Datei
folgende Punkte entschieden werden:

- verständliche inhaltliche Beschreibung statt nur historischer Dateiname
- gewünschte Lautstärke und akzeptable Länge im Spiel
- Sprache sowie potenziell beleidigender oder nicht mehr gewünschter Inhalt
- Quelle, Urheber, Lizenz und Erlaubnis zur Weiterverteilung
- behalten, ersetzen, nur privat verwenden oder löschen

Bis dieser Hör- und Rechte-Review erfolgt ist, dürfen Dateinamen nicht als
verlässliche Inhaltsbeschreibung und vorhandene Dateien nicht als freigegebene
Assets verstanden werden.
