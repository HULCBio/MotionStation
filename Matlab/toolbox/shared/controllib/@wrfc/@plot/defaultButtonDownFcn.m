function defaultButtonDownFcn(this,EventSrc)
% Default axis buttondown function

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:16 $
switch get(get(EventSrc,'Parent'),'SelectionType')
   case 'normal'
      PropEdit = PropEditor(this,'current');  % handle of (unique) property editor
      if ~isempty(PropEdit) & PropEdit.isVisible
         % Left-click & property editor open: quick target change
         PropEdit.setTarget(this);
      end
      % Get the cursor mode object
      hTool = datacursormode(ancestor(EventSrc,'figure'));
      % Clear all data tips
      target = handle(EventSrc);
      if isa(target,'axes')
          removeAllDataCursors(hTool,target);
      end
   case 'open'
      % Double-click: open editor
      PropEdit = PropEditor(this);
      PropEdit.setTarget(this);
end
