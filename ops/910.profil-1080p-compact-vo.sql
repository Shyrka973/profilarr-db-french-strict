-- [fork shirka.org] Profil '1080p Compact VO' pour les oeuvres sans doublage francais (VO sous-titree).
--
-- Besoin du 2026-11-19 : la serie coreenne « 100 Days of Deception » (Sonarr id 292) n'existe qu'en coreen ou
-- en anglais. Sur '1080p Compact FR', les 22 releases de l'episode 1 sont toutes rejetees par
-- 'Not French (strict)' (op 906) et 'French Missing'. Les sous-titres francais viennent de Bazarr (profil 2).
--
-- Copie de '1080p Compact FR' (qualites, groupes, tailles, bannissements materiels AV1/HDR/DV/Remux et VFQ
-- conserves), avec :
--   - langue du profil 'Any' au lieu de 'French' ;
--   - 'Not French (strict)' et 'French Missing' retires ;
--   - 'French VOSTFR' neutre (0 au lieu de -200000) : la VO sous-titree est la raison d'etre du profil ;
--   - nouveau custom format 'Not Original or English' a -999999.
--
-- 'Not Original or English' : les DEUX conditions sont niees ET requises. La base Dictionarry les declare
-- non requises ; or un *arr declenche un format des qu'UNE condition non requise est vraie, ce qui donnerait
-- « pas l'original OU pas l'anglais » et bannirait une release coreenne (« pas en anglais »).
-- Requises, elles donnent « ni l'original, ni l'anglais ».
--
-- La copie se fait a la compilation : ce profil reprend l'etat de '1080p Compact FR' laisse par les ops
-- precedentes. Une correction ulterieure de '1080p Compact FR' (op > 910) ne s'y propage PAS.

INSERT INTO custom_formats (name, description)
VALUES ('Not Original or English', 'Rejette tout release qui ne contient ni la langue originale de l''oeuvre ni l''anglais. Deux conditions de langue niees et requises.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES
  ('Not Original or English', 'Not Original', 'language', 'all', 1, 1),
  ('Not Original or English', 'Not English', 'language', 'all', 1, 1);

INSERT INTO condition_languages (custom_format_name, condition_name, language_name, except_language)
VALUES
  ('Not Original or English', 'Not Original', 'Original', 0),
  ('Not Original or English', 'Not English', 'English', 0);

INSERT INTO custom_format_tags (custom_format_name, tag_name)
VALUES ('Not Original or English', 'Language');

INSERT INTO quality_profiles (name, description, upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment)
SELECT '1080p Compact VO',
       '1080p Compact VO reprend 1080p Compact FR pour les oeuvres sans doublage français : langue originale ou anglais, sous-titres français fournis par Bazarr.

- Taille moyenne série ~ 1 à 2 Go par épisode
- Classement qualité ~ 4/10

Mêmes exclusions que 1080p Compact FR (AV1, HDR, Dolby Vision, Remux, VFQ).',
       upgrades_allowed, minimum_custom_format_score, upgrade_until_score, upgrade_score_increment
FROM quality_profiles
WHERE name = '1080p Compact FR';

INSERT INTO quality_profile_tags (quality_profile_name, tag_name)
SELECT '1080p Compact VO', tag_name
FROM quality_profile_tags
WHERE quality_profile_name = '1080p Compact FR' AND tag_name <> 'French';

INSERT INTO quality_profile_languages (quality_profile_name, language_name, type)
VALUES ('1080p Compact VO', 'Any', 'simple');

INSERT INTO quality_groups (quality_profile_name, name)
SELECT '1080p Compact VO', replace(name, '1080p Compact FR', '1080p Compact VO')
FROM quality_groups
WHERE quality_profile_name = '1080p Compact FR';

INSERT INTO quality_group_members (quality_profile_name, quality_group_name, quality_name, position)
SELECT '1080p Compact VO', replace(quality_group_name, '1080p Compact FR', '1080p Compact VO'), quality_name, position
FROM quality_group_members
WHERE quality_profile_name = '1080p Compact FR';

INSERT INTO quality_profile_qualities (quality_profile_name, quality_name, quality_group_name, position, enabled, upgrade_until)
SELECT '1080p Compact VO', quality_name, replace(quality_group_name, '1080p Compact FR', '1080p Compact VO'), position, enabled, upgrade_until
FROM quality_profile_qualities
WHERE quality_profile_name = '1080p Compact FR';

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT '1080p Compact VO', custom_format_name, arr_type,
       CASE WHEN custom_format_name = 'French VOSTFR' THEN 0 ELSE score END
FROM quality_profile_custom_formats
WHERE quality_profile_name = '1080p Compact FR'
  AND custom_format_name NOT IN ('Not French (strict)', 'French Missing');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
VALUES ('1080p Compact VO', 'Not Original or English', 'all', -999999);
