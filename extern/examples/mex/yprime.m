function yp = yprime(t,y)
% Differential equation system for restricted three body problem.
% Think of a small third body in orbit about the earth and moon.
% The coordinate system moves with the earth-moon system.
% The 1-axis goes through the earth and the moon.
% The 2-axis is perpendicular, in the plane of motion of the third body.
% The origin is at the center of gravity of the two heavy bodies.
% Let mu = the ratio of the mass of the moon to the mass of the earth.
% The earth is located at (-mu,0) and the moon at (1-mu,0). 
% y(1) and y(3) = coordinates of the third body.
% y(2) and y(4) = velocity of the third body
%.
% Copyright (c) 1984-98 by The MathWorks, Inc.
% All Rights Reserved.

mu = 1/82.45;
mus = 1-mu;
r1 = norm([y(1)+mu, y(3)]);   % Distance to the earth
r2 = norm([y(1)-mus, y(3)]);  % Distance to the moon
yp(1) = y(2);
yp(2) = 2*y(4) + y(1) - mus*(y(1)+mu)/r1^3 - mu*(y(1)-mus)/r2^3;
yp(3) = y(4);
yp(4) = -2*y(2) + y(3) - mus*y(3)/r1^3 - mu*y(3)/r2^3;
% yp = yp';
