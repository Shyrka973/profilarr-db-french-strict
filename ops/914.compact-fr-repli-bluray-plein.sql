-- [fork shirka.org] '1080p Compact FR' : bonus de REPLI pour un BluRay 1080p en encodage plein (non HDLight).
--
-- Constat du 2026-11-20 : le profil ne donne de bonus de palier qu'aux encodes compacts (HDLight Bluray
-- 940 000, HDLight WEBRip 930 000, WEBRip (Compact) 910 000, WEB-DL HEVC 900 000, WEB-DL AVC 860 000,
-- puis 720p et en dessous). Un BluRay 1080p classique ne touche que des bonus d'equipe et d'audio, moins les
-- tailles : il score entre 0 et ~5 000, sous le minimum de 20 000, et n'est JAMAIS telecharge, meme quand
-- c'est la seule release francaise du film. Cas reel : 'The Wizard of Lies' (2017), surveille depuis le
-- 04/10, dont les seules releases FR sont deux MULTi 1080p BluRay x264 de VENUE (scores 800 et 400).
--
-- Correctif : '1080p Bluray' (1080p + source bluray, hors Remux) recoit +25 000, juste au-dessus du minimum
-- (pire penalite de taille : -700). Tres en dessous des paliers compacts (>= 860 000) : le compact reste
-- prioritaire, et comme le cutoff (1 000 000) n'est jamais atteint par un BluRay plein, Radarr/Sonarr
-- continuent de chercher une version compacte en upgrade.
--
-- Chevauchement compense : '1080p Bluray' matche AUSSI toute release HDLight Bluray (meme resolution et
-- source). Pour que ces dernieres restent strictement a leur score, '1080p HDLight Bluray' perd les memes
-- 25 000 (940 000 -> 915 000 affiche, total inchange a 940 000).
--
-- Ne s'applique qu'aux releases francaises : 'Not French (strict)', 'French Missing', 'French VOSTFR',
-- 'French VFQ' restent a -999 999. 'French VF' (VF seule, sans VO) reste a -50 000 : un BluRay plein en VF
-- seule reste sous le minimum (choix amont : MULTi prefere), seul le MULTi passe.
--
-- Hors perimetre, justifie :
--   - '1080p WEBRip' : deja couvert en entier par 'WEBRip (Compact)' (non HDLight) et 'HDLight WEBRip' ;
--   - '1080p Remux' : exclu volontairement (Remux -999 999, qualite Remux-1080p desactivee) ;
--   - '1080p WEB-DL' sans codec dans le nom : chevauche 3 paliers compacts dont 'HDLight WEBRip' (sources
--     web_dl ET webrip), compensation impossible proprement ; non traite ici ;
--   - '2160p Compact FR' : pas de trou equivalent pour le 1080p (BluRay AVC 840 000 / HEVC 890 000 deja en
--     repli) ; un bonus sur le 2160p BluRay plein chevaucherait 4KLight Bluray et le pousserait au cutoff.
--
-- Idempotente : les deux instructions ne jouent que tant que '1080p Bluray' est absent du profil.

UPDATE quality_profile_custom_formats
SET score = score - 25000
WHERE quality_profile_name = '1080p Compact FR'
  AND custom_format_name = '1080p HDLight Bluray'
  AND NOT EXISTS (
    SELECT 1 FROM quality_profile_custom_formats
    WHERE quality_profile_name = '1080p Compact FR'
      AND custom_format_name = '1080p Bluray'
  );

INSERT INTO quality_profile_custom_formats (quality_profile_name, custom_format_name, arr_type, score)
SELECT '1080p Compact FR', '1080p Bluray', 'all', 25000
WHERE NOT EXISTS (
  SELECT 1 FROM quality_profile_custom_formats
  WHERE quality_profile_name = '1080p Compact FR'
    AND custom_format_name = '1080p Bluray'
);
