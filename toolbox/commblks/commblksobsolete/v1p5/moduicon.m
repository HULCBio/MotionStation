function [x,y] = moduicon(fla)
%MODUICON Outputs the input/output for the modulation icons.
% fla == 1, am modulation
% fla == 2, am demodulation
% fla == 3, fm modulation
% fla == 4, fm demodulation

%   Copyright 1996-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

if fla <= 4
    x1 = [0:10];
    y1 = sin(x1*pi/5);
    x1 = x1 * 4.5;
    y1 = y1*10 + 85;

    if fla <=2
        x2 = [0:.3:10];
        y2 = [sin(x2*pi/5).*sin(x2*pi*2)];
    else
        x2 = [0:.15:10];
        y2 = sin(x2*pi*2 + cumsum(sin(x2*pi/5))/2);
    end;
    x2 = x2 * 4.5;
    y2 = y2*10 + 85;
else
    x1 = [0 10 10 20 20 30];
    y1 = [8  8 -8 -8  8  8];
    x1 = x1 * 1.5;
    y1 = y1 + 85;

    if fla <=6
        x2 = [[0:.8:10] [10 20] [20:.8:30]];
        y2 = [sin([0 : .8 : 10]*pi*2/5) 0 0 sin([20 : .8 : 30]*pi*2/5)];
    else
        x2 = [[0:.8:10] [10:1.6:20] [20:.8:30]];
        y2 = [sin([0 : .8 : 10]*pi*2/5) sin([10:1.6:20]*pi/5) sin([20 : .8 : 30]*pi*2/5)];
    end;
    x2 = x2 * 1.5;
    y2 = y2*10 + 85;
end;
%x = [50 50 50 05 90 90 95 90 90 50];
%y = [85 95 75 75 75 72 75 78 75 75];

x = [50 50 50];
y = [85 99 75];


if rem(fla, 2) == 1
    x = [x1+5 x x2+50];
    y = [y1 y y2];
else
    x = [x2+5 x x1+50];
    y = [y2 y y1];
end;
%plot(0, 0, x, y);

