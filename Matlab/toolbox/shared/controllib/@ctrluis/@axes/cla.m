function cla(h,ClearedAxes)
%CLA  Clears axes group in response to a CLA on one of the axes.
%
%   CLA reduces the axes group to a single (clear) HG axes occupying 
%   the full extent of the axes group.  CLEARAXES is the HG handle of
%   the cleared axes (single handle).

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:26 $

% Delete @axes object
h.Axes2d = [];  % to prevent deletion of CLEARAXES
delete(h)

% Clear selected axes
delete(ClearedAxes.UIcontextMenu)
cla(double(ClearedAxes),'reset')  % REVISIT

% Reset style
set(ClearedAxes,'Units','normalized',...
   'FontSize',get(0,'DefaultAxesFontSize'));