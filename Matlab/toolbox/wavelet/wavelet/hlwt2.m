function [a,h,v,d] = hlwt2(x,integerFlag)
%HLWT2 Haar (Integer) Wavelet decomposition 2-D using lifting.
%
%     [a,h,v,d] = hlwt2(x) ou
%     [a,h,v,d] = hlwt2(x,integerFlag)
%     Dans le cas 2, on a une transformation en entiers
%     modulo la normalisation.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-Jan-2000.
%   Last Revision 16-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/13 00:39:39 $ 

% Test si transformation en entiers.
notInteger = nargin<2;

% Splitting.
L = x(:,2:2:end);
H = x(:,1:2:end);

% Lifting.
H = H-L;        % Dual lifting.
if notInteger
    L = (L+H/2);      % Primal lifting.
else
    L = (L+fix(H/2)); % Primal lifting.
end

% Splitting.
a = L(2:2:end,:);
h = L(1:2:end,:);
clear L

% Lifting.
h = h-a;        % Dual lifting.
if notInteger
    a = (a+h/2);      % Primal lifting.
else
    a = (a+fix(h/2)); % Primal lifting.
end

% Splitting.
v = H(2:2:end,:);
d = H(1:2:end,:);

% Lifting.
d = d-v;         % Dual lifting.
if notInteger
    v = (v+d/2); % Primal lifting.
    % Normalization.
    h = h/2;
    v = v/2;
    d = d/4;
else
    v = (v+fix(d/2)); % Primal lifting.
end

