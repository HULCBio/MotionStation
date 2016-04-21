function Axes = getaxes(this, varargin)
%GETAXES  Get array of HG axes to which response data is mapped.
%
%  Responses are arrays of curves, each curve being plotted in 
%  a particular HG axes. The mapping between response curves 
%  and axes is one-to-one for a full view, and many-to-one 
%  when axes are grouped.
%
%  AX = GETAXES(H) returns a 4D array of HG axes handles where
%  the first two dimensions are the I/O sizes, and the last two
%  dimensions are the subplot sizes (e.g., 2-by-1 for Bode plots).
%  This array specifies in which axes each response curve is 
%  currently drawn.
%
%  AX = GETAXES(H,'2d') formats the same information into a 2D 
%  matrix conforming with the axes grid layout.
% 
%  See also ALLAXES.

%  Author(s): Pascal Gahinet, Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:34 $

% REM: GridSize <= size(Axes)  (e.g, in bode plots)
Axes = getaxes(this.AxesGrid);
GridSize = this.AxesGrid.Size;

% Take axes grouping into account
switch this.IOGrouping
case 'all'
   Axes = repmat(Axes(1,1,:,:),GridSize([1 2]));
case 'inputs'
   Axes = repmat(Axes(:,1,:,:), [1 GridSize(2)]);
case 'outputs'
   Axes = repmat(Axes(1,:,:,:), [GridSize(1) 1]);
end

% Reformat to 2D if requested
if any(strcmp(varargin,'2d'))
   Axes = reshape(permute(Axes,[3 1 4 2]),...
      [prod(GridSize([1 3])),prod(GridSize([2 4]))]);
end