function Answer=inputdlg(Prompt, Title, NumLines, DefAns, Resize)
%INPUTDLG Input dialog box.
%  ANSWER = INPUTDLG(PROMPT) creates a modal dialog box that returns user
%  input for multiple prompts in the cell array ANSWER. PROMPT is a cell
%  array containing the PROMPT strings.
%
%  INPUTDLG uses UIWAIT to suspend execution until the user responds.
%
%  ANSWER = INPUTDLG(PROMPT,NAME) specifies the title for the dialog.
%
%  ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES) specifies the number of lines for
%  each answer in NUMLINES. NUMLINES may be a constant value or a column
%  vector having one element per PROMPT that specifies how many lines per
%  input field. NUMLINES may also be a matrix where the first column
%  specifies how many rows for the input field and the second column
%  specifies how many columns wide the input field should be.
%
%  ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER) specifies the
%  default answer to display for each PROMPT. DEFAULTANSWER must contain
%  the same number of elements as PROMPT and must be a cell array of
%  strings.
%
%  ANSWER = INPUTDLG(PROMPT,NAME,NUMLINES,DEFAULTANSWER,OPTIONS) specifies
%  additional options. If OPTIONS is the string 'on', the dialog is made
%  resizable. If OPTIONS is a structure, the fields Resize, WindowStyle, and
%  Interpreter are recognized. Resize can be either 'on' or
%  'off'. WindowStyle can be either 'normal' or 'modal'. Interpreter can be
%  either 'none' or 'tex'. If Interpreter is 'tex', the prompt strings are
%  rendered using LaTeX.
%
%  Examples:
%
%  prompt={'Enter the matrix size for x^2:','Enter the colormap name:'};
%  name='Input for Peaks function';
%  numlines=1;
%  defaultanswer={'20','hsv'};
%
%  answer=inputdlg(prompt,name,numlines,defaultanswer);
%
%  options.Resize='on';
%  options.WindowStyle='normal';
%  options.Interpreter='tex';
%
%  answer=inputdlg(prompt,name,numlines,defaultanswer,options);
%
%  See also TEXTWRAP, QUESTDLG, UIWAIT.

%  Copyright 1994-2003 The MathWorks, Inc.
%  $Revision: 1.58.4.5 $

%%%%%%%%%%%%%%%%%%%%
%%% Nargin Check %%%
%%%%%%%%%%%%%%%%%%%%
error(nargchk(1,5,nargin));
error(nargoutchk(1,1,nargout));

if nargin==1,
    Title=' ';
end

if nargin<=2
    NumLines=1;
end

if ~iscell(Prompt)
    Prompt={Prompt};
end

NumQuest=prod(size(Prompt));    

if nargin<=3 
    DefAns=cell(NumQuest,1);
    for lp=1:NumQuest
        DefAns{lp}='';
    end
end

WindowStyle='modal';
Interpreter='none';

if nargin<5
    Resize = 'off';
end

Options = struct([]);

if nargin==5 && isstruct(Resize)
    Options = Resize;
    Resize  = 'off';
    if isfield(Options,'Interpreter'), Interpreter=Options.Interpreter; end
    if isfield(Options,'WindowStyle'), WindowStyle=Options.WindowStyle; end
    if isfield(Options,'Resize'),      Resize=Options.Resize;           end
end

[rw,cl]=size(NumLines);
OneVect = ones(NumQuest,1);
if (rw == 1 & cl == 2)
    NumLines=NumLines(OneVect,:);
elseif (rw == 1 & cl == 1)
    NumLines=NumLines(OneVect);
elseif (rw == 1 & cl == NumQuest)
    NumLines = NumLines';
elseif rw ~= NumQuest | cl > 2,
    error('NumLines size is incorrect.')
end

if ~iscell(DefAns),
    error('Default Answer must be a cell array of strings.');  
end

%%%%%%%%%%%%%%%%%%%%%%%
%%% Create InputFig %%%
%%%%%%%%%%%%%%%%%%%%%%%
FigWidth=300;
FigHeight=100;
FigPos(3:4)=[FigWidth FigHeight];
FigColor=get(0,'Defaultuicontrolbackgroundcolor');

InputFig=dialog(                    ...
    'Visible'          ,'off'      , ...
    'KeyPressFcn'      ,@doFigureKeyPress, ...
    'Name'             ,Title      , ...
    'Pointer'          ,'arrow'    , ...
    'Units'            ,'pixels'   , ...
    'UserData'         ,'Cancel'   , ...
    'Tag'              ,Title      , ...
    'HandleVisibility' ,'callback' , ...
    'Color'            ,FigColor   , ...
    'NextPlot'         ,'add'      , ...
    'WindowStyle'      ,WindowStyle, ...
    'DoubleBuffer'     ,'on'       , ...
    'Resize'           ,Resize       ...
    );


%%%%%%%%%%%%%%%%%%%%%
%%% Set Positions %%%
%%%%%%%%%%%%%%%%%%%%%
DefOffset   = 10;

DefBtnWidth = 56;
BtnHeight   = 22;
BtnYOffset  = DefOffset;
BtnFontSize = get(0,'FactoryUIControlFontSize');
BtnWidth    = DefBtnWidth;

TextInfo.Units              = 'pixels'   ;   
TextInfo.FontSize           = BtnFontSize;
TextInfo.HorizontalAlignment= 'left'     ;
TextInfo.HandleVisibility   = 'callback' ;

StInfo=TextInfo;
StInfo.Style              = 'text'     ;
StInfo.BackgroundColor    = FigColor;

TextInfo.VerticalAlignment= 'bottom';

EdInfo=StInfo;
EdInfo.Style           = 'edit';
EdInfo.BackgroundColor = 'w';

BtnInfo=StInfo;
BtnInfo.Style               = 'pushbutton';
BtnInfo.HorizontalAlignment = 'center';

% adjust button height and width
btnMargin=1.4;
ExtControl=uicontrol(InputFig   ,BtnInfo     , ...
                     'String'   ,'OK'        , ...
                     'Visible'  ,'off'         ...
                     );
BtnExtent = get(ExtControl,'Extent');
BtnWidth  = max(BtnWidth,BtnExtent(3)+8);
BtnHeight = max(BtnHeight,BtnExtent(4)*btnMargin);
delete(ExtControl);

TxtWidth=FigWidth-2*DefOffset;

% Determine # of lines for all Prompts
ExtControl=uicontrol(InputFig   ,StInfo     , ...
                     'String'   ,''         , ...    
                     'Position' ,[ DefOffset DefOffset 0.96*TxtWidth BtnHeight ] , ...
                     'Visible'  ,'off'        ...
                     );

WrapQuest=cell(NumQuest,1);
QuestPos=zeros(NumQuest,4);

for ExtLp=1:NumQuest
    if size(NumLines,2)==2
        [WrapQuest{ExtLp},QuestPos(ExtLp,1:4)]= ...
            textwrap(ExtControl,Prompt(ExtLp),NumLines(ExtLp,2));
    else
        [WrapQuest{ExtLp},QuestPos(ExtLp,1:4)]= ...
            textwrap(ExtControl,Prompt(ExtLp),80);
    end
end % for ExtLp

delete(ExtControl);
QuestHeight=QuestPos(:,4);

TxtHeight=QuestHeight(1)/size(WrapQuest{1,1},1);
EditHeight=TxtHeight*NumLines(:,1);
EditHeight(NumLines(:,1)==1)=EditHeight(NumLines(:,1)==1)+4;

FigHeight=(NumQuest+2)*DefOffset    + ...
          BtnHeight+sum(EditHeight) + ...
          sum(QuestHeight);

TxtXOffset=DefOffset;

QuestYOffset=zeros(NumQuest,1);
EditYOffset=zeros(NumQuest,1);
QuestYOffset(1)=FigHeight-DefOffset-QuestHeight(1);
EditYOffset(1)=QuestYOffset(1)-EditHeight(1);

for YOffLp=2:NumQuest,
    QuestYOffset(YOffLp)=EditYOffset(YOffLp-1)-QuestHeight(YOffLp)-DefOffset;
    EditYOffset(YOffLp)=QuestYOffset(YOffLp)-EditHeight(YOffLp);
end % for YOffLp

QuestHandle=[];
EditHandle=[];
FigWidth =1;

AxesHandle=axes('Parent',InputFig,'Position',[0 0 1 1],'Visible','off');

for lp=1:NumQuest,
    EditTag=['Edit' num2str(lp)];
    if ~ischar(DefAns{lp}),
        delete(InputFig);
        error('Default Answer must be a cell array of strings.');  
    end

    EditHandle(lp)=uicontrol(InputFig    , ...
                             EdInfo      , ...
                             'Max'        ,NumLines(lp,1)       , ...
                             'Position'   ,[ TxtXOffset EditYOffset(lp) TxtWidth EditHeight(lp) ], ...
                             'String'     ,DefAns{lp}           , ...
                             'Tag'        ,'Edit'                 ...
                             );

    QuestHandle(lp)=text('Parent'     ,AxesHandle, ...
                         TextInfo     , ...
                         'Position'   ,[ TxtXOffset QuestYOffset(lp)], ...
                         'String'     ,WrapQuest{lp}                 , ...
                         'Color'      ,get(EditHandle(lp),'ForegroundColor')   , ...
                         'Interpreter',Interpreter                   , ...
                         'Tag'        ,'Quest'                         ...
                         );

    if size(NumLines,2) == 2,
        set(EditHandle(lp),'String',char(ones(1,NumLines(lp,2))*'x'));
        Extent = get(EditHandle(lp),'Extent');
        NewPos = [TxtXOffset EditYOffset(lp)  Extent(3) EditHeight(lp) ];

        NewPos1= [TxtXOffset QuestYOffset(lp)];
        set(EditHandle(lp),'Position',NewPos,'String',DefAns{lp})
        set(QuestHandle(lp),'Position',NewPos1)
        
        FigWidth=max(FigWidth,Extent(3)+2*DefOffset);
    else
        FigWidth=max(175,TxtWidth+2*DefOffset);
    end

end % for lp

FigPos=get(InputFig,'Position');

FigWidth=max(FigWidth,2*(BtnWidth+DefOffset)+DefOffset);
FigPos(1)=0;
FigPos(2)=0;
FigPos(3)=FigWidth;
FigPos(4)=FigHeight;

set(InputFig,'Position',getnicedialoglocation(FigPos,get(InputFig,'Units')));

OKHandle=uicontrol(InputFig     ,              ...
                   BtnInfo      , ...
                   'Position'   ,[ FigWidth-2*BtnWidth-2*DefOffset DefOffset BtnWidth BtnHeight ] , ...
                   'KeyPressFcn',@doControlKeyPress , ...
                   'String'     ,'OK'        , ...
                   'Callback'   ,@doCallback , ...
                   'Tag'        ,'OK'        , ...
                   'UserData'   ,'OK'          ...
                   );

BtnPos = get(OKHandle,'Position');
h = uicontrol(InputFig,'BackgroundColor', 'k', ...
              'Style','frame','Position',[ BtnPos(1)-1 BtnPos(2)-1 BtnPos(3)+2 BtnPos(4)+2 ]);
uistack(h,'bottom')

CancelHandle=uicontrol(InputFig     ,              ...
                       BtnInfo      , ...
                       'Position'   ,[ FigWidth-BtnWidth-DefOffset DefOffset BtnWidth BtnHeight ]           , ...
                       'KeyPressFcn',@doControlKeyPress            , ...
                       'String'     ,'Cancel'    , ...
                       'Callback'   ,@doCallback , ...
                       'Tag'        ,'Cancel'    , ...
                       'UserData'   ,'Cancel'      ...
                       );

handles = guihandles(InputFig);
handles.MinFigWidth = FigWidth;
handles.FigHeight   = FigHeight;
handles.TextMargin  = 2*DefOffset;
guidata(InputFig,handles);
set(InputFig,'ResizeFcn',@doResize);

% make sure we are on screen
movegui(InputFig)

% if there is a figure out there and it's modal, we need to be modal too
if ~isempty(gcbf) && strcmp(get(gcbf,'WindowStyle'),'modal')
    set(InputFig,'WindowStyle','modal');
end

set(InputFig,'Visible','on');
drawnow;

uiwait(InputFig);

if ishandle(InputFig)
    Answer={};
    if strcmp(get(InputFig,'UserData'),'OK'),
        Answer=cell(NumQuest,1);
        for lp=1:NumQuest,
            Answer(lp)=get(EditHandle(lp),{'String'});
        end
    end
    delete(InputFig);
else
    Answer={};
end

function doFigureKeyPress(obj, evd)
switch(evd.Key)
 case {'return','space'}
  set(gcbf,'UserData','OK');
  uiresume(gcbf);
 case {'escape'}
  delete(gcbf);
end

function doControlKeyPress(obj, evd)
switch(evd.Key)
 case {'return'}
  if ~strcmp(get(obj,'UserData'),'Cancel')
      set(gcbf,'UserData','OK');
      uiresume(gcbf);
  else
      delete(gcbf)
  end
 case 'escape'
  delete(gcbf)
end

function doCallback(obj, evd)
if ~strcmp(get(obj,'UserData'),'Cancel')
    set(gcbf,'UserData','OK');
    uiresume(gcbf);
else
    delete(gcbf)
end

function doResize(FigHandle, evd)
Data=guidata(FigHandle);

resetPos = false; 

FigPos = get(FigHandle,'Position');
FigWidth = FigPos(3);
FigHeight = FigPos(4);

if FigWidth < Data.MinFigWidth
    FigWidth  = Data.MinFigWidth;
    FigPos(3) = Data.MinFigWidth;
    resetPos = true;
end

% make sure edit fields use all available space  
for lp = 1:length(Data.Edit)
    EditPos = get(Data.Edit(lp),'Position');
    EditPos(3) = FigWidth - Data.TextMargin;
    set(Data.Edit(lp),'Position',EditPos);
end

if FigHeight ~= Data.FigHeight
    FigPos(4) = Data.FigHeight;
    resetPos = true;
end

if resetPos
    set(FigHandle,'Position',FigPos);  
end
