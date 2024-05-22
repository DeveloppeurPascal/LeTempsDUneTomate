unit uConsts;

interface

const
  /// <summary>
  /// Durée attendue d'un épisode
  /// </summary>
  CDureeEpisodeEnSecondes = 25 * 60;

  /// <summary>
  /// Durée en secondes repris sur l'épisode précédent en début du nouveau
  /// </summary>
  CDureeRattrapageEpisodePrecedent = 10;

  /// <summary>
  /// Durée en secondes pour le rappel de l'épisode précédent
  /// (jusqu'à sa durée moins la durée de rattrapage)
  /// </summary>
  CDureeRecap = 60 - CDureeRattrapageEpisodePrecedent;

  CFFmpeg = '/Users/patrickpremartin/Downloads/ffmpeg-tests/ffmpeg';

implementation

end.
