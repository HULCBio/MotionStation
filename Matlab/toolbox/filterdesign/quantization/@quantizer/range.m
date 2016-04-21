function varargout = range(q)
%RANGE  Numerical range of a QUANTIZER object.
%   R = RANGE(Q), for QUANTIZER object Q, returns the two-element 
%   row vector R = [A B] such that for all real X,  
%   Y = QUANTIZE(Q,X) returns Y in the range A <= Y <= B.
%
%   [A,B] = RANGE(Q) returns the minimum and maximum values of the range in
%   separate output variables.
%
%   Examples:
%     q = quantizer('float',[6 3]);
%     r = range(q)
%   returns r = [-14 14].
%
%     q = quantizer('fixed',[4 2],'floor');
%     [a,b] = range(q)
%   returns a = -2,  b = 1.75 = 2 - eps(q).
%     
%   See also QUANTIZER, QUANTIZER/EPS, QUANTIZER/QUANTIZE.

%   Thomas A. Bryan, 7 May 1999.
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/14 15:34:18 $

switch q.mode
  case 'fixed'
    a = -realmax(q) - eps(q);
    b = realmax(q);
  case 'ufixed'
    a = 0;
    b = realmax(q);
  case {'double','float','single'}
    a = -realmax(q);
    b = realmax(q);
end
switch nargout
  case {0,1}
    varargout(1) = {[a b]};
  case 2
    varargout(1) = {a};
    varargout(2) = {b};
  otherwise
    error('Too many output arguments');
end
 
