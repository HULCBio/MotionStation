function rebuild(h)
%REBUILD
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:32:52 $

% Hide graph editor if its visible. Clear the panel and re-initialize
% the GUI object
h.javaframe.reset(h);

% Display the gui
awtinvoke(h.javaframe,'setVisible',true);
h.Visible = 'on';
