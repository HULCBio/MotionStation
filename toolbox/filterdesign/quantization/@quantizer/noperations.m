function n = noperations(q)
%NOPERATIONS  Number of quantization operations by quantizer object.
%   NOPERATIONS(Q) is the number of quantization operations during a call to
%   QUANTIZE(Q,...)  for quantizer object Q.  This value accumulates over
%   successive calls to QUANTIZE and is reset with RESET(Q).  
%
%   Example:
%     q = quantizer;
%     w = warning('on');
%     y = quantize(q,-20:10);
%     noperations(q)
%     % Returns 31 and a warning for 29 overflows.
%     warning(w);
%
%   See also QUANTIZER, QUANTIZER/GET, QUANTIZER/MAX, QUANTIZER/QUANTIZE,
%   QUANTIZER/RANGE, QUANTIZER/RESET. 

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/12 23:26:11 $

n = get(q,'noperations');
