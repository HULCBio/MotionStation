% pds = addpv(pds,pv)
%
% Adds the parameter vector description to a parameter-
% dependent system
%
% See also  PDSIMUL.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function pds = addpv(pds,pv)

[rpv,cpv]=size(pv);
ls=size(pds,2);
pds(1:rpv,ls+1:ls+cpv)=pv;
