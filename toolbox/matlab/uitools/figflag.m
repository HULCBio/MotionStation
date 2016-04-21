function [flag,fig] = figflag(str,silent)
%FIGFLAG True if figure is currently displayed on screen.
%   [FLAG,FIG] = FIGFLAG(STR,SILENT) checks to see if any figure 
%   with Name STR is presently on the screen. If such a figure is 
%   presently on the screen, FLAG=1, else FLAG=0.  If SILENT=0, the
%   figures are brought to the front.
%
%   This function is OBSOLETE and may be removed in future versions.

%   Author: A. Potvin, 12-1-92,6-16-95
%   Modified: E.W. Gulley, 8-9-93
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.9 $  $Date: 2002/04/15 03:26:07 $

ni = nargin;
if ni==0,
   error('FIGFLAG must have at least one argument.');
elseif ni==1,
   silent = 0;
end

fig = findobj('Type','figure','Name',str)';
flag = ~isempty(fig);
if flag & ~silent,
   for i=fig,
      figure(i)
   end
end

% end figflag
