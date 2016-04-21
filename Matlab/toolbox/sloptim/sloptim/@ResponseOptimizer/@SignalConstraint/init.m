function init(this,Xrange,Yrange)
% Initializes signal constraint (default template)
%
%   Author(s): Pascal Gahinet
%   Copyright 1990-2003 The MathWorks, Inc.
tstart = Xrange(1);
tfinal = Xrange(2);
if isinf(tfinal)
   tfinal = tstart + 10;
end
dt = tfinal-tstart;

% Numbers calculated for Yrange = [0 1.2]
dy = diff(Yrange)/1.2;

% Lower bounds
this.LowerBoundX =  tstart + dt * [0 0.1;0.1 0.3;0.3 1];
this.LowerBoundY =  Yrange(1) + dy * [-0.01 -0.01;.9 .9;.99 .99];
this.LowerBoundWeight = ones(3,1);

% Upper bounds
this.UpperBoundX = tstart + dt * [0 0.3;0.3 1];
this.UpperBoundY = Yrange(1) + dy * [1.2 1.2 ; 1.01 1.01];
this.UpperBoundWeight = ones(2,1);
