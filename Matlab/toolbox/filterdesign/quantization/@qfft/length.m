function n = length(F)
%LENGTH  Length of a quantized FFT.
%   LENGTH(F) returns the value of the length property of quantized FFT
%   object F.  The value of the length property must be a positive
%   integer that is a power of the radix (F.RADIX).  The length of the
%   FFT is defined to be the length of the data vector that the FFT
%   operates on.
%
%   Example:
%     F = qfft;
%     length(F)
%   returns the default 16.
%
%   See also QFFT, QFFT/GET, QFFT/SET.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:25:52 $

n = F.length;
