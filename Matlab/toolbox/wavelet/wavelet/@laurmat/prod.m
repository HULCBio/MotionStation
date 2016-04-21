function P = prod(varargin)
%PROD Product of Laurent matrices.
%   P = PROD(M1,M2,...) returns a Laurent matrix which is
%   the product of the Laurent matrices Mi.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 31-May-2003.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:39:23 $ 

nbIn = nargin;
if nbIn<1
    error('Not enough input arguments.');
end
P = varargin{1};
for k = 2:nbIn
    P = P * varargin{k};
end
