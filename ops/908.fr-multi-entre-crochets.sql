-- [fork shirka.org] 'French MULTi' reconnait aussi MULTI entre crochets ou parentheses.
--
-- Le regex 'French MULTi' n'accepte MULTI qu'entoure de separateurs (espace . _ -). Un nom de FICHIER
-- comme 'Harry Potter ... (2005) [MULTI] [X265 10-bit] [Phoenix].mkv' n'est donc pas reconnu. Ce regex
-- porte deux custom formats en sens oppose :
--   'French MULTi'   condition positive  -> le fichier perd MULTi ;
--   'French Missing' condition 'Not French MULTi' (negate, required) -> elle reste vraie, et comme la
--                    langue resolue (French) n'est pas l'originale, 'French Missing' matche : -999999.
-- Mesure du 2026-11-10 (Radarr, '1080p Quality HDR FR') : 'Harry.Potter.Et.La.Coupe.De.Feu.2005.MULTI.VFF
-- .1080p.BluRay.DTS.HD.MA.5.1.x265-Phoenix' grabe a 895000, puis rejete a l'import (-104999 recalcule),
-- donc regrabe en boucle ; HP4 et HP5 blocklistes a la main.
--
-- Correctif : une alternative ajoutee AU BOUT du motif existant (pas de reecriture : un changement amont
-- du motif reste conserve). Meme mot-cle MULTI, memes suffixes francais, meme exclusion des SUBS que la
-- branche d'origine ; seules les bornes changent : '[' ou '(' avant, ']' ou ')' apres.
-- '([MULTI])' reste exclu, comme '([FR+EN])' dans la branche MediaInfo : entre parentheses, c'est le bloc
-- des sous-titres du format de renommage.
-- Effet attendu, par construction du regex partage : 'French MULTi' matche, 'French Missing',
-- 'French VF', 'French VOSTFR' et 'French Original' ne matchent plus sur '[MULTI]'.
-- 'French MULTi + Team FR Marker (INTL)' recopie le motif a l'op 24 : non concerne, et sans score sur
-- les profils FR deployes.

UPDATE regular_expressions
SET pattern = pattern || '|(?<=^|[\s._\[(-])(?<!\(\[)MULTI(?:[\s._,+&/-]?(?:FR|FRA|FRE|FRENCH|FRANCAIS|FRANÇAIS|TRUE[\s._-]?FR(?:ENCH)?|VFQ2?|VF|VFI|VFF2?|VFB|VOF|VOQ|VF2|VFI2|\d+))?(?![\s._,+&/-]?SUBS?)(?=$|[\s._,+&/\])-])'
WHERE name = 'French MULTi'
  AND instr(pattern, '(?<!\(\[)MULTI') = 0;
