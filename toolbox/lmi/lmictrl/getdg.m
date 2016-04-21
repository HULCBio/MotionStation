% D=getdg(ds,i)
% G=getdg(gs,i)
%
% Given the matrices DS and GS returned by MUSTAB, this
% function extracts the optimal D,G scalings at the
% i-th frequency FREQS(i)
%
% See also  MUSTAB.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function d=getdg(ds,i)

n=round(sqrt(size(ds,1)));
d=reshape(ds(:,i),n,n);
