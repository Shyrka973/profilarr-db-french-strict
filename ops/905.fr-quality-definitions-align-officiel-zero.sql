-- [fork shirka.org] max_size = 0 (sentinelle « illimite »), ALIGNEMENT SUR LA BASE OFFICIELLE.
--
-- Corrige a la racine le drift permanent « Quality Definitions » que les op 903 (tentative) et
-- 904 (revert) n'avaient PAS resolu, parce que le diagnostic d'alors etait faux.
--
-- 🔴 CE QUI A ETE ETABLI LE 2026-08-30 (et qui invalide l'analyse des op 903/904) :
-- Ce n'est PAS un bug de Profilarr. C'est NOTRE base qui diverge de l'amont.
--
--   Base OFFICIELLE `Dictionarry-Hub/database` @ branche `v2` (commit 04cd2c0, 2026-08-29) :
--       op 0.rosettarr.sql  : pose  min=0 max=2000 preferred=1990  (radarr, 30 definitions)
--       op 20.updated-media-management-names.sql :
--                             DELETE de ces lignes, puis
--                             INSERT ... values (..., 0, 0, 1990)      <-- max_size REMIS A 0
--       op 21.update-media-management-names.sql  : idem (0, 0, 1990)
--       => ETAT FINAL OFFICIEL : max_size = 0
--
--   NOTRE fork :
--       op 3.media-management.sql : pose max_size = 2000 / 1000
--       op 903 : 1999 / 999   (tentative)
--       op 904 : retour 2000 / 1000
--       => ETAT FINAL : max_size = 2000 / 1000   <-- SEULE base a rester au plafond
--
-- 🔑 L'ERREUR DE METHODE A NE PAS REFAIRE : les ops sont des MIGRATIONS SEQUENTIELLES.
-- L'analyse du 2026-08-30 a compare l'op 0 officielle a notre op 3 et conclu « valeurs
-- identiques », sans rejouer la suite -- alors que l'op 20 remet tout a 0 vingt crans plus loin.
-- Comparer deux bases Profilarr impose de REJOUER LA SEQUENCE ENTIERE, jamais de lire une op
-- isolee. Ce faux verdict a ete publie dans l'issue #926, puis retracte.
--
-- ⚠️ NE PAS CONFONDRE AVEC L'INTERDIT DE L'OP 903 : `0` n'est pas une limite basse, c'est la
-- valeur SENTINELLE « illimite » -- celle qu'emploie la base officielle. L'op 903 etait fautive
-- parce que 1999 posait une VRAIE limite (elle remplacait « pas de limite » par 1999 Mo) ; ici
-- la semantique « illimite » est CONSERVEE, on ne fait que l'ecrire comme l'amont l'ecrit.
-- `preferred_size` est laisse inchange (1990 / 990), exactement comme dans la base officielle.
--
-- ⏳ CE QUE CETTE OP NE PROUVE PAS : l'op 904 avait mesure que Profilarr normalise aussi A
-- L'ECRITURE (une base a 1999 envoyait quand meme 2000 aux *arr). L'application propre de cette
-- op ne suffit donc PAS a conclure. Le seul controle qui vaut est l'ETAGE 4 : relancer le sync
-- vers les *arr depuis l'UI, puis verifier que le drift « Quality Definitions » tombe a 0
-- changement sur Radarr (30) ET Sonarr (22).
--
-- 🔑 SOURCES : issue Dictionarry-Hub/Profilarr#926 (fermee DUPLICATE, a raison) ; PR #647
-- (« ignore unlimited quality definition drift », mergee 2026-05-22, livree en v2.0.5 -- donc
-- deja presente en 2.2.0 : il n'y a jamais eu de regression).

UPDATE radarr_quality_definitions
SET max_size = 0
WHERE max_size = 2000;

UPDATE sonarr_quality_definitions
SET max_size = 0
WHERE max_size = 1000;
