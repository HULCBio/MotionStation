function [hasFixedRowSize,hasFixedColSize] = hasFixedSize(this)
%HASFIXEDSIZE  Indicates when plot's row or column size is fixed, i.e.,
%              independent of the plot contents.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:22 $
hasFixedRowSize = false;
hasFixedColSize = false;