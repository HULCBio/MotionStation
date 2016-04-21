%WARNING: This is an obsolete function and may be removed in the future.

%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.12 $

hmodem('qam',1)
pause

x = randint(20, 1, 4);
y = rcosflt(x, 1, 10);
h=figure;
subplot(211);
t = [[0:9];[1:10]]; t=t(:);
x=[0;x];
z =[x(1:10)';x(1:10)'];z=z(:);
plot(t, z,[0:.1:10],y(1:101))
subplot(212);
x = randint(150, 2, 4);
y = rcosflt(x, 1, 10);
eyescat(y,.5,10,4);
pause
h(2) = figure;
eyescat(y, 1, 10, 0, '.')
pause
close(h)

hrscodec;
pause
close(h(1))
commu
p=1;b=1;
