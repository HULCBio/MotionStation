function hgset_grid(Editor,NewState)
% HG rendering of editor's Grid property.

%   $Revision: 1.5 $  $Date: 2001/08/10 21:07:58 $
%   Copyright 1986-2001 The MathWorks, Inc.

set(Editor.hgget_axeshandle,'Xgrid',NewState,'Ygrid',NewState)
