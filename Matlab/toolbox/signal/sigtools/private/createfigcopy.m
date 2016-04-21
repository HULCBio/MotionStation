function hFig_printprev = createfigcopy(hAx)
%CREATEFIGCOPY Copy axes to its own figure

%   Author(s): R. Losada, P. Pacheco, P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:48:25 $ 

% Create a "print preview" figure and copy FDATool's analysis axis.
hFig_printprev = figure(...
    'Number','off',...
    'visible','off');

copyobj(hAx,hFig_printprev);

% Get handle to the axes of print preview figure.
hax_printprev = findobj(hFig_printprev,'Type','axes');

% Delete invisible axis.
hax_printprev = delInvisibleax(hax_printprev);

% Set print preview's axis position to the default size in normalized units.
ax_pos = [0.1300 0.1100 0.7750 0.8150];  
set(hax_printprev,'Position',ax_pos);


%---------------------------------------------------------------------
function hax_printprev = delInvisibleax(hax_printprev)
% DELINVISIBLEAX Deletes the invisble axis.
%
% Input:
%   hax_printprev - handle to the print preview axes.
% Output:
%   hax_printprev - handle to the print preview axis that's visible.

% Delete the invisible axis.
visStates = get(hax_printprev,'Visible');
indx = find(strcmpi(visStates,'off'));
delete(hax_printprev(indx));
hax_printprev(indx) = [];

% [EOF]
