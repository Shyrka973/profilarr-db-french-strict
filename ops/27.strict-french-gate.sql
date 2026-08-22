-- [fork shirka.org] Garde-fou strict francais.
--
-- 'French Missing' porte SIX conditions required, dont CINQ portent sur le TITRE du release.
-- Un simple marqueur 'Vostfr' ou 'MULTi' dans le nom fait echouer une de ces conditions, donc
-- desarme tout le custom format -- alors meme que la langue resolue par l'*arr est Unknown.
-- Mesure du 2026-08-22 : trois releases anglais grabes malgre un score de -999999 cense les interdire.
--
-- Ce custom format n'a QU'UNE condition : la langue resolue. Aucune porte de sortie textuelle.

INSERT INTO custom_formats (name, description)
VALUES ('Not French (strict)', 'Rejette tout release dont la langue resolue n''est pas le francais. Condition unique (langue), sans dependance au titre.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('Not French (strict)', 'Not French', 'language', 'all', 1, 1);

INSERT INTO condition_languages (custom_format_name, condition_name, language_name, except_language)
VALUES ('Not French (strict)', 'Not French', 'French', 0);

-- Score bloquant sur les profils FR ('Anime 1080p VOSTFR FR' exclu : la VO sous-titree est sa raison d'etre).
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Balanced FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Compact FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Efficient FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Quality FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Quality HDR FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Remux FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '2160p Balanced FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '2160p Efficient FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '2160p Quality FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '2160p Remux FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '720p Quality FR' AND cf.name = 'Not French (strict)';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = 'Anime 1080p FR' AND cf.name = 'Not French (strict)';
