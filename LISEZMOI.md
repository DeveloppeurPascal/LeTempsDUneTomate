# Le temps d'une tomate

[This page in English.](README.md)

Le temps d'une tomate est un utilitaire développé en Delphi et basé sur la librairie FFmpeg pour découper des vidéos longues en séries de 20 à 25 minutes (le temps d'une pomodoro, d'où son intitulé). De nouvelles vidéos sont ensuite composées d'images de début, de fin, d'un extrait de la vidéo précédente et du contenu de l'épisode en cours.

Le tout fonctionne en utilisant FFmpeg en ligne de commande sur les vidéos stockées dans un dossier.

Ce dépôt de code contient un projet développé en langage Pascal Objet sous Delphi. Vous ne savez pas ce qu'est Dephi ni où le télécharger ? Vous en saurez plus [sur ce site web](https://delphi-resources.developpeur-pascal.fr/).

## Présentations et conférences

### Twitch

Suivez mes streams de développement de logiciels, jeux vidéo, applications mobiles et sites web sur [ma chaîne Twitch](https://www.twitch.tv/patrickpremartin) ou en rediffusion sur [Serial Streameur](https://serialstreameur.fr) la plupart du temps en français.

## Utiliser ce logiciel

Ce logiciel est disponible dans une version de production directement installable ou exécutable. Il est distribué en shareware.

Vous pouvez le télécharger et le rediffuser gratuitement à condition de ne pas en modifier le contenu (installeur, programme, fichiers annexes, ...).

[Télécharger le programme ou son installeur](DDD) (WIP)

Si vous utilisez régulièrement ce logiciel et en êtes satisfait vous êtes invité à en acheter une licence d'utilisateur final. L'achat d'une licence vous donnera accès aux mises à jour du logiciel en plus d'activer d'évenuelles fonctionnalités optionnelles.

[Acheter une licence](FFF) (WIP)

Vous pouvez aussi [consulter le site du logiciel](EEE) (WIP) pour en savoir plus sur son fonctionnement, accéder à des vidéos et articles, connaître les différentes versions disponibles et leurs fonctionnalités, contacter le support utilisateurs...

Ce programme a été développé pour alimenter [une playlist sur YouTube](https://www.youtube.com/playlist?list=PLI4jHydEwwtXKEELbExiToJSTjEF2CXWy) (et d'autres sites).

## Installation des codes sources

Pour télécharger ce dépôt de code il est recommandé de passer par "git" mais vous pouvez aussi télécharger un ZIP directement depuis [son dépôt GitHub](https://github.com/DeveloppeurPascal/LeTempsDUneTomate).

Ce projet utilise des dépendances sous forme de sous modules. Ils seront absents du fichier ZIP. Vous devrez les télécharger à la main.

* [DeveloppeurPascal/AboutDialog-Delphi-Component](https://github.com/DeveloppeurPascal/AboutDialog-Delphi-Component) doit être installé dans le sous dossier ./lib-externes/AboutDialog-Delphi-Component
* [DeveloppeurPascal/Delphi-FMXExtend-Library](https://github.com/DeveloppeurPascal/Delphi-FMXExtend-Library) doit être installé dans le sous dossier ./lib-externes/Delphi-FMXExtend-Library
* [DeveloppeurPascal/librairies](https://github.com/DeveloppeurPascal/librairies) doit être installé dans le sous dossier ./lib-externes/librairies
* [DeveloppeurPascal/Pic-Resize](https://github.com/DeveloppeurPascal/Pic-Resize) doit être installé dans le sous dossier ./lib-externes/Pic-Resize
* [DeveloppeurPascal/Video-Title-Page-Generator](https://github.com/DeveloppeurPascal/Video-Title-Page-Generator) doit être installé dans le sous dossier ./lib-externes/Video-Title-Page-Generator
* [DeveloppeurPascal/YTVideoSeries](https://github.com/DeveloppeurPascal/YTVideoSeries) doit être installé dans le sous dossier ./lib-externes/YTVideoSeries
* [TurboPack/DOSCommand](https://github.com/TurboPack/DOSCommand) doit être installé dans le sous dossier ./lib-externes/DOSCommand

## Licence d'utilisation de ce dépôt de code et de son contenu

Ces codes sources sont distribués sous licence [AGPL 3.0 ou ultérieure](https://choosealicense.com/licenses/agpl-3.0/).

Vous êtes globalement libre d'utiliser le contenu de ce dépôt de code n'importe où à condition :
* d'en faire mention dans vos projets
* de diffuser les modifications apportées aux fichiers fournis dans ce projet sous licence AGPL (en y laissant les mentions de copyright d'origine (auteur, lien vers ce dépôt, licence) obligatoirement complétées par les vôtres)
* de diffuser les codes sources de vos créations sous licence AGPL

Si cette licence ne convient pas à vos besoins vous pouvez acheter un droit d'utilisation de ce projet sous la licence [Apache License 2.0](https://choosealicense.com/licenses/apache-2.0/) ou une licence commerciale dédiée ([contactez l'auteur](https://developpeur-pascal.fr/nous-contacter.php) pour discuter de vos besoins).

Ces codes sources sont fournis en l'état sans garantie d'aucune sorte.

Certains éléments inclus dans ce dépôt peuvent dépendre de droits d'utilisation de tiers (images, sons, ...). Ils ne sont pas réutilisables dans vos projets sauf mention contraire.

## Comment demander une nouvelle fonctionnalité, signaler un bogue ou une faille de sécurité ?

Si vous voulez une réponse du propriétaire de ce dépôt la meilleure façon de procéder pour demander une nouvelle fonctionnalité ou signaler une anomalie est d'aller sur [le dépôt de code sur GitHub](https://github.com/DeveloppeurPascal/LeTempsDUneTomate) et [d'ouvrir un ticket](https://github.com/DeveloppeurPascal/LeTempsDUneTomate/issues).

Si vous avez trouvé une faille de sécurité n'en parlez pas en public avant qu'un correctif n'ait été déployé ou soit disponible. [Contactez l'auteur du dépôt en privé](https://developpeur-pascal.fr/nous-contacter.php) pour expliquer votre trouvaille.

Vous pouvez aussi cloner ce dépôt de code et participer à ses évolutions en soumettant vos modifications si vous le désirez. Lisez les explications dans le fichier [CONTRIBUTING.md](CONTRIBUTING.md).

## Supportez ce projet et son auteur

Si vous trouvez ce dépôt de code utile et voulez le montrer, merci de faire une donation [à son auteur](https://github.com/DeveloppeurPascal). Ca aidera à maintenir le projet (codes sources et binaires).

Vous pouvez utiliser l'un de ces services :

* [GitHub Sponsors](https://github.com/sponsors/DeveloppeurPascal)
* [Liberapay](https://liberapay.com/PatrickPremartin)
* [Patreon](https://www.patreon.com/patrickpremartin)
* [Paypal](https://www.paypal.com/paypalme/patrickpremartin)

ou si vous parlez français vous pouvez [vous abonner à Zone Abo](https://zone-abo.fr/nos-abonnements.php) sur une base mensuelle ou annuelle et avoir en plus accès à de nombreuses ressources en ligne (vidéos et articles).
