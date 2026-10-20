-- [fork shirka.org] Veto des WEBRip anonymes (sans groupe, ou groupe 'NoTag') sur les profils FR deployes.
--
-- 'Banned WEBRip' (base Dictionarry) bannit tout WEBRip hors de SA liste de groupes, qui ne contient
-- que des groupes anglophones : applique a un profil FR, il bannirait aussi les WEBRip des equipes
-- FR Tier 1-3. Mesure du 2026-10-20 sur Radarr : 80 films en place le portent, dont 38 d'equipes FR
-- notees. L'upstream FR le laisse donc a 0, et ce fork aussi.
--
-- Ce custom format ne vise que le WEBRip sans equipe : grab du 2026-10-20 de
-- 'Mulan...WEBRip.AAC.5.1.x265-Notag' (score 855200) contre un Bluray en place, faute de veto.
-- Radarr seulement : l'impact sur Sonarr n'a pas ete mesure.

INSERT INTO regular_expressions (name, pattern, description)
VALUES ('Shirka - Release Group NoTag', '(^|[\s._-])no[\s._-]?tag$', 'Groupe de release se terminant par NoTag (release sans equipe) ; Radarr lit "AC-3-NoTag" comme groupe "3-NoTag"');

INSERT INTO regular_expressions (name, pattern, description)
VALUES ('Shirka - Release Group (Any)', '.', 'Tout groupe de release ; nie, matche un groupe absent');

INSERT INTO custom_formats (name, description)
VALUES ('WEBRip anonyme', 'WEBRip sans groupe de release, ou de groupe NoTag.');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('WEBRip anonyme', 'WEBRip', 'source', 'all', 0, 1);

INSERT INTO condition_sources (custom_format_name, condition_name, source)
VALUES ('WEBRip anonyme', 'WEBRip', 'webrip');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('WEBRip anonyme', 'NoTag', 'release_group', 'all', 0, 0);

INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('WEBRip anonyme', 'NoTag', 'Shirka - Release Group NoTag');

INSERT INTO custom_format_conditions (custom_format_name, name, type, arr_type, negate, required)
VALUES ('WEBRip anonyme', 'Release Group (Missing)', 'release_group', 'all', 1, 0);

INSERT INTO condition_patterns (custom_format_name, condition_name, regular_expression_name)
VALUES ('WEBRip anonyme', 'Release Group (Missing)', 'Shirka - Release Group (Any)');

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'radarr', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Quality HDR FR' AND cf.name = 'WEBRip anonyme';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'radarr', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Quality FR' AND cf.name = 'WEBRip anonyme';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'radarr', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '1080p Compact FR' AND cf.name = 'WEBRip anonyme';
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'radarr', -999999
FROM quality_profiles qp, custom_formats cf
WHERE qp.name = '720p Quality FR' AND cf.name = 'WEBRip anonyme';
