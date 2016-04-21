function dlg_update_subsystem_ui( chartId, ui )
%DLG_UPDATE_SUBSYSTEM_UI( CHARTID, UI )

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.12.2.1 $  $Date: 2004/04/15 00:57:18 $

	if isempty(sf('get',chartId,'chart.isa'))
		ssName = sprintf('(#%d) ',chartId);
		warning('Bad chart type.');
   end
   [machine,instances] = sf('get',chartId,'.machine','.instances');
   if isempty(instances)
      warning('No instances of this char.');
      return;
   end
   instanceId = instances(1);
   ssName = [sf('get',machine,'.name') '/' sf('get',instanceId,'.name')];
	ssName(regexp(ssName,'\s'))=' ';
   set(ui,'String',ssName);
   extent = get(ui,'Extent');
   fontSize = 2*get(ui,'FontSize');
   position = get(ui,'Position');
   if extent(3)+fontSize>position(3)
      % ssName text exceeds its uicontrol width
      truncatedSize = floor((position(3)/(extent(3)+fontSize))*size(ssName,2));
      if truncatedSize < size(ssName,2)-3
         ssName = ssName(end-truncatedSize:end);
         ssName(1:3) = '...';
         set(ui,'String',ssName);
      else
         ssName = '...';
      end
   end





