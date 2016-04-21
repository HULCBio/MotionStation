function varargout = detcoef(coefs,longs,levels,dummy)
%DETCOEF Extract 1-D detail coefficients.
%   D = DETCOEF(C,L,N) extracts the detail coefficients
%   at level N from the wavelet decomposition structure [C,L].
%   See WAVEDEC for more information on C and L.
%   Level N must be an integer such that 1 <= N <= NMAX
%   where NMAX = length(L)-2.
%
%   D = DETCOEF(C,L) extracts the detail coefficients
%   at last level NMAX.
%
%   If N is a vector of integers such that 1 <= N(j) <= NMAX:
%
%     DCELL = DETCOEF(C,L,N,'cells') returns a cell array where
%     DCELL{j} contains the coefficients of detail N(j).
%
%     If length(N)>1, DCELL = DETCOEF(C,L,N) is equivalent to
%     DCELL = DETCOEF(C,L,N,'cells').
%
%     DCELL = DETCOEF(C,L,'cells') is equivalent to 
%     DCELL = DETCOEF(C,L,[1:NMAX])
%
%     [D1,...,Dp] = DETCOEF(C,L,[N(1),...,N(p)]) extracts the details
%     coefficients at levels [N(1),...,N(p)].
%
%   See also APPCOEF, WAVEDEC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $

% Check arguments.
nmax = length(longs)-2;
cellFLAG = false;
if nargin>2
    if isnumeric(levels)
        if (any(levels < 1)) || (any(levels > nmax) ) || ...
            any(levels ~= fix(levels))
            error('Invalid level(s) value.');
        end
        cellFLAG = (nargin>3);
    else
        cellFLAG = true;
        levels = [1:nmax];
    end   
else
    levels = nmax;
end

first = cumsum(longs)+1;
first = first(end-2:-1:1);
longs = longs(end-1:-1:2);
last  = first+longs-1;
nblev = length(levels);
tmp   = cell(1,nblev);
for j = 1:nblev
    k = levels(j);
    tmp{j} = coefs(first(k):last(k));
end

if nargout>0
   if (nargout==1 && nblev>1) || cellFLAG
       varargout{1} = tmp;
   else
       varargout = tmp;
   end
end
