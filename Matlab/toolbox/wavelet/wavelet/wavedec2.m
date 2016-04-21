function [c,s] = wavedec2(x,n,IN3,IN4)
%WAVEDEC2 Multilevel 2-D wavelet decomposition.
%   [C,S] = WAVEDEC2(X,N,'wname') returns the wavelet
%   decomposition of the matrix X at level N, using the
%   wavelet named in string 'wname' (see WFILTERS).
%   Outputs are the decomposition vector C and the
%   corresponding bookkeeping matrix S.
%   N must be a strictly positive integer (see WMAXLEV).
%
%   Instead of giving the wavelet name, you can give the
%   filters.
%   For [C,S] = WAVEDEC2(X,N,Lo_D,Hi_D),
%   Lo_D is the decomposition low-pass filter and
%   Hi_D is the decomposition high-pass filter.
%
%   The output wavelet 2-D decomposition structure [C,S]
%   contains the wavelet decomposition vector C and the 
%   corresponding bookeeping matrix S. 
%   Vector C is organized as:
%     C = [ A(N)   | H(N)   | V(N)   | D(N) | ... 
%   H(N-1) | V(N-1) | D(N-1) | ...  | H(1) | V(1) | D(1) ].
%     where A, H, V, D, are row vectors such that: 
%   A = approximation coefficients, 
%   H = hori. detail coefficients,
%   V = vert. detail coefficients,
%   D = diag. detail coefficients,
%   each vector is the vector column-wise storage of a matrix. 
%   Matrix S is such that:
%     S(1,:) = size of app. coef.(N)
%     S(i,:) = size of det. coef.(N-i+2) for i = 2,...,N+1
%     and S(N+2,:) = size(X).
%
%   See also DWT2, WAVEINFO, WAVEREC2, WFILTERS, WMAXLEV.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.14.4.2 $

% Check arguments.
if nargin==3
    [Lo_D,Hi_D] = wfilters(IN3,'d');
else
    Lo_D = IN3;   Hi_D = IN4;
end

% Initialization.
s = [size(x)];
c = [];

for i=1:n
    [x,h,v,d] = dwt2(x,Lo_D,Hi_D); % decomposition
    c = [h(:)' v(:)' d(:)' c];     % store details
    s = [size(x);s];               % store size

end

% Last approximation.
c = [x(:)' c];
s = [size(x);s];
