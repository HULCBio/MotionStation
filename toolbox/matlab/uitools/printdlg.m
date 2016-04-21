function varargout = printdlg(varargin)
%PRINTDLG  Print dialog box.
%  PRINTDLG(FIG) creates a dialog box from which the figure
%  window, FIG, can be printed.  Note that uimenus do not print.  
%  PRINTDLG by itself prints the gcf.
%
%  PRINTDLG('-crossplatform',FIG) will force the standard cross-platform
%  MATLAB printing dialog to appear rather than the built-in printing 
%  dialog for PC. This option gets inserted just before any of the 
%  other options.
%  
%  PRINTDLG('-setup',FIG) forces the printing dialog to appear in a 
%  setup mode.  Here one can set the default printing options
%  without actually printing.

%  Loren Dean
%  Copyright 1984-2003 The MathWorks, Inc.
%  $Revision: 1.57.4.2 $  $Date: 2004/04/10 23:34:05 $

%  PRINTDLG(FIG,POS1,POS2) maps the figure from POS1 to POS2
%  for printing, and then maps it back when done.  POS1 and POS2 
%  are rectangle position vectors in normalized coordinates.  
%  This allows for excluding the empty space taken up by 
%  uicontrols. For example: 
%    printdlg(1,[.13 .11 .62 .815],get(gcf,'defaultaxesposition'))
%  
%  PRINTDLG(FIG,POS1,POS2,HIDEME) turns all the objects with handles
%  in HIDEME invisible for printing, and turns them visible again
%  when done (if they are visible originally).  Children of objects
%  that are hidden will also be hidden.
%
%  See Also REMAPFIG.


ForceBuiltIn=~isunix;
InputArgs=varargin;
NumInputArgs=nargin;
if NumInputArgs == 0
    Fig = gcbf;
	if isempty(Fig),
	  Fig = gcf;
	end
else,
    if isstr(varargin{1}),
       if strcmp(varargin{1},'-crossplatform'),
	 ForceBuiltIn=logical(0);
          InputArgs(1)=[];
          NumInputArgs=NumInputArgs-1;
       elseif strcmp(varargin{1},'-setup'),
          InputArgs(1)=[];
          NumInputArgs=NumInputArgs-1;
          setupmode=1;
       else
	 ForceBuiltIn = logical(0);
       end % if strcmp
    end % if isstr
    if ~isempty(InputArgs),    
      Fig=InputArgs{1};
      InputArgs(1)=[];    
    else,
	  Fig = gcbf;
	  if isempty(Fig),
		Fig = gcf;
	  end
    end      
end

% Bring up the print dialog for PC and MAC
if ForceBuiltIn, % =============
  Data=LocalGetPlatformIndData(Fig,InputArgs{:});  
  Data=LocalHideMe(Fig,Data);  

  if exist('setupmode')
    pargs = '-dsetup';
  else
    pargs = '-v';
  end
  
  if strcmp(get(Fig,'IntegerHandle'),'on'),
    pstr = ['print ' pargs ' -f' sprintf('%d',Fig)];
  else,
    pstr = ['print ' pargs ' -f' sprintf('%.16f',Fig)];
  end
  eval(pstr)
  
  LocalRevealMe(Fig,Data);  
  if nargout==1,
    varargout{1}=[];
  end
  return % ============= 
end

if ~isstr(Fig)     % initialization - open figure 
   Data=LocalGetPlatformIndData(Fig,InputArgs{:});
   if exist('setupmode')
      Data.SetupMode=1;
   else
      Data.SetupMode=0;
   end;
   Dlg=LocalInitFig(Data);
   if nargout, varargout{1}=Dlg; end  
   
else, % this must be a uicontrol callback
   if NumInputArgs==1,  
      Dlg=gcbf;
   else,
      Dlg=InputArgs{1};
   end    
   
   Data=get(Dlg,'UserData');
   if ~ishandle(Data.Fig),
      Data.Fig=[];
      LocalClose(Dlg,Data)
      return
   end
   
   switch Fig,
   case 'PageSetup',
      FigName=dlgfigname(Data.Fig);
      PageFig=findall(0,'Name',['Page Position: ' FigName]);
      if isempty(PageFig),
         Data.PageSetupFlag=logical(1);
         set(Dlg,'UserData',Data);
      end
      PageDialog=pagesetupdlg(Data.Fig);    
      
    case 'PageDlgCall',
      if strcmp(get(Data.Fig,'PaperOrientation'),'portrait'),
        Value={1;0};
      else,
        Value={0;1};
      end % if strcmp
      set(Data.Orientation,{'Value'},Value);
      
   case 'Orientation',
      if isequal(gcbo,Data.Orientation(1)),
        set(Data.Orientation,{'Value'},{1;0});
        set(Data.Fig,'PaperOrientation','portrait');        
      else,
        set(Data.Orientation,{'Value'},{0;1});
        set(Data.Fig,'PaperOrientation','landscape'); 
      end        
      FigName=dlgfigname(Data.Fig);
      PageFig=findall(0,'Name',['Page Position: ' FigName]);
      if ~isempty(PageFig),
        pagesetupdlg('PrintDlgCall',PageFig);
      end        
      local_call_figure_resize(Data.Fig);

    case 'ToFile',
      FileInfo=get(Data.ToFile,{'String','Value'});
      if isequal(gcbo,Data.ToFile(1)),
         if ~Data.SetupMode
            set(Data.PrintHandle,'String','Print');
         end;
         set(Data.ToFile,{'Value'},{1;0});
         if (isunix),
            set(Data.Printer,'Enable','on');
         end
     else,
        if ~Data.SetupMode
           set(Data.PrintHandle,'String','Save...');
        end;
        set(Data.ToFile,{'Value'},{0;1});
        if (isunix),
           set(Data.Printer,'Enable','off');
        end
      end        
    
    case 'Print',
      LocalPrint(Dlg,Data)
      LocalClose(Dlg,Data)
      
    case 'Cancel',      
      set(Data.Fig,{'PaperType' ,'PaperOrientation', ...
                    'PaperUnits','PaperPosition', ...
                    'PaperPositionMode'},Data.OrigData);
      LocalClose(Dlg,Data)
          
    case 'Help',
      LocalHelp    

    case 'PaperType',
      TypeInfo=get(Data.PaperType,{'String','Value'});
      set(Data.Fig,'PaperType',TypeInfo{1}{TypeInfo{2}});
      FigName=dlgfigname(Data.Fig);
      PageFig=findall(0,'Name',['Page Position: ' FigName]);
      if ~isempty(PageFig),
        pagesetupdlg('PrintDlgCall',PageFig);
      end        
      local_call_figure_resize(Data.Fig);
      
  end % switch
  
end % if

%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalClose %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalClose(Dlg,Data)
  
% If the Page Setup Dialog was opened from the Print Dialog
% then close the page setup dialog too.
if Data.PageSetupFlag,
  FigName=dlgfigname(Data.Fig);
  PageFig=findall(0,'Name',['Page Position: ' FigName]);
  if ~isempty(PageFig),
    pagesetupdlg('Close',PageFig)
  end
end
delete(Dlg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalFindHandles %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function Match=LocalFindHandles(NewHandleVect,OldHandleVect,FirstSecond)

if isempty(OldHandleVect)|isempty(NewHandleVect),
  Match=[];  
else,  
  OldHandleVect=reshape(OldHandleVect,prod(size(OldHandleVect)),1);
  NewHandleVect=reshape(NewHandleVect,1,prod(size(NewHandleVect)));

  OldHandleMat=OldHandleVect(:,ones(size(NewHandleVect,2),1));
  NewHandleMat=NewHandleVect(ones(size(OldHandleVect,1),1),:);
  MatchMat= OldHandleMat==NewHandleMat;
  [Row,Column]=find(MatchMat);
  Match=(1:length(NewHandleVect));
  if FirstSecond==1,  
    Match=Column;    
  else,
    Match=Row;    
  end    

end % if isempty  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetPlatformIndData %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalGetPlatformIndData(Fig,varargin)

Data.Fig=Fig;
Data.remapfig = false;

if nargin < 2
    Data.Pos1 = [0 0 1 1];
else,
    Data.remapfig = true;
    Data.Pos1=varargin{1};  
end

if nargin < 3
    Data.Pos2 = [0 0 1 1];
else,
    Data.Pos2=varargin{2};  
end

if nargin < 4
    Data.HideMe = [];
else
    Data.HideMe=varargin{3};  
end    
Data.HideMeVis=[];


%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalHelp %%%%%
%%%%%%%%%%%%%%%%%%%%%
function LocalHelp
ttlStr = 'Print Dialog';


hlpStr1= ...                                               
        ['                                                     '  
         '   To send the designated figure window to           '  
         '   the default printer, select "Printer" from the    '  
         '   "Send To:" radiobuttons                           '  
         '                                                     '  
         '   To send the figure to a file, select "File"       '  
         '   from the "Send To:" radiobuttons and then press   '
         '   the "Save..." pushbutton.  A dialog box           '
         '   will appear in which you can enter a              '  
         '   filename for the file.                            '
         '                                                     '  
         '   If you change your mind about printing at any     '  
         '   time, press the "Cancel" button to cancel the     '  
         '   operation.                                        '];


hlpStr2= ...                                             
        ['                                               '  
         '    DEVICES                                    '  
         '    -------                                    '  
         '                                               '  
         '    Specify a device and other options in the  '  
         '    Device Option field.                       '  
         '                                               '  
         '    Type "help print" in the command window for'  
         '    a complete list of supported devices.      '  
         '                                               '  
         '                                               '  
         '                                               '];
hlpStr3= ...                                           
        ['                                             '  
         '    PAPER ORIENTATION                        '  
         '    ----------------                         '  
         '                                             '  
         '    LANDSCAPE generates output in full-page  '  
         '    landscape orientation on the paper.      '  
         '                                             '  
         '    PORTRAIT prints the figure window        '  
         '    occupying a rectangle with aspect ratio  '  
         '    4/3 in the middle of the page.           '  
         '                                             '  
         '    These radiobuttons set the               '
         '    PaperOrientation and PaperPosition       '
         '    properties of the printed figure window. '  
         '                                             '];

helpwin({'Print Dialog'      hlpStr1 ; ...
         'Devices'           hlpStr2 ; ...
         'Paper Orientation' hlpStr3},'Print Dialog',ttlStr);


%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalHideMe %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalHideMe(Fig,Data)

hidemeax = findobj(Data.HideMe,'Type','axes');   % make all axes children
             % invisible too
for i = 1:length(hidemeax)
    temp = get(hidemeax(i),'children');
    Data.HideMe = [Data.HideMe(:); temp(:)];
end

Data.HideMeVis = [];   % store which of the hidden objects are visible
for i = 1:length(Data.HideMe)
    if strcmp(get(Data.HideMe(i),'visible'),'on')
        Data.HideMeVis = [Data.HideMeVis i];
    end
end

if (Data.remapfig)
  set(Data.HideMe,'visible','off')   % vectorized set
  remapfig(Data.Pos1,Data.Pos2,Fig,findobj(Fig,'type','axes'))
  drawnow discard    % don't redraw on screen
end

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalRevealMe %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalRevealMe(Fig,Data)
if (Data.remapfig)
  remapfig(Data.Pos2,Data.Pos1,Fig,findobj(Fig,'type','axes'))
  set(Data.HideMe(Data.HideMeVis),'visible','on')   % vectorized set
end

%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalPrint %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalPrint(Dlg,Data)

    if get(Data.ToFile(2),'Value')==1 & ~Data.SetupMode
        [fname, pname] = uiputfile('*.*','Save As');
        if isequal(fname,0),
          return
        end
        printer='';
        
    else
        fname = '';
        pname = '';
        if (isunix),
          printer=['-P' get(Data.Printer,'String')];
        else
          printer='';
        end
    end

    Fig=Data.Fig;
    %figure(Fig)  %is this legacy code? We don't want to draw invis figs!

    device = get(Data.Device,'String');
    device=strrep(device,' ',''',''');

    % Need to use parentheses for print command
    % Re: The Mac will otherwise error for files of paths with spaces
    if ~isempty(fname) & ~isempty(pname)
      if strcmp(get(Fig,'IntegerHandle'),'on'),
        pstr = ['print(''-f' sprintf('%d',Fig) ''','''  ...
                 printer ''',''' ...
                 device ''',''' ...
                 fullfile(pname,fname) ''')'];
      else,
        pstr = ['print(''-f' sprintf('%.16f',Fig) ''',''' ...
                 printer ''',''' ...
                 device ''',''' ...
                 fullfile(pname,fname) ''')'];
      end
    elseif ~isempty(fname) 
      if strcmp(get(Fig,'IntegerHandle'),'on'),
        pstr = ['print(''-f' sprintf('%d',Fig) ''',''' ...
                 printer ''',''' ...
                 device ''',''' ...
                 fname ''')'];
      else,
        pstr = ['print(''-f' sprintf('%.16f',Fig) ''',''' ...
                 printer ''',''' ...
                 device ''',''' ...
                 fname ''')'];
      end
    else
      if strcmp(get(Fig,'IntegerHandle'),'on'),
        pstr = ['print(''-f' sprintf('%d',Fig) ''',''' ...
                 printer ''',''' ...
                 device ''')'];
      else,
        pstr = ['print(''-f' sprintf('%.16f',Fig) ''',''' ...
                 printer ''',''' ...
                 device ''')'];
      end
    end

    Data=LocalHideMe(Fig,Data);    
    
    % NOW EVAL THE PRINT STATEMENT:
    error = 0;
    if ~Data.SetupMode
       eval(pstr,'error = 1;');   % print causes uicontrols to flash - sigh...
    end
    
    if error
       errordlg({'The attempt to print produced an error.','',...
             'Here was the print command:',pstr,'and here was the error:',...
             lasterr},'Print Error');
     else
        % save stuff in appdata for future calls to printdlg
        setappdata(0,'PrintSetupPrinter',get(Data.Printer,'string'));
        setappdata(0,'PrintSetupDeviceOption',get(Data.Device,'string'));
        setappdata(0,'PrintSetupSendTo',get(Data.ToFile,'value'));
     end

    LocalRevealMe(Fig,Data);    

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function Dlg=LocalInitFig(Data)

if length(Data.Fig)~=1, error('FIG input must be a scalar'), end

% return if fig is not a figure
if ~ishandle(Data.Fig) & ~strcmp(get(Data.Fig,'Type'),'figure'),
  warning('PRINTDLG requires a single figure handle');  
  return
end  

FigName=dlgfigname(Data.Fig);

if Data.SetupMode
   Dlgname = ['Print Setup: ' FigName ];
else
   Dlgname = ['Print: ' FigName ];
end

%use java version if possible
if usejava('MWT')
  if LocalJavaPrintDlg( Data, Dlgname )
    Dlg = [];
    return;
  end
end

Dlg=findobj(allchild(0),'flat','Name',Dlgname);

if ~isempty(Dlg),
  figure(Dlg);
  return
end  

pos = get(0,'defaultfigureposition');

BtnWidth=75;BtnHeight=20;
Offset=3;
    
 
FigWidth=275;

BtnPos=zeros(4,4);    
BtnPos(1,:)=[Offset Offset BtnWidth BtnHeight];
BtnPos(2,:)=BtnPos(1,:);BtnPos(2,1)=FigWidth-Offset-BtnWidth;
BtnPos(3,:)=BtnPos(1,:)+[0 BtnHeight+Offset 0 0];
BtnPos(4,:)=BtnPos(2,:)+[0 BtnHeight+Offset 0 0];
    
FramePos=zeros(2,4);    
FramePos(1,:)=[0 0 FigWidth sum(BtnPos(4,[2 4]))+Offset];
FramePos(2,:)=FramePos(1,:);FramePos(2,2)=sum(FramePos(1,[2 4]));

Width=(FramePos(1,3)-3*Offset)/3;
Upper=5;
TextPos=zeros(Upper,4);
TextPos(1,:)=[FramePos(2,1)+Offset FramePos(2,2)+Offset Width BtnHeight]; 
for lp=2:Upper,
  TextPos(lp,:)=TextPos(lp-1,:)+[0 BtnHeight+2 0 0];
end      

PopupPos=TextPos([1 1 2 3 4 4 5],:);
PopupPos([1 3 4 5 7],1)=sum(TextPos(1,[1 3]))+Offset;
PopupPos([2 6],1)=sum(PopupPos(1,[1 3]));
PopupPos([1 2 5 6 7],3)=Width;  
PopupPos(3:4,3)=2*Width;  
FramePos(2,4)=sum(PopupPos(end,[2 4]))+Offset-FramePos(2,2);


Units=get(0,'Units');
set(0,'Units','points');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',Units);
FigHeight=sum(FramePos(2,[2 4]))+Offset;
pos=[(ScreenSize(3)-FigWidth)/2 (ScreenSize(4)-FigHeight-40)/2 ...
        FigWidth FigHeight];


%%% Set up the controls

White=[1 1 1];Black=[0 0 0];

Std.Units                = 'points'     ;
Std.HandleVisibility     = 'callback'   ;    
Std.Interruptible        = 'off'        ;
Std.BusyAction           = 'queue'      ;    
Btn=Std;
Btn.FontUnits            = 'points'                         ;
Btn.FontSize             = get(0,'FactoryUIControlFontSize');
Btn.ForeGroundColor      = Black                            ;
Btn.HorizontalAlignment  = 'center'                         ;

Popup=Btn;
Popup.HorizontalAlignment='left'                            ;    
Btn.Style                = 'pushbutton'                     ;    
Txt=Btn;
Txt.HorizontalAlignment  ='right'                           ;    
Txt.Style                ='text'                            ;    

FigColor=get(0,'defaultuicontrolbackgroundcolor');
if Data.SetupMode
   GoLabel='OK';
else
   GoLabel='Print';
end;
BtnString={'Cancel';GoLabel;'Help';'Page Setup...'};      
BtnTag=BtnString;
BtnCall={'printdlg Cancel';'printdlg Print'
         'printdlg Help'  ;'printdlg PageSetup'
        };

TextString={'Send to:'          ;'Device option:';'Printer:'
            'Paper orientation:';'Paper type:'
           };
[pcmd,device] = printopt;
Loc=findstr('-P',pcmd);
if isempty(Loc)
  Printer='';
  if (isunix),
    Printer=getenv('PRINTER');
  elseif strcmp(computer, 'PCWIN')
    Printer=system_dependent('getdefaultprinter');
  end
else
  Loc2=Loc-1+find(pcmd(Loc:end)==' ');
  if isempty(Loc2) % min(x,[]) --> []
    Loc2=length(pcmd);
  end
  Printer=pcmd(Loc+2:Loc2);
  pcmd(Loc:Loc2)='';
end % if isempty

PopupString=[{'Printer';'File'}
             {device}
             {Printer}
             {'Portrait';'Landscape'}
             {set(Data.Fig,'PaperType')}
            ];                   
PopupTag={'ToPrinter';'ToFile'
         'Device';
         'Printer';
         'Portrait';'Landscape'
         'PaperOrientation'};
PopupCall={'printdlg ToFile';'printdlg ToFile'     
           ''
           ''
           'printdlg Orientation';'printdlg Orientation'
           'printdlg PaperType'};
PopupStyle={'radiobutton';'radiobutton'
            'edit'
            'edit'
            'radiobutton';'radiobutton'
            'popupmenu'};
PopupColor={FigColor;FigColor;White;White;FigColor;FigColor;White};

%%% Create Everything    
Dlg = figure(Std             , ...
    'Color'          ,FigColor         , ...
    'Colormap'       ,[]               , ...
    'Menubar'        ,menubar          , ...
    'Resize'         ,'off'            , ...
    'Visible'        ,'off'            , ...
    'WindowStyle'    ,'modal'          , ...
    'Name'           ,Dlgname          , ...
    'Position'       ,pos              , ...
    'IntegerHandle'  ,'off'            , ...            
    'CloseRequestFcn','printdlg Cancel', ...                
    'Resize'         ,'off'            , ...                
    'NumberTitle'    ,'off'              ...
    );

Std.Parent=Dlg; Btn.Parent=Dlg;
Txt.Parent=Dlg; Popup.Parent=Dlg;

for lp=1:size(FramePos,1),
  FrameHandles(lp)=uicontrol(Std, ...
      'Style'   ,'frame'        , ...
      'Position',FramePos(lp,:)   ...
      );
end      
for lp=1:length(BtnTag),
  BtnHandles(lp)=uicontrol(Btn, ...
      'Position',BtnPos(lp,:) , ...          
      'Tag'     ,BtnTag{lp}   , ...
      'Callback',BtnCall{lp}  , ...
      'String'  ,BtnString{lp}  ...
      );                          
end      
for lp=1:length(TextString),
  TextHandles(lp)=uicontrol(Txt , ...
      'Position',TextPos(lp,:)  , ...          
      'Enable'  ,'inactive'     , ...               
      'String'  ,TextString{lp}   ...
      );
end      
  
for lp=1:length(PopupString),
  PopupHandles(lp)=uicontrol(Popup        , ...
      'Position'          ,PopupPos(lp,:) , ...
      'Tag'               ,PopupTag{lp}   , ...
      'Style'             ,PopupStyle{lp} , ...
      'BackgroundColor'   ,PopupColor{lp} , ...
      'Callback'          ,PopupCall{lp}  , ...
      'String'            ,PopupString{lp}  ...
      );                          
end      


Data.PrintHandle=BtnHandles(2);                   
Data.ToFile=PopupHandles(1:2);
Data.Device=PopupHandles(3);
Data.Printer=PopupHandles(4);
Data.Orientation=PopupHandles(5:6);
Data.PaperType=PopupHandles(7);
Data.PageSetupFlag=logical(0);

if ~(isunix),
  set(Data.Printer,'Style','text','BackgroundColor',FigColor);
end

Val=find(strcmp(get(Data.Fig,'PaperType'),set(Data.Fig,'PaperType')));
set(Data.PaperType,'Value',Val);
set(Data.ToFile(1),'Value',1);
if strcmp(get(Data.Fig,'PaperOrientation'),'portrait'),
   set(Data.Orientation,{'Value'},{1;0});
else
   set(Data.Orientation,{'Value'},{0;1});
end

% Read Default Printer, Device, and SendTo from appdata of root
if isappdata(0,'PrintSetupPrinter')
   set(Data.Printer,'string',getappdata(0,'PrintSetupPrinter'));
end
if isappdata(0,'PrintSetupDeviceOption')
   set(Data.Device,'string',getappdata(0,'PrintSetupDeviceOption'));
end
if isappdata(0,'PrintSetupSendTo')
   EachChoice=getappdata(0,'PrintSetupSendTo');
   set(Data.ToFile,{'value'},EachChoice);
   if EachChoice{2} ... % Send to File is selected
      & ~Data.SetupMode
      set(Data.PrintHandle,'String','Save...');
   end
end

% this is saved in case of "Cancel"
Data.OrigData=get(Data.Fig,{'PaperType' ,'PaperOrientation', ...
                       'PaperUnits','PaperPosition','PaperPositionMode'});

set(Dlg,'Visible','on','UserData',Data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function local_call_figure_resize(fig),
%
% Stateflow printables draw themselves based on 
% papersize.  This function is called to allow the resize
% method of the stateflow printable figure to do it's gig
% whenver the papersize is changed.

% Short circuit non-stateflow related callbacks.
if (~ishandle(fig)) return; end;
if (~strcmp(get(fig, 'Tag'), 'STATEFLOW_PRINTABLE')), return; end;

sfprint(fig, 'resize');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function status = LocalJavaPrintDlg( Data, name )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Try using the Java print dialog. If fails return 0.
% The dialog will have been dismissed by the time this routine returns.

[optKeys, optVals, driverList] = LocalGetPrintOptions( Data.Fig );
try
  jDlg = com.mathworks.page.export.printdlg.Printdlg(Data.Fig, ...
						  name,optKeys,optVals);
catch
  status = 0;
  return;
end
jDlg.setNonBlockingVisible(1);
LocalWaitForJava(jDlg);
if ~jDlg.isCanceled
  % get options from dialog
  optVals = jDlg.getPrintOptions;

  if Data.SetupMode
    LocalDoPrintSetup( Data.Fig, optKeys, optVals, driverList );
  else
    Data = LocalHideMe( Data.Fig, Data );
    
    oldPPM = get(Data.Fig, 'PaperPositionMode');
    oldPP = get(Data.Fig, 'PaperPosition');
    oldPT = getprinttemplate(Data.Fig);
    pOpts = LocalGetCmdLineArgs(Data.Fig, optKeys, optVals, driverList );

    hadError = 0;
    try
      print(Data.Fig, pOpts{:});
    catch
      hadError = 1;
    end

    set(Data.Fig, 'PaperPositionMode', oldPPM);
    set(Data.Fig, 'PaperPosition', oldPP);
    set(Data.Fig, 'PrintTemplate', oldPT);

    LocalRevealMe( Data.Fig, Data )

    if hadError
      error(lasterr);
    end
  end
end

status = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalWaitForJava(jDlg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% performs the analogue of "waitfor" but on a
% Java dialog instead of a HG figure.

shadow=figure('visible','off','tag','JavaDialogHGShadow');
set(jDlg,'WindowClosedCallback',...
		 'delete(findobj(''tag'',''JavaDialogHGShadow''))');
try
  waitfor(shadow);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [keys,options,driverList] = LocalGetPrintOptions( Fig )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% returns cell array of options from the figure's printing
% properties and any PrintTemplate it has. Also computes
% lists and values needed by the print dialog

pt = getprinttemplate(Fig);
if isempty(pt)
  pt = printtemplate;
end

% fill in PrintDriver field if not already filled
if isempty( pt.PrintDriver )
	[cmd, defDevice] = printopt;
    pt.PrintDriver = defDevice(3:end); %no -d
end
keys = fieldnames( pt );
options = struct2cell( pt );

% compute driver list and printer list
[a1, driverList, extList, a2, a3, dest, driverNameList] = printtables;
filter = strcmp(dest, 'P') & ~strcmp(driverList,'ps2c');
driverList = driverList(filter);
driverNameList = driverNameList(filter);
extList = extList(filter);
PrintDriverIndex = find(strcmp(driverList, pt.PrintDriver));
[defPrinter, printerList] = findprinters;
if isappdata(0,'PrintSetupPrinter')
  lastPrinter = getappdata(0,'PrintSetupPrinter');
  if ~isempty( lastPrinter )
    defPrinter = lastPrinter;
  end
end

% compute the position for the print dialog
Units = get(Fig,'units'); %save units
set(Fig, 'units','pixels');
dlgPos = get(Fig,'position');
screensize = get(0,'screensize');
dlgPos(1) = dlgPos(1) + 10;  % offset a little
dlgPos(2) = (screensize(4) - dlgPos(2))- dlgPos(4);
set(Fig,'units',Units);	%restore units

% construct list of keys and values
keys = {keys{:}, 'PaperPositionMode', 'PaperUnits', 'PaperPosition', ...
	   'PrintDriverIndex','DlgPos', 'defPrinter', 'extList', 'printerList',...
	   'driverNameList'};
options = {options{:}, ...
		   get(Fig, 'PaperPositionMode'), ...
		   get(Fig, 'PaperUnits'), ...
		   get(Fig, 'PaperPosition'), ...
		   PrintDriverIndex, ...
		   dlgPos, defPrinter, extList, printerList, ...
		   driverNameList };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDoPrintSetup( Fig, keys, options, driverList )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% saves the given printing options in the given figure's 
% properties and PrintTemplate.

% get the existing printtemplate, if it exists
pt = getprinttemplate(Fig);
if isempty(pt)
  pt = printtemplate;
end
nfields = size(keys,2)-3;
t = cell(2,nfields);
t(1,:) = keys(1:nfields);
t(2,:) = options(1:nfields);
t = reshape(t,1,2*nfields);
st = struct(t{:});

% fill the printtemplate with new options
pt.Loose = st.Loose;
pt.CMYK = st.CMYK;
pt.Adobecset = st.Adobecset;
pt.PrintUI = st.PrintUI;
pt.AxesFreezeTicks = st.AxesFreezeTicks;
pt.AxesFreezeLimits = st.AxesFreezeLimits;
pt.Renderer = st.Renderer;
pt.ResolutionMode = st.ResolutionMode;
pt.DPI = st.DPI;
pt.PrintDriver = driverList{st.PrintDriverIndex};
pt.Destination = st.Destination;
pt.FileName = st.FileName;

% set the figure properties
set(Fig, 'PrintTemplate', pt);
set(Fig, 'PaperPositionMode', st.PaperPositionMode);
setappdata(0,'PrintSetupPrinter', st.defPrinter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function pOpts = LocalGetCmdLineArgs( Fig, keys, options, driverList )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Makes a cell array of options for passing to the
% print command. Also sets figure properties for those
% options that can't be passed on the command line.

nfields = size(keys,2)-3;
t = cell(2,nfields);
t(1,:) = keys(1:nfields);
t(2,:) = options(1:nfields);
t = reshape(t,1,2*nfields);
st = struct(t{:});

% check each possible option and build cell array
pOpts = {};
if st.Loose
  pOpts = {pOpts{:},'-loose'};
end
if st.CMYK
  pOpts = {pOpts{:},'-cmyk'};
end
if st.Adobecset
  pOpts = {pOpts{:},'-adobecset'};
end
if ~st.PrintUI
  pOpts = {pOpts{:},'-noui'};
end
if ~strcmp(st.Renderer,'auto')
  pOpts = {pOpts{:} ,['-' st.Renderer]};
end
if ~strcmp(st.ResolutionMode,'auto')
  if ~strcmp(st.ResolutionMode,'screen')
	pOpts = {pOpts{:},['-r' sprintf('%d',st.DPI)]};
  else
	pOpts = {pOpts{:},'-r0'};
  end
end
if strcmp(st.Destination,'file')
  pOpts = {pOpts{:}, st.FileName};
elseif isunix
  pOpts = {pOpts{:},['-P' st.defPrinter]};
end
pOpts = {pOpts{:},['-d' driverList{st.PrintDriverIndex}]};

% process options that aren't passed on the command line
set(Fig, 'PaperPositionMode', st.PaperPositionMode);
pt = getprinttemplate(Fig);
if isempty(pt)
  pt = printtemplate;
end
pt.AxesFreezeTicks = st.AxesFreezeTicks;
pt.AxesFreezeLimits = st.AxesFreezeLimits;
set(Fig, 'PrintTemplate', pt);
setappdata(0,'PrintSetupPrinter', st.defPrinter);
