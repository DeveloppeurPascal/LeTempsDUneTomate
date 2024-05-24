unit uConsts;

interface

const
  /// <summary>
  /// Dur�e attendue d'un �pisode
  /// </summary>
{$IFDEF DEBUG}
  CDureeEpisodeEnSecondes = 3 * 60;
{$ELSE}
  CDureeEpisodeEnSecondes = 25 * 60;
{$ENDIF}
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

  CFFmpeg = '/Users/patrickpremartin/Downloads/ffmpeg-tests/ffmpeg';
  CPrecedemment =
    '/Users/patrickpremartin/Downloads/ffmpeg-tests/precedemment.png';
  CPageIntro =
    '/Users/patrickpremartin/Downloads/ffmpeg-tests/start-picture.png';
  CPageFinEpisode =
    '/Users/patrickpremartin/Downloads/ffmpeg-tests/end-picture.png';

  CVideoWidth = 1920;
  CVideoHeight = 1080;

implementation

end.
