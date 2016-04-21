function dv = datavis(this)
%DATAVIS  Data visibility.
%
%  Waves are arrays of curves. Each curve is associated with a
%  particular channel and is plotted in a separate pair of HG axes.
%
%  DV = DATAVIS(RESPPLOT) returns an array of the same size as the
%  axes grid (see GETAXES) indicating which curves are currently
%  displayed.  The result is affected by the plot visibility,
%  the input and output visibility, and other parameters such
%  as the mag or phase visibility in Bode plots.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:30 $

dv = false(this.AxesGrid.Size);
if strcmp(this.Visible,'on')
   % Row and column visibility (subgrid assumed 1x1 in generic case)
   dv(strcmp(this.ChannelVisible,'on'),:) = true;
end
