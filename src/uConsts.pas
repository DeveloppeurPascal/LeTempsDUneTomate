unit uConsts;

interface

const
  /// <summary>
  /// Durée attendue d'un épisode
  /// </summary>
{$IFDEF DEBUG}
  CDureeEpisodeEnSecondes = 3 * 60;
{$ELSE}
  CDureeEpisodeEnSecondes = 25 * 60;
{$ENDIF}
  /// <summary>
  /// Durée en secondes repris sur l'épisode précédent en début du nouveau
  /// </summary>
  CDureeRattrapageEpisodePrecedent = 10;

  /// <summary>
  /// Durée en secondes pour le rappel de l'épisode précédent
  /// (jusqu'à sa durée moins la durée de rattrapage)
  /// </summary>
  CDureeRecap = 60 - CDureeRattrapageEpisodePrecedent;

  /// <summary>
  /// Durée d'affichage de l'écran de départ en secondes
  /// </summary>
  CDureeIntro = 3;

  /// <summary>
  /// Durée d'affichage de l'écran de fin en secondes
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
