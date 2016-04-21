function L = repsys(L,s)
% Metadata management for REPSYS

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:13:05 $
L.Name = '';
[ny,nu] = iosize(L);
if isscalar(s)
   s = [s s];
end
L.InputName(1:nu*s(2),:) = {''};
L.OutputName(1:ny*s(1),:) = {''};
L.InputGroup = struct;
L.OutputGroup = struct;