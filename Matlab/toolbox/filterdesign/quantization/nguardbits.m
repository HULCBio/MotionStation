function n = nguardbits(naccum)
%NGUARDBITS Return the number of guard bits N necessary to accumulate
%   NACCUM times without overflow 

%   Author(s): V. Pellissier
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/06 15:47:20 $

error(nargchk(1,1,nargin))
if naccum<0,
    error('First input argument must be positive.');
end
n = ceil(log2(naccum+1));

% [EOF]
