function this = EditState(viewer)

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/02/01 21:56:33 $

this = MapViewer.EditState;
this.MapViewer = viewer;
this.EditMenu = this.MapViewer.EditMenu;
this.AnnotationAxes = viewer.AnnotationAxes;
c = get(this.AnnotationAxes,'Children');

if (length(c) > 0 &&...
      isa(handle(c(1)),'MapGraphics.DragLine') &&...
      ~get(handle(c(1)),'Finished'))
  % delete DragLine if line wasn't finished
  delete(handle(c(1)));
end

this.AnnotationAxes.setEditMode(true);
selectAllMenu = findall(this.EditMenu,'Tag','select all');
set(selectAllMenu,'Enable','off');
if ~isempty(get(this.AnnotationAxes,'Children'))
  this.enableMenus;
end

set(viewer.Figure,'Pointer','Arrow',...
                  'WindowButtonDownFcn','');
