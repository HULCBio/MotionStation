function [a,d] = hlwt(x,integerFlag)
%HLWT Haar (Integer) Wavelet decomposition 1-D using lifting.
%
%     [a,d] = hlwt(x) or
%     [a,d] = hlwt(x,integerFlag)
%     Dans le cas 2, on a une transformation en entiers
%     modulo la normalisation.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-Jan-2000.
%   Last Revision 16-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/13 00:39:38 $ 

% Test si transformation en entiers.
notInteger = nargin<2;

% Splitting.
a = x(2:2:end);
d = x(1:2:end);

% Lifting.
d = d-a;              % Dual lifting.
if notInteger
    a = (a+d/2);      % Primal lifting.
    d = d/2;          % Normalization.
else
    a = (a+fix(d/2)); % Primal lifting.
end
