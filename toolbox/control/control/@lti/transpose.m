function L = transpose(L)
%TRANSPOSE  LTI properties management in transpose operations
%
%   SYS.LTI = (SYS.LTI).'

%       Author(s): P. Gahinet, 5-28-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.12.4.1 $

% Get I/O dims
nu = length(L.InputName);
ny = length(L.OutputName);

% Delete I/O names and groups
EmptyStr = {''};
L.InputName = EmptyStr(ones(ny,1),1);
L.OutputName = EmptyStr(ones(nu,1),1);
L.InputGroup = struct;
L.OutputGroup = struct;

% Transpose delay times
L.ioDelay = permute(L.ioDelay,[2 1 3:ndims(L.ioDelay)]);
Li = L.InputDelay;
L.InputDelay = L.OutputDelay;
L.OutputDelay = Li;
