function scribeeventhandler(fig,co,selType)
%SCRIBEEVENTHANDLER  Plot Editor helper function

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/04/15 04:08:19 $

if nargin<1
    fig=gcbf;
end
if nargin<2
    co=gcoall(fig);
end
if nargin<3
    selType=get(fig,'SelectionType');
end

cbo = co;

scribeButtonDownFcn = 'doclick';
primaryObject = getappdata(co,'ScribeButtonDownHGObj');
if ~isempty(primaryObject)
   co = primaryObject;
end
setappdata(fig,'ScribeHGCurrentObject',co);

MLObj = getorcreateobj(co);

if isempty(MLObj)
    return;
end

ud = getscribeobjectdata(co);

switch selType
case {'normal' 'open' 'extend'}  % left click
   setappdata(cbo,'ScribeSaveFcns',get(cbo,'ButtonDownFcn'));
   set(cbo,'ButtonDownFcn','scriberestoresavefcns');
   switch get(co,'Type')
      case 'axes'
         if get(MLObj,'IsSelected') & get(MLObj,'Draggable')
            H = ud.HandleStore;
            domethod(H,'resize');
         else
            if ~isempty(scribeButtonDownFcn)
               feval(scribeButtonDownFcn,MLObj);
            end
         end
      otherwise
         if ~isempty(scribeButtonDownFcn)
            feval(scribeButtonDownFcn,MLObj);
         end
   end
case 'alt'     % right click
   contextMenu = getscribecontextmenu(co);
   if ~isempty(contextMenu)
      saveFcns = get(co,{'UIContextMenu' 'ButtonDownFcn'});
      setappdata(contextMenu,'ScribeSaveFcns', saveFcns);
      set(fig,'CurrentObject',co);
      set(co,{'UIContextMenu' 'ButtonDownFcn'}, ...
              {contextMenu 'doclick(gcbo)'});
      % fire the context menu if there is one
      % the original is restored by domymenu update
      setappdata(contextMenu,'ScribeOneShotContextMenuFlag',co);
   end
end







