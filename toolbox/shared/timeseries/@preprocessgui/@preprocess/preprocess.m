function h = preprocess(dataset)
%PREPROCESS
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:32:51 $

h = preprocessgui.preprocess;
h.initialize(dataset);
