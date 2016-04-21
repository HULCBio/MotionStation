function Axes = getaxes(this, varargin)
%GETAXES  Get array of HG axes to which wave data is mapped.
%
%  Waveforms are arrays of curves, each curve being plotted in 
%  a particular HG axes. The mapping between curves and axes is 
%  one-to-one for a full view, and many-to-one when axes are grouped.
%
%  AX = GETAXES(H) returns a 4D array of HG axes handles where
%  the first dimension is th enumber of channels, and the last two
%  dimensions are the subplot sizes.  This array specifies in which 
%  axes each wave curve is currently drawn.
%
%  AX = GETAXES(H,'2d') formats the same information into a 2D 
%  matrix conforming with the axes grid layout.
% 
%  See also ALLAXES.

%  Author(s): Pascal Gahinet, Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:33 $

% REM: GridSize <= size(Axes)  (e.g, in bode plots)
Axes = getaxes(this.AxesGrid);
GridSize = this.AxesGrid.Size;

% Take axes grouping into account
if strcmp(this.ChannelGrouping,'all')
   Axes = repmat(Axes(1,1,:,:),GridSize([1 2]));
end

% Reformat to 2D if requested
if any(strcmp(varargin,'2d'))
   Axes = reshape(permute(Axes,[3 1 4 2]),...
      [prod(GridSize([1 3])),prod(GridSize([2 4]))]);
end