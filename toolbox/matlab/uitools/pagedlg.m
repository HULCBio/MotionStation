function varargout = pagedlg(Action,varargin)
%PAGEDLG  Page position dialog box.
%  DLG = PAGEDLG(FIG) creates a dialog box from which a set of page
%  layout related properties for the figure window, FIG, can be 
%  set.  FIG may be a vector of handles.
%
%  DLG = PAGEDLG(SYS) works on the Simulink system(s) listed in SYS.
%  SYS may be a vector of handles or a cell array of system names.

%   Loren Dean 
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.16 $  $Date: 2002/04/15 03:24:57 $

if nargin == 0
    Action = gcf;  
end

switch class(Action),
  case {'double','cell'},
    % initialization - open figure 
    [HandleStr,ErrorString]=LocalValidateHandleStr(Action);
    if ~isempty(ErrorString),
      error(ErrorString);
    end            
    Dlg=LocalInitFig(HandleStr);
    if nargout,
      varargout{1}=Dlg;
    end  
    
  case 'char',
    % This could be a callback from the dialog or initialization of
    % the dialog for a Simulink system
    if nargin==1,  
      Dlg=gcbf;
      if isempty(gcbf) & ~strcmp(get(gcbf,'Tag'),'Page Dialog'),
        [HandleStr,ErrorString]=LocalValidateHandleStr(Action);
        if ~isempty(ErrorString),
          error(ErrorString);
        end            
        Dlg=LocalInitFig(HandleStr);
        if nargout,
          varargout{1}=Dlg;
        end
        return
      end          
      
      % This is a callback from somewhere else
    else,
      Dlg=varargin{1};
    end    
    
    if strcmp(get(Dlg,'Tag'),'Page Dialog'),  
      Data=get(Dlg,'UserData');
      
    else,
      FigName=LocalFigName(Dlg);
      PageFig=findall(0,'Name',['Page Position: ' FigName]);
      if isempty(PageFig),
        FigName=LocalFigName(1:2);
        PageFig=findall(0,'Name',['Page Position: ' FigName]);
      end
      
      if isempty(PageFig),
        set(Dlg,'ResizeFcn','');
        warning('The Figure''s ResizeFcn may have changed inadvertently.'); 
        return      
      else,
        Dlg=PageFig;
        Data=get(Dlg,'UserData');      
      end % if isempty
    end % if strcmp
    
    
    [HandleStr,ErrorString]=LocalValidateHandleStr(Data.Fig);
    if ~isempty(ErrorString),
      LocalClose(Data,Dlg)
      return
    end            
    
    switch Action,
      case 'Cancel',      
        for lp=1:length(Data.Properties),
          LocalSet(Data.Fig,Data.Properties{lp},Data.OrigData(:,lp));
        end
        LocalDealWithPageFig(Data);      
        LocalClose(Data,Dlg)
        
      case 'CenterOnPage',
        LocalCenterOnPage(Data)
        LocalUpdate(Data);      
        
      case 'Close',      
        LocalClose(Data,Dlg)
        
      case 'Default',      
        for lp=1:length(Data.Properties),
          LocalSet(Data.Fig,Data.Properties{lp}, ...
              get(0,['DefaultFigure' Data.Properties{lp}]));
        end
        if strcmp(LocalGet(Data.Fig(1),'PaperPositionMode'),'auto'),  
          Data=LocalSetRadioButtons(Data.OtherHandles(2),Data);
        else,
          Data=LocalSetRadioButtons(Data.OtherHandles(1),Data);
        end % if strcmp
        
        LocalUpdate(Data);      
        LocalDealWithPageFig(Data);      
        
      case 'FigResize',
        
        % If one figure is resized, all of the others need to be too
        if length(Data.Fig>1),
          LocalSizeAllFigs(gcbf,Data.Fig);
          set(Data.Fig,'ResizeFcn','pagedlg FigResize')
          LocalSet(Data.Fig,'PaperPositionMode','auto');  
        end
          
        for lp=1:length(Data.ResizeFcn),
          ErrorFlag=logical(0);    
          set(0,'CurrentFigure',Data.Fig(lp));
          evalin('base',Data.ResizeFcn{lp},'ErrorFlag=logical(1);');
          if ErrorFlag,
            warning('ResizeFcn could not be evaluated');
          end
        end
        
        LocalCenterOnPage(Data)
        LocalUpdate(Data)      
        
      case 'FillPage',
        for lp=1:length(Data.Fig),
          PaperUnits=LocalGet(Data.Fig(lp),'PaperUnits');
          LocalSet(Data.Fig(lp),'PaperUnits','inches');      
          PaperPosition=[.25 .25 LocalGet(Data.Fig(lp),'PaperSize')-.5];
          LocalSetFigPos(Data.Fig(lp),PaperPosition, ...
              Data.AutoMode,Data.ResizeFcn{lp})
          LocalSet(Data.Fig,'PaperUnits',PaperUnits);
        end
        LocalUpdate(Data);      
        
      case 'FixedAR',
        for lp=1:length(Data.Fig),
          PaperUnits=LocalGet(Data.Fig(lp),'PaperUnits');
          LocalSet(Data.Fig(lp),'PaperUnits','inches');      
          CurrentPos=LocalGet(Data.Fig(lp),'PaperPosition');
          PaperSize=LocalGet(Data.Fig(lp),'PaperSize')-0.5;
          
          HorizRatio=PaperSize(1)/CurrentPos(3);      
          VertRatio=PaperSize(2)/CurrentPos(4);
          
          if HorizRatio<VertRatio,      
            NewPos=[0.25 0.25 PaperSize(1)        CurrentPos(4)*HorizRatio];
          else,
            NewPos=[0.25 0.25 CurrentPos(3)*VertRatio PaperSize(2)        ];
          end        
          
          LocalSetFigPos(Data.Fig(lp),NewPos,Data.AutoMode,Data.ResizeFcn{lp})
          LocalSet(Data.Fig(lp),'PaperUnits',PaperUnits);
          LocalCenterOnPage(Data)
        end
        
        LocalUpdate(Data);      
        
      case 'Help',
        LocalHelp    

      case 'MovePositionDown',
        BoxPos=LocalGetBoxPos(Data);
        NewBoxPos=dragrect(BoxPos);
        
        if any(NewBoxPos~=BoxPos),
          InFlag=LocalInAxes(Data,NewBoxPos);        
          if InFlag,
            LocalSetPaperPosition(Data,NewBoxPos);
          end          
        end        
        
      case 'Orientation',
        OrientInfo=get(Data.Orientation,{'String','Value'});
        LocalSet(Data.Fig,'PaperOrientation',OrientInfo{1}{OrientInfo{2}});
        LocalCenterOnPage(Data)
        LocalUpdate(Data);      
        LocalDealWithPageFig(Data);      

      case 'Position',
        EvalFlag=1;
        eval(['LocalSet(Data.Fig,''PaperPosition'','  ...
              get(Data.PaperPosition,'String') ');EvalFlag=0;'],'');
        if EvalFlag,
          warndlg(['A valid Paper Position must be entered.  ', ...
                'Old value still set.'],'Paper Position Warning');            
          return        
        end     
        for lp=1:length(Data.Fig),
          LocalSetFigPos(Data.Fig(lp), ...
              LocalGet(Data.Fig(lp),'PaperPosition'),Data.AutoMode, ...
                        Data.ResizeFcn{lp})
        end
        LocalSetPaperPositionBox(Data)
        
      case 'Print',    
        if isnumeric(Data.Fig),
          printdlg(Data.Fig(1))
        else,
          simprintdlg(Data.Fig)
        end
        
        %LocalClose(Data,Dlg)
        
      case 'PrintDlgCall',
        LocalCenterOnPage(Data)
        LocalUpdate(Data);
        
      case 'Radio',  
        Data=LocalSetRadioButtons(gcbo,Data);    
        LocalUpdate(Data);      
        
      case 'ResizePositionDown',    
        
        BoxPos=LocalGetBoxPos(Data);
        NewBoxPos=rbbox(BoxPos);

        if any(NewBoxPos~=BoxPos),
          InFlag=LocalInAxes(Data,NewBoxPos);        
          if InFlag,
            LocalSetPaperPosition(Data,NewBoxPos);  
          end          
        end  

        for lp=1:length(Data.Fig),
          LocalSetFigPos(Data.Fig(lp), ...
              LocalGet(Data.Fig(lp),'PaperPosition'),Data.AutoMode, ...
              Data.ResizeFcn{lp});
        end
        
      case 'Units',
        UnitInfo=get(Data.PaperUnits,{'String','Value'});
        LocalSet(Data.Fig,'PaperUnits',UnitInfo{1}{UnitInfo{2}});
        LocalUpdate(Data);      

      otherwise,
        error('Invalid Action passed to PAGEDLG.');
        
    end % switch
    
    if ishandle(Dlg),
      set(Dlg,'UserData',Data);  
    end    
    
  otherwise,
    error('Invalid input argument.');
    
end % switch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCenterOnPage %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCenterOnPage(Data)
PaperSize=LocalGet(Data.Fig(1),'PaperSize');
PaperPosition=LocalGet(Data.Fig(1),'PaperPosition');
PaperPosition(1)=(PaperSize(1)-PaperPosition(3))/2;
PaperPosition(2)=(PaperSize(2)-PaperPosition(4))/2;
LocalSet(Data.Fig,'PaperPosition',PaperPosition);

%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalClose %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalClose(Data,Dlg)
if isnumeric(Data.Fig),
  % Take care of problem with figure being deleted
  if ishandle(Data.Fig),
    LocalSet(Data.Fig,'ResizeFcn',Data.ResizeFcn)
  end
end

delete(Dlg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalDealWithPageFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDealWithPageFig(Data)
FigName=LocalFigName(Data.Fig);
PageFig=findall(0,'Name',['Print: ' FigName]);
if ~isempty(PageFig),
  printdlg('PageDlgCall',PageFig);
end        
          
%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalFigName %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function FigName=LocalFigName(Fig)

if length(Fig)>1,
  if iscell(Fig),
    FigName='Multiple Systems';
  else,
    FigName='Multiple Figures';
  end
  return
end

Fig=Fig(1);
FigName = LocalGet(Fig,'name');

% Check to see if it's HG
if isnumeric(Fig),
  if strcmp(get(Fig,'numbertitle'),'on') 
    if (length(FigName)>0)
      FigName = [': ' FigName];
    end
    if strcmp(get(Fig,'IntegerHandle'),'on'),
      FigName = ['Figure ' sprintf('%d ',Fig) FigName];
    else,
      FigName = ['Figure ' sprintf('%.16g ',Fig) FigName];
    end
  end
  
  if isempty(FigName)   % no name, number title off
    if strcmp(get(Fig,'IntegerHandle'),'on'),
      FigName = ['Figure ' sprintf('%d ',Fig)];
    else,
      FigName = ['Figure ' sprintf('%.16f ',Fig)];
    end
  end
else,
  FigName=['System: ' FigName];
  
end

%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGet %%%%%
%%%%%%%%%%%%%%%%%%%%
function Value=LocalGet(HandleStr,Parameter)

% Deal with SL model
if iscell(HandleStr),
  if length(HandleStr)==1,
    HandleStr=HandleStr{1};
  end
  Value=get_param(HandleStr,Parameter);
else,
  Value=get(HandleStr,Parameter);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetBoxPos %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function BoxPos=LocalGetBoxPos(Data)

PX=get(Data.PositionBox(1),'XData');
PY=get(Data.PositionBox(1),'YData');
AxisPos=get(Data.AxisHandle,'Position');     
OX=AxisPos(1);OY=AxisPos(2);      
BoxPos=[OX+PX(1) OY+PY(1) PX(3)-PX(1) PY(3)-PY(1)];
       

%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalHelp %%%%%
%%%%%%%%%%%%%%%%%%%%%
function LocalHelp
ttlStr = 'Page Position Dialog';

hlpStr1= ...                                               
        {'                                                              '  
         '   This dialog allows interactive setting of figure           '
         '   properties that determine how a figure gets layed          '
         '   out on a piece of paper.  The figure''s PaperPosition       '
         '   may either be set by moving it interactively on the        '
         '   page display at the top of the dialog or it may be         '
         '   set manually through the editable text field near the      '
         '   bottom of the dialog.  Two radiobuttons exist which        '
         '   allow the area covered by PaperPosition to be equal to     '
         '   the area covered by the figure position or to allow the    '
         '   PaperPosition to be set manually.  Two pushbuttons exist   '
         '   which will set the PaperPosition to the size of the        '
         '   page or which will hold the current aspect ratio fixed     '
         '   while filling the page as best as possible.                '
         '                                                              '
         '   Cancel reverts the figure back to its original settings    '
         '   and Done closes the dialog saving the current settings.    '
         '   The Print... button opens the print dialog that is         '
         '   specific to the platform being used.                       '};
     
helpwin(hlpStr1,ttlStr);

%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInAxes %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function InFlag=LocalInAxes(Data,NewBoxPos)

XPos=[NewBoxPos(:,1)       ; sum(NewBoxPos([1 3]))
      sum(NewBoxPos([1 3])); NewBoxPos(:,1)               
     ];
YPos=[NewBoxPos(:,2)           ; NewBoxPos(:,2)         
      sum(NewBoxPos([2 4])); sum(NewBoxPos([2 4]))
     ];
AxesPos=get(Data.AxisHandle,'Position');AxesPos=AxesPos+[7 7 -14 -14];   
XRect=[AxesPos(1)         ; sum(AxesPos([1 3]))     
       sum(AxesPos([1 3])); AxesPos(1)
      ];         
YRect=[AxesPos(2)         ; AxesPos(2)
       sum(AxesPos([2 4])); sum(AxesPos([2 4]))
      ];
InFlag=any(inpolygon(XPos,YPos,XRect,YRect));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalResizePaper %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalResizePaper(Data)

PaperUnits=LocalGet(Data.Fig(1),'PaperUnits');
LocalSet(Data.Fig(1),'PaperUnits','inches');
PaperSize=LocalGet(Data.Fig(1),'PaperSize');
LocalSet(Data.Fig(1),'PaperUnits',PaperUnits);

ScaleFactor=1.2*max(PaperSize);
Scale=Data.Scale;
X=PaperSize(1)/ScaleFactor*Scale;Y=PaperSize(2)/ScaleFactor*Scale;
XOffset=(Scale-X)/2;
YOffset=(Scale-Y)/2;
set(Data.PaperHandle, ...
   'XData',[XOffset X+XOffset X+XOffset XOffset   ], ...
   'YData',[YOffset YOffset   Y+YOffset Y+YOffset ]  ...
   );

%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSet %%%%%
%%%%%%%%%%%%%%%%%%%%
function LocalSet(HandleStr,Parameter,Value)

% SL
if iscell(HandleStr),
  RootSys=unique(bdroot(HandleStr));
  LockSetting=get_param(RootSys,'Lock');
  for lp=1:length(RootSys),
    set_param(RootSys{lp},'Lock','off');
  end
  
  if iscell(Value),
    for lp=1:length(HandleStr),
      set_param(HandleStr{lp},Parameter,Value{lp});
    end
  else,
    for lp=1:length(HandleStr),
      set_param(HandleStr{lp},Parameter,Value);
    end
  end
  
  for lp=1:length(RootSys),
    set_param(RootSys{lp},'Lock',LockSetting{lp});
  end
  
% HG
else,
  if iscell(Value),
    Parameter={Parameter};
  end
  set(HandleStr,Parameter,Value)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetFigPos %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetFigPos(Fig,PaperPos,AutoMode,ResizeFcn)

if isnumeric(Fig),
  FigUnits=get(Fig,'Units');      
end

PaperUnits=LocalGet(Fig,'PaperUnits');
if isnumeric(Fig),
  LocalSet(Fig,'Units',PaperUnits);
end
if AutoMode & isnumeric(Fig),      
  if isnumeric(Fig),
    FigPos=LocalGet(Fig,'Position');
    FigPos(2)=FigPos(2)+FigPos(4)-PaperPos(4);
    FigPos(3:4)=PaperPos(3:4);
    LocalSet(Fig,'ResizeFcn',ResizeFcn);
  
    LocalSet(Fig,'PaperPosition',PaperPos);
    LocalSet(Fig,'Position',FigPos);      
    drawnow  
    
    LocalSet(Fig,'ResizeFcn','pagedlg FigResize');
    
  else,
    LocalSet(Fig,'PaperPosition',PaperPos);
    
  end
  
  LocalSet(Fig,'PaperPositionMode','auto');

else,
  LocalSet(Fig,'PaperPosition',PaperPos);
end        


if isnumeric(Fig),
  LocalSet(Fig,'Units',FigUnits);      
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetPaperPosition %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetPaperPosition(Data,BoxPos)

AxisPos=get(Data.AxisHandle,'Position');     
OX=AxisPos(1);OY=AxisPos(2);      
PP=BoxPos-[OX OY 0 0];

PaperUnits=LocalGet(Data.Fig,'PaperUnits');
LocalSet(Data.Fig,'PaperUnits','inches');
PaperSize=LocalGet(Data.Fig(1),'PaperSize');
PaperSizeXData=get(Data.PaperHandle,'XData');
PaperSizeYData=get(Data.PaperHandle,'YData');
ScaleFactor=1.2*max(PaperSize);
Scale=Data.Scale;
PP(1)=PP(1)-PaperSizeXData(1);
PP(2)=PP(2)-PaperSizeYData(1);
PP=PP*ScaleFactor/Scale;

LocalSet(Data.Fig,'PaperPosition',PP);
LocalSet(Data.Fig,'PaperUnits',PaperUnits);
set(Data.PaperPosition, ...
    'String',mat2str(LocalGet(Data.Fig(1),'PaperPosition'),5));
  
LocalSetPaperPositionBox(Data)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetPaperPositionBox %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetPaperPositionBox(Data)

PaperUnits=LocalGet(Data.Fig(1),'PaperUnits');
LocalSet(Data.Fig(1),'PaperUnits','inches');
PaperSize=LocalGet(Data.Fig(1),'PaperSize');

PaperSizeXData=get(Data.PaperHandle,'XData');
PaperSizeYData=get(Data.PaperHandle,'YData');
XOffset=PaperSizeXData(1);
YOffset=PaperSizeYData(1);
ScaleFactor=1.2*max(PaperSize);
Scale=Data.Scale;

PP=LocalGet(Data.Fig(1),'PaperPosition')/ScaleFactor*Scale;
XD=XOffset+[PP(1) PP(1)+PP(3) PP(1)+PP(3) PP(1)];
YD=YOffset+[PP(2) PP(2)       PP(2)+PP(4) PP(2)+PP(4)];
WH=6;

LocalSet(Data.Fig(1),'PaperUnits',PaperUnits);
set(Data.PositionBox(1),'XData',XD,'YData',YD);

set(Data.PositionBox(2), ...
   'XData',XD(1)+[  0  WH WH 0], ...
   'YData',YD(1)+[  0  0 WH   WH]  ...
   );

set(Data.PositionBox(3), ...
   'XData',XD(2)+[-WH  0  0  -WH], ...
   'YData',YD(2)+[  0  0 WH   WH]  ...
   );

set(Data.PositionBox(4), ...
   'XData',XD(3)+[-WH    0  0  -WH], ...
   'YData',YD(3)+[-WH  -WH  0    0]  ...
   );

set(Data.PositionBox(5), ...
   'XData',XD(4)+[  0   WH WH    0], ...
   'YData',YD(4)+[-WH  -WH  0    0]  ...
   );

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetRadioButtons %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalSetRadioButtons(Handle,Data)
% PPMode manual
if Handle==Data.OtherHandles(1),
  if Data.AutoMode,
    if isnumeric(Data.Fig),
      LocalSet(Data.Fig,'ResizeFcn',Data.ResizeFcn);
    end
    Data.ResizeFcn(1:length(Data.Fig),1)={''};
  end          
  Data.AutoMode=logical(0);  
  set(Data.OtherHandles,{'Value'},{1;0});        
  LocalSet(Data.Fig,'PaperPositionMode','manual');        
        
% PPMode auto
elseif Handle==Data.OtherHandles(2),
  if ~Data.AutoMode,
    if isnumeric(Data.Fig),
      LocalSizeAllFigs(Data.Fig(1),Data.Fig);
      Data.ResizeFcn=get(Data.Fig,{'ResizeFcn'});
      LocalSet(Data.Fig,'ResizeFcn','pagedlg FigResize');
    end
  end          
  Data.AutoMode=logical(1);  
  set(Data.OtherHandles,{'Value'},{0;1});        
  LocalSet(Data.Fig,'PaperPositionMode','auto');        
        
end        
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSizeAllFigs %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSizeAllFigs(OrigFig,AllFigs);
          
% PPMode is auto and only HG coming in
CurPosition=get(OrigFig,'Position');
CurUnits=get(AllFigs,{'Units'});
set(AllFigs,'Units',get(OrigFig,'Units'));
Position=LocalGet(AllFigs,{'Position'});
Position=cat(1,Position{:});
Position(:,3)=CurPosition(3);
Position(:,4)=CurPosition(4);
Position=num2cell(Position,2);
set(AllFigs,'ResizeFcn','');
drawnow
set(AllFigs,{'Position'},Position,{'Units'},CurUnits);

%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalUpdate %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdate(Data)

LocalResizePaper(Data)
LocalSetPaperPositionBox(Data)

set(Data.PaperSize,'String',mat2str(LocalGet(Data.Fig(1),'PaperSize'),5));
set(Data.PaperPosition, ...
    'String',mat2str(LocalGet(Data.Fig(1),'PaperPosition'),5));
set(Data.PaperUnits,'Value', ...
      find(strcmp(LocalGet(Data.Fig(1),'PaperUnits'), ...
                  get(Data.PaperUnits,'String'))) ...
   );
set(Data.Orientation,'Value', ...
      find(strcmp(LocalGet(Data.Fig(1),'PaperOrientation'), ...
                  get(Data.Orientation,'String'))) ...
   );
if Data.AutoMode,
  LocalSet(Data.Fig,'PaperPositionMode','auto');  
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalValidateHandleStr %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NewHandleStr,ErrorString]=LocalValidateHandleStr(HandleStr)

%Returns a cell array for SL and a vector for HG

NewHandleStr=HandleStr;
if isnumeric(NewHandleStr),
  NewHandleStr=num2cell(NewHandleStr(:));
else,
  if iscell(NewHandleStr),
    NewHandleStr=NewHandleStr(:);
  else,
    NewHandleStr={NewHandleStr};
  end
  
end  

for clp=1:length(NewHandleStr),
  HandleStr=NewHandleStr{clp};
  
  IsHG(clp)=logical(0);
  IsSimulink(clp)=logical(1);
  eval('get_param(HandleStr,''Handle'');','IsSimulink(clp)=logical(0);');
  
  if ~isstr(HandleStr) & ~IsSimulink(clp),
    IsHG(clp)=ishandle(HandleStr);
  end  
  
  ErrorString='';
  if IsHG(clp),
    HandleStr=HandleStr;
    
  elseif IsSimulink(clp),
    if ~strcmp(get_param(HandleStr,'Type'),'block_diagram') & ...
          ~strcmp(get_param(HandleStr,'BlockType'),'SubSystem'),
      HandleStr=[];
      ErrorString='Invalid figure handle, Simulink model or system name.';
      return     
    else
      HandleStr=getfullname(HandleStr);
    end
    
  else,
    HandleStr=[];
    ErrorString='Invalid figure handle, Simulink model or system name.';
  end  
  if ~isempty(ErrorString),
    return
  end
  
  NewHandleStr{clp}=HandleStr;
  
end % for clp

if ~all(IsSimulink) & ~all(IsHG),
  ErrorString='Pages being set must be all Handle Graphics or all Simulink';
end

if all(IsHG),
  NewHandleStr=cat(1,NewHandleStr{:});
end  
NewHandleStr=unique(NewHandleStr);


%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function Dlg=LocalInitFig(Fig)

FigName = LocalFigName(Fig);
Dlgname = ['Page Position: ' FigName ];
Dlg=findall(0,'Name',Dlgname);
DlgFlag=~isempty(Dlg);

if DlgFlag
  figure(Dlg)  
  return
end

pos = get(0,'defaultfigureposition');

BtnWidth=60;BtnHeight=20;
Offset=3;
FigWidth=320;
  
BtnPos=zeros(4,4);    
BtnPos(1,:)=[Offset Offset BtnWidth BtnHeight];
BtnPos(2,:)=BtnPos(1,:)+[1 0 0 0];
BtnPos(3,:)=BtnPos(2,:)+[2 0 0 0];
BtnPos(4,:)=BtnPos(1,:);
BtnPos(4,1)=FigWidth-Offset-BtnWidth;
BtnPos=align(BtnPos,'Distribute','Bottom');
    
FramePos=zeros(4,4);    
FramePos(1,:)=[0                           0    ...
               sum(BtnPos(4,[1 3]))+Offset sum(BtnPos(4,[2 4]))+Offset];
FramePos(2,:)=FramePos(1,:);FramePos(2,2)=sum(FramePos(1,[2 4]));
FramePos(3,:)=FramePos(2,:);
FramePos(4,:)=FramePos(2,:);

Width=(FramePos(1,3)-3*Offset)/2;
Width=150;
  
CtlPos=zeros(14,4);
CtlPos(1,:)=[FramePos(2,1)+Offset FramePos(2,2)+Offset Width BtnHeight]; 
CtlPos(2,:)=CtlPos(1,:);CtlPos(2,1)=sum(FramePos(2,[1 3]))-Width-Offset;
CtlPos(3:4,:)=CtlPos(1:2,:);
CtlPos(3:4,2)=sum(CtlPos(1,[2 4]))+Offset;
CtlPos(5:6,:)=CtlPos(3:4,:);
CtlPos(5:6,2)=sum(CtlPos(4,[2 4]))+Offset;
CtlPos(6,1)=sum(CtlPos(5,[1 3]))+Offset;
CtlPos(6,3)=sum(FramePos(2,[1 3]))-CtlPos(6,1)-Offset;

FramePos(2,4)=sum(CtlPos(6,[2 4]))+Offset-FramePos(2,2);
FramePos(3,2)=sum(FramePos(2,[2 4]));

CtlPos(7:8,1)=FramePos(3,1)+Offset; 
CtlPos(7:8,4)=BtnHeight;
CtlPos(7,2)=FramePos(3,2)+Offset;
CtlPos(8,2)=sum(CtlPos(7,[2 4]));  


FramePos(3,4)=sum(CtlPos(8,[2 4]))+Offset-FramePos(3,2);
FramePos(4,2)=sum(FramePos(3,[2 4]));


Scale=120;
AxesPos=[(sum(FramePos(2,[1 3]))-Scale) sum(FramePos(2,[2 4]))+(~isunix) ...
           Scale Scale];
    
FramePos(3:4,3)=AxesPos(1)-FramePos(3,1)-isunix;
CtlPos(7:8,3)=FramePos(3,3)-2*Offset;


FigHeight=sum(AxesPos([2 4]));

CtlPos(13:14,:)=CtlPos(1:2,:);
CtlPos(13:14,2)=FigHeight-Offset-CtlPos(13,4);
CtlPos(13:14,3)=(FramePos(3,3)-3*Offset)/2;
CtlPos(14,1)=sum(CtlPos(13,[1 3]))+Offset;

CtlPos(11:12,:)=CtlPos(13:14,:);
CtlPos(11:12,2)=CtlPos(13,2)-Offset-CtlPos(11,4);
CtlPos(9:10,:)=CtlPos(13:14,:);CtlPos(9:10,2)=CtlPos(11,2)-Offset-CtlPos(9,4);


FramePos(4,4)=sum(CtlPos(end,[2 4]))+Offset-FramePos(4,2);

Units=get(0,'Units');
set(0,'Units','points');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',Units);
FigPos=[(ScreenSize(3)-FigWidth)/2 (ScreenSize(4)-FigHeight-20)/2 ...
     FigWidth FigHeight];

    
%%% Set up the controls

White=[1 1 1];Black=[0 0 0];
  
Std.Units                = 'points'                         ;
Std.HandleVisibility     = 'callback'                       ;    
Std.Interruptible        = 'off'                            ;
Std.BusyAction           = 'queue'                          ;    
Btn=Std;
Btn.FontUnits            = 'points'                         ;
Btn.FontSize             = get(0,'FactoryUIControlFontSize');
Btn.ForeGroundColor      = Black                            ;
Btn.HorizontalAlignment  = 'center'                         ;
Btn.Style                = 'pushbutton'                     ;    
Ctl=Btn;
FigColor=get(0,'defaultuicontrolbackgroundcolor');
    
BtnString={'Help';'Print...';'Cancel';'Done'};
BtnTag={'Help';'Print';'Cancel';'Done'};
BtnCall={'pagedlg Help';'pagedlg Print';'pagedlg Cancel';'pagedlg Close'};
    
CtlTag={'CenterOnPage'    ;'DefaultPos'
        'FillPage'        ;'FixedAR'
        'PaperPosition'   ;'PaperPositionEdit'
        'SetExplicitly'
        'MatchArea'
        'PaperOrientation';'PaperOrientationPopup'        
        'PaperUnits'      ;'PaperUnitsEdit'
        'PaperSize'       ;'PaperSizeEdit'
       };        

if isnumeric(Fig(1)),
  PaperOrientation=set(Fig(1),'PaperOrientation');
  PaperUnits=set(Fig(1),'PaperUnits');
else,
  ObjParams=get_param(Fig{1},'ObjectParameters');
  PaperOrientation=ObjParams.PaperOrientation.Enum;
  PaperUnits=ObjParams.PaperUnits.Enum;
end
  

CtlString={'Center';'Fill(Fixed Aspect Ratio)'
           'Default Paper Settings';   'Fill'
           'Paper Position:'   ;mat2str(LocalGet(Fig(1),'PaperPosition'),5)
           'Set Paper Position Explicitly'
           'Match Paper Area to Figure Area'
           'Paper Orientation:';PaperOrientation
           'Paper Units:'      ;PaperUnits
           'Paper Size:'       ; mat2str(LocalGet(Fig(1),'PaperSize'),5)
           };
CtlCall={'pagedlg CenterOnPage'; 'pagedlg FixedAR'
         'pagedlg Default';'pagedlg FillPage';
         ''                ;'pagedlg Position'
         'pagedlg Radio'   
         'pagedlg Radio'   
         ''                ;'pagedlg Orientation'
         ''                ;'pagedlg Units'
         ''                ;''
         };             
CtlStyle={'pushbutton' ; 'pushbutton' ;'pushbutton';'pushbutton'
          'text'       ;'edit'
          'radiobutton'
          'radiobutton'
          'text'       ;'popupmenu'
          'text'       ;'popupmenu'
          'text'       ;'text'              
          };
CtlColor={FigColor;FigColor;FigColor;FigColor
          FigColor;White;
          FigColor
          FigColor
          FigColor;FigColor              
          FigColor;FigColor           
          FigColor;FigColor              
          };

CtlAlign={'center';'center';'center';'Center'
          'right' ;'left'
          'left'
          'left'
          'right' ;'left'
          'right' ;'left'
          'right' ;'left'
         };            
              
%%% Create Everything    
Dlg = figure(Std             , ...
            'Color'          ,FigColor         , ...
            'Colormap'       ,[]               , ...
            'Menubar'        ,menubar          , ...
            'Resize'         ,'off'            , ...
            'Visible'        ,'off'            , ...
            'Name'           ,Dlgname          , ...
            'Position'       ,FigPos           , ...
            'Units'          ,'pixels'         , ...            
            'IntegerHandle'  ,'off'            , ...            
            'CloseRequestFcn','pagedlg Close'  , ...                
            'Resize'         ,'off'            , ...                
            'Tag'            ,'Page Dialog'    , ...            
            'NumberTitle'    ,'off'              ...
            );
Std.Parent=Dlg; Btn.Parent=Dlg;Ctl.Parent=Dlg; 
    
for lp=1:size(FramePos,1),
  FrameHandles(lp)=uicontrol(Std      , ...
                            'Style'   ,'frame'       , ...
                            'Position',FramePos(lp,:)  ...
                            );
end      
for lp=1:length(BtnTag),
  BtnHandles(lp)=uicontrol(Btn      , ...
                          'Position',BtnPos(lp,:) , ...          
                          'Tag'     ,BtnTag{lp}   , ...
                          'Callback',BtnCall{lp}  , ...
                          'String'  ,BtnString{lp}  ...
                          );                          
end      
for lp=1:length(CtlString),
  CtlHandles(lp)=uicontrol(Ctl                 , ...
                          'Position'           ,CtlPos(lp,:) , ...
                          'Tag'                ,CtlTag{lp}   , ...
                          'Style'              ,CtlStyle{lp} , ...
                          'BackgroundColor'    ,CtlColor{lp} , ...
                          'Callback'           ,CtlCall{lp}  , ...
                          'HorizontalAlignment',CtlAlign{lp} , ...
                          'String'             ,CtlString{lp}  ...
                          );                          
end  

set(CtlHandles(7),'Value',1);

AxisHandle=axes(Std                 , ...
               'Position'           ,AxesPos       , ...
               'Units'              ,'pixels'      , ...               
               'Tag'                ,'Axes'        , ...
               'XLim'               ,[1 AxesPos(3)], ...   
               'YLim'               ,[1 AxesPos(4)], ...                   
               'XTickMode'          ,'manual'      , ...
               'XTick'              ,[]            , ...
               'XTickLabelMode'     ,'manual'      , ...
               'XTickLabel'         ,[]            , ...
               'YTickMode'          ,'manual'      , ...
               'YTick'              ,[]            , ...
               'YTickLabelMode'     ,'manual'      , ...
               'YTickLabel'         ,[]            , ...
               'Box'                ,'on'          , ...                   
               'Color'              ,FigColor        ...
               );

% Note: 4 changes were made to deal with dragrect not respecting the
% figure unites.  The two lines below and the lines in the figure
% and axis creation that set the units back to pixels.  These lines
% should be removed when dragrect starts doing the right thing.
NewAxesPos=get(AxisHandle,'Position');
set(AxisHandle,'XLim',[1 NewAxesPos(3)],'YLim',[1 NewAxesPos(4)]);
               
PaperHandle=patch('Parent'          ,AxisHandle   , ...
                  'HandleVisibility','callback'   , ...
                  'Interruptible'   ,'off'        , ...
                  'BusyAction'      ,'queue'      , ...
                  'XData'           ,[.1 .9 .9 .1], ...
                  'YData'           ,[.1 .1 .9 .9], ...
                  'FaceColor'       ,White        , ...
                  'EdgeColor'       ,Black        , ...
                  'LineStyle'       ,'-'            ...                     
                 );
              
% When pixel units are available for axes children this all simplifies    
PositionHandle=copyobj(PaperHandle([1 1 1 1 1]),AxisHandle);
set(PositionHandle(1), ...
   'LineStyle'       ,'--'                       , ...
   'FaceColor'       ,[.9 .9 .9]                 , ...   
   'ButtonDownFcn'   ,'pagedlg MovePositionDown'   ...
   );
     
set(PositionHandle(2:end), ...
   'FaceColor'           ,Black                        , ...
   'ButtonDownFcn'       ,'pagedlg ResizePositionDown'  ...
   );   
  
Data.Fig=Fig;
Data.Properties={'PaperType','PaperUnits', ...
                 'PaperPosition','PaperPositionMode','PaperOrientation'};

for lp=1:length(Data.Properties),
  Temp=LocalGet(Fig,Data.Properties{lp});
  if ~iscell(Temp),Temp={Temp};end
  Data.OrigData(:,lp)=Temp;
end

Data.AxisHandle=AxisHandle;                   
Data.PaperHandle=PaperHandle;
Data.PositionBox=PositionHandle;
Data.PaperPosition=CtlHandles(6);
Data.Orientation=CtlHandles(10);
Data.PaperUnits=CtlHandles(12);
Data.PaperSize=CtlHandles(14);
Data.OtherHandles=CtlHandles(7:8);
Data.ResizeFcn(1:length(Data.Fig),1)={''};
Data.AutoMode=logical(0);
Data.Scale=Scale;

set(Data.Orientation,'Value', ...
      find(strcmp(LocalGet(Data.Fig(1),'PaperOrientation'), ...
                  PaperOrientation)) ...
   );

set(Data.PaperUnits,'Value', ...
      find(strcmp(LocalGet(Data.Fig(1),'PaperUnits'), ...
                  PaperUnits)) ...
   );


% Turn off the print button if more than one figure is sent to pagedlg
% This is becaus printdlg is not vectorized.
if isnumeric(Data.Fig) & length(Data.Fig)>1,
  set(BtnHandles(2),'Enable','off');
end

if strcmp(LocalGet(Data.Fig(1),'PaperPositionMode'),'auto'),  
  Data=LocalSetRadioButtons(Data.OtherHandles(2),Data);
else,
  Data=LocalSetRadioButtons(Data.OtherHandles(1),Data);
end  

LocalUpdate(Data)

set(Dlg,'Visible','on','UserData',Data);
