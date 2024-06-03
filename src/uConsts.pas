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
  CDureeRattrapageEpisodePrecedent = 10;

  /// <summary>
  /// Dur�e en secondes pour le rappel de l'�pisode pr�c�dent
  /// (jusqu'� sa dur�e moins la dur�e de rattrapage)
  /// </summary>
  CDureeRecap = 60 - CDureeRattrapageEpisodePrecedent;

  /// <summary>
  /// Dur�e d'affichage de l'�cran de d�part en secondes
  /// </summary>
  CDureeIntro = 3;

  /// <summary>
  /// Dur�e d'affichage de l'�cran de fin en secondes
  /// </summary>
  CDureeFin = 5;

  // TODO : supprimer ces constantes li�es et les laisser en fen�tre d'option du programme
  CFFmpeg = '/Volumes/LeTempsDUneTomate/ffmpeg';
  CPrecedemment = '/Volumes/LeTempsDUneTomate/precedemment.png';
  CPageIntro = '/Volumes/LeTempsDUneTomate/start-picture.png';
  CPageFinEpisode = '/Volumes/LeTempsDUneTomate/end-picture.png';

implementation

end.
