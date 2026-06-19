# 🚀 Guide Inception: Kifach Tbda w Tmchi b A7san Tariqa

Mre7ba! Hada guide mofassal b ddarija bach tbda l'projet **Inception** dyalek w temchi fih d9a d9a bla matlef. L'hadaf mn had l'projet howa tfhem mzian **Docker** w kifach t'creer wa7d l'infrastructure sghira fiha wa7d l'architecture m9ssma.

## 📌 1. Fhem l'Architecture (L'Asas)
9bel matkteb ay code, khassek tfhem l'concepts l'asasiya. Fhad l'projet, ghatbni 3 dyal les **Containers** kol wa7d fih service:
- **Nginx**: Howa l'Web Server, ghadi ytkllaf b l'istقبال dyal les requêtes HTTP/HTTPS.
- **WordPress (+ PHP-FPM)**: Howa l'Application dyalna.
- **MariaDB**: Hia la Base de Données (Database) fin ghaytsjjlo l'ma3lomat dyal WordPress.

**Lexique (L'mostala7at):**
- **Image**: B7al chi template aw recette. Katkon read-only.
- **Container**: Howa l'exécution dyal dik l'**Image**. Hna fin kayrunni l'code dyalek.
- **Volume**: B7al chi dossier kayt'stockaw fih l'fichiers bach maymchiwch lma yteffa l'**Container** (Persistance des données).
- **Network**: Chabaka dakhiliya bach had les **Containers** y9dro idwiw m3a ba3dyathom bla maykono expozé l'bra.

## 📌 2. Siyer b a7san Tariqa (La Méthodologie)

### Etape 1: 💻 VM Setup
L'projet ghaytlebb mnnek tkhdm f wa7d l'**Virtual Machine** (b7al Debian aw Alpine).
- Sir 9ad l'VM dyalek mzian.
- Installi fiha **Docker** w **Docker Compose**.

### Etape 2: 🛠️ Bni kol Service Bo7do (Séparation des préoccupations)
A7san blan howa mat7awelch tjem3 kolchi f de9a. Bdal b service b service:

**1. MariaDB:**
- 9ad l'**Dockerfile** dyal MariaDB.
- Khdem b Alpine aw Debian base image.
- 9ad l'script lli ghay'creer la base de données w l'user.
- Testiha bo7dha: `docker build` w `docker run`. Wach katkhdem? Wach kat9der dkhel liha?

**2. Nginx:**
- 9ad l'**Dockerfile** dyal Nginx.
- 9ad l'**Configuration File** (`nginx.conf`) bach yst9bel l'HTTPS (Port 443).
- Généri l'**SSL Certificates** (TLS).
- Testih bo7do m3a chi page HTML sghira bach t'assuré bli l'HTTPS khaddam.
  
**3. WordPress (PHP-FPM):**
- 9ad l'**Dockerfile** dyal PHP-FPM w wget/curl bach t'téléchargi WordPress.
- Khdem b **WP-CLI** (WordPress Command Line Interface) bash dir l'installation automatique mn l'script (`2-Script.txt` f dossier wordpress dyalek).

### Etape 3: 🔗 Jme3 Kolchi b Docker Compose
Mlli t'testi kol **Container** bo7do w ykhdm mzian, dba w9et tjem3hom f fichier wa7ed smiyto `docker-compose.yml`.
- Kteb les **Services** (MariaDB, WordPress, Nginx).
- 7ded les **Networks**: Khali les services ytkalmo binathom. Nginx w WordPress khasshom network, w WordPress w MariaDB khasshom network (aw dirhom f réseau wa7ed).
- Zid les **Volumes**: Wa7d l'Base de Données (MariaDB), w Wa7d l'Fichiers dyal Site (WordPress).

### Etape 4: PID 1 w l'Processus (L'mohim!)
Rred lbal l wa7d lblan mohim (rak 7att doc 3lih `4-PID1.txt`): L'processus principal dyal l'**Container** khasso idima ykon howa l'PID 1. Ya3ni ila knti mkhdem script bash f l'entrée, khassek tkhdem l'commande `exec` bash le service iched l'blast l'script.
- Exemple: `exec nginx -g "daemon off;"`

## 📌 3. Kifach ddir Debugging (Mli ti7 f mochkil)
L'projet Inception kigolo 3lih s3ib bzaf 7it fih l'debugging, bch t'debuggi a7san 7aja hia:
1. `docker compose logs -f <service_name>` : Katwerrik les erreurs li kayw93o f l'inside dyal l'**Container**.
2. `docker exec -it <container_name> /bin/bash` (aw `/bin/sh`) : Katkhlik dkhel wste l'**Container** w tchouf l'fichiers chno fihom, wach l'permissions huma hadok...

## 💡 Nassi7a Lakhira
- Mchii l'dossier `InceptionGuide/Concepts` li 3ndk f l'workspace w 9ra l'fichiers text li temma b t-tartib.
- Tafa2al m3a kol w7da, u bni l'**Dockerfile** dyal kol dossier mnhom.
- Ay mostala7 jdid sdeftih, sir 9leb 3lih bl'english (mtln: "What is Docker bind mount vs volume").

Bon courage f l'Inception! 🚀