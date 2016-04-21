function val = popupVal(handles,popupTag,choiceString)
% Returns flint value corresponding to the specified popup string choice
% Helper function for HIL Block GUI

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/08 20:45:07 $

h = eval(['handles.' popupTag]);
strings = get(h,'string');
val = -1;
for k = 1:length(strings),
    if strcmp(strings{k},choiceString),
        val = k;
        break;
    end
end
