-- [fork shirka.org] max_size sous le plafond de chaque *arr, pour supprimer un DRIFT PERMANENT.
--
-- L'op 3 pose `max_size` exactement AU PLAFOND de chaque application :
--     Radarr : 2000  (maximum de son echelle, 30 definitions)
--     Sonarr : 1000  (maximum de la sienne,  22 definitions)
-- Or, a cette valeur precise, les *arr traitent la borne comme « illimite » -- et Profilarr la
-- RELIT comme `Unlimited`, alors qu'il la COMPARE a son propre `2000` / `1000` brut. L'ecart est
-- donc structurel : il ne peut jamais se resorber, quel que soit le nombre de synchronisations.
--
-- 🔑 Symptomes observes le 2026-08-30, et pourquoi ils egarent :
--   · l'UI annonce « Quality Definitions: Radarr -- 30 changes detected », toutes en
--     « Maximum Size changed », colonne Profilarr = 2000 / colonne Radarr = Unlimited ;
--   · le sync ECRIT pourtant bien (`Updating 30 quality definitions`, success=true) et le drift
--     est redetecte UNE SECONDE apres, avec un `diffHash` STABLE d'un passage a l'autre
--     (Radarr 410469f5..., Sonarr da31401d...) ;
--   · l'API des *arr rend `maxSize: 2000` (un ENTIER, pas `null`) sur les 30 definitions --
--     donc les deux cotes portent la MEME valeur. Ce n'est pas un defaut de donnee.
--
-- ⚠️ PIEGE DE DIAGNOSTIC A NE PAS REFAIRE : le compteur des logs (`media_management: 1`) donne
-- « 1 item », tandis que l'UI affiche « 30 changements ». Ce ne sont pas les memes granularites
-- -- `media_management` regroupe TROIS items (Media Settings, Naming, Quality Definitions) et
-- n'en compte qu'un. Deduire le CONTENU du drift depuis ce compteur mene a chercher au mauvais
-- endroit (ce qui a coute une op 902 visant le Naming, ecart reel mais SANS rapport).
--
-- ✅ MECANISME PROUVE PAR UN TEST CIBLE (Radarr, definition `Raw-HD` passee a 1999) :
--     valeur 2000  -> Profilarr affiche « Unlimited »
--     valeur 1999  -> Profilarr affiche « 1999 »
-- La normalisation ne s'applique donc QU'A la valeur plafond. Descendre d'une unite suffit a
-- rendre la valeur comparable, et le drift disparait.
--
-- 📏 Impact fonctionnel : NUL en pratique. `max_size` s'exprime en Mo/minute :
--     Radarr 1999 Mo/min = ~240 Go pour un film de 2 h
--     Sonarr  999 Mo/min = ~45 Go pour un episode de 45 min
-- Le plus gros fichier du parc (25,3 Go) pese ~211 Mo/min, soit un ordre de grandeur sous la
-- borne. Aucun release realiste ne peut etre rejete par ce changement.
--
-- 📌 Perimetre : les 52 definitions (30 Radarr + 22 Sonarr) de l'op 3. `min_size` (0) et
-- `preferred_size` (1990 / 990) ne sont PAS touches : etant deja sous le plafond, ils ne
-- subissent aucune normalisation -- ce que confirme l'UI, qui ne signale que « Maximum Size
-- changed » et jamais les deux autres champs.

UPDATE radarr_quality_definitions
SET max_size = 1999
WHERE max_size = 2000;

UPDATE sonarr_quality_definitions
SET max_size = 999
WHERE max_size = 1000;
