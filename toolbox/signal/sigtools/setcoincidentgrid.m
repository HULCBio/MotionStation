function setcoincidentgrid(hallax)
%SETCOINCIDENTGRID Set coincident grids for two axes.
%
%   SETCOINCIDENTGRID(HAXES) creates coincident grids for the 
%   two Y-axes specified by the two element vector of axes handles
%   HAXES.

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:50:36 $ 

% Create coincident grids
ylimits1 = get(hallax(1),'YLim');
ylimits2 = get(hallax(2),'YLim');
yinc1 = (ylimits1(2)-ylimits1(1))/5;
yinc2 = (ylimits2(2)-ylimits2(1))/5;
set(hallax(1),'YTick',[ylimits1(1):yinc1:ylimits1(2)])
set(hallax(2),'YTick',[ylimits2(1):yinc2:ylimits2(2)])

% [EOF]
