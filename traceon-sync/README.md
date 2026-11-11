# traceon-sync

Traceon-Anbindung für das Dispotool der Spezialreinigung, Clean Service Scaramuzzo AG.

Holt alle 5 Minuten die GPS-Dateien vom Traceon-FTPS-Server, speichert die
Fahrzeugpositionen in Supabase und löscht die übertragenen Dateien danach.

- Code: `api/traceon-sync.js` (Vercel Serverless Function, Node 18+)
- Datenbank: `supabase.sql`
- Einrichtung Schritt für Schritt: [ANLEITUNG.md](ANLEITUNG.md)

Zugangsdaten gehören nie in dieses Repository, nur in die Umgebungsvariablen bei Vercel.
