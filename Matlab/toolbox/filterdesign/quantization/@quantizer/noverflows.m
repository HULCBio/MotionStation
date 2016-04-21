function n = noverflows(q)
%NOVERFLOWS  Number of overflows of quantizer object.
%   NOVERFLOWS(Q) is the number of overflows during a call to QUANTIZE(Q,...)
%   for quantizer object Q.  This value accumulates over successive calls to
%   QUANTIZE and is reset with RESET(Q).  An overflow is defined as a value,
%   that when quantized, is outside the range of Q.
%
%   Example:
%     q = quantizer;
%     w = warning('on');
%     y = quantize(q,-20:10);
%     noverflows(q)
%     % Returns 29 and a warning for 29 overflows.
%     warning(w);
%
%   See also QUANTIZER, QUANTIZER/GET, QUANTIZER/MAX, QUANTIZER/QUANTIZE,
%   QUANTIZER/RANGE, QUANTIZER/RESET. 

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/12 23:26:12 $

n = get(q,'noverflows');
