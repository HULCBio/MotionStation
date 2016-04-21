function name = figname(str)
%FIGNAMER Chooses next available figure name.
%   NAME = FIGNAMER(STR) returns the next available figure name starting with STR.
%   Note that it even checks figures with HiddenHandles.

%   Author(s): A. Potvin, 11-1-94
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9 $

figs=allchild(0);
i = 1;
name = [str int2str(i)];
while ~isempty(findobj(figs,'flat','Name',name)),
   i = i +1;
   name = [str int2str(i)];
end

% end fignamer
