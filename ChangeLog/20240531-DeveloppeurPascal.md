# 20240531 - [DeveloppeurPascal](https://github.com/XXX_USER_XXX)

* mise à jour des dépendances
* correction de la réactivation de l'interface en fin de traitement d'une liste de fichiers
* correction de quelques erreurs de compilation pour Windows (en DEBUG)
* suppression des plateformes non cibles du projet (iOS/Android)
* mise à jour des informations de version
* mise à jour du paramétrage de la boite de dialogue "à propos"
* ajout du module habituel de changement du titre de la fenêtre principale
* ajout du module habituel de remplissage de la licence et de la description du projet distribué en tant que shareware
* modification de la génération des éléments d'un épisode afin de ne pas les traiter s'ils existent déjà et permettre d'ajouter de nouvelles vidéos en fin de série sans tout regénérer
* création d'une image d'overlay "dans l'épisode précédent" pour choisir entre celle-ci et "précédemment" selon la série à traiter

* ajout de Pic Resize en sous-module pour utiliser la méthode de retaillage d'images : https://github.com/DeveloppeurPascal/Pic-Resize
* copie et adaptation de la méthode de retaillage de PicResize vers une méthode de la fiche principale
* ajout de la génération d'une image en 1280x720 (pour YouTube) à partir de la version 1920x1080

* mise en place d'un fichier de configuration pour le programme destiné à remplacer les constantes en dur dans l'exécutable

* mise en place d'un fichier de configuration par projet (= par dossier de stockage) servant à gérer les options d'une série de vidéos

* adaptation de la fiche principale pour utiliser les paramètres du projet en cours (s'il est ouvert) et de la configuration pour la génération des éléments (images et vidéos)

* changement de l'interface utilisateur pour prendre en charge la notion de projet et rendre le programme utilisable

* mise en ligne de la version 1.1 - 20240531

fr.olfsoftware.letempsdunetomate