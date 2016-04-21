function fmt = outputformat(F)
%OUTPUTFORMAT  Output format of a quantized FFT object.
%   Q = OUTPUTFORMAT(F) returns the value of the OUTPUTFORMAT property
%   of quantized FFT object F.  Quantized FFTs use the OUTPUTFORMAT to
%   quantize their outputs.  The value is either a QUANTIZER object or a
%   UNITQUANTIZER object.  For more information on this property, see the help
%   for QUANTIZER and UNITQUANTIZER.
%
%   The default is 
%     q = quantizer('fixed', 'floor', 'saturate', [16  15])
%
%   Example:
%     F = qfft
%     q = outputformat(F)
%
%   See also QFFT, QFFT/GET, QFFT/SET, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:25:41 $

fmt = F.outputformat;
