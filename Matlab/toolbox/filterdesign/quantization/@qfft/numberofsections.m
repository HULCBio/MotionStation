function n = numberofsections(F)
%NUMBEROFSECTIONS Return the value of the NumberOfSections property of QFFT.
%   NUMBEROFSECTIONS(F) returns the value of the Numberofsections property of
%   quantized FFT object F.  The number of sections is equal to
%   log2(F.length)/log2(F.radix).  Sections of an FFT are also known as
%   stages. 
%
%   Examples:
%     F = qfft;
%     numberofsections(F)
%   returns the default 4 = log2(16).
%
%   See also QFFT, QFFT/FFT, QFFT/IFFT, QFFT/GET, QFFT/SET.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 15:26:40 $

n = get(F,'numberofsections');
