function pltcols(fig)
%function pltcols(fig)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

% this function, if called before plotting to the figure "fig",
% produces defaults for "fig" similar to those used in v4. This
% includes a black background and border, white axes, and the
% old yellow, magenta, cyan, red, green, blue color order.

% Tried using colordef, but it's really broken as you cannot
% query the status of anything, and any subplot structure must
% be thrown away if you want to change the colordef (clf required).
%
% Something is still broken with colordef

%===================================================================
%   Added for Matlab 5 -- some default colors and such
%   Compatible with version 4 defaults for now
%===================================================================
plt_ax_color  = 'black';
plt_txt_color = 'white';
plt_fig_color = [0.35 0.35 0.35];
plt_xgrid     = 'off';
plt_ygrid     = 'off';
plt_colororder = [1   1   0;...
                  1   0   1;...
                  0   1   1;...
                  1   0   0;...
                  0   1   0;...
                  0   0   1];

% v5 would add 0.75 0.75 0.75

%===================================================================
%   Or the v5 defaults
%===================================================================
%	plt_ax_color  = 'white';
%	plt_txt_color = 'black';
%	plt_fig_color = [0.8 0.8 0.8];
%	plt_xgrid     = 'on';
%	plt_ygrid     = 'on';
%	plt_colororder = [0.00 0.00 1.00;...
%                           0.00 0.50 0.00;...
%                           1.00 0.00 0.00;...
%                           0.00 0.75 0.75;...
%                           0.75 0.00 0.75;...
%                           0.75 0.75 0.00;...
%                           0.25 0.25 0.25];
%===================================================================

% Set default colors and stuff here .. GJW 09/10/96
%
set(fig,'color',plt_fig_color);
set(fig,'DefaultAxesColor',plt_ax_color);
set(fig,'DefaultAxesXgrid',plt_xgrid);
set(fig,'DefaultAxesYgrid',plt_ygrid);
set(fig,'DefaultAxesXColor',plt_txt_color);
set(fig,'DefaultAxesYColor',plt_txt_color);
set(fig,'DefaultTextColor',plt_txt_color);
set(fig,'DefaultAxesColorOrder',plt_colororder);