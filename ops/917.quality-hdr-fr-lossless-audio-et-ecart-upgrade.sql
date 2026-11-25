-- [fork shirka.org] '1080p Quality HDR FR' : 'Lossless Audio' a +1000 et ecart minimal d'upgrade a 500 (decision Andre, 2026-11-25).
--
-- Motif (cas fondateur, Radarr film 693 'Men in Black International') : un release
-- 'MULTI.VFF.1080p.BluRay.HDLight.AAC.5.1.x265' scorait 895 200 contre 895 004 pour le BluRay en place
-- (DTS-HD MA, sans perte, 5,7 Go). Dans ce profil, 'AAC' vaut +200 alors que 'Lossless Audio' n'y est pas
-- lie (score 0) : un son compresse battait le sans-perte, et l'ecart de 196 passait le minimum d'upgrade de 5.
-- ~33 remplacements de ce type (sans perte -> compresse) depuis le 2026-10-01.
--
-- (1) 'Lossless Audio' (TrueHD, DTS-HD MA, DTS-X, PCM, hors 2160p) a +1000 : au-dessus de tous les codecs
--     compresses du profil (FLAC 800, Opus 700, DTS-HD HRA 700, Dolby Digital + 600, DTS-ES 500,
--     Dolby Atmos 400, Dolby Digital 400, DTS 300, AAC 200).
-- (2) upgrade_score_increment (= minUpgradeFormatScore des *arr) de 5 a 500 : un ecart de quelques
--     centaines de points (codec audio, freeleech, repack) ne declenche plus a lui seul un remplacement.
--
-- Seul ce profil est touche. Gardes : l'INSERT ne joue que si le couple (profil, CF) n'existe pas ; les
-- UPDATE ne partent que des valeurs relues le 2026-11-25 (0 et 5), pour ne pas ecraser en silence une valeur
-- qu'une op amont poserait un jour (le banc de compilation au merge suivant le montrera).

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT '1080p Quality HDR FR', 'Lossless Audio', 'all', 1000
WHERE EXISTS (SELECT 1 FROM quality_profiles WHERE name = '1080p Quality HDR FR')
  AND EXISTS (SELECT 1 FROM custom_formats WHERE name = 'Lossless Audio')
  AND NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats
    WHERE quality_profile_name = '1080p Quality HDR FR' AND custom_format_name = 'Lossless Audio'
  );

UPDATE quality_profile_custom_formats
SET score = 1000
WHERE quality_profile_name = '1080p Quality HDR FR'
  AND custom_format_name = 'Lossless Audio'
  AND arr_type = 'all'
  AND score = 0;

UPDATE quality_profiles
SET upgrade_score_increment = 500
WHERE name = '1080p Quality HDR FR'
  AND upgrade_score_increment = 5;
