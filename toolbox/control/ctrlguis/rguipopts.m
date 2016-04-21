function varargout = rguipopts(varargin)
%RGUIPOPTS Open the Linestyle Preferences for the LTI Viewer
%   RGUIPOPTS(action) contains the functions for opening the Linestyle
%   Preferences window for the LTI Viewer, as well as the 
%   functions called by the controls located on the preference window
%
%   See also LTIVIEW

%   Authors: Karen Gondoly, 8-6-96
%   Revised: Adam W. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.22 $  $Date: 2002/04/10 04:42:40 $

ni=nargin;

switch ni
case 0, % called from a Plot Preferences menu
   
   %%%-Look for an already open linestyle preferences window
   H=get(gcbo,'UserData');
   LTIviewerFig=gcbf;
   
   if isempty(H) | ~H, 
      action='initialize';
   else
      %---Use only one response preference window for all GUIs
      action = 'visible';
   end % if/else ~H
   
case 1
   H = gcbf;
   action=varargin{1};
   
case 2,
   LTIviewerFig=varargin{2};
   action=varargin{1};
   
end % if nargin

switch action
   
case 'initialize'
   fignum = LocalOpenFig(LTIviewerFig);
   
case 'visible',
   ViewerObj = get(LTIviewerFig(1),'UserData');
   FigureMenu = get(ViewerObj,'FigureMenu');
   PlotGUI = get(FigureMenu.EditMenu.LineStyles,'UserData');
   set(findobj(PlotGUI,'Tag','ApplyButton'),'Enable','off');
   %---Position figure within LTI Viewer bounds
   centerfig(PlotGUI,LTIviewerFig);
   set(PlotGUI,'Visible','on');
   figure(PlotGUI);
   fignum = PlotGUI;
   
case 'recordold',
   H=gcbf;
   ud = get(H,'UserData');
   
   %---Place current control values in the userdata
   ud.Revert.ColorSystem=get(ud.Handles.ColorSystem,'Value');
   ud.Revert.ColorInput=get(ud.Handles.ColorInput,'Value');
   ud.Revert.ColorOutput=get(ud.Handles.ColorOutput,'Value');
   ud.Revert.ColorChannel=get(ud.Handles.ColorChannel,'Value');
   ud.Revert.MarkSystem=get(ud.Handles.MarkSystem,'Value');
   ud.Revert.MarkInput=get(ud.Handles.MarkInput,'Value');
   ud.Revert.MarkOutput=get(ud.Handles.MarkOutput,'Value');
   ud.Revert.MarkChannel=get(ud.Handles.MarkChannel,'Value');
   ud.Revert.LineSystem=get(ud.Handles.LineSystem,'Value');
   ud.Revert.LineInput=get(ud.Handles.LineInput,'Value');
   ud.Revert.LineOutput=get(ud.Handles.LineOutput,'Value');
   ud.Revert.LineChannel=get(ud.Handles.LineChannel,'Value');
   ud.Revert.NoSystem=get(ud.Handles.NoSystem,'Value');
   ud.Revert.NoInput=get(ud.Handles.NoInput,'Value');
   ud.Revert.NoOutput=get(ud.Handles.NoOutput,'Value');
   ud.Revert.NoChannel=get(ud.Handles.NoChannel,'Value');
   
   ud.Revert.ColorList=get(ud.Handles.ColorList,'Userdata');
   ud.Revert.LineList=get(ud.Handles.LineList,'Userdata');
   ud.Revert.MarkerList=get(ud.Handles.MarkerList,'Userdata');
   
   set(gcbf,'UserData',ud);
   
case 'revert'
   %---Place original control values in their userdata 
   ud = get(gcbf,'UserData');
   set(ud.Handles.ColorSystem,'Value',ud.Revert.ColorSystem);
   set(ud.Handles.ColorInput,'Value',ud.Revert.ColorInput);
   set(ud.Handles.ColorOutput,'Value',ud.Revert.ColorOutput);
   set(ud.Handles.ColorChannel,'Value',ud.Revert.ColorChannel);
   set(ud.Handles.MarkSystem,'Value',ud.Revert.MarkSystem);
   set(ud.Handles.MarkInput,'Value',ud.Revert.MarkInput);
   set(ud.Handles.MarkOutput,'Value',ud.Revert.MarkOutput);
   set(ud.Handles.MarkChannel,'Value',ud.Revert.MarkChannel);
   set(ud.Handles.LineSystem,'Value',ud.Revert.LineSystem);
   set(ud.Handles.LineInput,'Value',ud.Revert.LineInput);
   set(ud.Handles.LineOutput,'Value',ud.Revert.LineOutput);
   set(ud.Handles.LineChannel,'Value',ud.Revert.LineChannel);
   set(ud.Handles.NoSystem,'Value',ud.Revert.NoSystem);
   set(ud.Handles.NoInput,'Value',ud.Revert.NoInput);
   set(ud.Handles.NoOutput,'Value',ud.Revert.NoOutput);
   set(ud.Handles.NoChannel,'Value',ud.Revert.NoChannel);    
   OldColData = ud.Revert.ColorList;
   OldLineData = ud.Revert.LineList;
   OldMarkData = ud.Revert.MarkerList;
   
   LineString = {'solid';'dashed';'dash-dot';'dotted';'none'};
   LineData = {'-';'--';'-.';':';'none'};
   [garb,IA,IB] = intersect(OldLineData,LineData);
   OldLineStr = LineString(IB(IA));
   
   set(ud.Handles.ColorList,'String',OldColData,'UserData',OldColData);
   set(ud.Handles.MarkerList,'String',OldMarkData,'UserData',OldMarkData);
   set(ud.Handles.LineList,'String',OldLineStr,'UserData',OldLineData);
   
   %---return plots to original configuration
   set(findobj(gcbf,'Tag','ApplyButton'),'Enable','off')
   
   %---Callback to handle mutually exclusive radio buttons
case 'radiocallback'
   val=get(gcbo,'Value');
   ud=get(gcbo,'UserData');
   
   if val,
      set(ud.row,'Value',0);
      for ct=1:length(ud.column);
         indon=find(get(ud.column(ct),'Value'));
         if indon
            ud2=get(ud.column(ct),'UserData');
            set(ud.column(ct),'Value',0);
            set(ud2.nodist,'Value',1);
         end % if indon
      end % for ct
   else
      set(gcbo,'Value',1);
      
   end % if/else val
   
   set(findobj(gcbf,'tag','ApplyButton'),'Enable','on');
   
   %---Delete function
case 'deletefig'
   ud = get(gcbf,'UserData');
   if ishandle(ud.Parent)
      ViewerObj = get(ud.Parent,'UserData');
      if ~isempty(ViewerObj)
         FigureMenu = get(ViewerObj,'FigureMenu');
         set(FigureMenu.EditMenu.LineStyles,'UserData',0);
      end
   end      
   
   %---ApplyButton callback
case 'applycallback'
   ud = get(gcbf,'UserData');
   ViewerObj = get(ud.Parent,'UserData');
   rguipopts('recordold');
   ViewerObj = plotapply(ViewerObj);
   set(ud.Parent,'UserData',ViewerObj);
   set(findobj(gcbf,'Tag','ApplyButton'),'Enable','off');
   
   %---Help callback
case 'help'
   
   
   %---Function to enable/disable arrow buttons
case 'listcallback'
   me=gcbo;
   H=gcbf;
   udfig = get(H,'UserData');
   myTag=get(me,'Tag');
   myVal=get(me,'Value');
   myStr=get(me,'String');
   LL=size(myStr,1);
   
   load prefimag;
   if myVal==1
      UpCdata = LocalProcessCData(moveupno);
      UpEnable = 'off';
      DnCdata = LocalProcessCData(movedn);
      DnEnable = 'on';
   elseif myVal==LL
      UpCdata = LocalProcessCData(moveup);
      UpEnable = 'on';
      DnCdata = LocalProcessCData(movednno);
      DnEnable = 'off';
   else
      UpCdata = LocalProcessCData(moveup);
      UpEnable = 'on';
      DnCdata = LocalProcessCData(movedn);
      DnEnable = 'on';
   end
   
   switch myTag,
      
   case {'ColorList'}
      set(udfig.Handles.UpColor,'enable',UpEnable,'Cdata',UpCdata);
      set(udfig.Handles.DownColor,'enable',DnEnable,'Cdata',DnCdata);
   case {'MarkerList'}
      set(udfig.Handles.UpMark,'enable',UpEnable,'Cdata',UpCdata);
      set(udfig.Handles.DownMark,'enable',DnEnable,'Cdata',DnCdata);
   case {'LineList'}
      set(udfig.Handles.UpLine,'enable',UpEnable,'Cdata',UpCdata);
      set(udfig.Handles.DownLine,'enable',DnEnable,'Cdata',DnCdata);
      
   end % switch myTag
   
   %---Functions to move an item up in the list
case 'up'
   me=gcbo;
   H=gcbf;
   udfig = get(H,'UserData');
   myTag=get(me,'Tag');
   switch myTag,
      
   case {'UpColor'}
      myList=udfig.Handles.ColorList;
      Downbutton=udfig.Handles.DownColor;
   case {'UpMark'}
      myList=udfig.Handles.MarkerList;
      Downbutton=udfig.Handles.DownMark;
   case {'UpLine'}
      myList=udfig.Handles.LineList;
      Downbutton=udfig.Handles.DownLine;
      
   end % switch myTag
   
   myData=get(myList,'UserData');
   OrigStr=get(myList,'String');
   val=get(myList,'Value');
   NewStr=[OrigStr(1:val-2);OrigStr(val);OrigStr(val-1);OrigStr(val+1:end)];
   NewData=[myData(1:val-2);myData(val);myData(val-1);myData(val+1:end)];
   
   set(myList,'String',NewStr,'UserData',NewData,'Value',val-1);
   
   load prefimag
   movedn=LocalProcessCData(movedn);
   
   if (val-1)==1
      moveupno=LocalProcessCData(moveupno);
      set(me,'enable','off','Cdata',moveupno);
      set(Downbutton,'enable','on','Cdata',movedn);
   elseif val==size(myList,1),
      movednno=LocalProcessCData(movednno);
      set(Downbutton,'enable','off','Cdata',movednno);
      moveup=LocalProcessCData(moveup);
      set(me,'enable','on','Cdata',moveup);
   else
      set(Downbutton,'enable','on','Cdata',movedn);
   end
   
   set(findobj(H,'Tag','ApplyButton'),'enable','on');
   
   %---Functions to move an item down in the list
case 'down'
   me=gcbo;
   H=gcbf;
   udfig = get(H,'UserData');
   myTag=get(me,'Tag');
   switch myTag,
      
   case {'DownColor'}
      myList=udfig.Handles.ColorList;
      Upbutton=udfig.Handles.UpColor;
   case {'DownMark'}
      myList=udfig.Handles.MarkerList;
      Upbutton=udfig.Handles.UpMark;
   case {'DownLine'}
      myList=udfig.Handles.LineList;
      Upbutton=udfig.Handles.UpLine;
      
   end % switch myTag
   
   myData=get(myList,'UserData');
   OrigStr=get(myList,'String');
   val=get(myList,'Value');
   
   NewStr=[OrigStr(1:val-1);OrigStr(val+1);OrigStr(val);OrigStr(val+2:end)];
   NewData=[myData(1:val-1);myData(val+1);myData(val);myData(val+2:end)];
   
   set(myList,'String',NewStr,'UserData',NewData,'Value',val+1);
   
   load prefimag
   moveup=LocalProcessCData(moveup);
   
   if (val+1)==size(OrigStr,1),
      movednno=LocalProcessCData(movednno);
      set(me,'enable','off','Cdata',movednno);
      set(Upbutton,'enable','on','Cdata',moveup);
   elseif val==1,
      set(Upbutton,'enable','on','Cdata',moveup);
   else
      set(Upbutton,'enable','on','Cdata',moveup);
   end
   
   set(findobj(H,'Tag','ApplyButton'),'enable','on');
   
end % switch action

if nargout,
   varargout{1}=fignum;
end	

%---------------------Internal Functions---------------------
%%%%%%%%%%%%%%%%%%%%
%%% LocalOpenFig %%%
%%%%%%%%%%%%%%%%%%%%
function a = LocalOpenFig(LTIviewerFig);

ViewerObj = get(LTIviewerFig,'UserData');
ud = struct('Parent',LTIviewerFig,'Handles',[],'Revert',[]);

StdUnit = 'point';
UIColor = get(0,'DefaultUIControlBackground');

%---RadioButton Data
DiffStrs = {'color','marker','linestyle','none'};
RBvals =[strcmpi(get(ViewerObj,'SystemPlotVariable'),DiffStrs);
   strcmpi(get(ViewerObj,'InputPlotVariable'),DiffStrs);
   strcmpi(get(ViewerObj,'OutputPlotVariable'),DiffStrs);
   strcmpi(get(ViewerObj,'ChannelPlotVariable'),DiffStrs)];
RBtags = [{'ColorSystem'},{'MarkSystem'},{'LineSystem'},{'NoSystem'};
   {'ColorInput'},{'MarkInput'},{'LineInput'},{'NoInput'};
   {'ColorOutput'},{'MarkOutput'},{'LineOutput'},{'NoOutput'};
   {'ColorChannel'},{'MarkChannel'},{'LineChannel'},{'NoChannel'}];

%---Look for old Color/Line/Marker Orders
ColStr = get(ViewerObj,'ColorOrder');
ColStr = ColStr(:,2);
MarkerStr = get(ViewerObj,'MarkerOrder');
LineUd = get(ViewerObj,'LinestyleOrder');
Ltemp = {'-';'--';'-.';':';'none'};
LStemp = {'solid';'dashed';'dash-dot';'dotted';'none'};
[garb,IA,IB] = intersect(LineUd,Ltemp);
LineStr = LStemp(IB(IA));
PointsToPixels = 72/get(0,'ScreenPixelsPerInch');

%%%-Open original figure-%%%
a = figure(...
   'Name',xlate('Line Styles'),...
   'MenuBar','none',...
   'NumberTitle','off',...
   'IntegerHandle','off',...
   'HandleVisibility','callback',...
   'Resize','off',...
   'DeleteFcn','rguipopts(''deletefig'');',...
   'WindowButtonMotionFcn',@LocalHover,...
   'Unit',StdUnit,...
   'Position',[50 22.5 335 325],...
   'Visible','off',...
   'Color',UIColor,...
   'Tag','PlotPrefs');

%---Position figure within LTI Viewer bounds
centerfig(a,LTIviewerFig);
set(a,'Visible','on');

%%%-Add Plotting Preference to LineStyle Menu Userdata-%%%
FigureMenu = get(ViewerObj,'FigureMenu');
set(FigureMenu.EditMenu.LineStyles,'UserData',a);

%%%-Add window Options-%%%
ButtonStrings=[{'OK'};{'Cancel'};{'Help'};{'Apply'}];
ButtonCallback=[{'rguipopts(''applycallback'');set(gcbf,''visible'',''off'');'};
   {'rguipopts(''revert'');set(gcbf,''visible'',''off'');'};{'ctrlguihelp(''viewer_linestyles'');'};
   {'rguipopts(''applycallback'');'}];
ButtonTags=[{'OKButton'};{'CloseButton'};{'HelpButton'};{'ApplyButton'}];

for ct=1:4,
   Buttons(ct) = uicontrol('Parent',a, ...
      'Unit',StdUnit, ...
      'Position',[7+((ct-1)*83) 5 72 20], ...
      'String',ButtonStrings{ct}, ...
      'Callback',ButtonCallback{ct}, ...
      'BackgroundColor',UIColor, ...
      'Tag',ButtonTags{ct});
end   
set(Buttons(4),'Enable','off');

%%%-Add Frames-%%%
FramePositions=[{[7 163 320 158]};
   {[8 30 320 128]};
   {[15 270 304 1]};
   {[95 171 1 132]};
   {[15 244 304 1]};
   {[15 218 304 1]};
   {[15 192 304 1]};
   {[149 171 1 132]};
   {[202 171 1 132]};
   {[256 171 1 132]}];

for ctFrame=1:length(FramePositions),
   Frames(ctFrame) = uicontrol('Parent',a, ...
      'Unit',StdUnit, ...
      'Position',FramePositions{ctFrame}, ...
      'BackgroundColor',UIColor, ...
      'Style','frame');
end   

%%%-Add text-%%%
OrderText=[{'Color Order'};{'Marker Order'};{'Linestyle Order'}];
OrderTag =[{'ColorOrderText'};{'MarkerOrderText'};{'LineOrderText'}];
for ctOrder=1:length(OrderText);
   b = uicontrol('Parent',a, ...
      'Unit',StdUnit, ...
      'Position',[47+((ctOrder-1)*100) 136 78 14], ...
      'String',OrderText{ctOrder}, ...
      'horiz','left', ...
      'Tag',OrderTag{ctOrder}, ...
      'BackgroundColor',UIColor, ...
      'Style','text');
end

b = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[105 305 120 14], ...
   'String','Distinguish by:', ...
   'Tag','DistinquishText', ...
   'BackgroundColor',UIColor, ...
   'Style','text');
b = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[99 279 40 14], ...
   'String','Color', ...
   'Tag','ColorText', ...
   'BackgroundColor',UIColor, ...
   'Style','text');
b = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[154 279 44 14], ...
   'String','Marker', ...
   'Tag','MarkerText', ...
   'BackgroundColor',UIColor, ...
   'Style','text');
b = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[208 279 44 14], ...
   'String','Linestyle', ...
   'Tag','LineText', ...
   'BackgroundColor',UIColor, ...
   'Style','text');
b = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[264 286 55 14], ...
   'String','No', ...
   'Tag','NoText', ...
   'BackgroundColor',UIColor, ...
   'Style','text');
b = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[264 274 55 14], ...
   'String','Distinction', ...
   'Tag','NoText', ...
   'BackgroundColor',UIColor, ...
   'Style','text');

DifferentText=[{'Systems'};{'Inputs'};{'Outputs'};{'Channels'}];
DifferentTag=[{'SystemText'};{'InputText'};{'OutputText'};{'ChannelText'}];
for ctText = 1:length(DifferentText),
   b = uicontrol('Parent',a, ...
      'Unit',StdUnit, ...
      'HorizontalAlignment','left', ...
      'Position',[19 249-((ctText-1)*26) 44 15], ...
      'String',DifferentText{ctText}, ...
      'Tag',DifferentTag{ctText}, ...
      'BackgroundColor',UIColor, ...
      'Style','text');
end

%%%-Add radio buttons-%%%
for ctRow=1:4,
   for ctCol = 1:4,
      b = uicontrol('Parent',a, ...
         'Unit',StdUnit, ...
         'Position',[114+((ctCol-1)*55) 249-((ctRow-1)*26) 18 18], ...
         'Style','radiobutton', ...
         'Callback','rguipopts(''radiocallback'');', ...
         'Value',RBvals(ctRow,ctCol), ...
         'BackgroundColor',UIColor, ...
         'Tag',RBtags{ctRow,ctCol});
      eval(['ud.Handles.',RBtags{ctRow,ctCol},'= b;']);
      eval(['ud.Revert.',RBtags{ctRow,ctCol},'=',num2str(RBvals(ctRow,ctCol)),';']);;
   end, % for ctCol
end % for ctRow

%%%-Set radio button userdata-%%%

%---ColorSystem
set(ud.Handles.ColorSystem,'UserData',struct('value',1, ...
   'row',[ud.Handles.MarkSystem,ud.Handles.LineSystem,ud.Handles.NoSystem], ...
   'column',[ud.Handles.ColorInput,ud.Handles.ColorOutput,ud.Handles.ColorChannel],...
   'nodist',ud.Handles.NoSystem));
%---ColorInput
set(ud.Handles.ColorInput,'UserData',struct('value',0, ...
   'row',[ud.Handles.MarkInput,ud.Handles.LineInput,ud.Handles.NoInput], ...
   'column',[ud.Handles.ColorSystem,ud.Handles.ColorOutput,ud.Handles.ColorChannel], ...
   'nodist',ud.Handles.NoInput));
%---ColorOutput
set(ud.Handles.ColorOutput,'UserData',struct('value',0, ...
   'row',[ud.Handles.MarkOutput,ud.Handles.LineOutput,ud.Handles.NoOutput], ...
   'column',[ud.Handles.ColorSystem,ud.Handles.ColorInput,ud.Handles.ColorChannel], ...
   'nodist',ud.Handles.NoOutput));
%---ColorChannel
set(ud.Handles.ColorChannel,'UserData',struct('value',0, ...
   'row',[ud.Handles.MarkChannel,ud.Handles.LineChannel,ud.Handles.NoChannel], ...
   'column',[ud.Handles.ColorSystem,ud.Handles.ColorInput,ud.Handles.ColorOutput], ...
   'nodist',ud.Handles.NoChannel));

%---MarkSystem
set(ud.Handles.MarkSystem,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorSystem,ud.Handles.LineSystem,ud.Handles.NoSystem], ...
   'column',[ud.Handles.MarkInput,ud.Handles.MarkOutput,ud.Handles.MarkChannel], ...
   'nodist',ud.Handles.NoSystem));
%---MarkInput
set(ud.Handles.MarkInput,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorInput,ud.Handles.LineInput,ud.Handles.NoInput], ...
   'column',[ud.Handles.MarkSystem,ud.Handles.MarkOutput,ud.Handles.MarkChannel], ...
   'nodist',ud.Handles.NoInput));
%---MarkOutput
set(ud.Handles.MarkOutput,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorOutput,ud.Handles.LineOutput,ud.Handles.NoOutput], ...
   'column',[ud.Handles.MarkSystem,ud.Handles.MarkInput,ud.Handles.MarkChannel], ...
   'nodist',ud.Handles.NoOutput));
%---MarkChannel
set(ud.Handles.MarkChannel,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorChannel,ud.Handles.LineChannel,ud.Handles.NoChannel], ...
   'column',[ud.Handles.MarkSystem,ud.Handles.MarkInput,ud.Handles.MarkOutput], ...
   'nodist',ud.Handles.NoChannel));

%---LineSystem
set(ud.Handles.LineSystem,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorSystem,ud.Handles.MarkSystem,ud.Handles.NoSystem], ...
   'column',[ud.Handles.LineInput,ud.Handles.LineOutput,ud.Handles.LineChannel], ...
   'nodist',ud.Handles.NoSystem));
%---LineInput
set(ud.Handles.LineInput,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorInput,ud.Handles.MarkInput,ud.Handles.NoInput], ...
   'column',[ud.Handles.LineSystem,ud.Handles.LineOutput,ud.Handles.LineChannel], ...
   'nodist',ud.Handles.NoInput));
%---LineOutput
set(ud.Handles.LineOutput,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorOutput,ud.Handles.MarkOutput,ud.Handles.NoOutput], ...
   'column',[ud.Handles.LineSystem,ud.Handles.LineInput,ud.Handles.LineChannel], ...
   'nodist',ud.Handles.NoOutput));
%---LineChannel
set(ud.Handles.LineChannel,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorChannel,ud.Handles.MarkChannel,ud.Handles.NoChannel], ...
   'column',[ud.Handles.LineSystem,ud.Handles.LineInput,ud.Handles.LineOutput], ...
   'nodist',ud.Handles.NoChannel));

%---NoSystem
set(ud.Handles.NoSystem,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorSystem,ud.Handles.MarkSystem,ud.Handles.LineSystem], ...
   'column',[],'nodist',[]));
%---NoInput
set(ud.Handles.NoInput,'UserData',struct('value',1, ...
   'row',[ud.Handles.ColorInput,ud.Handles.MarkInput,ud.Handles.LineInput], ...
   'column',[],'nodist',[]));
%---NoOutput
set(ud.Handles.NoOutput,'UserData',struct('value',1, ...
   'row',[ud.Handles.ColorOutput,ud.Handles.MarkOutput,ud.Handles.LineOutput], ...
   'column',[],'nodist',[]));
%---NoChannel
set(ud.Handles.NoChannel,'UserData',struct('value',1, ...
   'row',[ud.Handles.ColorChannel,ud.Handles.MarkChannel,ud.Handles.LineChannel], ...
   'column',[],'nodist',[]));

%%%-Add order listboxes
ud.Handles.ColorList = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'BackgroundColor',[1 1 1], ...
   'Position',[46 35 68 98], ...
   'String',ColStr, ...
   'UserData',ColStr, ...
   'Style','listbox', ...
   'Callback','rguipopts(''listcallback'');', ...
   'Tag','ColorList', ...
   'Value',1);
ud.Revert.ColorList=ColStr;
ud.Handles.MarkerList = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'BackgroundColor',[1 1 1], ...
   'Position',[150 35 60 98], ...
   'String',MarkerStr, ...
   'UserData',MarkerStr, ...
   'Style','listbox', ...
   'Callback','rguipopts(''listcallback'');', ...
   'Tag','MarkerList', ...
   'Value',1);
ud.Revert.MarkerList=MarkerStr;
ud.Handles.LineList = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'BackgroundColor',[1 1 1], ...
   'Position',[251 35 68 98], ...
   'String',LineStr, ...
   'UserData',LineUd, ...
   'Style','listbox', ...
   'Callback','rguipopts(''listcallback'');', ...
   'Tag','LineList', ...
   'Value',1);
ud.Revert.LineList=LineUd;

%%%-Add arrow buttons-%%%
load prefimag
moveupno=LocalProcessCData(moveupno);
movedn=LocalProcessCData(movedn);

ud.Handles.UpColor = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Cdata',moveupno, ...
   'Unit',StdUnit, ...
   'Position',[23 85 23 23], ...
   'enable','off', ...
   'UserData',[{'r'};{'b'};{'g'};{'c'};{'m'};{'y'};{'k'}], ...
   'callback','rguipopts(''up'');', ...
   'Tag','UpColor');
ud.Handles.DownColor = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Cdata',movedn, ...
   'Unit',StdUnit, ...
   'Position',[23 57 23 23], ...
   'callback','rguipopts(''down'');', ...
   'Tag','DownColor');
ud.Handles.UpMark = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Unit',StdUnit, ...
   'Position',[127 85 23 23], ...
   'Cdata',moveupno, ...
   'UserData',[{'none'};{'o'};{'x'};{'+'};{'*'};{'s'};{'d'};{'p'};{'h'}], ...
   'enable','off', ...
   'FontName','courier',...
   'callback','rguipopts(''up'');', ...
   'Tag','UpMark');
ud.Handles.DownMark = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Unit',StdUnit, ...
   'Position',[127 57 23 23], ...
   'Cdata',movedn, ...
   'callback','rguipopts(''down'');', ...
   'FontName','courier',...
   'Tag','DownMark');
ud.Handles.UpLine = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Unit',StdUnit, ...
   'Position',[228 85 23 23], ...
   'enable','off', ...
   'UserData',[{'-'};{'--'};{'-.'};{':'}], ...
   'callback','rguipopts(''up'');', ...
   'Cdata',moveupno, ...
   'Tag','UpLine');
ud.Handles.DownLine = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Unit',StdUnit, ...
   'Position',[228 57 23 23], ...
   'Cdata',movedn, ...
   'callback','rguipopts(''down'');', ...
   'Tag','DownLine');

set(a,'UserData',ud)


%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalProcessCData %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function cdata = LocalProcessCData(cdata);

bgc=255*get(0,'DefaultUIcontrolBackgroundColor');

%remove NAN's out and replace with BGC
nanIndex=find(isnan(cdata(:,:,1)));
if ~isempty(nanIndex)
   for k=1:3
      cLayer=cdata(:,:,k);
      cLayer(nanIndex)=ones(1,length(nanIndex))*bgc(k);
      cdata(:,:,k)=cLayer;
   end
end

cdata=uint8(cdata);


%%%%%%%%%%%%%%%%%%
%%% LocalHover %%%
%%%%%%%%%%%%%%%%%%
function LocalHover(eventSrc,eventData)
% Update Viewer status bar while hovering in this GUI
ud = get(eventSrc,'UserData');
ViewerObj = get(ud.Parent,'UserData');
status(ViewerObj,'Change the line styles shown in this LTI Viewer.');
