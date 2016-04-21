function y = qmf(x,p)
%QMF    Quadrature mirror filter.
%   Y = QMF(X,P) changes the signs of the even index entries
%   of the reversed vector filter coefficients X if P is even.
%   If P is odd the same holds for odd index entries.
%
%   Y = QMF(X) is equivalent to Y = QMF(X,0).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 13-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

% Check arguments.
if nargin == 1 , p = 0; end
if (p~=fix(p)) | (p<0)
    error('Invalid input argument: p')
end

% Compute quadrature mirror filter.
y = x(end:-1:1);
first = 2-rem(p,2);
y(first:2:end) = -y(first:2:end);
