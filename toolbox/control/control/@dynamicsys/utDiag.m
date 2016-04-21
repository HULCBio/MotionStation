function L = utDiag(L)
% Metadata management in DIAG interconnection.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:12:57 $
% Notes and UserData
L.Notes = {};
L.UserData = [];
L.Name = '';

% I/O groups
L.InputGroup = struct;
L.OutputGroup = struct;

% I/O names
n = max(length(L.InputName),length(L.OutputName));
L.InputName(1:n,:) = {''};
L.OutputName(1:n,:) = {''};