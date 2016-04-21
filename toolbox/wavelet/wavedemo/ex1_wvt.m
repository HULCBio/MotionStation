%EX1_WVT Example of 1-D wavelet tree (WVTREE OBJECT).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-Sep-1999.
%   Last Revision: 18-Oct-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 19:31:51 $ 

% load the signal.
  load noisbloc;
  x = noisbloc;

% Define the level and the wavelet.   
  lev = 3;
  wav = 'db2';

% Create the wavelet tree.
  t = wvtree(x,lev,wav);

% Plot tree t.
  plot(t)

%---------------------------------------------------
% Change Node Action from Visualize to Split_Merge.
% Merge the node (3).
% Change Node Action from Split_Merge to Reconstruct.
% Click the node (3). You obtain the following plot.
%
% HERE NEW PLOT
%---------------------------------------------------

