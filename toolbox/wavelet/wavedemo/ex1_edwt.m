%EX1_EDWT Example of 1-D wavelet tree (EDWTTREE OBJECT).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-Sep-1999.
%   Last Revision: 18-Oct-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 19:31:42 $ 

% load the signal.
load noisbloc;
x = noisbloc;

% Define the level and the wavelet.   
lev = 2;
wav = 'haar';

% Create the wavelet tree.
t = edwttree(x,lev,wav);

% Plot tree t.
plot(t)

%---------------------------------------------------
% Click the node (0). You obtain the following plot.
%
% HERE NEW PLOT
%---------------------------------------------------
% Change Node Action from Visualize to Split_Merge.
% Split the nodes (5) and (20).
%
% HERE NEW PLOT
%---------------------------------------------------
% Select Tree Action: De-noise.
% Click the node (0). You obtain the following plot.
%
% HERE NEW PLOT
%---------------------------------------------------
