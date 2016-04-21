function dlg_update_parent_ui( parent, ui )
%DLG_UPDATE_PARENT_UI( PARENT, UI )

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $  $Date: 2004/04/15 00:57:16 $

   [MACHINE,CHART,STATE] = sf('get','default','machine.isa','chart.isa','state.isa');
   switch sf('get',parent,'.isa')
      case MACHINE
         parentName = '(machine) ';
      case CHART
         parentName = '(chart) ';
      case STATE
			type = sf('get',parent,'.type');
			if type==3 %GROUP_STATE
	         parentName = '(box) ';
         elseif(type==2)
	         parentName = '(function) ';
			else
	         parentName = '(state) ';
			end
      case EVENT
         parentName = '(event) ';
      otherwise
         parentName = sprintf('(#%d) ',parent);
         warning('Bad parent type.');
   end
   parentName = [parentName sf('FullNameOf',parent,'.')];
   set(ui,'String',parentName);
   extent = get(ui,'Extent');
   fontSize = 2*get(ui,'FontSize');
   position = get(ui,'Position');
   if extent(3)+fontSize>position(3)
      % parent text exceeds its uicontrol width
      truncatedSize = floor((position(3)/(extent(3)+fontSize))*size(parentName,2));
      if truncatedSize < size(parentName,2)-3
         parentName = parentName(end-truncatedSize:end);
         parentName(1:3) = '...';
         set(ui,'String',parentName);
      else
         parentName = '...';
      end
   end


