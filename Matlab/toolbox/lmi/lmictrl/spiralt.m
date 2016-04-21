% spiral parameter trajectory for missile demo

% Author: P. Gahinet  10/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function p=spiral(t)

w1=100; w2=4;
p=[2.25+1.70*exp(-w2*t).*cos(w1*t);50+49*exp(-w2*t).*sin(w1*t)];
