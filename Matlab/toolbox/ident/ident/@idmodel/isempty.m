function kk=isempty(m)
% IDMODEL/ISEMPTY
% ISEMPTY(MOD)
% Returns 1 if MOD is an empty model and 0 otherwise

%   $Revision: 1.2 $  $Date: 2001/01/16 15:22:38 $
%   Copyright 1986-2001 The MathWorks, Inc.


[Ny,Nu] = size(m);
kk = (Ny==0)&(Nu==0);
