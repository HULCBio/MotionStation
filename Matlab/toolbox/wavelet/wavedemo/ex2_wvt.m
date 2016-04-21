%EX2_WVT Example of 2-D wavelet tree (WVTREE OBJECT).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-Sep-1999.
%   Last Revision: 18-Oct-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 19:31:57 $ 

% load the image.
  load woman;

% Define the level and the wavelet.   
  lev = 2;
  wav = 'db1';

% Create the wavelet tree.
  t = wvtree(X,lev,wav);

% Plot tree t.
  plot(t)

%---------------------------------------------------
% Click the node (5). You get the following plot.
%
% HERE NEW PLOT
%---------------------------------------------------
% Click the node (2). You obtain the following plot.
%
% HERE NEW PLOT
%---------------------------------------------------
% Change Node Action from Visualize to Split_Merge.
% Split the node (5).
% Change Node Action from Split_Merge to Reconstruct.
% Click the node (21). You obtain the following plot.
%
% HERE NEW PLOT
%---------------------------------------------------
