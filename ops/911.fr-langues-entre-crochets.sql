-- [fork shirka.org] 'French VF', 'French VOSTFR' et 'French VFQ' reconnaissent aussi leurs marqueurs
-- entre crochets ou parentheses.
--
-- Ces trois regex n'acceptent un mot-cle qu'entoure d'espace, '.' ou '-' (plus '[FR]' exact pour VF).
-- Un nom de FICHIER comme 'Tu ne tueras point (2016) [1080p BluRay] [FR(VFF)-EN] [x265 10-bit AC3]
-- [GWEN].mkv' n'est donc pas reconnu : aucune des conditions 'Not French VF/VOSTFR/VFQ/MULTi' de
-- 'French Missing' ne tombe, la langue resolue n'est pas l'originale, et le fichier prend -104599 a
-- l'import (mesure du 2026-11-20, Radarr, film 947). Memes trous pour '[VFF]', '(TRUEFRENCH)',
-- '[VOSTFR]' et '[VFQ]'.
--
-- Correctif : meme forme que l'op 908 -- une alternative ajoutee AU BOUT de chaque motif (pas de
-- reecriture : un changement amont du motif reste conserve), memes mots-cles et memes exclusions que la
-- branche d'origine ; seules les bornes changent : '[' ou '(' en plus avant, ']' '(' ')' en plus apres
-- ('(' apres pour 'FR(VFF)'). '([...])' reste exclu par '(?<!\(\[)' : entre parentheses, c'est le bloc
-- des sous-titres du format de renommage, deja traite par la branche MediaInfo de 'French VOSTFR'.
-- Les exclusions croisees sont conservees : VF(?!Q) (un '[VFQ]' ne fait pas 'French VF'), FRENCH non
-- suivi de SUBS/CANADIAN, et 'FR' seul n'est accepte que borne, donc '[FR+EN]' reste a 'French MULTi'.
-- Une seule difference voulue avec la branche d'origine : 'FR' n'est pas suivi de SUBS dans la nouvelle
-- alternative ('[FR SUBS]' est une VOSTFR ; sans cette garde, 'Not French VF' l'aurait retiree de
-- 'French VOSTFR'). La branche d'origine garde son comportement ('.FR.SUBS.' y reste VF).
-- Pour 'French VFQ', l'alternative exige un crochet ou une parenthese DES DEUX COTES ('[VFQ]', '(VFQ)',
-- 'MULTi (VFQ)') : la liste '(VFF-VO-VFQ)' d'un release MULTi qui porte aussi la VFF (4 fichiers de Radarr
-- au 2026-11-20) ne doit pas basculer de 'French MULTi' a 'French VFQ', qui est banni sur les profils FR.
-- Idempotente : chaque UPDATE ne s'applique que si son alternative est absente.

UPDATE regular_expressions
SET pattern = pattern || '|(?<=^|[\s.\[(-])(?<!\(\[)(?:VF(?!Q)|VFI|VFF2?|VF2|TRUE[ ._-]?FR(?:ENCH)?|FRENCH(?![ ._-]?(?:SUBS?|CANADIAN))|FRANCAIS|FRANÇAIS|FR(?![ ._-]?SUBS?)|FRE|FRA)(?=$|[\s.\]()-])'
WHERE name = 'French VF'
  AND instr(pattern, '(?<!\(\[)(?:VF(?!Q)') = 0;

UPDATE regular_expressions
SET pattern = pattern || '|(?<=^|[\s.\[(-])(?<!\(\[)(?:VOST(?:[ ._-]?FR)?|SUB[ ._-]?(?:FR|FRENCH)|FRENCH[ ._-]?SUBS?|FR[ ._-]?SUBS?)(?=$|[\s.\]()-])'
WHERE name = 'French VOSTFR'
  AND instr(pattern, '(?<!\(\[)(?:VOST') = 0;

UPDATE regular_expressions
SET pattern = pattern || '|(?<=[\[(])(?<!\(\[)(?:VFQ2?|VQ|(?:MULTI|FRENCH)[ ._-]+CA|FRENCH[ ._-]?CANADIAN|CANADIAN[ ._-]?FRENCH|QUEBECOIS)(?=[\])])'
WHERE name = 'French VFQ'
  AND instr(pattern, '(?<!\(\[)(?:VFQ2?') = 0;
