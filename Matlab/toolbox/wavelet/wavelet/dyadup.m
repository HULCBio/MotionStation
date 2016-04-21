function y = dyadup(x,varargin)
%DYADUP Dyadic upsampling.
%   DYADUP implements a simple zero-padding scheme very
%   useful in the wavelet reconstruction algorithm.
%
%   Y = DYADUP(X,EVENODD), where X is a vector, returns
%   an extended copy of vector X obtained by inserting zeros.
%   Whether the zeros are inserted as even- or odd-indexed
%   elements of Y depends on the value of positive integer
%   EVENODD:
%   If EVENODD is even, then Y(2k-1) = X(k), Y(2k) = 0.
%   If EVENODD is odd,  then Y(2k-1) = 0   , Y(2k) = X(k).
%
%   Y = DYADUP(X) is equivalent to Y = DYADUP(X,1)
%
%   Y = DYADUP(X,EVENODD,'type') or
%   Y = DYADUP(X,'type',EVENODD) where X is a matrix,
%   return extended copies of X obtained by inserting columns 
%   of zeros (or rows or both) if 'type' = 'c' (or 'r' or 'm'
%   respectively), according to the parameter EVENODD, which
%   is as above.
%
%   Y = DYADUP(X) is equivalent to
%   Y = DYADUP(X,1,'c')
%   Y = DYADUP(X,'type')  is equivalent to
%   Y = DYADUP(X,1,'type')
%   Y = DYADUP(X,EVENODD) is equivalent to
%   Y = DYADUP(X,EVENODD,'c') 
%
%                  |1 2|                     |0 1 0 2 0|
%   Examples : X = |3 4|  ,  DYADUP(X,'c') = |0 3 0 4 0|
%
%                     |1 2|                      |1 0 2|
%   DYADUP(X,'r',0) = |0 0|  , DYADUP(X,'m',0) = |0 0 0|
%                     |3 4|                      |3 0 4|
%
%   See also DYADDOWN.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 19-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.15.4.2 $

% Internal options.
%-----------------
% Y = DYADUP(X,EVENODD,ARG) returns a vector with even length.
% Y = DYADUP([1 2 3],1,ARG) ==> [0 1 0 2 0 3]
% Y = DYADUP([1 2 3],0,ARG) ==> [1 0 2 0 3 0]
% 
% Y = DYADUP(X,EVENODD,TYPE,ARG) ... for a matrix
%--------------------------------------------------------------

% Check arguments.
nbIn = nargin;
if nbIn < 1
  error('Not enough input arguments.');
elseif nbIn > 4
  error('Too many input arguments.');
end

% Special case.
if isempty(x) , y = []; return; end

def_evenodd = 1;
nbInVar = nargin-1;
[r,c]   = size(x);
evenLEN = 0;
if min(r,c)<=1
    dim = 1;
    switch nbInVar
        case {1,3}
           if ischar(varargin{1}) , dim = 2; end
        case 2
           if ischar(varargin{1}) | ischar(varargin{2}) , dim = 2; end
    end
else
    dim = 2;
end
if dim==1
    switch nbInVar
        case 0
            p = def_evenodd;
        case {1,2}
            p = varargin{1};
            if nbInVar==2 , evenLEN = 1; end
        otherwise
            errargt(mfilename,'too many arguments','msg'); error('*');
    end
    rem2    = rem(p,2);
    if evenLEN , addLEN = 0; else , addLEN = 2*rem2-1; end
    l = 2*length(x)+addLEN;
    y = zeros(1,l);
    y(1+rem2:2:l) = x;
    if r>1, y = y'; end
else
    switch nbInVar
        case 0 , p = def_evenodd; o = 'c';
        case 1
            if ischar(varargin{1})
                p = def_evenodd; o = lower(varargin{1}(1));
            else
                p = varargin{1}; o = 'c';
            end
        otherwise
            if ischar(varargin{1})
                p = varargin{2}; o = lower(varargin{1}(1));
            else
                p = varargin{1}; o = lower(varargin{2}(1));
            end
    end
    if nbInVar==3 , evenLEN = 1; end
    rem2 = rem(p,2);
    if evenLEN , addLEN = 0; else , addLEN = 2*rem2-1; end
    switch o
        case 'c'
            nc = 2*c+addLEN;
            y  = zeros(r,nc);
            y(:,1+rem2:2:nc) = x;

        case 'r'
            nr = 2*r+addLEN;
            y  = zeros(nr,c);
            y(1+rem2:2:nr,:) = x;

        case 'm'
            nc = 2*c+addLEN;
            nr = 2*r+addLEN;
            y  = zeros(nr,nc);
            y(1+rem2:2:nr,1+rem2:2:nc) = x;

        otherwise
            error('Invalid argument value.');
    end
end