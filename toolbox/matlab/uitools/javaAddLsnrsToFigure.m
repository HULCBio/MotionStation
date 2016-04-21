function javaAddLsnrsToFigure (fig, javaSelectionManager)
% This is a utility function used by the plot tool.

% Copyright 2002-2003 The MathWorks, Inc.

model = handle (findall (fig,'Tag','scribeOverlay'));
schemaClass = classhandle (handle (model));
sl  = handle.listener (model, ...
	     schemaClass.findprop('SelectedObjects'), ...
	     'PropertyPostSet', ...
             {@scribeLsnr, model, javaSelectionManager});
scribeLsnr([],[], model, javaSelectionManager);

% These guarantee that the event handlers will not pass out of scope
% and be garbage-collected:
appDataName = strcat ('PlotToolLsnrs', strrep (num2str (fig), '.', ''));
setappdata (0, appDataName, sl);
% setappdata (fig, 'PlotToolNonScribeLsnr', nsl);
% setappdata (fig, 'PlotToolScribeLsnr', sl);

%-------------------------------
function scribeLsnr (hProp, eventData, model, javaSelectionManager)
tmp = model.SelectedObjects;
for i = 1:length(tmp)
  if ~isprop(tmp(i),'ShapeType') && ...
        (strcmp ('line', get (tmp(i),'type')) || ...
         strcmp ('patch', get (tmp(i),'type')) || ...
         strcmp ('text', get (tmp(i),'type')))
    theParent = handle (get (tmp(i), 'parent'));
    parentSuperClasses = get (classhandle(theParent), 'superclasses');
    if ~isempty (parentSuperClasses)
      if (strcmp ('series', get (parentSuperClasses(1),'name')))
        tmp(i) = theParent;
      end
    end 
  end
end
objs = javaGetHandles (tmp);
javaSelectionManager.onScribeSelectionChanged (objs);
