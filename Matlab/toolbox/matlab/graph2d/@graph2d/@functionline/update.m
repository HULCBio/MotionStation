function y = update(hfuncLine)
% UPDATE  Update functionline based on axes limits.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $  $Date: 2004/04/10 23:26:21 $

hAxes = ancestor(hfuncLine,'axes');

% Compute a step size that results in n points, n determined
% from Granularity, being plotted.  Then build an array of these points.
gran = hfuncLine.Granularity;
xlims = get(hAxes,'xlim');
x = linspace(xlims(2), xlims(1), gran);

if ~isempty(hfuncLine.Function) & iscell(hfuncLine.UserArgs)
   y = feval(hfuncLine.Function, x, hfuncLine.UserArgs{:});

   % Set the XData to be the points evenly spaced
   % between the X Limits.
   % Set the YData to be the result of the function
   % applied to the XData.
   set(hfuncLine, 'xdata', x, 'ydata', y);
end

% Opaque array methods need to know how many left-hand-sides were
% requested, so we must always return one argument.
y = [];


