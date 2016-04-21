function setposition(h,varargin)
%SETPOSITION   Sets axes group position.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:55 $

% Grid position: delegate to @plotarray object
% Scaled Resize (for printing)

Geometry = h.Axes.Geometry;
op = get(h.Parent,'OuterPosition');
fp = get(h.Parent,'Position');
labtitle = hglabel(h,'Title');
if fp(4) > op(4) & strcmpi(get(labtitle,'Units'),'points')
    % Use scale factor when resizing prior to print
    pp = get(h.Parent,'PaperPosition');
    printscale = fp(4)/pp(4);
else
    % Dont use scale factor when returning from print
    printscale = 1;
end
Geometry.PrintScale = printscale;
h.Axes.Geometry = Geometry;
%
h.Axes.setposition(h.Position);
% Background axes
set(h.BackgroundAxes,'Position',h.Position)
% Adjust label position
labelpos(h);