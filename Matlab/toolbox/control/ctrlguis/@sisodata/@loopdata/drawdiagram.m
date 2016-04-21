function drawdiagram(LoopData)
%DRAWDIAGRAM  Draws Simulink diagram for SISO Tool feedback loop.

%   Author(s): K. Gondoly and P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/10 23:14:03 $

%---Check if the User has Simulink
if license('test', 'SIMULINK')
    Answer = questdlg(...
        {'Before the diagram can be drawn, the plant and '
        'compensator data must be exported to the workspace.'
        ' '
        'The data will be stored in the variable names used' 
        'in the SISO Tool and may overwrite data currently '
        'in the Workspace.'
        ' '
        'Do you wish to continue?'},...
        'Drawing Simulink Diagrams','Yes','No','Yes');
    if strcmp(Answer,'Yes')
        LocalDrawDiagram(LoopData)
    end
else
    WarnStr = {'Simulink must be included in your MATLAB path before',...
            'requesting a Simulink diagram of the closed-loop system'};
    warndlg(WarnStr,'SISO Tool Warning');
end 

%----------------- Local functions -----------------

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalDrawDiagram %%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDrawDiagram(LoopData)

WatchFig = watchon;

% Find adequate name for new diagram
AllDiagrams = find_system('Type','block_diagram');
DiagramName = LoopData.SystemName;
if ~isempty(AllDiagrams)
   %---Look first for an exact match
   ExactMatch = strmatch(DiagramName,AllDiagrams,'exact');
   if ~isempty(ExactMatch)
      DiagramName = sprintf('%s_',DiagramName);
      % Look for an available name of the form DiagramName_xxx
      UsedInds = strmatch(DiagramName,AllDiagrams);
      if ~isempty(UsedInds)
         %---Look for minimum available number to use
         UsedNames = strvcat(AllDiagrams{UsedInds});
         %---Weed out names that don't end in scalar values.
         strVals = real(UsedNames(:,length(DiagramName)+1:end));
         strVals(find(strVals(:,1)<48 | strVals(:,1)>57),:)=[];
         RealVals = zeros(size(strVals,1),1);
         for ctR=1:size(strVals,1),
            RealVals(ctR,1) = str2double(char(strVals(ctR,:)));
         end
         if ~isnan(RealVals),
            NextInd = setdiff(1:max(RealVals)+1,RealVals);
            NextInd = NextInd(1);
         else
            NextInd=1;
         end
      else
         NextInd=1;
      end % if/else isempty(UsedInds)
      DiagramName = sprintf('%s%d',DiagramName,NextInd);
   end % if ~isempty(ExactMatch)
end % if ~isempty(AllDiagrams)

%---Open New Simulink diagram
NewDiagram = new_system;
set_param(NewDiagram,'Name',DiagramName);

% Write model data in workspace
assignin('base',LoopData.Plant.Name,LoopData.Plant.Model);
assignin('base',LoopData.Sensor.Name,LoopData.Sensor.Model);
assignin('base',LoopData.Filter.Name,zpk(LoopData.Filter));
assignin('base',LoopData.Compensator.Name,zpk(LoopData.Compensator));

%---Open CSTBLOCKS, if not already open
BlockOpenFlag = find_system('Name','cstblocks');
if isempty(BlockOpenFlag)
   load_system('cstblocks');
end

CompBlock = add_block('cstblocks/LTI System',[DiagramName,'/Compensator']);
set_param(CompBlock,'MaskValueString',[LoopData.Compensator.Name,'|[]']);
InBlock = add_block('built-in/SignalGenerator',[DiagramName,'/Input']);
OutBlock = add_block('built-in/Scope',[DiagramName,'/Output']);
SumBlock = add_block('built-in/Sum',[DiagramName,'/Sum']);
PlantBlock = add_block('cstblocks/LTI System',[DiagramName,'/Plant']);
set_param(PlantBlock,'MaskValueString',[LoopData.Plant.Name,'|[]']);
SensorBlock = add_block('cstblocks/LTI System',[DiagramName,'/Sensor Dynamics']);
set_param(SensorBlock,'MaskValueString',[LoopData.Sensor.Name,'|[]']);
FilterBlock = add_block('cstblocks/LTI System',[DiagramName,'/Feed Forward']);
set_param(FilterBlock,'MaskValueString',[LoopData.Filter.Name,'|[]']);

%---Close CSTBLOCKS, if it wasn't open before
if isempty(BlockOpenFlag),
   close_system('cstblocks')
end

if LoopData.FeedbackSign>0,
   SumStr='++';
else
   SumStr='+-';
end	
set_param(SumBlock,'Inputs',SumStr)
set_param(NewDiagram,'Location',[70, 200, 560, 420])
set_param(SensorBlock,'Orientation','left');

open_system(NewDiagram)

% Diagram topology depends on loop configuration
switch LoopData.Configuration
case 1 % Forward
   set_param(SumBlock,'Position',[165, 42, 195, 73])
   set_param(OutBlock,'Position',[440, 45, 465, 75])
   set_param(InBlock,'Position',[15, 35, 45, 65])
   set_param(PlantBlock,'Position',[315, 42, 380, 78])
   set_param(SensorBlock,'Position',[285, 112, 350, 148])
   set_param(CompBlock,'Position',[220, 42, 285, 78])
   set_param(FilterBlock,'Position',[65, 32, 130, 68])
   LinePos=[{[50 50; 60 50]};
      {[135 50; 160 50]};
      {[280 130; 150 130; 150 65; 160 65]};
      {[200 60;215 60]};
      {[290 60;310 60]};
      {[385 60;435 60]};
      {[400 60; 400 130;355 130]}];
case 2 % Feedback
   set_param(SumBlock,'Position',[165, 42, 195, 73])
   set_param(OutBlock,'Position',[440, 45, 465, 75])
   set_param(InBlock,'Position',[15, 35, 45, 65])
   set_param(PlantBlock,'Position',[255, 42, 320, 78])
   set_param(SensorBlock,'Position',[310, 112, 375, 148])
   set_param(CompBlock,'Position',[200, 112, 265, 148],'Orientation','left')
   set_param(FilterBlock,'Position',[65, 32, 130, 68])
   LinePos=[{[305 130;270 130]};
      {[200 60;250 60]};
      {[195 130;150 130;150 65;160 65]};
      {[50 50;60 50]};
      {[135 50;160 50;]};
      {[325 60; 435 60]};
      {[400 60; 400 130; 380 130]}];
case 3 % Filter in the Feedforward path
   set_param(SumBlock,'Position',[155 62 185 93])
   set_param(OutBlock,'Position',[485 60 510 90])
   set_param(InBlock,'Position',[15 55 45 85])
   set_param(PlantBlock,'Position',[370 57 435 93])
   set_param(SensorBlock,'Position',[285 137 350 173])
   set_param(CompBlock,'Position',[210 62 275 98])
   set_param(FilterBlock,'Position',[85 12 150 48])
   SumBlock2 = add_block('built-in/Sum',[DiagramName,'/Sum2'],'Position',[310 57 340 88],'Inputs','++');
   LinePos={[155 30;295 30;295 65;305 65] ; ...
         [50 70;60 70;60 30;80 30];...
         [60 70;150 70];...
         [280 155;130 155;130 85;150 85];...
         [190 80;205 80];...
         [280 80;305 80];...
         [345 75;365 75];...
         [440 75;455 75;455 155;355 155];...
         [455 75;480 75]};
case 4 %  Filter in the Feedback path
   set_param(SumBlock,'Position',[80 37 110 68])
   set_param(OutBlock,'Position',[450 50 475 80])
   set_param(InBlock,'Position',[15 30 45 60])
   set_param(PlantBlock,'Position',[315 47 380 83])
   set_param(SensorBlock,'Position',[310 147 375 183])
   set_param(CompBlock,'Position',[135 37 200 73])
   set_param(FilterBlock,'Position',[187 105 253 145],'Orientation','up')
   SumBlock2 = add_block('built-in/Sum',[DiagramName,'/Sum2'],...
      'Position',[245 47 275 78],'Inputs','++');
   LinePos={[220 100;220 70;240 70];...
         [385 65;385 65;420 65;420 165;380 165];...
         [420 65;445 65];...
         [205 55;240 55];...
         [50 45;75 45];...
         [305 165;305 165;220 165;65 165;65 60;75 60];...
         [220 165;220 150];...
         [115 55;130 55];...
         [280 65;310 65]};
end


for ctLine = 1:length(LinePos)
   add_line(NewDiagram,LinePos{ctLine});
end

open_system(NewDiagram);

watchoff(WatchFig)
