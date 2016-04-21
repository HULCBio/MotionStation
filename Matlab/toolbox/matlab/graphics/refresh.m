function refresh(h)
%REFRESH Refresh figure.
%   REFRESH causes the current figure window to be redrawn. 
%   REFRESH(FIG) causes the figure FIG to be redrawn.

%   D. Thomas   5/26/93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.11 $  $Date: 2002/04/10 17:08:05 $

if nargin==1,
    if ~strcmp(get(h,'type'),'figure'),
        error('Handle does not refer to a figure object')
    end
else,
    h = gcf;
end

color = get(h,'color');
if ~isstr(color) & color == [0 0 0]
    tmpcolor = [1 1 1];
else
    tmpcolor = [0 0 0];
end
set(h,'color',tmpcolor,'color',color);
