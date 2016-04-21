function close(this)
%CLOSE  Close LTI Viewer

%   Author(s): Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/05/11 17:36:19 $

% Clear LineStyles Window.

PP = get(this.HG.FigureMenu.EditMenu.LineStyles,'UserData');
if PP & ishandle(PP), delete(PP), end
%
LTIFIG = this.Figure;
%
% Clear main database
delete(this);

% Delete HG figure
set(LTIFIG,'DeleteFcn','');
delete(LTIFIG(ishandle(LTIFIG)));


