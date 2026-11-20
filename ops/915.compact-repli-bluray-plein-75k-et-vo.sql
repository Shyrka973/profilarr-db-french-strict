-- [fork shirka.org] Repli BluRay 1080p plein porte a +75 000 dans '1080p Compact FR', et etendu a '1080p Compact VO'.
--
-- Suite de l'op 914 (+25 000 dans Compact FR). Decision d'Andre du 2026-11-20 : un BluRay 1080p plein en
-- VF SEULE doit lui aussi passer le minimum (20 000). Or 'French VF' vaut -50 000 : avec +25 000 il restait
-- a -25 000, refuse. Il faut au moins +70 700 (50 000 + 20 000 + 700 de pire penalite de taille) ; +75 000
-- donne une VF seule a 25 000 (24 300 au pire), un MULTi a 75 000-90 000.
--
-- Position dans l'echelle des paliers : au-dessus de '720p HDTV' (40 000), sous '1080p HDTV' (80 000) et tres
-- sous les paliers compacts (>= 860 000). Le compact reste prioritaire, et le cutoff (1 000 000) n'etant
-- jamais atteint par un BluRay plein, Radarr/Sonarr continuent de chercher un compact en upgrade.
--
-- Chevauchement compense comme en 914 : '1080p Bluray' matche aussi toute release HDLight Bluray, donc
-- '1080p HDLight Bluray' perd ce que '1080p Bluray' gagne (865 000 affiche) ; le total HDLight reste 940 000.
--
-- '1080p Compact FR' : rien d'autre ne bouge. VOSTFR, VFQ, 'Not French (strict)' (anglais, FR SUBS lu
-- comme VOSTFR), 'French Missing' restent a -999 999 : ils restent tres sous le minimum.
--
-- '1080p Compact VO' (copie de Compact FR faite par l'op 910, AVANT l'op 914 : il n'avait aucun repli) :
-- meme trou, un BluRay 1080p plein en VO ou VOSTFR scorait 0 a ~5 000. Ses penalites propres : 'Not
-- Original or English' (-999 999) ecarte toute release sans la langue d'origine ni l'anglais (donc la VF
-- seule ou le MULTi VFF lu 'French' d'une oeuvre etrangere), 'French VFQ' -999 999. 'French VF' (-50 000)
-- n'y est jamais decisif : il ne matche pas une oeuvre d'origine francaise (mesure : 'Frantz' FRENCH = 0),
-- et une VF seule etrangere est deja a -999 999. VO, VOSTFR, anglais et VO francaise etant a 0, tout
-- repli >= 20 700 les fait passer a l'identique ; +75 000 est retenu pour garder la MEME place dans
-- l'echelle des paliers que Compact FR (entre 720p HDTV et 1080p HDTV) et des copies alignees.
--
-- Idempotente : chaque profil n'est ajuste que tant que '1080p Bluray' n'y vaut pas 75 000 ; la
-- compensation HDLight est calculee sur l'ecart reel (0 si absent, 25 000 apres 914).

UPDATE quality_profile_custom_formats
SET score = score - (75000 - COALESCE((
    SELECT b.score FROM quality_profile_custom_formats b
    WHERE b.quality_profile_name = quality_profile_custom_formats.quality_profile_name
      AND b.custom_format_name = '1080p Bluray' AND b.arr_type = 'all'), 0))
WHERE quality_profile_name IN ('1080p Compact FR', '1080p Compact VO')
  AND custom_format_name = '1080p HDLight Bluray'
  AND arr_type = 'all'
  AND NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats b
    WHERE b.quality_profile_name = quality_profile_custom_formats.quality_profile_name
      AND b.custom_format_name = '1080p Bluray' AND b.arr_type = 'all' AND b.score = 75000
  );

UPDATE quality_profile_custom_formats
SET score = 75000
WHERE quality_profile_name IN ('1080p Compact FR', '1080p Compact VO')
  AND custom_format_name = '1080p Bluray'
  AND arr_type = 'all'
  AND score <> 75000;

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT p.name, '1080p Bluray', 'all', 75000
FROM quality_profiles p
WHERE p.name IN ('1080p Compact FR', '1080p Compact VO')
  AND NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats b
    WHERE b.quality_profile_name = p.name AND b.custom_format_name = '1080p Bluray'
  );
