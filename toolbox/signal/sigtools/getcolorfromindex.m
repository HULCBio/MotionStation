function [color, marker, line] = getcolorfromindex(gca, indx)
%GETCOLORFROMINDEX Get the color by cycling through the Axes ColorOrder

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:54:10 $

colOrd = get(gca, 'ColorOrder');
mrkOrd = {'o','s','*','d','v'};
linOrd = {'-',':','-.','--'};

[row, col] = size(colOrd);

% Determine which row (number of colors) to use.
color  = colOrd(mod(indx-1,row)+1,:);

marker = mrkOrd{mod(ceil(indx/row)-1,length(mrkOrd))+1};
line   = linOrd{mod(ceil(indx/row)-1,length(linOrd))+1};

% [EOF]
