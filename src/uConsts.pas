unit uConsts;

interface

const
  /// <summary>
  /// Dur�e attendue d'un �pisode
  /// </summary>
  CDureeEpisodeEnSecondes = 25 * 60;

  /// <summary>
  /// Dur�e en secondes repris sur l'�pisode pr�c�dent en d�but du nouveau
  /// </summary>
  CDureeRattrapageEpisodePrecedent = 10;

  /// <summary>
  /// Dur�e en secondes pour le rappel de l'�pisode pr�c�dent
  /// (jusqu'� sa dur�e moins la dur�e de rattrapage)
  /// </summary>
  CDureeRecap = 60 - CDureeRattrapageEpisodePrecedent;

  CFFmpeg = '/Users/patrickpremartin/Downloads/ffmpeg-tests/ffmpeg';

implementation

end.
