function q = sumformat(Hq)
%SUMFORMAT  Sum format of a quantized filter object.
%   Q = SUMFORMAT(Hq) returns the value of the SUMFORMAT property of quantized
%   filter object Hq.  Quantized filters use the SUMFORMAT to quantize their
%   sums.  The value is either a QUANTIZER object or a UNITQUANTIZER object.
%   For more information on this property, see the help for QUANTIZER and
%   UNITQUANTIZER.
%
%   The default is 
%     q = quantizer('fixed', 'floor', 'saturate', [32 30])
%
%   Example:
%     Hq = qfilt
%     q = sumformat(Hq)
%
%   See also QFILT, QFILT/GET, QFILT/SET, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:29:37 $

q = Hq.sumformat;
