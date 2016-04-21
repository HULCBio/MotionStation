function x = ihlwt(a,d,integerFlag)
%IHLWT Haar (Integer) Wavelet reconstruction 1-D using lifting.
%
%     x = ihlwt(a,d) ou
%     x = ihlwt(a,d,integerFlag)
%     Dans le cas 2, on a une transformation en entiers
%     modulo la normalisation.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-Jan-2000.
%   Last Revision 16-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/13 00:39:40 $ 

% Test si transformation en entiers.
notInteger = nargin<3;

% Reverse Lifting.
if notInteger
    d = 2*d;          % Normalization.
    a = (a-d/2);      % Reverse primal lifting.
else
    a = (a-fix(d/2)); % Reverse primal lifting.
end
d = a+d;   % Reverse dual lifting.

% Merging.
x = [d;a];
x = x(:)';
