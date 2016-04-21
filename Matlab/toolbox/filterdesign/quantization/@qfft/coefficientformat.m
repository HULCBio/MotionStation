function fmt = coefficientformat(F)
%COEFFICIENTFORMAT  Coefficient format of a quantized FFT object.
%   Q = COEFFICIENTFORMAT(F) returns the value of the COEFFICIENTFORMAT property
%   of quantized FFT object F.  Quantized FFTs use the COEFFICIENTFORMAT to
%   quantize their coefficients.  The value is either a QUANTIZER object or a
%   UNITQUANTIZER object.  For more information on this property, see the help
%   for QUANTIZER and UNITQUANTIZER.
%
%   FFT coefficients are also known as twiddle factors.
%
%   The default is 
%     q = quantizer('fixed', 'round', 'saturate', [16  15])
%
%   Example:
%     F = qfft
%     q = coefficientformat(F)
%
%   See also QFFT, QFFT/GET, QFFT/SET, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 15:27:04 $

fmt = F.coefficientformat;
