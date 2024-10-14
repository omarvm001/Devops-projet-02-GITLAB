# Description du Projet 02 GITLAB-CI
   Lien vers le **Projet 01 DOCKER** de la formation Bootcamp DevOps : 
   [here](https://github.com/omarvm001/Devops_projet_01_Docker "here").
   
   Ce rapport détaille les étapes du pipeline décrites dans le fichier .gitlab-ci.yml, Dockerfile ainsi que les bénéfices associés à l'automatisation complète du processus de développement, test et déploiement d'une application via un pipeline CI/CD (Intégration Continue / Livraison Continue) sur GitLab, en utilisant des conteneurs Docker et des environnements cloud comme Heroku.

![project](https://github.com/omarvm001/Devops-projet-02-GITLAB/blob/main/images/pipeline-ci-cd.jpeg)

# Conteneurisation & Déploiement CI/CD via GITLAB d'une Application Web Statique
   
   Dans ce projet, j'ai conteneurisé une application web statique et mis en place un pipeline CI/CD complet sur GitLab pour automatiser les étapes de build, test et déploiement sur Heroku. Le Dockerfile décrit la construction de l'image, où le code source est cloné, puis intégré à un serveur Nginx minimaliste pour servir l'application. Le fichier .gitlab-ci.yml structure le pipeline en plusieurs étapes, incluant la construction de l'image Docker, des tests d'acceptation, la publication de l'image sur un registre Docker, ainsi que le déploiement automatique sur des environnements Heroku (staging, production et environnement de revue pour les merge requests).

Le pipeline tire parti de services comme docker:dind pour gérer les conteneurs Docker et utilise des templates pour réutiliser les configurations de déploiement et de test sur différents environnements. Chaque étape est soigneusement orchestrée pour assurer une livraison continue en passant par des phases de tests automatisés avant chaque mise en production.

# Technologies Utilisées

Dans ce projet, plusieurs technologies ont été employées pour assurer une intégration continue fluide, un déploiement automatisé et un hébergement fiable de l'application web statique.

### 1. Docker

[Docker](https://www.docker.com/) a été utilisé pour **conteneuriser** l'application. L'application est isolée dans un conteneur léger qui comprend toutes les dépendances nécessaires. Cela garantit :
- **Portabilité** : Fonctionne de manière cohérente sur n'importe quel environnement.
- **Isolation** : Les dépendances sont gérées au sein du conteneur.
- **Gestion simplifiée des versions** : Chaque commit correspond à une image Docker identifiable par un tag.

### 2. GitLab CI/CD

[GitLab CI/CD](https://docs.gitlab.com/ee/ci/) a permis d'automatiser les processus de **build**, **test** et **déploiement**. Voici un aperçu du pipeline CI/CD :
- **Build** : Construction de l'image Docker à partir du Dockerfile.
- **Tests d'acceptation** : Teste l'application pour valider le déploiement.
- **Publication de l'image** : L'image Docker est poussée dans le registre GitLab.
- **Déploiement** : Automatisation du déploiement sur Heroku dans différents environnements (review, staging, production).


### 3. Heroku

[Heroku](https://www.heroku.com/) est utilisé pour **héberger l'application** dans trois environnements :
- **Review** : Création d'un environnement temporaire pour chaque merge request.
- **Staging** : Déploiement de l'application pour des tests pré-production.
- **Production** : L'environnement final où l'application est accessible aux utilisateurs.

# Workflow du Pipeline CI/CD

Ce projet utilise un pipeline CI/CD pour automatiser le processus de développement et de déploiement de l'application. Voici un aperçu des étapes clés du workflow, ainsi que leurs conditions d'exécution :

![project](https://github.com/omarvm001/Devops-projet-02-GITLAB/blob/main/images/Gitlab-CI_pipeline.png)

## 1. Build image
- **Condition :** S'exécute pour chaque commit.
- **Description :** Construction de l'image Docker à partir du Dockerfile en utilisant une approche multi-stage pour réduire la taille de l'image finale.

## 2. Acceptance test
- **Condition :** S'exécute pour chaque commit.
- **Description :** Exécution des tests d'acceptation sur l'image Docker. L'image est chargée depuis l'artefact `static-site.tar`, puis le conteneur est exécuté. Des requêtes HTTP sont envoyées pour vérifier la présence d'un contenu spécifique.

## 3. Release de l'Image
- **Condition :** S'exécute pour chaque commit.
- **Description :** Publication de l'image Docker dans le registre GitLab. L'image est taguée avec le nom de la branche et le commit SHA pour garder un historique.

## 4. Deploy review
- **Condition :** S'exécute pour chaque nouvelle merge request ou mise à jour.
- **Description :** Déploiement de l'application dans un environnement de révision sur Heroku.

## 5. Stop review
- **Condition :** S'exécute lors de la fermeture ou de l'acceptation d'une merge request.
- **Description :** Arrêt de l'environnement de révision sur Heroku pour libérer des ressources.

## 6. Deploy staging
- **Condition :** S'exécute lors du push d'un commit sur la branche principale (main).
- **Description :** Déploiement de l'application dans un environnement de préproduction sur Heroku.

## 7. Test staging
- **Condition :** S'exécute après un déploiement réussi en préproduction.
- **Description :** Exécution de tests pour s'assurer que l'application fonctionne correctement.

## 8. Deploy prod
- **Condition :** S'exécute manuellement après validation des tests de préproduction.
- **Description :** Déploiement de l'application dans l'environnement de production sur Heroku.

## 9. Test prod
- **Condition :** S'exécute après un déploiement réussi en production.
- **Description :** Exécution de tests pour garantir le bon fonctionnement de l'application.

---

Ce pipeline assure une intégration et un déploiement continus, garantissant ainsi une livraison rapide et fiable des nouvelles fonctionnalités.

# Explications Détailées du Pipeline

## 1. Construction de l'Image

La construction de l'image Docker commence par le clonage du dépôt contenant le code source de l'application. Nous utilisons pour cela une image de base `ubuntu:18.04` dans la première étape de notre Dockerfile. Voici un aperçu des étapes de cette phase :

1. **Clonage du Dépôt** :
   - Nous démarrons avec l'image `ubuntu:18.04`, où nous installons Git après avoir mis à jour les paquets. L'installation se fait en mode non interactif pour éviter les interruptions pendant la construction.
   - Nous clonons ensuite le dépôt depuis GitHub, ce qui permet d'obtenir le code source de l'application à déployer.

   ```dockerfile
   FROM ubuntu:18.04 as files
   RUN apt-get update
   RUN DEBIAN_FRONTEND=noninteractive apt-get install git -y
   RUN git clone https://github.com/omarvm001/Devops-projet-02-GITLAB.git /project
   ```

2. **Création de l'Image Légère** :

Dans la seconde étape, nous utilisons une image légère de Nginx (`nginx:stable-alpine3.17-slim`), ce qui nous permet de servir l'application de manière efficace avec un serveur HTTP minimal. Le code source cloné est copié depuis l'étape précédente vers le répertoire de Nginx destiné à servir les fichiers statiques.

   ```dockerfile
   FROM nginx:stable-alpine3.17-slim
   COPY --from=files /project /usr/share/nginx/html/
   COPY nginx.conf /etc/nginx/conf.d/default.conf
   EXPOSE 80
   CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'
   ```
3. **Configuration CI/CD avec GitLab** :

Dans le pipeline GitLab CI, une tâche `docker-build` est définie pour automatiser la construction de l'image Docker. Cette étape utilise l'image Docker officielle et construit l'image à partir du Dockerfile spécifié dans le projet. 

Après la construction, l'image est sauvegardée sous forme d'artefact, `static-site.tar`, facilitant ainsi son chargement lors des étapes suivantes du pipeline CI/CD. Cela permet de garantir que l'image construite est disponible pour des tests, des déploiements et d'autres opérations qui suivent dans le processus d'intégration continue et de déploiement continu.

Voici un exemple de la configuration de la tâche `docker-build` :

   ```yaml
   docker-build:
     stage: build
     script:
       - docker build -t static-site .
       - docker save static-site > static-site.tar
     artifacts:
       paths:
         - static-site.tar
   ```


## 2. Tests d'Acceptation

Cette étape du pipeline est dédiée aux tests d'acceptation de l'application, afin de s'assurer que l'image Docker construite fonctionne correctement dans un environnement de conteneur.

### Détails du processus

1. **Chargement de l'image Docker** : L'image `static-site` est chargée à partir de l'artefact généré lors de la phase de construction (`static-site.tar`), ce qui permet de réutiliser l'image Docker pour l'étape de test.
    ```bash
    docker load < static-site.tar
    ```

2. **Exécution du conteneur** : Le conteneur est lancé à partir de l'image Docker précédemment chargée. Il est exécuté en arrière-plan (`-d`) avec les ports configurés pour mapper le port du conteneur (défini par `APP_CONTAINER_PORT`) à l'extérieur (exposé via `APP_EXPOSED_PORT`). La variable d'environnement `PORT` est également passée au conteneur pour configurer correctement le serveur HTTP.
    ```bash
    docker run -d -p $APP_CONTAINER_PORT:$APP_EXPOSED_PORT -e PORT=$APP_CONTAINER_PORT --name webapp static-site
    ```

3. **Attente de la disponibilité du service** : Un délai de 5 secondes est introduit pour s'assurer que le conteneur a démarré et que le service est prêt à recevoir des requêtes.
    ```bash
    sleep 5
    ```

4. **Exécution des tests** : Un outil léger comme `curl` est installé dans le conteneur pour effectuer une requête HTTP vers l'application déployée. Cette requête vérifie si le contenu attendu ("Dimension") est présent dans la réponse, ce qui prouve que l'application fonctionne correctement.
    ```bash
    apk --no-cache add curl
    curl "http://docker:$APP_CONTAINER_PORT" | grep -i "Dimension"
    ```

### Résultat attendu

Si le test réussit, cela signifie que le service est correctement déployé et opérationnel dans le conteneur. En cas d'échec (absence de "Dimension" dans la réponse HTTP), le pipeline est interrompu, signalant une défaillance dans l'application ou dans son environnement d'exécution.

Cette étape assure que l'image Docker, une fois construite, fonctionne correctement et peut répondre aux requêtes dans un environnement conteneurisé avant de passer à l'étape suivante du pipeline (par exemple, le déploiement ou la publication).

## 3. Release de l'Image

L'étape "Release image" du pipeline GitLab CI a pour objectif de publier l'image Docker dans le registre GitLab, afin de la rendre disponible pour d'autres étapes du déploiement ou pour des environnements externes. Voici les actions réalisées dans cette étape :

### Détails du processus

1. **Chargement de l'image Docker** : L'image Docker préalablement construite est chargée à partir de l'artefact `static-site.tar`. Cela permet de réutiliser l'image générée dans les étapes précédentes pour la publication.
    ```bash
    docker load < static-site.tar
    ```

2. **Tag de l'image Docker** : L'image est marquée (ou "taguée") avec deux identifiants :
   - Le nom de la branche (`CI_COMMIT_REF_NAME`), ce qui permet d'identifier l'image en fonction de la branche Git.
   - Le hash court du commit (`CI_COMMIT_SHORT_SHA`), pour associer l'image à un commit spécifique.
    ```bash
    docker tag static-site "${IMAGE_NAME}:${CI_COMMIT_REF_NAME}"
    docker tag static-site "${IMAGE_NAME}:${CI_COMMIT_SHORT_SHA}"
    ```

3. **Authentification au registre GitLab** : Le script se connecte au registre GitLab en utilisant les variables d'environnement `CI_REGISTRY_USER` et `CI_REGISTRY_PASSWORD`. Cela permet de pousser l'image dans un registre privé sécurisé.
    ```bash
    docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
    ```

4. **Publication de l'image Docker** : Une fois l'image taguée, elle est poussée dans le registre GitLab à deux endroits :
   - Avec le tag correspondant au nom de la branche (`CI_COMMIT_REF_NAME`).
   - Avec le tag correspondant au commit SHA (`CI_COMMIT_SHORT_SHA`).
    ```bash
    docker push "${IMAGE_NAME}:${CI_COMMIT_REF_NAME}"
    docker push "${IMAGE_NAME}:${CI_COMMIT_SHORT_SHA}"
    ```

### Objectif

Cette étape permet de versionner et de sauvegarder les images Docker pour chaque commit et branche dans un registre Docker. Cela facilite :
- **La gestion des versions** : Chaque image est liée à un commit spécifique, ce qui permet de retrouver facilement quelle version de l'application est associée à un déploiement.
- **Le déploiement** : Les images taguées peuvent être utilisées pour déployer l'application dans différents environnements (staging, production, etc.).
- **La collaboration** : Les autres développeurs ou équipes peuvent récupérer l'image à partir du registre pour la tester ou la déployer dans leur propre environnement.

Grâce à cette étape, le pipeline CI/CD devient plus robuste et permet de gérer les différentes versions de l'application de manière organisée et traçable.


## 4. Déploiement en Environnements de Revue, Staging et Production
J'ai mis en place des étapes de déploiement spécifiques pour les environnements de revue, staging et production sur Heroku. Ces étapes garantissent que l'application est rigoureusement testée et validée avant son déploiement en production. Les déploiements utilisent des variables d'environnement pour distinguer chaque environnement, assurant ainsi l'application des configurations appropriées.

## 5. Arrêt de l'Environnement de Revue
L'étape "Stop review" est conçue pour arrêter et supprimer l'environnement de révision sur Heroku lorsque celui-ci n'est plus nécessaire. Cela permet de libérer des ressources tout en maintenant la propreté des environnements de déploiement.

## 6. Tests en Staging et en Production
Après chaque déploiement dans les environnements de staging et production, des étapes de test sont mises en place pour valider le bon fonctionnement de l'application. Cela garantit que l'application fonctionne correctement dans son environnement cible avant d'être considérée comme prête pour une utilisation en production.

# Aperçu du Site

![project](https://github.com/omarvm001/Devops-projet-02-GITLAB/blob/main/images/site-prod.png)

![project](https://github.com/omarvm001/Devops-projet-02-GITLAB/blob/main/images/site-staging.png)

# Conclusion

En mettant en place ce pipeline CI/CD pour l'application web statique, j'ai pu automatiser les processus de construction, test et déploiement, tout en garantissant que chaque modification de l'application est testée de manière rigoureuse avant sa mise en production. Grâce à Docker, j'ai assuré la portabilité de l'application et la gestion des environnements de manière consistante. L'intégration de GitLab CI/CD a non seulement simplifié le flux de travail, mais aussi accéléré les déploiements, en réduisant les risques d'erreurs humaines et en facilitant le suivi des versions.

Ce pipeline m'a permis d'adopter une approche DevOps robuste, avec un cycle de développement plus agile et des retours d'information rapides grâce aux tests automatisés. Enfin, l'hébergement sur Heroku m'a fourni une plateforme flexible pour déployer l'application dans des environnements distincts (review, staging, production), garantissant que l'application est toujours en état de fonctionner avant chaque mise à jour en production.

En somme, ce projet a démontré comment les outils modernes comme Docker, GitLab CI/CD, et Heroku peuvent être intégrés de manière transparente pour améliorer la qualité, la rapidité et la fiabilité des livraisons d'applications.

