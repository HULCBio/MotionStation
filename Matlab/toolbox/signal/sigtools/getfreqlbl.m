function xlbl = getfreqlbl(xunits)
%GETFREQLBL Returns a label for the frequency axis.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:53:16 $

options = getfrequnitstrs;

xlbl = options{1};
for i = length(options):-1:1,
    if strfind(options{i}, xunits),
        xlbl = options{i};
    end
end

% [EOF]
