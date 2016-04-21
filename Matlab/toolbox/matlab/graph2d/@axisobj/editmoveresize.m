function A = editmoveresize(A, varargin)
%AXISOBJ/EDITMOVERESIZE Move and resize axisobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:11:40 $

newDrag = ~get(A,'Draggable');
A = set(A,'Draggable', newDrag);
A = set(A,'IsSelected', newDrag);


