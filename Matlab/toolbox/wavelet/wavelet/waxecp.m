function [cp,xlim,ylim] = waxecp(fig,axe)
%WAXECP BUG for axes CurrentPoint property.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 06-Feb-98.
%   Last Revision: 01-Jun-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.9 $

% We suppose that fig and axes use same units.
%---------------------------------------------
xlim = get(axe,'Xlim');
ylim = get(axe,'Ylim');
cp   = get(axe,'CurrentPoint');
cp   = cp(1,1:2);
