function y = dividenowarn(num,den)
% DIVIDENOWARN Divides two polynomials while suppressing warnings.
% DIVIDENOWARN(NUM,DEN) array divides two polynomials but suppresses warnings 
% to avoid "Divide by zero" warnings.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/04/15 01:08:30 $

s = warning; % Cache warning state
warning off  % Avoid "Divide by zero" warnings
y = (num./den);
warning(s);  % Reset warning state

% [EOF] dividenowarn.m