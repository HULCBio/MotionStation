function a = appcoef(c,l,varargin)
%APPCOEF Extract 1-D approximation coefficients.
%   APPCOEF computes the approximation coefficients of a
%   one-dimensional signal.
%
%   A = APPCOEF(C,L,'wname',N) computes the approximation
%   coefficients at level N using the wavelet decomposition
%   structure [C,L] (see WAVEDEC).
%   'wname' is a string containing the wavelet name.
%   Level N must be an integer such that 0 <= N <= length(L)-2. 
%
%   A = APPCOEF(C,L,'wname') extracts the approximation
%   coefficients at the last level length(L)-2.
%
%   Instead of giving the wavelet name, you can give the filters.
%   For A = APPCOEF(C,L,Lo_R,Hi_R) or
%   A = APPCOEF(C,L,Lo_R,Hi_R,N),
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter.
%   
%   See also DETCOEF, WAVEDEC.

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
rmax = length(l);
nmax = rmax-2;
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end
if nargin>=(2+next) , n = varargin{next}; else, n = nmax; end
if (n < 0) | (n > nmax) | (n ~= fix(n))
    error('Invalid level value.');
end

% Initialization.
a = c(1:l(1));

% Iterated reconstruction.
imax = rmax+1;
for p = nmax:-1:n+1
    d = detcoef(c,l,p);                % extract detail
    a = idwt(a,d,Lo_R,Hi_R,l(imax-p));
end
