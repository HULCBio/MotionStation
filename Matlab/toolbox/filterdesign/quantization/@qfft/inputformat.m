function fmt = inputformat(F)
%INPUTFORMAT  Input format of a quantized FFT object.
%   Q = INPUTFORMAT(F) returns the value of the INPUTFORMAT property of
%   quantized FFT object F.  Quantized FFTs use the INPUTFORMAT to quantize
%   their inputs.  The value is either a QUANTIZER object or a UNITQUANTIZER
%   object.  For more information on this property, see the help for QUANTIZER
%   and UNITQUANTIZER.
%
%   The default is 
%     q = quantizer('fixed', 'floor', 'saturate', [16  15])
%
%   Example:
%     F = qfft
%     q = inputformat(F)
%
%   See also QFFT, QFFT/GET, QFFT/SET, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/14 15:26:43 $

fmt = F.inputformat;
