-- [fork shirka.org] Preference HEVC sur les profils FR deployes.
--
-- La base upstream bannit h265/x265 a -999999 sur les profils FR. Le veto vise les
-- re-encodes anonymes, pas HEVC en soi : le profil non-FR '1080p Compact' recompense
-- '1080p WEB-DL HEVC Tier 1' a +920000 tout en gardant '(Efficient)' a -999999.
--
-- Mesure du 2026-08-22 : Unmanic transcode ~300 fichiers/semaine en hevc_nvenc sur la
-- P400 d'Anakin. Les seules releases HEVC qui entraient encore passaient a la faveur du
-- minFormatScore non applique (grabs a 60-80 points) ; depuis le durcissement, 0 sur 16.
-- Sans cette op, la part de HEVC grabee tend vers zero.
--
-- Calibrage a +5000, choisi sur l'echelle Dictionarry reelle :
--   marqueur individuel le plus fort   +3000  (AMZN, Dolby Vision)   -> domine
--   ecart 1080p WEB-DL / WEBRip       +10000                        -> preserve
--   ecart 1080p Bluray / WEBRip       +20000                        -> preserve
-- HEVC departage donc a source egale, sans jamais faire preferer une source inferieure.
--
-- '(Efficient)' reste a -999999 : ces custom formats ciblent les resolutions < 1080p et
-- servent de garde-fou anti-re-encode. Les neutraliser ouvrirait la porte que le veto ferme.
--
-- Aucun cumul possible : le regex 'h265' ([h][ ._-]?265) et le regex 'x265'
-- (x265|HEVC) sont disjoints, et 'x265 (WEB)' / 'x265 (Bluray)' portent une condition
-- Source mutuellement exclusive. Chaque release ne matche donc qu'un seul de ces formats.

UPDATE quality_profile_custom_formats
SET score = 5000
WHERE quality_profile_name = '1080p Quality HDR FR'
  AND custom_format_name IN ('h265', 'x265 (WEB)', 'x265 (Bluray)');

UPDATE quality_profile_custom_formats
SET score = 5000
WHERE quality_profile_name = '1080p Quality FR'
  AND custom_format_name IN ('h265', 'x265');

UPDATE quality_profile_custom_formats
SET score = 5000
WHERE quality_profile_name = '720p Quality FR'
  AND custom_format_name IN ('h265', 'x265');

UPDATE quality_profile_custom_formats
SET score = 5000
WHERE quality_profile_name = '1080p Compact FR'
  AND custom_format_name IN ('h265', 'x265');

-- Les lignes absentes sont creees ('1080p Compact FR' ne scorait que les '(Efficient)').
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', 5000
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Compact FR'
  AND cf.name IN ('h265', 'x265')
  AND NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats q
    WHERE q.quality_profile_name = qp.name AND q.custom_format_name = cf.name
  );

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', 5000
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Quality HDR FR'
  AND cf.name IN ('h265', 'x265 (WEB)', 'x265 (Bluray)')
  AND NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats q
    WHERE q.quality_profile_name = qp.name AND q.custom_format_name = cf.name
  );

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', 5000
FROM quality_profiles qp, custom_formats cf
WHERE qp.name IN ('1080p Quality FR', '720p Quality FR')
  AND cf.name IN ('h265', 'x265')
  AND NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats q
    WHERE q.quality_profile_name = qp.name AND q.custom_format_name = cf.name
  );
