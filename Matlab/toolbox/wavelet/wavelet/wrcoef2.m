function x = wrcoef2(o,c,s,varargin)
%WRCOEF2 Reconstruct single branch from 2-D wavelet coefficients.
%   WRCOEF2 reconstructs the coefficients of an image.
%
%   X = WRCOEF2('type',C,S,'wname',N) computes the matrix of
%   reconstructed coefficients of level N, based on the 
%   wavelet decomposition structure [C,S] (see WAVEDEC2 for 
%   more information).
%   'wname' is a string containing the name of the wavelet.
%   If 'type' = 'a', approximation coefficients are reconstructed
%   otherwise if 'type' = 'h' ('v' or 'd', respectively), 
%   horizontal (vertical or diagonal, respectively) detail
%   coefficients are reconstructed.
%
%   Level N must be an integer such that:
%   0 <= N <= size(S,1)-2 if 'type' = 'a' and such that 
%   1 <= N <= size(S,1)-2 if 'type' = 'h', 'v'or 'd'.
%
%   Instead of giving the wavelet name, you can give the filters.
%   For X = WRCOEF2('type',C,S,Lo_R,Hi_R,N),  
%   Lo_R is the reconstruction low-pass filter and
%   Hi_R is the reconstruction high-pass filter
%
%   X = WRCOEF2('type',C,S,'wname') or
%   X = WRCOEF2('type',C,S,Lo_R,Hi_R) reconstruct 
%   coefficients of maximum level N = size(S,1)-2.
%
%   See also APPCOEF2, DETCOEF2, WAVEDEC2.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.14.4.2 $

% Check arguments.
nbIn = nargin;
if nbIn < 4
  error('Not enough input arguments.');
elseif nbIn > 6
  error('Too many input arguments.');
end
o = lower(o(1));
rmax = size(s,1); nmax = rmax-2;
if o=='a', nmin = 0; else , nmin = 1; end
if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r'); next = 2;
else
    Lo_R = varargin{1}; Hi_R = varargin{2};  next = 3;
end
if nargin>=(3+next) , n = varargin{next}; else, n = nmax; end

if (n<nmin) | (n>nmax) | (n~=fix(n))
    error('Invalid argument value.');
end

% Get DWT_Mode
dwtATTR = dwtmode('get');

switch o
  case 'a'
    x = appcoef2(c,s,Lo_R,Hi_R,n);
    if n==0, return; end
    F1 = Lo_R; F2 = Lo_R;

  case 'h'
    x = detcoef2(o,c,s,n);
    F1 = Hi_R; F2 = Lo_R;

  case 'v'
    x = detcoef2(o,c,s,n);
    F1 = Lo_R; F2 = Hi_R;

  case 'd'
    x = detcoef2(o,c,s,n);
    F1 = Hi_R; F2 = Hi_R;

  otherwise
    error('Invalid argument value.');
end

imin = rmax-n;
x  = upsconv2(x,{F1,F2},s(imin+1,:),dwtATTR);
for p=2:n
    x = upsconv2(x,{Lo_R,Lo_R},s(imin+p,:),dwtATTR);
end
