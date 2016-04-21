function h=nndrawax(c,e)
%NNDRAWAX Neural Network Design utility function.

%  NNDRAWAX(C)
%    C - Color (default = dark blue).
%   E - Erase mode (default = 'normal');
%  Draws the x- and y-axes on a plot with color C.

% First Version, 8-31-95.
% $Revision: 1.7 $
% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.

%==================================================================

% DEFAULTS
if nargin < 1, c = nndkblue; end
if nargin < 2, e = 'normal'; end

ca = gca;
NP = get(ca ,'nextplot');
set(ca ,'nextplot','add')

xlim = get(ca,'xlim');
xmin = xlim(1);
xmax = xlim(2);
ylim = get(ca,'ylim');
ymin = ylim(1);
ymax = ylim(2);
g = plot([xmin xmax NaN 0 0],[0 0 NaN ymax ymin],':',...
  'color',c,...
  'erasemode',e);

set(ca,'nextplot',NP)

if nargout, h = g; end
