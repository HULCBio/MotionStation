%% XY plots in MATLAB.
%   Here are some examples of 2-D line plots in MATLAB.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.9.4.3 $  $Date: 2004/04/10 23:24:43 $

%% Line plot of a chirp

x=0:0.05:5;
y=sin(x.^2);
plot(x,y);


%% Bar plot of a bell shaped curve

x = -2.9:0.2:2.9;
bar(x,exp(-x.*x));

%% Stairstep plot of a sine wave

x=0:0.25:10;
stairs(x,sin(x));

%% Errorbar plot

x=-2:0.1:2;
y=erf(x);
e = rand(size(x))/10;
errorbar(x,y,e);

%% Polar plot

t=0:.01:2*pi;
polar(t,abs(sin(2*t).*cos(2*t)));

%% Stem plot

x = 0:0.1:4;
y = sin(x.^2).*exp(-x);
stem(x,y)
