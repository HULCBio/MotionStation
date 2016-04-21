function hgset_position(Editor,NewPosition)
% HG rendering of editor's Position property.

%   $Revision: 1.5 $  $Date: 2001/08/10 21:04:56 $
%   Copyright 1986-2001 The MathWorks, Inc.

% Set editor position in host figure
set(Editor.hgget_axeshandle,'Position',NewPosition)
