function Axes = getaxes(this, varargin)
%GETAXES  Get array of HG axes to which response data is mapped.
%
%  Same as WAVEPLOT/GETAXES, but also takes RowIndex and ColumnIndex 
%  into account.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:26:11 $

% Get axes for entire @waveplot (4d array)
Axes = getaxes(this.Parent);

% Apply row and column indices
Axes = Axes(this.RowIndex,this.ColumnIndex,:,:);

% Reformat to 2D if requested
if any(strcmp(varargin,'2d'))
   s = size(Axes);
   Axes = reshape(permute(Axes,[3 1 4 2]),[s(1)*s(3),s(2)*s(4)]);
end