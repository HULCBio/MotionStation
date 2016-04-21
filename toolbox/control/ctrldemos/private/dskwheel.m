function dskwheel(x0,y0,R);
%DSKWHEEL  Draw a car wheel for the ACC Benchmark schematic.
%   Subroutine called by DRAWACC.
%   Wheel is centered about (x0,y0) and has radius R.

%   Denise L. Chen, Aug. 1993.
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:41:33 $

n = 55;

% Calculate the top half arc of the circle.
x = x0-R: (2*R)/n : x0+R;
s = ones(size(x));
t = sqrt( R*R*s - (x-x0*s).^2);
y = t + y0*s;
y = real(y);    % get rid the extraneous complex part

x = [x' flipud(x')];
y = [y' flipud((2*y0-y)')];
fill(x,y,[0 0 0],'EdgeColor',[0 0 0]);
