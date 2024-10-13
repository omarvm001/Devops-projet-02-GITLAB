# Project Description
   Ce rapport détaille les étapes du pipeline décrites dans le fichier .gitlab-ci.yml, Dockerfile ainsi que les bénéfices associés à l'automatisation complète du processus de développement, test et déploiement d'une application via un pipeline CI/CD (Intégration Continue / Livraison Continue) sur GitLab, en utilisant des conteneurs Docker et des environnements cloud comme Heroku.

![project](https://github.com/omarvm001/Devops_projet_01_Docker/blob/main/pipeline-ci-cd.jpeg)

# Conteneurisation et Déploiement CI/CD via GITLAB d'une Application Web Statique
    Dans ce projet, j'ai conteneurisé une application web statique et mis en place un pipeline CI/CD complet sur GitLab pour automatiser les étapes de build, test et déploiement sur Heroku. Le Dockerfile décrit la construction de l'image, où le code source est cloné, puis intégré à un serveur Nginx minimaliste pour servir l'application. Le fichier .gitlab-ci.yml structure le pipeline en plusieurs étapes, incluant la construction de l'image Docker, des tests d'acceptation, la publication de l'image sur un registre Docker, ainsi que le déploiement automatique sur des environnements Heroku (staging, production et environnement de revue pour les merge requests).

Le pipeline tire parti de services comme docker:dind pour gérer les conteneurs Docker et utilise des templates pour réutiliser les configurations de déploiement et de test sur différents environnements. Chaque étape est soigneusement orchestrée pour assurer une livraison continue en passant par des phases de tests automatisés avant chaque mise en production.
