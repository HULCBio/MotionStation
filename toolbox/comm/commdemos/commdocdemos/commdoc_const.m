%% Plotting Signal Constellations
% This example, described in the Getting Started chapter of the
% Communications Toolbox documentation, aims to solve the following
% problem:
%
% Plot a 16-QAM signal constellation with annotations that
% indicate the mapping from integers to constellation points.

% Copyright 1996-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/01/09 17:35:28 $

%% Initial Plot, Without Gray Coding
M = 16; % Number of points in constellation
intg = [0:M-1].'; % Vector of integers between 0 and M-1
pt = qammod(intg,M); % Vector of all points in constellation

% Plot the constellation.
scatterplot(pt);

% Include text annotations that number the points.
text(real(pt)+0.1,imag(pt),dec2bin(intg));
axis([-4 4 -4 4]); % Change axis so all labels fit in plot.

%% Modified Plot, With Gray Coding
M = 16; % Number of points in constellation
intg = [0:M-1].';
mapping = [0 1 3 2 4 5 7 6 12 13 15 14 8 9 11 10].';
intgray = mapping(intg+1);
pt = qammod(intgray,M); % Vector of all points in constellation

scatterplot(pt); % Plot the constellation.

% Include text annotations that number the points.
text(real(pt)+0.1,imag(pt),dec2bin(intg));
axis([-4 4 -4 4]); % Change axis so all labels fit in plot.
