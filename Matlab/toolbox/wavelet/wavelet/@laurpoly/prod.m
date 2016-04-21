function P = prod(varargin)
%PROD Product of Laurent polynomials.
%   P = PROD(P1,P2,...) returns a Laurent polynomial  
%   which is the product of the Laurent polynomials Pi.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-Mar-2003.
%   Last Revision: 07-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2004/03/15 22:38:10 $ 

nbIn = nargin;
if nbIn<1
    error('Not enough input arguments.');
end
P = varargin{1};
for k = 2:nbIn
    P = P * varargin{k};
end
