function aObj = doresize(aObj, posOffsets)
%FRAMERECT/DORESIZE Resize framerect object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:12:44 $

%   posOffsets [L B R T]

set(aObj,'Position',get(aObj,'Position') + posOffsets);
