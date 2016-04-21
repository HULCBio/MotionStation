function Axes = allaxes(this, varargin)
%ALLAXES  Get array of HG axes making up plot.
%
%  AX = ALLAXES(H) returns a 4D array of HG axes handles where
%  the first two dimensions are the row and column sizes of the 
%  axes grid, and the last two dimensions are the subplot sizes 
%  (e.g., 2-by-1 for Bode plots).
%
%  AX = ALLAXES(H,'2d') returns a matrix listing the HG axes as 
%  they appear in the plot grid.

%  Author(s): Pascal Gahinet, Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:13 $

Axes = getaxes(this.AxesGrid);
GridSize = this.AxesGrid.Size;

% Reformat to 2D if requested
if any(strcmp(varargin,'2d'))
   Axes = reshape(permute(Axes,[3 1 4 2]),...
      [prod(GridSize([1 3])),prod(GridSize([2 4]))]);
end