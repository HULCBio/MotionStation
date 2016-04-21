function varargout = chart_recovery_man(method,varargin)
% STATEFLOW CHART RECOVERY MANAGER
%   BLOCKHANDLE = CHART_RECOVERY_MAN( METHOD, VARARGIN)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.8.2.1 $  $Date: 2004/04/15 00:56:09 $

RECOVERED_CHARTS_PER_ROW = 5;
CONTAINER_NAME = '###Recovered Stateflow Charts###';
CONTAINER_X = 200.0;
CONTAINER_Y = 50.0;
CONTAINER_W =200;
CONTAINER_H =200;
CONTAINER_ANNOTATION = ['Stateflow load mechanism has detected a set of corrupted charts.',10,...
      'Specifically, Stateflow did not find the corresponding Simulink blocks',10,...
      'for these charts. These charts are salvaged and collected in this subsystem.',10,...
      'Their fullpath names are modified by substituting underscores(''_'') for',10,...
      'path separators(''/''), so that you can figure out where these charts belong.',10,...
      'Please move them to the appropriate locations and rename them immediately',10,...
      'before saving this model again.',10,...
      'Date of this message : ',sf_date_str,10,...
      'Stateflow ',sf('Version')];
NOTE_X = 20;
NOTE_Y = 30;

RECOVERED_CHART_X =50;
RECOVERED_CHART_Y =300;
RECOVERED_CHART_W =200;
RECOVERED_CHART_H =200;
RECOVERED_CHART_X_SPACING =(RECOVERED_CHART_W+30);
RECOVERED_CHART_Y_SPACING =(RECOVERED_CHART_H+30);

switch(method)
case 'get_container'
   modelH = varargin{1};
   containerHandle = find_system(modelH,'SearchDepth',1,'Name',CONTAINER_NAME);
   modelName = get_param(modelH,'Name');
   if(isempty(containerHandle))
      containerHandle = add_block('built-in/SubSystem', [modelName,'/',CONTAINER_NAME]);
      position = [CONTAINER_X,CONTAINER_Y,CONTAINER_X+CONTAINER_W,CONTAINER_Y+CONTAINER_H];
      set_param(containerHandle,...
         'Position',position,...
         'ForeGroundColor','Red',...
         'BackGroundColor','Gray',...
         'FontSize',20);
      
   end
   noteHandle = find_system(containerHandle,'SearchDepth',1,'FindAll','on','Type','annotation');
   if(isempty(noteHandle))
      noteHandle = add_block('built-in/Note',[modelName,'/',CONTAINER_NAME,'/','xyz']);
   end
   notePosition = [NOTE_X,NOTE_Y];
   set_param(noteHandle,'text',CONTAINER_ANNOTATION,...
      'Position',notePosition,...
      'FontSize',20,...
      'HorizontalAlignment','left');      
   
   if(nargout>1)
      varargout{2} = CONTAINER_NAME;
   end
   if(nargout>0)
      varargout{1} = containerHandle;
   end

case 'get_chart'
   containerHandle = varargin{1};
   chartName = varargin{2};
   chartIndex = varargin{3};
   
   recoveredChartHandle = find_system(containerHandle,'SearchDepth',1,'Name',chartName);
   if(isempty(recoveredChartHandle))
      chartFullName = [getfullname(containerHandle),'/',chartName];
      recoveredChartHandle = add_block('built-in/SubSystem',chartFullName);
      set_param(recoveredChartHandle,'MaskType','Stateflow');
      
		rowNumber = floor((chartIndex-1)/RECOVERED_CHARTS_PER_ROW) +1;
      columnNumber = mod((chartIndex-1),RECOVERED_CHARTS_PER_ROW)+1;
      posx = RECOVERED_CHART_X+RECOVERED_CHART_X_SPACING*(columnNumber-1);
      posy = RECOVERED_CHART_Y + RECOVERED_CHART_Y_SPACING*(rowNumber-1);
      posw = posx+RECOVERED_CHART_W;
      posh = posy+RECOVERED_CHART_H;
      set_param(recoveredChartHandle,'Position',[posx,posy,posw,posh]);
      set_param(recoveredChartHandle,'MaskIconFrame','off');
   end
   if(nargout>0)
      varargout{1} = recoveredChartHandle;
   end
case 'display_help'
   modelH = varargin{1};
   modelName = get_param(modelH,'Name');
   
   displayMsg = ['******IMPORTANT******',10,...
         'Corrupted Stateflow charts are recovered and placed in a subsystem named ',10,...
         CONTAINER_NAME,'. You can open it using ',10,...
         '   open_system(''',modelName,'/',CONTAINER_NAME,''');'];
   disp(displayMsg);
end