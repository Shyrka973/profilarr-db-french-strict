-- [fork shirka.org] Borne haute explicite (1 TiB) sur les 6 custom formats de taille « au-dela de » de l'op 28.
--
-- L'op 28 (compact release size penalties) cree les tranches ouvertes ('> 15 GiB', '> 2 GiB', ...) avec
-- max_bytes = NULL, que le schema documente comme « pas de maximum ». Profilarr 2.3.1 compile pourtant NULL
-- en 'max: 0' (bytesToGb), que Radarr et Sonarr refusent : 'Max' must be greater than '15'. Ces 6 custom
-- formats ne sont donc jamais crees dans les *arr, et les plus grosses releases echappent a la penalite
-- de taille la plus forte (-600 / -700) des profils Compact FR.
--
-- Correctif : 1 TiB (1099511627776 octets) comme borne haute, inatteignable pour une release. Seules les
-- lignes encore a NULL sont touchees : un correctif amont qui poserait sa propre borne reste conserve.
-- Les tranches '<=' (min_bytes NULL) ne sont pas concernees : un minimum a 0 est accepte par les *arr.

UPDATE condition_sizes
SET max_bytes = 1099511627776
WHERE condition_name = 'Size'
  AND max_bytes IS NULL
  AND custom_format_name IN (
    '1080p Compact Movie Size > 15 GiB',
    '1080p Compact Episode Size > 2 GiB',
    '1080p Compact Season Pack Size > 35 GiB',
    '2160p Compact Movie Size > 25 GiB',
    '2160p Compact Episode Size > 5 GiB',
    '2160p Compact Season Pack Size > 50 GiB'
  );
