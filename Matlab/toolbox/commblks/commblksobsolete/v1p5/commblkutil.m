function [s,x,y] = commblkutil

% COMMBLKUTIL Communications Blockset utilities library mask helper function.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/01/26 18:44:45 $

t = 0:30; 
x1 = 20*cos(2*pi*t/30); 
y1 = 20*sin(2*pi*t/30);
y2 = -10*sin(2*pi*(t-15)/30);
z = complex(-15:15,20*sin(2*pi*(t-15)/50));
z = z*exp(sqrt(-1)*pi/8);
xbox = [-10 10 10 -10 -10];
ybox = [25 25 -25 -25 25];
xarrow = [0 20 15 20 15];
yarrow = [0 0 5 0 -5];
x = [x1+70 NaN (t-15)+70 NaN real(z)+18     NaN xbox+18 ...
     NaN xarrow+51]; 
y = [y1+35 NaN y2+35     NaN 0.8*imag(z)+30 NaN ybox+30 ...
     NaN yarrow+83];
s = '101     5';