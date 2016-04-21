function lut = makelut(varargin)
%MAKELUT Construct lookup table for use with APPLYLUT.
%   LUT = MAKELUT(FUN,N) returns a lookup table for use with APPLYLUT.  FUN
%   is a function that accepts an N-by-N matrix of 1s and 0s and returns a
%   scalar.  N can be either 2 or 3.  MAKELUT creates LUT by passing all
%   possible 2-by-2 or 3-by-3 neighborhoods to FUN, one at a time, and
%   constructing either a 16-element vector (for 2-by-2 neighborhoods) or a
%   512-element vector (for 3-by-3 neighborhoods).  The vector consists of
%   the output from FUN for each possible neighborhood.
%
%   LUT = MAKELUT(FUN,N,P1,P2,...) passes the additional parameters P1, P2,
%   ..., to FUN.
%
%   FUN can be a FUNCTION_HANDLE, creating using @, or an INLINE object.
%
%   Class Support
%   -------------
%   LUT is returned as a vector of class double.
%
%   Example
%   -------
%       f = inline('sum(x(:)) >= 2');
%       lut = makelut(f,2);
%
%   See also APPLYLUT, FUNCTION_HANDLE, INLINE.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.20.4.2 $  $Date: 2003/08/01 18:09:23 $

if (nargin < 2)
    eid = sprintf('Images:%s:tooFewInputs',mfilename);
    msg = 'Too few input arguments';
    error(eid,'%s',msg);
end

fun = varargin{1};
n = varargin{2};
params = varargin(3:end);
fun = fcnchk(fun, length(params));

if (n == 2)
    lut = zeros(16,1);
    for k = 1:16
        a = reshape(fliplr(dec2bin(k-1,4) == '1'), 2, 2);
        lut(k) = feval(fun, a, params{:});
    end
    
elseif (n == 3)
    lut = zeros(512,1);
    for k = 1:512
        a = reshape(fliplr(dec2bin(k-1,9) == '1'), 3, 3);
        lut(k) = feval(fun, a, params{:});
    end
    
else
    eid = sprintf('Images:%s:invalidN',mfilename);
    msg = 'N must be 2 or 3';
    error(eid,'%s',msg);
end
