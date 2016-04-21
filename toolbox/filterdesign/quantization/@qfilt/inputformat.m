function q = inputformat(Hq)
%INPUTFORMAT  Input format of a quantized filter object.
%   Q = INPUTFORMAT(Hq) returns the value of the INPUTFORMAT property of
%   quantized filter object Hq.  Quantized filters use the INPUTFORMAT to
%   quantize their inputs.  The value is either a QUANTIZER object or a
%   UNITQUANTIZER object.  For more information on this property, see the help
%   for QUANTIZER and UNITQUANTIZER.
%
%   The default is 
%     q = quantizer('fixed', 'floor', 'saturate', [16  15])
%
%   Example:
%     Hq = qfilt
%     q = inputformat(Hq)
%
%   See also QFILT, QFILT/GET, QFILT/SET, QUANTIZER, UNITQUANTIZER.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/14 15:30:40 $

q = Hq.inputformat;
