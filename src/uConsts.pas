unit uConsts;

interface

const
  /// <summary>
  /// Dur�e attendue d'un �pisode (en minutes)
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
  /// Dur�e en secondes repris sur l'�pisode pr�c�dent en d�but du nouveau
  /// </summary>
  CDureePreviouslyAndNow = 10;

  /// <summary>
  /// Dur�e en secondes pour le rappel de l'�pisode pr�c�dent
  /// </summary>
  CDureePreviously = 60;

  /// <summary>
  /// Dur�e d'affichage de l'�cran de d�part en secondes
  /// </summary>
  CDureeIntro = 3;

  /// <summary>
  /// Dur�e d'affichage de l'�cran de fin en secondes
  /// </summary>
  CDureeFin = 5;

  /// <summary>
  /// Default Frame Per Seconds in the source and final videos
  /// </summary>
  CVideoFPS = 30;

implementation

end.
