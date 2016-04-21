function dv = datavis(this)
%DATAVIS  Data visibility.
%
%  Responses are arrays of curves. Each curve represents a piece
%  of response data and is plotted in a particular HG axes.
%
%  DV = DATAVIS(RESPPLOT) returns an array of the same size as the
%  axes grid (see GETAXES) indicating which curves are currently
%  displayed.  The result is affected by the plot visibility,
%  the input and output visibility, and other parameters such
%  as the mag or phase visibility in Bode plots.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:30 $

dv = false(this.AxesGrid.Size);
if strcmp(this.Visible,'on')
   % Row and column visibility (subgrid assumed 1x1 in generic case)
   dv(strcmp(this.OutputVisible,'on'),strcmp(this.InputVisible,'on'),:) = true;
end
