function varargout = detcoef2(o,c,s,n)
%DETCOEF2 Extract 2-D detail coefficients.
%   D = DETCOEF2(O,C,S,N) extracts from the wavelet
%   decomposition structure [C,S], the horizontal, vertical 
%   or diagonal detail coefficients for O = 'h' 
%   (or 'v' or 'd',respectively), at level N. N must
%   be an integer such that 1 <= N <= size(S,1)-2.
%   See WAVEDEC2 for more information on C and S.
%
%   [H,V,D] = DETCOEF2('all',C,S,N) returns the horizontal H,
%   vertical V, and diagonal D detail coefficients at level N.
%
%   D = DETCOEF2('compact',C,S,N) returns the detail 
%   coefficients at level N, stored row-wise.
%
%   DETCOEF2('a',C,S,N) is equivalent to DETCOEF2('all',C,S,N).
%   DETCOEF2('c',C,S,N) is equivalent to DETCOEF2('compact',C,S,N).
%
%   See also APPCOEF2, WAVEDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 22-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.11.4.2 $

% Check arguments.
nmax = size(s,1)-2;
if (n<1) || (n>nmax) || (n~=fix(n))
    error('Invalid argument value');
end

k     = size(s,1)-n;
first = s(1,1)*s(1,2)+3*sum(s(2:k-1,1).*s(2:k-1,2))+1;
add   = s(k,1)*s(k,2);
o     = lower(o);

switch o
  case 'h' ,
  case 'v' ,  first = first+add;
  case 'd' ,  first = first+2*add;
  case {'a','all','c','compact'} ,
  otherwise , error('Invalid argument value');
end

switch o
  case {'h','v','d'}
    last = first+add-1;
    varargout{1} = reshape(c(first:last),s(k,:));

  case {'c','compact'}
    last = first+3*add-1;
    varargout{1} = c(first:last);

  case {'a','all'}
    last = first+add-1;
    varargout{1} = reshape(c(first:last),s(k,:));
    first = first+add; last = first+add-1;
    varargout{2} = reshape(c(first:last),s(k,:));
    first = first+add; last = first+add-1;
    varargout{3} = reshape(c(first:last),s(k,:));
end
