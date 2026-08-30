-- [fork shirka.org] replace_illegal_characters = 1 sur les configs de nommage Radarr / Sonarr.
--
-- La base amont pose `replace_illegal_characters = 0` sur TOUTES ses configs de nommage
-- (op 3.media-management.sql). Ce reglage convient a un stockage strictement POSIX, ou seul
-- `/` est illegal. Ce n'est PAS notre cas : les medias vivent sur un partage SMB
-- (`/mnt/remotes/Tower_Media`, monte depuis Tower) et sont lus par Plex, y compris depuis des
-- clients Windows -- ou `? * < > | " :` sont refuses. Laisser les *arr ecrire ces caracteres
-- produit des fichiers illisibles pour une partie des clients.
--
-- ⚠️ CE N'EST PAS QU'UNE PREFERENCE : c'est aussi la cause d'un DRIFT PERMANENT, diagnostique
-- le 2026-08-30. Profilarr detectait `media_management: 1` sur Radarr ET Sonarr, en boucle,
-- avec un `diffHash` STABLE d'un controle a l'autre (Radarr 410469f5..., Sonarr da31401d...).
--
-- 🔑 Le libelle affiche etait TROMPEUR -- le drift n'etait PAS sur les Quality Definitions,
-- qui sont conformes au caractere pres (mesure le 2026-08-30) :
--     Radarr : 30 definitions a min=0 max=2000 pref=1990  = exactement ce que demande l'op 3
--     Sonarr : 22 definitions a min=0 max=1000 pref=990   = idem, au plafond propre a Sonarr
-- `media_management` regroupe TROIS items (Media Settings, Naming, Quality Definitions) et le
-- compteur ne dit pas lequel diverge. Le seul ecart reel etait `replaceIllegalCharacters` :
-- depot=0, runtime=true, sur les deux instances. Tout le reste du Naming correspondait
-- (formats identiques, `colonReplacementFormat` smart / 4, `multiEpisodeStyle` 5).
--
-- 🔴 POURQUOI RE-SYNCHRONISER NE LE CORRIGEAIT PAS -- Profilarr n'ENVOIE PAS ce champ dans son
-- sync `Naming`. Prouve par trois mesures le 2026-08-30 :
--   (a) le sync ecrit bien (`Sync:Naming` puis `Quality Definitions: updated`, success=true)
--       et le drift est redetecte 1 SECONDE apres, avec le meme diffHash ;
--   (b) un `PUT /api/v3/config/naming` manuel a false est ACCEPTE (202) -- l'*arr ne refuse
--       donc rien, ce n'est pas une normalisation cote recepteur ;
--   (c) un `pcd.sync` relance ensuite n'a PAS ecrase cette valeur manuelle.
-- ⇒ Aligner le DEPOT sur la realite est la seule correction durable : forcer la valeur cote
-- *arr survivrait mal a un rebuild, et ne dirait nulle part POURQUOI elle a ete changee.
--
-- 📌 Perimetre : les 4 entrees de nommage de l'op 3. Les deux en SERVICE (`Radarr`, `Sonarr`,
-- confirmees par `configName` dans les logs de sync) sont celles qui ont ete MESUREES. Les deux
-- variantes (`Radarr / Editionless`, `Radarr / Jellyfin-Emby`) sont incluses par coherence
-- d'INFRASTRUCTURE et non par mesure : la contrainte vient du systeme de fichiers, pas du format
-- de nommage, donc elle vaudrait a l'identique si l'une d'elles etait activee un jour. Les
-- inclure ne change rien au runtime actuel (elles ne sont pas deployees) et evite une
-- regression silencieuse au prochain changement de variante.

UPDATE radarr_naming
SET replace_illegal_characters = 1
WHERE name IN ('Radarr', 'Radarr / Editionless', 'Radarr / Jellyfin-Emby');

UPDATE sonarr_naming
SET replace_illegal_characters = 1
WHERE name = 'Sonarr';
