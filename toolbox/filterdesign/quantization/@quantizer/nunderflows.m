function n = nunderflows(q)
%NUNDERFLOWS  Number of underflows of quantizer object.
%   NUNDERFLOWS(Q) is the number of underflows during a call to
%   QUANTIZE(Q,...)  for quantizer object Q.  This value accumulates
%   over successive calls to QUANTIZE and is reset with RESET(Q).  An
%   underflow is defined as a number that is nonzero before it is
%   quantized, and zero after it is quantized.
%
%   Example:
%     q = quantizer('fixed','floor',[4 3]);
%     x = (0:eps(q)/4:2*eps(q))';
%     y = quantize(q,x);
%     nunderflows(q)
%   returns 3.  By looking at x and y, you can see which ones went to zero:
%     [x y]
%
%   See also QUANTIZER, QUANTIZER/EPS, QUANTIZER/DENORMALMIN,
%   QUANTIZER/QUANTIZE, QUANTIZER/RESET.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:34:39 $

n = get(q,'nunderflows');
