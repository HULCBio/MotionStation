function a = appcoef2(c,s,varargin)
%APPCOEF2 Extract 2-D approximation coefficients.
%   APPCOEF2 computes the approximation coefficients of a
%   two-dimensional signal.
%
%   A = APPCOEF2(C,S,'wname',N) computes the approximation
%   coefficients at level N using the wavelet decomposition
%   structure [C,S] (see WAVEDEC2). 
%   'wname' is a string containing the wavelet name.
%   Level N must be an integer such that 0 <= N <= size(S,1)-2. 
%
%   A = APPCOEF2(C,S,'wname') extracts the approximation
%   coefficients at the last level size(S,1)-2.
%
%   Instead of giving the wavelet name, you can give the filters.
%   For A = APPCOEF2(C,S,Lo_R,Hi_R) or 
%   A = APPCOEF2(C,S,Lo_R,Hi_R,N),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%   
%   See also DETCOEF2, WAVEDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.12.4.2 $

% Check arguments.
nbIn = nargin;
if nbIn < 2
  error('Not enough input arguments.');
elseif nbIn > 5
  error('Too many input arguments.');
end
rmax = size(s,1);
nmax = rmax-2;
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end
if nargin>=(2+next) , n = varargin{next}; else, n = nmax; end
if (n<0) | (n>nmax) | (n~=fix(n))
    error('Invalid level value.');
end

% Initialization.
nl   = s(1,1);
nc   = s(1,2);
a    = zeros(nl,nc);
a(:) = c(1:nl*nc);

% Iterated reconstruction.
rm   = rmax+1;
for p=nmax:-1:n+1
    [h,v,d] = detcoef2('all',c,s,p);
    a = idwt2(a,h,v,d,Lo_R,Hi_R,s(rm-p,:));
end
