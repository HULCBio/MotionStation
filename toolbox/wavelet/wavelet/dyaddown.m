function y = dyaddown(x,IN2,IN3)
%DYADDOWN Dyadic downsampling.
%   Y = DYADDOWN(X,EVENODD) where X is a vector, and returns
%   a version of X that has been downsampled by 2.
%   Whether Y contains the even- or odd-indexed samples
%   of X depends on the value of positive integer EVENODD:
%   If EVENODD is even, then Y(k) = X(2k).
%   If EVENODD is odd,  then Y(k) = X(2k-1).
%
%   Y = DYADDOWN(X) is equivalent to Y = DYADDOWN(X,0)
%
%   Y = DYADDOWN(X,EVENODD,'type') or 
%   Y = DYADDOWN(X,'type',EVENODD) where X is a matrix,
%   return a version of X obtained by suppressing columns
%   (or rows or both) if 'type' = 'c' (or 'r' or 'm'
%   respectively), according to the parameter EVENODD, which
%   is as above.
%
%   Y = DYADDOWN(X) is equivalent to
%   Y = DYADDOWN(X,0,'c').
%   Y = DYADDOWN(X,'type') is equivalent to
%   Y = DYADDOWN(X,0,'type').
%   Y = DYADDOWN(X,EVENODD) is equivalent to
%   Y = DYADDOWN(X,EVENODD,'c').
%
%                  |1 2 3 4|                       |2 4|
%   Examples : X = |2 4 6 8|  ,  DYADDOWN(X,'c') = |4 8|
%                  |3 6 9 0|                       |6 0|
%
%                       |1 2 3 4|                        |1 3|
%   DYADDOWN(X,'r',1) = |3 6 9 0|  , DYADDOWN(X,'m',1) = |3 9|
%
%   See also DYADUP.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.13.4.2 $

% Check arguments.
def_evenodd = 0;
nbin  = nargin-1;
[r,c] = size(x);

if min(r,c)<=1
    dim = 1;
    switch nbin
      case 1 , if ischar(IN2) , dim = 2; end
      case 2 , if ischar(IN2) | ischar(IN3) , dim = 2; end
    end
else
    dim = 2;
end

if dim==1
    switch nbin
      case 0 ,    p = def_evenodd;
      case 1 ,    p = IN2;
      otherwise , error('Too many input arguments.');
    end
    y = x(2-rem(p,2):2:end);
else
    switch nbin
        case 0
            o = 'c'; p = def_evenodd;

        case 1 
            if ischar(IN2)
                p = def_evenodd; o = lower(IN2(1));
            else
                p = IN2; o = 'c';
            end

        otherwise
            if ischar(IN2)
                p = IN3; o = lower(IN2(1));
            else
                p = IN2; o = lower(IN3(1));
            end
    end
    first = 2-rem(p,2);
    switch o
      case 'c'  , y = x(:,first:2:c);
      case 'r'  , y = x(first:2:r,:);
      case 'm'  , y = x(first:2:r,first:2:c);
      otherwise , error('Invalid argument value.');
    end
end
