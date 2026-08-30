-- [fork shirka.org] REVERT de l'op 903 : retour a max_size au plafond (Radarr 2000 / Sonarr 1000).
--
-- L'op 903 (posee le 2026-08-30) descendait `max_size` d'une unite sous le plafond pour faire
-- disparaitre un drift « Quality Definitions » permanent. Le diagnostic du mecanisme etait juste
-- -- Profilarr lit la valeur plafond comme `Unlimited` puis la compare a son propre entier --
-- mais la CONCLUSION etait fausse : ce n'est pas notre donnee qui derive, c'est un BUG DE
-- PROFILARR, reconnu par son mainteneur.
--
-- 🔑 SOURCE UPSTREAM -- Dictionarry-Hub/Profilarr, issue #640
--    « [Improvement] Drift - Quality Definitions Maximum » :
--      « Currently a drift will be detected when Profilarr has a Max. of 2000 (Radarr) or 1000
--        (Sonarr) set. The Profilarr logic will see "Unlimited" instead of the actual value and
--        show a drift. In reality the values are the same, just displayed differently. »
--    Reponse du mainteneur (santiagosayshey) : « Can do, this is actually a bug ».
--    Issue CLOSED -- mais le defaut est TOUJOURS PRESENT en 2.2.0 (mesure du 2026-08-30), et un
--    autre utilisateur le signalait deja en 2.0.7 dans le meme fil.
--    Voir aussi #920, ferme avec la meme reponse : « The values for 990 / 1000 are supposed to
--    show as unlimited, that is intended. »
--
-- ⛔ POURQUOI IL NE FAUT PAS « CORRIGER » CE DRIFT DANS LA DONNEE : `max_size` au plafond
-- signifie ILLIMITE, et c'est l'intention. Descendre a 1999 / 999 remplace une absence de borne
-- par une borne reelle, pour ne gagner qu'un affichage. On degraderait la configuration pour
-- eteindre un voyant. L'impact du drift lui-meme est NUL : aucun release n'est rejete, rien
-- n'est casse -- c'est un faux positif d'affichage.
--
-- 📌 Preuve que l'op 903 etait de toute facon INOPERANTE : appliquee proprement (pcd_op_history
-- status=applied, rowcount=52 = 30 Radarr + 22 Sonarr, aucune erreur, sequence 903 > sequence 3),
-- suivie de quatre `arr.sync.mediaManagement` en succes ecrivant « Updating 30 quality
-- definitions » -- et les *arr recevaient toujours 2000. Profilarr normalise donc vers le plafond
-- a l'ECRITURE aussi, pas seulement a la lecture. Un `docker restart` du conteneur n'y change
-- rien (teste), ce qui ecarte l'hypothese d'un cache.
--
-- ✅ Conduite retenue : conserver la valeur amont (le plafond), assumer le drift comme faux
-- positif connu et documente, et porter le signalement en amont plutot que dans notre donnee.

UPDATE radarr_quality_definitions
SET max_size = 2000
WHERE max_size = 1999;

UPDATE sonarr_quality_definitions
SET max_size = 1000
WHERE max_size = 999;
