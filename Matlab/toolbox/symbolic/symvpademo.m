%SYMVPADEMO Demonstrate Variable Precision Arithmetic

%  Copyright 1993-2002 The MathWorks, Inc. 
%  $Revision: 1.9 $  $Date: 2002/04/15 03:13:56 $

if any(get(0,'children') == 3), close(3), end
echo on
clc

% Demonstrate Symbolic Math Toolbox variable precision arithmetic.

% Compute 19/81 to 70 digits.  Notice the repeated pattern of digits.
% "vpa" stands for variable precision arithmetic.

vpa 19/81 70

pause % Strike any key to continue.
clc

% Compute pi to 780 digits.  Notice the string of 9's near the end.

vpa pi 780

pause % Strike any key to continue.
vpa('exp(sqrt(163)*pi)',50);
clc

% Compute exp(sqrt(163)*pi) to 30 digits.

vpa exp(sqrt(163)*pi) 30

% The value might be an integer.

pause % Strike any key to continue.

% Compute the same value to 40 digits.

vpa exp(sqrt(163)*pi) 40

% So, the value is close to, but not exactly equal to, an integer.

pause % Strike any key to continue.
clc

% Compute 70 factorial with 200 digit arithmetic.

f = vpa('70!',200)

pause % Strike any key to continue.

% How many digits in 70!?

length(char(f))

pause % Strike any key to continue.
clc

% Compute the eigenvalues of the fifth order magic square to 50 digits.

digits(50)
A = sym(magic(5))
e = eig(vpa(A))

pause % Strike any key to terminate.
clc
echo off
