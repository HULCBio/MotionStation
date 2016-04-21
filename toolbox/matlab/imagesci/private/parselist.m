function list = parselist(listin)
%Parse comma seperated list into a cell array

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:53 $

if (isempty(listin))
    list = {};
else
    % Return a row vector.
    list = strread(listin, '%s', 'delimiter', ',')';
end
