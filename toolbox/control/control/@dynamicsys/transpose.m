function L = transpose(L)
% Metadata management in SYS.' and SYS'

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:12:50 $

% Clear name
L.Name = '';

% Delete I/O names and groups
EmptyStr = {''};
ny = length(L.OutputName);
nu = length(L.InputName);
L.InputName = EmptyStr(ones(ny,1),:);
L.OutputName = EmptyStr(ones(nu,1),:);
L.InputGroup = struct;
L.OutputGroup = struct;