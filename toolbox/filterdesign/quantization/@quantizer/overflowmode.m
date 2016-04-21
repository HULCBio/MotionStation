function m = overflowmode(q)
%OVERFLOWMODE  Overflow mode of a quantizer object.
%   OVERFLOWMODE(Q) returns the overflow mode of quantizer object Q.  A
%   number X is said to overflow if it falls outside the range of Q
%   during a call to QUANTIZE(Q,X). The overflow mode of a quantizer
%   object can be one of the strings:
%
%     saturate - Saturate to max or min value of quantizer range on overflow.
%     wrap     - Wrap on overflow.  Also known as two's complement
%                overflow.
%
%   Example:
%     q = quantizer;
%     overflowmode(q)
%   returns the default 'saturate'.
%
%   See also QUANTIZER, QUANTIZER/GET, QUANTIZER/SET, QUANTIZER/RANGE.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:34:36 $

m = get(q,'overflowmode');
