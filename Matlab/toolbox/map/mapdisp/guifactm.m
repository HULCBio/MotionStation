function factor = guifactm(str)

% GUIFACTM computes scaling factors for cross platform GUIS
%
%  factor = GUIFACTM('pixels') compute the Pixel Scaling Factor
%
%  factor = GUIFACTM('fonts') compute the Font Scaling Factor
%
%  Use units of points to get GUIs that take into account the platform's
%  resolution and the pixel factor in the position values to scale the window
%  across platform.  For example, 'Units','Points', 'Position',
%  PixelFactor*72*[2 1 3 3.3] scales a window designed in inches.  A uicontrol
%  designed would look like 'Units','Points', 'Position', PixelFactor*[430 215
%  85 20].
%
%  Use 'FontSize',FontScaling*10 to scale fonts.
%
%  This function works well for GUIs that were designed on a Macintosh, and
%  need to work on other platforms.  GUIs designed on other platforms might
%  need a different scaling factor.
%

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf, E. Byrns
%   $Revision: 1.8.4.1 $    $Date: 2003/08/01 18:18:31 $



switch str
case 'pixels'

	factor = (72/get(0,'ScreenPixelsPerInch'))^.6;

case 'fonts'

	factor = get(0,'FactoryUicontrolFontSize')/10;

otherwise

	error('Unrecognized scaling string')

end
