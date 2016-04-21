function s = scalevalues(F)
%SCALEVALUES Return the value of the ScaleValues property of QFFT.
%   S = SCALEVALUES(F) returns the scale values.  They scale the input to each
%   section of the FFT.  The value of the ScaleValues property must be a scalar,
%   or a vector of length F.NumberOfSections.  For efficient computation, it is
%   recommended that the scale values are powers of 2.  If S is a scalar, then
%   the input to the first section of the quantized FFT or IFFT is scaled by S.
%   If S is a vector, then the input to the ith section of the FFT or IFFT is
%   scaled by S(i).
%
%   Examples:
%     F = qfft;
%     scalevalues(F)
%   returns the default 1.
%
%   See also QFFT, QFFT/FFT, QFFT/IFFT, QFFT/GET, QFFT/SET.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:26:13 $

s = get(F,'scalevalues');
