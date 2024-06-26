# 20240626 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* quelques changements au niveau des constantes pour gérer les bonnes durées et le FPS de la vidéo de départ et d'arrivée (le même pour les deux)
* répercussion de ces changements sur les paramètres de configuration du programme et ajout des paramètres manquants
* répercussion de ces changements sur les paramètres de configuration du projet et ajout des paramètres manquants
* adaptation du programme principal et du traitement des vidéos pour ne plus prendre en compte les constantes ni les paramètres de configuration du programme (hors FFmpeg qui n'a rien à faire au niveau du projet)
* suppression des constantes liées aux noms de fichiers par défaut (images de début, de fin et d'overlay, chemin de FFmpeg en dur)
* finalisation de la fenêtre de saisie des options du programme
* mise en place de la fenêtre de saisie des options de projet à partir de la fenêtre des options du programme
* prise en compte des données non enregistrées du projet actuel lors de sa fermeture, du lancement des opérations (refusées) et de la fermeture du programme

* released version 1.3 - 20240626
