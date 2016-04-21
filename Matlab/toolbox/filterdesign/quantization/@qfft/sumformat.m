function fmt = sumformat(F)
%SUMFORMAT  Sum format of a quantized FFT object.
%   Q = SUMFORMAT(F) returns the value of the SUMFORMAT property
%   of quantized FFT object F.  Quantized FFTs use the SUMFORMAT to
%   quantize their sums.  The value is either a QUANTIZER object or a
%   UNITQUANTIZER object.  For more information on this property, see the help
%   for QUANTIZER and UNITQUANTIZER.
%
%   The default is 
%     q = quantizer('fixed', 'floor', 'saturate', [32 30])
%
%   Example:
%     F = qfft
%     q = sumformat(F)
%
%   See also QFFT, QFFT/GET, QFFT/SET, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:26:01 $

fmt = F.sumformat;
