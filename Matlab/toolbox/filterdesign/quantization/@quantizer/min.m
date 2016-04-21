function m = min(q)
%MIN  Min of quantizer object.
%   MIN(Q) is the minimum value before quantization during a call to
%   QUANTIZE(Q,...) for quantizer object Q.  This value is the min over
%   successive calls to QUANTIZE and is reset with RESET(Q).  
%
%   Example:
%     q = quantizer;
%     w = warning('on');
%     y = quantize(q,-20:10);
%     min(q)
%     % Returns -20 and a warning for 29 overflows.
%     warning(w);
%
%   See also QUANTIZER, QUANTIZER/GET, QUANTIZER/MAX, QUANTIZER/QUANTIZE,
%   QUANTIZER/RESET. 

%   Thomas A. Bryan
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/12 23:26:10 $

m = get(q,'min');
