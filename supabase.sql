-- Traceon-Anbindung Dispotool Spezialreinigung
-- Im Supabase-Projekt unter «SQL Editor» ausführen. Den letzten Block erst nach dem Test.

create table if not exists public.fahrzeug_positionen (
  id           bigint generated always as identity primary key,
  fahrzeug_nr  int         not null,          -- CSSA-Nummer, z. B. 41
  kennzeichen  text,                          -- z. B. «SH 52 620»
  geraet       text,                          -- Traceon HirotID
  zeit         timestamptz not null,
  lat          double precision not null,
  lng          double precision not null,
  tempo        real,                          -- km/h
  datei        text,
  eingelesen   timestamptz not null default now(),
  unique (fahrzeug_nr, zeit)
);
create index if not exists fahrzeug_positionen_zeit on public.fahrzeug_positionen (fahrzeug_nr, zeit desc);

create table if not exists public.traceon_dateien (
  name        text primary key,
  eintraege   int,
  verarbeitet timestamptz
);

-- Letzte Position pro Fahrzeug (liest später das Dispotool)
create or replace view public.fahrzeug_letzte_position as
select distinct on (fahrzeug_nr) fahrzeug_nr, kennzeichen, zeit, lat, lng, tempo
from public.fahrzeug_positionen
order by fahrzeug_nr, zeit desc;

-- Nur der Server (Secret Key) darf schreiben und lesen
alter table public.fahrzeug_positionen enable row level security;
alter table public.traceon_dateien     enable row level security;

-- Datenschutz: Positionen nach 30 Tagen, Dateiliste nach 7 Tagen löschen (jede Nacht 03:15 UTC)
create extension if not exists pg_cron;
select cron.schedule('traceon-aufraeumen', '15 3 * * *', $$
  delete from public.fahrzeug_positionen where zeit < now() - interval '30 days';
  delete from public.traceon_dateien where verarbeitet < now() - interval '7 days';
$$);

-- ===== ERST NACH DEM ERFOLGREICHEN TEST AUSFÜHREN =====
-- Abgleich alle 5 Minuten rund um die Uhr (holt auch den Rückstand ab).
-- <VERCEL-ADRESSE> und <CRON_SECRET> vor dem Ausführen ersetzen.
create extension if not exists pg_net;
select cron.schedule('traceon-abgleich', '*/5 * * * *',
  $$select net.http_get(
      url := 'https://<VERCEL-ADRESSE>/api/traceon-sync',
      headers := jsonb_build_object('Authorization', 'Bearer <CRON_SECRET>'),
      timeout_milliseconds := 55000)$$);
