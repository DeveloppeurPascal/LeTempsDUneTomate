(* C2PP
  ***************************************************************************

  Le temps d'une tomate

  Copyright 2024-2025 Patrick PREMARTIN under AGPL 3.0 license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://developpeur-pascal.fr/le-temps-d-une-tomate.html

  Project site :
  https://github.com/DeveloppeurPascal/LeTempsDUneTomate

  ***************************************************************************
  File last update : 2025-10-16T10:42:09.121+02:00
  Signature : df938843ea3c8bd6bcc74481f444ba9c7eaae8fc
  ***************************************************************************
*)

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
