function q = coefficientformat(Hq)
%COEFFICIENTFORMAT  Coefficient format of a quantized filter object.
%   Q = COEFFICIENTFORMAT(Hq) returns the value of the COEFFICIENTFORMAT
%   property of quantized filter object Hq.  Quantized filters use the
%   COEFFICIENTFORMAT to quantize their coefficients.  The value is either a
%   QUANTIZER object or a UNITQUANTIZER object.  For more information on this
%   property, see the help for QUANTIZER and UNITQUANTIZER.
%
%   The default is 
%     q = quantizer('fixed', 'round', 'saturate', [16  15])
%
%   Example:
%     Hq = qfilt
%     q = coefficientformat(Hq)
%
%   See also QFILT, QFILT/GET, QFILT/SET, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:31:03 $

q = Hq.coefficientformat;
