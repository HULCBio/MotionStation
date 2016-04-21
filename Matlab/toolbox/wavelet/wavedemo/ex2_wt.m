%EX2_WT Example of 2-D wavelet tree (WTREE OBJECT).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 16-Sep-1999.
%   Last Revision: 18-Oct-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 19:32:00 $ 

% load the image.
  load woman;

% Define the level and the wavelet.   
  lev = 2;
  wav = 'db1';

% Create the wavelet tree.
  t = wtree(X,lev,wav);

% Plot tree t.
  plot(t)

%---------------------------------------------------
% Change Node Label from Depth_Position to Index.
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
% Change Node Action from Split_Merge to Visualize.
% Click the node (21). You obtain the following plot.
%
% HERE NEW PLOT
%---------------------------------------------------
