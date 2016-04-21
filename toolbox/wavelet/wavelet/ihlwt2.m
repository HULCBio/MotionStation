function x = ihlwt2(a,h,v,d,integerFlag)
%IHLWT2 Haar (Integer) Wavelet reconstruction 2-D using lifting.
%
%     x = ihlwt2(a,h,v,d) ou
%     x = ihlwt2(a,h,v,d,integerFlag)
%     Dans le cas 2, on a une transformation en entiers
%     modulo la normalisation.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-Jan-2000.
%   Last Revision 16-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/13 00:39:41 $ 

% Test si transformation en entiers.
notInteger = nargin<5;

% Reverse Lifting.
if notInteger
    % Normalization.
    d = 4*d;
    v = 2*v;
    h = 2*h;
    v = (v-d/2);      % Reverse primal lifting.
else
    v = (v-fix(d/2)); % Reverse primal lifting.
end
d = v+d;   % Reverse dual lifting.

% Merging.
nbR = size(d,1)+size(v,1);
nbC = size(d,2);
H = zeros(nbR,nbC);
H(2:2:end,:) = v;
H(1:2:end,:) = d;

% Reverse Lifting.
if notInteger
    a = (a-h/2);      % Reverse primal lifting.
else
    a = (a-fix(h/2)); % Reverse primal lifting.
end
h = a+h;   % Reverse dual lifting.

% Merging.
L = zeros(nbR,nbC);
L(2:2:end,:) = a;
L(1:2:end,:) = h;

% Reverse Lifting.
if notInteger
    L = (L-H/2);      % Reverse primal lifting.
else
    L = (L-fix(H/2)); % Reverse primal lifting.
end
H = L+H;   % Reverse dual lifting.

% Merging.
nbC = size(L,2)+size(H,2);
nbR = size(L,1);
x = zeros(nbR,nbC);
x(:,2:2:end,:) = L;
x(:,1:2:end,:) = H;
