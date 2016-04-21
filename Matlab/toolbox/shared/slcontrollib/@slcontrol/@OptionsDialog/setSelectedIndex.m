function setSelectedIndex(this, index)
% SETSELECTEDINDEX Selects the tab panel at INDEX (uses Matlab indexing)

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:49 $

% Get tabbed panel handle
this.Dialog.setSelectedIndex(index-1);
