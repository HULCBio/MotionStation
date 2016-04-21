function init_graphics(this)
%INIT_GRAPHICS  Generic initialization of plot graphics.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:23 $

% Tag low-level HG axes
% RE: Needed to know if given axes associated with response (HOLD,..)
hgaxes = double(getaxes(this.AxesGrid));
for ct=1:prod(size(hgaxes))
   setappdata(hgaxes(ct),'WaveRespPlot',this);
end

% Initialize row/column labels
rclabel(this)

% Set response plot visibility
this.AxesGrid.Visible = this.Visible;