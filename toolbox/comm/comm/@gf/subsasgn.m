function z=subsasgn(x,s,y)
%SUBSASGN Subscripted assignment A(I)=B for GF arrays.
%   A(I) = B assigns the values of B into the elements of A specifed by
%   the subscript vector I.  B must have the same number of elements as I
%   or be a scalar. 

%    Copyright 1996-2002 The MathWorks, Inc.
%    $Revision: 1.3 $  $Date: 2002/03/27 00:16:39 $ 

switch s.type
case '()'
  z=x;
  y=gf(y,x.m,x.prim_poly);
  z.x(s.subs{:}) = y.x;
case '{}'
  error('{} reference not allowed for assignment')
case '.'
  error('. reference not allowed for assignment')
end

