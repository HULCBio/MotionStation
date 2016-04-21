function holdstate = ishold(ca)
%ISHOLD Return hold state.
%   ISHOLD returns 1 if hold is on, and 0 if it is off.
%   When HOLD is ON, the current plot and all axis properties
%   are held so that subsequent graphing commands add to the 
%   existing graph.
%
%   Hold on means the NextPlot property of both figure
%   and axes is set to "add".
%
%   See also HOLD, NEWPLOT, FIGURE, AXES.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.11.4.2 $  $Date: 2004/04/10 23:28:51 $

%ISHOLD(AXH) returns whether hold is on for the specified axis

if nargin<1
    cf = gcf;
    ca = get(cf,'currentaxes');
    if isempty(ca)
        holdstate = 0;
        return;
    end
else
    ca=ca(1);
    cf = ancestor(ca,'figure');
end

holdstate = strcmp(get(ca,'nextplot'),'add') & ...
           strcmp(get(cf,'nextplot'),'add');
