unit uConsts;

interface

const
  /// <summary>
  /// Durée attendue d'un épisode (en minutes)
  /// </summary>
  /// <remarks>
  /// Utiliser la valeur depuis TConfig ou TProject, pas la constante !
  /// </remarks>
{$IFDEF DEBUG}
  // CDureeEpisodeEnMinutes = 3;
  CDureeEpisodeEnMinutes = 25;
{$ELSE}
  CDureeEpisodeEnMinutes = 25;
{$ENDIF}
  /// <summary>
  /// Default video width
  /// </summary>
  /// <remarks>
  /// Utiliser la valeur depuis TConfig ou TProject, pas la constante !
  /// </remarks>
  CVideoWidth = 1920;

  /// <summary>
  /// Default video height
  /// </summary>
  /// <remarks>
  /// Utiliser la valeur depuis TConfig ou TProject, pas la constante !
  /// </remarks>
  CVideoHeight = 1080;

  /// <summary>
  /// Durée en secondes repris sur l'épisode précédent en début du nouveau
  /// </summary>
  CDureePreviouslyAndNow = 10;

  /// <summary>
  /// Durée en secondes pour le rappel de l'épisode précédent
  /// </summary>
  CDureePreviously = 60;

  /// <summary>
  /// Durée d'affichage de l'écran de départ en secondes
  /// </summary>
  CDureeIntro = 3;

  /// <summary>
  /// Durée d'affichage de l'écran de fin en secondes
  /// </summary>
  CDureeFin = 5;

  /// <summary>
  /// Default Frame Per Seconds in the source and final videos
  /// </summary>
  CVideoFPS = 30;

implementation

end.
