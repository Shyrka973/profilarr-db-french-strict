-- [fork shirka.org] 'FR SUBS' n'est plus une VF, et 'French Original Marker' reconnait '[VOF]' / '[VOQ]'
-- entre crochets ou parentheses.
--
-- 1. 'French VF' : la branche d'origine accepte 'FR' borne par espace, '.' ou '-' sans regarder ce qui
--    suit. 'Film.2020.1080p.FR.SUBS.x264-GRP' (sous-titres francais, donc une VOSTFR) matchait donc
--    'French VF', ce qui le retirait aussi de 'French VOSTFR' (condition 'Not French VF'). L'op 911 ne
--    l'avait corrige que dans sa propre alternative.
--    Correctif : une GARDE en tete de motif, '(?!FR[ ._-]?SUBS?(?![A-Z0-9]))', qui interdit qu'un match
--    commence sur 'FR' suivi de SUB/SUBS (memes separateurs que la branche 'FR[ ._-]?SUBS?' de 'French
--    VOSTFR'). Le motif existant est enveloppe tel quel dans '(?:...)' : pas de reecriture, un changement
--    amont du motif reste conserve. 'FRENCH.SUBS' etait deja exclu ; '.FR.' seul, 'FR(VFF)',
--    'MULTi.FR.EN' et '[FR]' ne sont pas touches (la garde ne vise que 'FR' + SUB).
--
-- 2. 'French Original Marker' n'accepte 'VOF' / 'VOQ' qu'entoure d'espace, '.' ou '-'. Un film francais
--    annonce 'Film Francais (2020) [1080p] [VOF] [x265]' sortait donc 'French Missing' (refuse, puis
--    blockliste par Arr_Queue_Auto).
--    Correctif : meme forme que les ops 908 et 911 -- une alternative ajoutee AU BOUT du motif, memes
--    mots-cles, bornes elargies a '[' '(' avant et ']' '(' ')' apres. '([...])' reste exclu par
--    '(?<!\(\[)' : entre parentheses, c'est le bloc des sous-titres du format de renommage.
--
-- Idempotente : chaque UPDATE ne s'applique que si sa garde ou son alternative est absente.

UPDATE regular_expressions
SET pattern = '(?i)(?!FR[ ._-]?SUBS?(?![A-Z0-9]))(?:' || substr(pattern, 5) || ')'
WHERE name = 'French VF'
  AND substr(pattern, 1, 4) = '(?i)'
  AND instr(pattern, '(?!FR[ ._-]?SUBS?(?![A-Z0-9]))') = 0;

UPDATE regular_expressions
SET pattern = pattern || '|(?<=^|[\s.\[(-])(?<!\(\[)(?:VOF|VOQ)(?=$|[\s.\]()-])'
WHERE name = 'French Original Marker'
  AND instr(pattern, '(?<!\(\[)(?:VOF|VOQ)') = 0;
