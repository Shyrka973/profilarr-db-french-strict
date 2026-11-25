-- [fork shirka.org] '1080p Quality HDR FR' : 'Lossless Audio' de +1000 a +25 000 (decision Andre, 2026-11-25).
--
-- Priorite d'Andre : un Bluray 1080p avec l'audio de qualite, jamais de 4K, pas de perte sur l'audio de qualite.
-- L'op 917 (+1000) ne suffisait pas : un BluRay x264 sans perte (891 000) perdait encore contre un HDLight
-- AAC x265 (895 200) ; les bonus video et d'equipe (h265/x265 +5000, FR Team Tier 1-4 +1000 a +4000, DV, HDR10+)
-- pesent plus que +1000.
--
-- +25 000 depasse ces combinaisons de bonus d'un release compresse et reste SOUS l'ecart de 30 000 entre
-- '1080p Bluray' (890 000) et '1080p WEB-DL' (860 000) : a bonus egaux, un WEB sans perte ne bat pas un Bluray.
-- minUpgradeFormatScore (500, op 917) n'est pas touche ; aucun autre profil n'est touche.
--
-- Garde : l'UPDATE ne part que de la valeur posee par l'op 917 (1000), pour ne pas ecraser en silence une
-- valeur qu'une op amont poserait un jour (le banc de compilation au merge suivant le montrera).

UPDATE quality_profile_custom_formats
SET score = 25000
WHERE quality_profile_name = '1080p Quality HDR FR'
  AND custom_format_name = 'Lossless Audio'
  AND arr_type = 'all'
  AND score = 1000;
