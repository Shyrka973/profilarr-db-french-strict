-- [fork shirka.org] HDLight neutre (et non banni) sur les profils Quality FR deployes.
--
-- L'op du 2026-05-28 (commit b3709a4, « HDLight / 4KLight exclusion des profils Quality »)
-- a banni 'HDLight' des profils Quality pour ecarter les re-encodes a bitrate reduit. La
-- regle est saine dans son intention, mais elle a ete posee sans mesurer ce que la
-- bibliotheque contenait REELLEMENT.
--
-- Mesure du 2026-08-30, sur la TOTALITE des 1378 fichiers du profil '1080p Quality HDR FR'
-- (parc complet, pas un echantillon) :
--   - taille MEDIANE = 2,89 Go (p25 2,24 / p75 4,21), quand le profil cible 10 a 20 Go
--   - 53 % des fichiers pesent moins de 3 Go
--   - 377 fichiers (27,3 %) ont un score NEGATIF, dont 181 a cause du seul 'HDLight'
--   - 170 de ces 181 portent par ailleurs le tier '1080p Bluray' (720000)
-- Autrement dit : la bibliotheque est faite d'encodes compacts, et le profil les declare
-- tous indesirables. Chacun devient candidat permanent au remplacement, ce qui alimente les
-- regrabs que le §27 du daily check remonte.
--
-- ALTERNATIVE TESTEE ET REFUTEE LE MEME JOUR -- bascule des 1399 films vers
-- '1080p Compact FR' : elle porte la part de fichiers sous le seuil minimum de 27,4 % a
-- 50 % (698/1396). Motif : ce profil ne recompense que les custom formats '(Compact)'
-- ('HDLight Bluray (Compact)' +900000) et laisse les tiers 'Quality'/'Scene' a quelques
-- milliers de points -- or la bibliotheque est MIXTE. Rollback complet, 0 grab declenche.
-- Lecon retenue : le test avait ete fait sur UN film, choisi parmi les HDLight, donc dans
-- la population la plus favorable. Un echantillon non representatif ne valide pas une
-- bascule de masse.
--
-- Calibrage a 0 (neutre), et non a un malus doux, sur l'echelle du profil mesuree ce jour :
--   1080p Bluray   720000
--   1080p WEB-DL   710000    -> ecart entre tiers = 10000
--   1080p WEBRip   700000
-- Le scoring ne regarde PAS la taille du fichier : un Bluray HDLight de 3,6 Go est note
-- exactement comme un Bluray de 15 Go des lors que 'HDLight' cesse de le penaliser. Un
-- malus, meme de -5000, re-penaliserait donc precisement les fichiers compacts qu'on
-- cherche a conserver, sans rien apporter en contrepartie. Le veto anti-basse-qualite
-- reste porte par 'FR LQ' (-999999), qui vise la qualite reelle et n'est pas touche ici.
--
-- Perimetre volontairement limite aux DEUX profils Quality DEPLOYES ET MESURES :
--   '1080p Quality HDR FR' : 181 fichiers concernes sur 1378 (Radarr)
--   '1080p Quality FR'     : 2 fichiers concernes sur 32 -- et ce sont ses 2 SEULS negatifs
--
-- SONARR EST AUSSI CONCERNE (arr_type='all'), et il a ete mesure separement le 2026-08-30
-- avant application -- 3265 fichiers d'episodes sur les 176 series de '1080p Quality HDR FR' :
--   negatifs = 293 (9,0 %) ; sous le seuil = 382 (11,7 %) ; median = 730600
--   MAIS seulement 15 negatifs portent 'HDLight' (0,5 % des fichiers)
-- L'effet de cette op sur Sonarr est donc MARGINAL et ne peut qu'ameliorer : elle retire un
-- malus, elle n'en ajoute aucun. Les 278 autres negatifs de Sonarr relevent de 'FR LQ',
-- 'AV1', 'Remux', 'French VFQ' -- non touches ici, et non instruits a ce stade.
--
-- '720p Quality FR' n'est PAS modifie. ⚠️ Attention a la formulation : il n'est pas deploye
-- dans RADARR, mais il EXISTE dans SONARR (2 series, HDLight a -999999). Il est exclu parce
-- qu'il n'a pas ete mesure, pas parce qu'il serait absent du parc. Elargir sans mesure est
-- exactement l'erreur de la bascule refutee ci-dessus.
--
-- Effet attendu, calcule sur la mesure : 167 fichiers repassent positifs, soit 378 -> ~211
-- fichiers sous le seuil (27,4 % -> 15,3 %) -- mieux que les DEUX profils existants.
--
-- '4KLight' n'est PAS touche : il vise le 2160p, hors perimetre de cette mesure, et un
-- seul fichier du parc le porte.

UPDATE quality_profile_custom_formats
SET score = 0
WHERE quality_profile_name IN ('1080p Quality HDR FR', '1080p Quality FR')
  AND custom_format_name = 'HDLight';

-- Les lignes absentes sont creees (meme garde que l'op 900 : un UPDATE seul ne fait rien
-- si le couple (profil, custom format) n'existe pas encore dans la table).
INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT qp.name, cf.name, 'all', 0
FROM quality_profiles qp, custom_formats cf
WHERE qp.name IN ('1080p Quality HDR FR', '1080p Quality FR')
  AND cf.name = 'HDLight'
  AND NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats q
    WHERE q.quality_profile_name = qp.name AND q.custom_format_name = cf.name
  );
