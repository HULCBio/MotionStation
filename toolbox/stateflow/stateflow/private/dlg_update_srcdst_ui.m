function dlg_update_srcdst_ui( id, ui )
%DLG_UPDATE_SRCDST_UI( ID, UI )

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.14.2.1 $  $Date: 2004/04/15 00:57:17 $

if id>0
   [STATE,JUNCTION] = sf('get','default','state.isa','junction.isa');
   switch sf('get',id,'.isa')
   case STATE
      objName = ['(state) ' sf('FullNameOf',id,'.')];
   case JUNCTION
      switch sf('get',id,'.type')
      case 0 % CONNECTIVE
         objName = '(connective junction)';
      case 1 % HISTORY	
         objName = '(history junction)';
      otherwise
         objName = '(junction)';
         warning('Bad junction type.');
      end
   otherwise
      objName = sprintf('(#%d) ',id);
      warning('Bad object type.');
   end
else
   objName = '~';
end
set(ui,'String',objName);
extent = get(ui,'Extent');
adjustment = 5*get(ui,'FontSize');
position = get(ui,'Position');
if extent(3)+adjustment>position(3)
   % parent text exceeds its uicontrol width
   truncatedSize = floor((position(3)/(extent(3)+adjustment))*size(objName,2));
   if truncatedSize < size(objName,2)-3
      objName = objName(end-truncatedSize:end);
      objName(1:3) = '...';
      set(ui,'String',objName);
   else
      objName = '...';
   end
end


