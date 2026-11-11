# Traceon-Anbindung · Dispotool Spezialreinigung

Diese kleine Server-Funktion holt alle 5 Minuten die GPS-Dateien vom
Traceon-FTPS-Server, speichert die Fahrzeugpositionen in Supabase und löscht
die übertragenen Dateien danach auf dem Traceon-Server (Wunsch von Traceon).
Das Dispotool liest die Positionen dort aus (Grün-Status, Ankunft und Abfahrt).

Die Zugangsdaten stehen nirgends im Code. Sie werden nur in Vercel als
geschützte Umgebungsvariablen hinterlegt.

## Was gespeichert wird
- Pro Fahrzeug höchstens ein Punkt pro Minute: CSSA-Nummer, Kennzeichen, Zeit, Koordinaten, Tempo.
- **Keine Fahrernamen.** Traceon liefert sie mit, die Funktion lässt sie weg.
- Nur die Fahrzeuge aus `TRACEON_FAHRZEUGE` (z. B. nur die der Spezialreinigung).
- Positionen werden nach 30 Tagen automatisch gelöscht.
- Die Tagesdateien `Triplog_…json` bleiben vorerst auf dem Server liegen,
  bis ihr Format eingebaut ist.

## 1. Supabase
1. Supabase-Projekt öffnen → SQL Editor.
2. `supabase.sql` einfügen, **ohne den letzten Block** («ERST NACH DEM TEST»), ausführen.
3. Unter Project Settings → API Keys notieren: Project URL und Secret Key.

## 2. Vercel
1. Ordner als neues Projekt hochladen (GitHub oder `vercel deploy`).
2. Settings → Environment Variables, Passwort und Keys als «Sensitive» markieren:

| Variable | Wert |
|---|---|
| TRACEON_FTPS_HOST | traceontachoweb.ddns.net |
| TRACEON_FTPS_USER | Benutzername von Traceon |
| TRACEON_FTPS_PASSWORD | Passwort von Traceon |
| TRACEON_FAHRZEUGE | CSSA-Nummern der Spezialreinigung, mit Komma, z. B. `41, 57, 59, 61, 65` |
| TRACEON_TLS_STRICT | 0 (nur falls der Test einen Zertifikatsfehler meldet) |
| SUPABASE_URL | Project URL aus Schritt 1 |
| SUPABASE_SERVICE_KEY | Secret Key aus Schritt 1 |
| CRON_SECRET | langes Zufallswort, z. B. 40 Zeichen |

Optional: `TRACEON_DATEIEN_PRO_LAUF` (Standard 25) und `TRACEON_LOESCHEN=0`,
falls die Dateien auf dem Server vorerst nicht gelöscht werden sollen.

3. Neu deployen.

## 3. Verbindung testen (im Browser)
Diese Adresse im Browser öffnen:

    https://<VERCEL-ADRESSE>/api/traceon-sync?test=1&key=<CRON_SECRET>

Der Test speichert und löscht nichts. Er zeigt, wie viele GPS- und
Triplog-Dateien auf dem Server liegen und welche Fahrzeuge in der neuesten
Datei erkannt wurden. Erscheinen dort eure Spezialreinigungs-Fahrzeuge, ist
alles bereit.

## 4. Automatisch alle 5 Minuten
Im letzten Block von `supabase.sql` `<VERCEL-ADRESSE>` und `<CRON_SECRET>`
ersetzen und ausführen.

Rückstand: Auf dem Server liegen noch die Dateien seit dem 22.10.2026. Pro Lauf
werden 25 Dateien übernommen und gelöscht, die neuesten zuerst. Der Rückstand
ist so nach rund einem Tag abgebaut.

Kontrolle in Supabase: Tabelle `traceon_dateien` füllt sich, Ansicht
`fahrzeug_letzte_position` zeigt pro Fahrzeug die letzte Position.

## Datenschutz
Die Mitarbeitenden vorab informieren, dass die Fahrzeugpositionen für die
Einsatzplanung genutzt werden, nicht zur Leistungs- oder Verhaltenskontrolle.
