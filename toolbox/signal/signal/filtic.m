function vinit = filtic( b, a, ypast, xpast )
%FILTIC Make initial conditions for 'filter' function.
%   Z = filtic( B, A, Y, X ) converts past input X and output Y
%   into initial conditions for the state variables Z needed in the
%       TRANSPOSED DIRECT FORM II filter structure.
%   The vectors of past inputs & outputs are stored with more recent
%   values first, i.e.
%          X = [ x[-1] x[-2] x[-3] ... x[-nb] ... ]
%          Y = [ y[-1] y[-2] y[-3] ... y[-na] ... ]
%   where nb = length(B)-1 and na = length(A)-1.  Short input vectors
%   X and Y are zeropadded to length nb and na respectively.  If X
%   or Y are longer than nb or na, the values beyond those lengths
%   are irrelevant to the filter's initial conditions and are ignored.
%
%   Z = filtic( B, A, Y ) assumes that X = 0 in the past.
%
%   See also FILTER.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 01:11:22 $

if nargin == 3
   xpast = [0];   % this is the zero input condition
end
if (sum(size(a)>1)>1)|(sum(size(b)>1)>1)| ...
      (sum(size(xpast)>1)>1)|(sum(size(ypast)>1)>1)
    error('Requires vector (row or column) inputs.')
end
na = length(a);   nb = length(b);
m = max([na nb]) - 1;
if( m < 1 )
   vinit = [];  return
end
Lx = length(xpast);   Ly = length(ypast);
if( Lx < (nb-1) ),   xpast(nb-1) = 0;    end   %--- zero pad
if( Ly < (na-1) ),   ypast(na-1) = 0;    end
vinit = zeros(1,m);  vx = vinit;
% --- use filter() to do convolution
if( na-1 > 0 )
  vinit((na-1):-1:1) = filter( -a(na:-1:2)/a(1), 1, ypast(1:(na-1)) );
end
if( nb-1 > 0 )
  vx((nb-1):-1:1) = filter( b(nb:-1:2)/a(1), 1, xpast(1:(nb-1)) );
end
vinit = vinit + vx;
