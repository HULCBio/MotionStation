function y = lincontest7(x);
%LINCONTEST7 objective function.
%   y = LINCONTEST7(X) evaluates y for the input X. Make sure that x is a column 
%   vector, whereas objective function gets a row vector.


%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2004/01/16 16:52:26 $

x = x';
%Define a quadratic problem in terms of H and f (From web unknown source)
H = [36 17 19 12 8 15; 17 33 18 11 7 14; 19 18 43 13 8 16;
12 11 13 18 6 11; 8 7 8 6 9 8; 15 14 16 11 8 29];
 f = [ 20 15 21 18 29 24 ]';
 
 y = 0.5*x'*H*x + f'*x;