function graymon
%GRAYMON Set graphics defaults for gray-scale monitors.
%   GRAYMON changes the default graphics properties to produce
%   legible displays for gray-scale monitors.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 04:29:05 $

ch = get(0,'children');
if isempty(ch)
   fig = 0;
else
   fig = [gcf 0];
end
co = [.75 .5 .25]'*ones(1,3);
set(fig,'defaultaxescolororder',co)
