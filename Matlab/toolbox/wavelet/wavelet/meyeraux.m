function y = meyeraux(x);
%MEYERAUX Meyer wavelet auxiliary function.
%   Y = MEYERAUX(X) returns values of the auxiliary
%   function used for Meyer wavelet generation evaluated
%   at the elements of the vector or matrix X.
%
%   The function is 35*x^4 - 84*x^5 + 70*x^6 - 20*x^7.
%
%   See also MEYER.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

% Auxiliary function values.
p = [-20 70 -84 35 0 0 0 0];
y = polyval(p,x);
