function addlisteners(this, L)
%ADDLISTENERS  Adds new listeners to listener set.
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:37 $

this.Listeners = [this.Listeners; L];
