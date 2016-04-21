function varargout = move(varargin)
%MOVE Move and/or resize an ActiveX control in its parent window.
%   POSITION = MOVE(OBJ) returns the current position.
%
%   Equivalent syntax is
%      P = OBJ.MOVE
%
%   MOVE(OBJ, POSITION) moves the control OBJ to a new position in the 
%   parent figure window. The position argument is a four-element vector 
%   specifying the position and size of the control in the window. The 
%   elements of the vector are  [x, y, width, height] where x and y are the
%   distances, in pixels, from the left window border and bottom window
%   border respectively.
%
%   Equivalent syntax is
%      P = OBJ.MOVE(POSITION)
%
%   Example:
%       f = figure('Position', [100 100 200 200]);
%       h = actxcontrol('mwsamp.mwsampctrl.1', [0 0 200 200], f);
%       pos = h.move([50 50 200 200])
%       pos =
%           50    50   200   200
%
%   See also  COM/ACTXCONTROL, COM/ACTXCONTROLSELECT

% Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2004/01/02 18:06:07 $
