function q = multiplicandformat(Hq)
%MULTIPLICANDFORMAT  Multiplicand format of a quantized filter object.
%   Q = MULTIPLICANDFORMAT(Hq) returns the value of the MULTIPLICANDFORMAT property of
%   quantized filter object Hq.  Quantized filters use the MULTIPLICANDFORMAT to
%   quantize their multiplicands.  The value is either a QUANTIZER object or a
%   UNITQUANTIZER object.  For more information on this property, see the help
%   for QUANTIZER and UNITQUANTIZER.
%
%   A multiplicand is defined as a number that is to be multiplied by a filter
%   coefficient.  
%
%   The default is 
%     q = quantizer('fixed', 'floor', 'saturate', [16  15])
%
%   Example:
%     Hq = qfilt
%     q = multiplicandformat(Hq)
%
%   See also QFILT, QFILT/GET, QFILT/SET, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:31:21 $

q = Hq.multiplicandformat;
