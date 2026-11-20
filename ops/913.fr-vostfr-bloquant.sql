-- [fork shirka.org] 'French VOSTFR' devient BLOQUANT (-999999) dans les profils francais qui le penalisent.
--
-- Constat du 2026-11-20 : un release 'Tu.ne.tueras.point.2016.1080p.BluRay.FR.SUBS.x264-GRP' (sous-titres
-- francais, donc une VOSTFR) est bien reconnu 'French VOSTFR' depuis l'op 912, mais score encore 690 000 dans
-- '1080p Quality HDR FR', au-dessus du minimum de 20 000. Le parseur de LANGUE des *arr lit 'FR' dans le titre
-- comme du francais : 'Not French (strict)' (op 906) ne se declenche pas, et la seule penalite restante est
-- celle de 'French VOSTFR' (-200 000), trop faible face aux scores de qualite et de team.
--
-- Correctif : 'French VOSTFR' passe de -200 000 a -999 999 partout ou il valait une penalite d'exclusion
-- (<= -200 000), soit 12 profils : les 11 profils FR stricts et '2160p Compact FR' (langue Any, sans
-- 'Not French (strict)', mais francais par construction). Ne sont PAS touches :
--   - '1080p Compact VO' et 'Anime 1080p VOSTFR FR' (0) : la VO sous-titree est leur raison d'etre ;
--   - 'Anime 1080p FR' (-30 000) : ordre voulu en amont (MULTi / Original > VOSTFR > VF), la VOSTFR y reste
--     un repli accepte.
--
-- Idempotente : ne modifie que les lignes encore au-dessus de -999 999.

UPDATE quality_profile_custom_formats
SET score = -999999
WHERE custom_format_name = 'French VOSTFR'
  AND score <= -200000
  AND score > -999999;
