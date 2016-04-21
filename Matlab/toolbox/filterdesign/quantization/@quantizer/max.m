function m = max(q)
%MAX  Max of quantizer object.
%   MAX(Q) is the maximum value before quantization during a call to
%   QUANTIZE(Q,...) for quantizer object Q.  This value is the max over
%   successive calls to QUANTIZE and is reset with RESET(Q).  
%
%   Example:
%     q = quantizer;
%     w = warning('on');
%     y = quantize(q,-20:10);
%     % Returns 10 and a warning for 29 overflows.
%     max(q)
%
%   See also QUANTIZER, QUANTIZER/GET, QUANTIZER/MIN, QUANTIZER/QUANTIZE,
%   QUANTIZER/RESET. 

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/12 23:26:09 $


m = get(q,'max');

