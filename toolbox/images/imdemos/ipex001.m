% Construct and transform a grid, and display
% it over the original and transformed images.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $ $Date: 2003/05/03 17:53:34 $

[U,V] = meshgrid(0:64:320,0:64:256);
[X,Y] = tformfwd(T,U,V);
gray = 0.65 * [1 1 1];

figure(h1);
hold on;
line(U, V, 'Color',gray);
line(U',V','Color',gray);

figure(h2);
hold on;
line(X, Y, 'Color',gray);
line(X',Y','Color',gray);
