-- [fork shirka.org] '1080p Bluray HEVC' compense du repli '1080p Bluray' (+75 000) dans '1080p Compact FR' et '1080p Compact VO'.
--
-- L'op amont 29 (hdlight-efficient-profile-alignment, fusionnee le 2026-11-23) donne '1080p Bluray HEVC' a 890 000
-- dans '1080p Compact FR' (et donc dans sa copie '1080p Compact VO', faite par l'op 910) et lui ajoute une
-- condition 'Not HDLight'. L'echelle voulue par l'amont est : HDLight Bluray 940 000 > HDLight WEBRip 930 000 >
-- WEB-DL HEVC 900 000 > Bluray HEVC 890 000.
--
-- Or notre op 915 donne +75 000 a '1080p Bluray', qui matche TOUTE release BluRay 1080p hors Remux, donc aussi
-- un BluRay HEVC. Sans compensation, un BluRay HEVC non HDLight monte a 965 000 et passe DEVANT le HDLight
-- (940 000, deja compense par 914/915) : inversion que ni l'amont ni l'op 915 ne voulaient.
--
-- Correctif, meme principe que la compensation HDLight de 914/915 : '1080p Bluray HEVC' perd ce que
-- '1080p Bluray' lui ajoute (815 000 affiche) ; le total BluRay HEVC reste 890 000, l'ordre amont est retabli.
--
-- Garde volontairement STRICTE sur 890 000 : si l'amont change un jour cette valeur, l'op ne touche plus rien,
-- et le banc de compilation (comparaison amont seul / fork fusionne) le montre au merge suivant, au lieu
-- d'appliquer en silence une compensation calculee sur une valeur que personne n'a relue.

UPDATE quality_profile_custom_formats
SET score = score - 75000
WHERE quality_profile_name IN ('1080p Compact FR', '1080p Compact VO')
  AND custom_format_name = '1080p Bluray HEVC'
  AND arr_type = 'all'
  AND score = 890000
  AND EXISTS (
    SELECT 1 FROM quality_profile_custom_formats b
    WHERE b.quality_profile_name = quality_profile_custom_formats.quality_profile_name
      AND b.custom_format_name = '1080p Bluray' AND b.arr_type = 'all' AND b.score = 75000
  );
