function [varargout] = selectmoveresize(varargin)
%SELECTMOVERESIZE Interactively select, move, resize, or copy objects.
%   SELECTMOVERESIZE as a button down function will handle
%   selecting, moving, resizing, and copying of Axes and Uicontrol 
%   graphics objects.
%   For example, this statement sets the button down function of the
%   current Axes to SELECTMOVERESIZE:
%   set(gca,'ButtonDownFcn','selectmoveresize')
%
%   A = SELECTMOVERESIZE returns a structure array containing:
%      A.Type: a string containing the action type, which can be
%      Select, Move, Resize, or Copy
%      A.Handles: A list of the selected handles or for a Copy an Mx2
%      matrix containing the original handles in the first column and 
%      the new handles in the second column.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/10 23:34:23 $
%   Built-in function.

if nargout == 0
  builtin('selectmoveresize', varargin{:});
else
  [varargout{1:nargout}] = builtin('selectmoveresize', varargin{:});
end
