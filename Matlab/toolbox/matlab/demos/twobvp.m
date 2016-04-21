%TWOBVP  Solve a BVP that has exactly two solutions.
%   TWOBVP uses BVP4C to compute the two solutions of
%      y'' + |y| = 0
%   that satisfy the boundary conditions
%      y(0) = 0,  y(4) = -2
%   This example illustrates how different initial guesses can lead to
%   different solutions.
%
%   See also: TWOODE, TWOBC, BVPINIT, BVPSET, BVPGET, BVP4C, DEVAL, @.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 03:35:02 $

% One solution is obtained using an initial guess of y1(x)=1, y2(x)=0 
solinit = bvpinit(linspace(0,4,5),[1 0]);
sol = bvp4c(@twoode,@twobc,solinit);
x = linspace(0,4);
y1 = deval(sol,x);
figure;
plot(x,y1(1,:));
xlabel('x');
ylabel('y');

% The other solution is obtained using an initial guess of y1(x)=-1, y2(x)=0
solinit = bvpinit(linspace(0,4,5),[-1 0]);
sol = bvp4c(@twoode,@twobc,solinit);
y2 = deval(sol,x);

% Plot both solutions
figure;
plot(x,y1(1,:),x,y2(1,:));
xlabel('x');
ylabel('solution y');
title('A BVP with two solutions');

