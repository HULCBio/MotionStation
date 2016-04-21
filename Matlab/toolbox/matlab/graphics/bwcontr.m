function newcolor = bwcontr(cc)
%BWCONTR Contrasting black or white color.
%   NEW = BWCONTR(COLOR) produces a black or white depending on which
%   one would contrast the most.  Used by NODITHER.
 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 17:08:02 $

if (isstr(cc))
    warning([mfilename ' was passed a string -- using black'])
    newcolor = [0 0 0];
else
    if ((cc * [.3; .59; .11]) > .75)
        newcolor = [0 0 0];
    else
        newcolor = [1 1 1];
    end
end
