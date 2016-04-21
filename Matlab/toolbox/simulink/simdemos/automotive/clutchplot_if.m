function clutchplot_if(Action)
%CLUTCHPLOT_IF plot clutch time histories.
%   CLUTCHPLOT_IF plots the input and output time histories of the clutch_if
%   model.  
%
%   This function uses the model callbacks PreLoadFcn, PostLoadFcn, StartFcn,
%   StopFcn and CloseFcn.  It also makes use of the find_system command.

%   Loren Dean
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.3 $

FigHandle=findobj(allchild(0),'flat','Tag','OverlayFigure');
FigPlotHandle=findobj(allchild(0),'flat','Tag','OverlayPlotFigure');

if nargin,
  Data=get(FigHandle,'UserData');

  % Find the Figure and check if it's open  

  switch Action,
    %%%%%%%%%%%%%  
    %%% Close %%%  
    %%%%%%%%%%%%%  
    case 'Close',
      close(FigPlotHandle)
      delete(FigHandle)      
      
    %%%%%%%%%%%%%%%%%%%%%%%
    %%% Plot everything %%%
    %%%%%%%%%%%%%%%%%%%%%%%
    case 'Plot',
      LocalPlot(Data,FigHandle,FigPlotHandle)
      
    %%%%%%%%%%%%%  
    %%% Start %%%  
    %%%%%%%%%%%%%  
    case 'Start',
      if ~isempty(FigHandle),    
        set(Data.Handles,'Enable','off');    
      end        
      
    %%%%%%%%%%%%  
    %%% Stop %%%  
    %%%%%%%%%%%%  
    case 'Stop',
      if ~isempty(FigHandle),    
        figure(FigHandle)        
        set(Data.Handles,'Enable','on');    
        LocalPlot(Data,FigHandle,FigPlotHandle)
        
      else,
        LocalInitFig(FigHandle,FigPlotHandle)
      end % if ~isempty
     
    %%%%%%%%%%%%%%%%%%
    %%% Initialize %%%
    %%%%%%%%%%%%%%%%%%
    otherwise,    
      LocalInitFig(FigHandle,FigPlotHandle)
      
  end % switch
  
%%%%%%%%%%%%%%%%%  
%%% Intialize %%%
%%%%%%%%%%%%%%%%%
else,
  LocalInitFig(FigHandle,FigPlotHandle);
  
end % if nargin

%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalPlot %%%%%
%%%%%%%%%%%%%%%%%%%%%
function LocalPlot(Data,FigHandle,FigPlotHandle)

LineStyleOrder={'-';'--';':';'-.'};
LineW=2;  
ColorOrder='rgbymc';

Value=get(Data.Handles,{'Value'});
Value=find([Value{:}]);

% Check to see that the simulation was run  
Vars=evalin('base','whos(''y'')');

FigPlotOpen=~isempty(FigPlotHandle);

if ~isempty(Vars) & ~isempty(Value),  
  % If the figure isn't open, then create an empty one  
  if ~FigPlotOpen,
    FigPlotHandle=figure('Tag','OverlayPlotFigure', ...
                         'Name','Clutch_if demo Input and Output Plots'  ...
                        );
  end

  % Bring the figure to the front and delete the axes  
  figure(FigPlotHandle);
  cla
  AxesHandle=findobj(FigPlotHandle,'Type','axes');  

  tout=evalin('base','t');  
  yout=evalin('base','y');  
  
  LineIndex=1;
  ColorIndex=1;  
  String={};  
  for lp=1:length(Value),          
    if Value(lp)<=Data.NumInputs,    
      EvalStr=get_param(Data.BlockHandles(Value(lp)),'VariableName');
      Matrix=evalin('base',EvalStr);        
      plot(Matrix(:,1),Matrix(:,2), ...
          'LineStyle',LineStyleOrder{LineIndex}, ...
          'LineWidth',LineW, ...            
          'Color',ColorOrder(ColorIndex))
      
    else,
      plot(tout,yout(:,Value(lp)-2), ...
          'LineWidth',LineW, ...            
          'LineStyle',LineStyleOrder{LineIndex}, ...
          'Color',ColorOrder(ColorIndex))      
    end      
    hold on
    grid on    
    String=[String {[' ' Data.Names{Value(lp)} '(' ...
            ColorOrder(ColorIndex) ...
            LineStyleOrder{LineIndex} ')']}];
    
    ColorIndex=ColorIndex+1;
    if ColorIndex>length(ColorOrder),
      LineIndex=LineIndex+1;
      ColorIndex=1;
    end
  end
  
  if length(Value)<5,
    String=strcat(String{:});    
  elseif length(Value)<8,
    String={strcat(String{1:4});strcat(String{5:end})};
  else,
    String={strcat(String{1:4});strcat(String{5:7});strcat(String{8:end})};
  end    
  TtlHandle=title(String);
  set([FigPlotHandle,AxesHandle,TtlHandle],'Units','points');  
  AxesPos=get(AxesHandle,'Position');
  FigPos=get(FigPlotHandle,'Position');
  TtlExtent=get(TtlHandle,'Extent');
  TtlPos=get(TtlHandle,'Position');
  Offset=0;  
  if sum(AxesPos(1,[2 4]))+TtlExtent(4)+5>FigPos(4),
    Offset=FigPos(4)-TtlExtent(4)-sum(AxesPos(1,[2 4]))-5;
  end    
  AxesPos(4)=AxesPos(4)+Offset;
  TtlPos(2)=TtlPos(2)+Offset;
  set(AxesHandle,'Position',AxesPos);
  set(TtlHandle,'Position',TtlPos);
  set([FigPlotHandle,AxesHandle,TtlHandle],'Units','normalized');  
  xlabel('Time (sec.)')        
  zoom on

% Nothing is selected  
else,
  % if the figure is open, clear the axes.  
  if FigPlotOpen,
    % Bring the figure to the front and delete the axes  
    set(0,'CurrentFigure',FigPlotHandle);
    cla
    title('')    
  end
end % if ~isempty


%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function LocalInitFig(FigHandle,FigPlotHandle)

FigOpen=~isempty(FigHandle);

% If clutch_if is simulated from the command line, don't open figures.
if ~isempty(find_system(0,'flat','name','clutch_if')) & ...
   strcmp(get_param('clutch_if','Open'),'off'),
  return
end

% If clutch is not open, open it
if isempty(find_system(0,'flat','name','clutch_if')),
  clutch_if
end  

%%% Open a new figure %%%  
if FigOpen,
  figure(FigHandle)    
  return
end % if FigOpen

ReturnChar=sprintf('\n');      
%%% Get Input and Output name info.    
Name=find_system('clutch_if','SearchDepth',1,'BlockType','Outport');
for lp=1:length(Name),
  PortNumber(lp,1)=str2num(get_param(Name{lp},'Port'));
  OutputName{lp,1}=get_param(Name{lp},'Name');
  OutputName{lp,1}(OutputName{lp,1}==ReturnChar)=' ';      
  OutputHandles(lp,1)=get_param(Name{lp},'Handle');      
end % for lp

[Junk,SortIndex]=sort(PortNumber);
PortNumber=PortNumber(SortIndex);
Name=Name(SortIndex);
OutputName=OutputName(SortIndex);
OutputHandles=OutputHandles(SortIndex);      
OutputName=[{'Outputs'};OutputName];


TempInputName=find_system('clutch_if'     , ...
                          'SearchDepth',1, ...
                          'BlockType'  ,'FromWorkspace');

for lp=1:length(TempInputName),
  InputName{lp,1}=get_param(TempInputName{lp},'Name');      
  InputName{lp,1}(InputName{lp,1}==ReturnChar)=' ';      
  InputHandles(lp,1)=get_param(TempInputName{lp},'Handle');      
end  % for lp
InputName=[{'Inputs'};InputName];

Names=[InputName;OutputName];

%%% Set up Positions %%%    
Offset=10; 
ButtonWidth=150;              ButtonHeight=20; 

FigWidth=2*Offset+ButtonWidth;

Ct=0;    
for lp=length(Names):-1:1,
  BtnPos(lp,:)=[Offset Offset+Ct*ButtonHeight ButtonWidth ButtonHeight];
  Ct=Ct+1;        
end % for lp

BtnPos(1:length(InputName),2)=BtnPos(1:length(InputName),2)+2*Offset;  

Frame2Y=BtnPos(length(InputName),2)-Offset;
FramePos=[0 0 FigWidth sum(BtnPos(length(InputName)+1,[2 4]))+Offset
          0 Frame2Y FigWidth sum(BtnPos(1,[2 4]))+Offset-Frame2Y];
      
FigHeight=sum(BtnPos(1,[2 4]))+Offset;

ScreenUnits=get(0,'Units');
set(0,'Units','pixels');
ScreenPos=get(0,'ScreenSize');
set(0,'Units',ScreenUnits);    
ModelPos=get_param('clutch_if','Location');

FigX=0;FigY=0;
%%% Create Everything %%%    
Fig=figure('Units'          ,'points'                                , ...
           'Position'       ,[FigX FigY FigWidth FigHeight]          , ...
           'CloseRequestFcn','clutchplot_if Close'                      , ...
           'Menubar'        ,'none'                                  , ...
           'Colormap'       ,[]                                      , ...
           'NumberTitle'    ,'off'                                   , ...
           'Name'           ,'Clutch_if Demo Signals'                   , ...
           'Color'          ,get(0,'defaultuicontrolbackgroundcolor'), ...
           'IntegerHandle'  ,'off'                                   , ...   
           'Visible'        ,'off'                                   , ...
           'Tag'            ,'OverlayFigure'                           ...
           );

set(Fig,'Units','pixels');
FigPos=get(Fig,'Position');

FigX=ModelPos(3)+Offset;
if FigX>ScreenPos(3)-FigPos(3),
  FigX=ScreenPos(3)-FigPos(3);
end    

FigY=ScreenPos(4)-ModelPos(2)-FigPos(4);
FigPos(1:2)=[FigX FigY];

set(Fig,'Position',FigPos,'Units','points');

for lp=1:size(FramePos,1),    
  Frame(lp)=uicontrol('Style'   ,'frame'       , ...
                      'Units'   ,'points'      , ...
                      'Position',FramePos(lp,:), ...
                      'Units'   ,'normalized'    ...                      
                      );
end % for lp
       
for lp=1:length(Names),    
  UI(lp)=uicontrol('Style'   ,'checkbox'       , ...
                   'Units'   ,'points'         , ...
                   'Position',BtnPos(lp,:)     , ...
                   'Units'   ,'normalized'     , ...               
                   'String'  ,Names{lp}        , ...
                   'Callback','clutchplot_if Plot', ...                       
                   'Tag'     ,Names{lp}          ...
                   );
end % for lp
Loc=[1 length(InputName)+1];
set(UI(Loc),'Style','text');
UI(Loc)=[];
Names(Loc)=[];

Data.BlockHandles=[InputHandles;OutputHandles];      
Data.Handles=UI;
Data.Names=Names;
Data.NumInputs=length(InputName)-1;      

set(Fig,'UserData',Data,'HandleVisibility','callback','Visible','on');