function f = flops(x)
%FLOPS Obsolete floating point operation count.
%   Earlier versions of MATLAB counted the number of floating point
%   operations.  With the incorporation of LAPACK in MATLAB 6, this
%   is no longer practical.  

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.1 $  $Date: 2004/01/24 09:21:21 $

if (nargin < 1) || (x ~= 0)
    warning('MATLAB:flops:UnavailableFunction', ...
        'Flop counts are no longer available.')
end
if nargout > 0
    f = 0;
end
