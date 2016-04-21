function hTxt = makeCopy(this)
%makeCopy Copy this Text object
%
%   makeCopy returns a new text object that is a copy of this object. The new
%   text object is not visible.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 21:56:04 $

hTxt = copy(this);
% Make sure the new text object is parented properly
set(hTxt,'Parent',get(this,'Parent'));