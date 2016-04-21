function m = mode(q)
%MODE  Mode of a quantizer object.
%   MODE(Q) returns the mode of quantizer object Q.  The mode of a quantizer
%   object can be one of the strings:
%
%     double -  Double precision IEEE floating point.
%     fixed  -  Signed fixed-point in two's complement format.
%     float  -  Custom-precision floating-point.
%     single -  Single precision IEEE floating point.
%     ufixed -  Unsigned fixed-point.
%
%   Example:
%     q = quantizer;
%     mode(q)
%   returns the default 'fixed'.
%
%   See also QUANTIZER, QUANTIZER/GET, QUANTIZER/SET.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:34:48 $

m = get(q,'mode');



