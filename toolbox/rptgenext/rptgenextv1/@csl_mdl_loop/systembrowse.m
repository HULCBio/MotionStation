function varargout=systembrowse(c,varargin)
%SYSTEMBROWSE creates modal dialog for choosing reported systems

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:12 $

if isa(varargin{1},'struct')
   varargout{1}=LocRunBrowser(c,varargin{1});
else
   feval(varargin{1},c,varargin{2:end});   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mStruct=LocRunBrowser(c,mStruct);

oldPtr=get(c.x.all.Parent,'Pointer');
set(c.x.all.Parent,'Pointer','Watch');


allProps.Units='points';
allProps.HandleVisibility='off';
allProps.BackgroundColor=get(0,'defaultuicontrolbackgroundcolor');

sfePosition=get(c.x.all.Parent,'Position');

dims.figWd=300;
dims.figHt=200;
dims.btnHt=20;
dims.btnWd=60;
dims.pad=5;

c.x.BrowseFigure = figure('DoubleBuffer','on',...
   'Units',allProps.Units,...
   'HandleVisibility',allProps.HandleVisibility,...
   'IntegerHandle','off',...
   'Color',allProps.BackgroundColor,...
   'MenuBar','none', ...
   'Name','Select "current" system(s)', ...
   'Visible','off',...
   'Position',[sfePosition(1)+100 sfePosition(2)+100,...
      dims.figWd dims.figHt],...
   'NumberTitle','off', ...
   'WindowStyle','modal',...
   'resize','off',...
   'closerequestfcn','systembrowse(get(gcbf,''UserData''),''cancelselect'')',...
   'Tag',c.x.all.Tag);

allProps.Parent=c.x.BrowseFigure;

ok=0;
if ~isempty(mStruct.MdlName)
   if exist(mStruct.MdlName)==4
      try
         feval(mStruct.MdlName,[],[],[],'load');
         ok=1;
      end
   end
   
   myName=mStruct.MdlName;
else
   myName='<No Model Name Specified>';
end

if ok
   okEnable='on';
     
   allSystems=excludesystems(c.zslmethods,...
      find_system(myName,...
      'LookUnderMasks','all',...
      'FollowLinks','on',...
      'BlockType','SubSystem'));
   
   list.UserData=[{'$top'};allSystems];
   list.String=[{sprintf('Top-Level System (%s)', myName )}
      strrep(allSystems,sprintf('\n'),' ')];
   
   
   list.Value=find(ismember(list.UserData,mStruct.MdlCurrSys));
   list.Callback='systembrowse(get(gcbf,''UserData''),''listselect'')';
else
   okEnable='off';
   list.String={sprintf('Error - can not load model %s', myName)};
   list.UserData=[];
   list.Value=[];
   list.Callback='';
end

c.x.BrowseList= uicontrol(allProps,...
   'style','listbox',...
   'Position',[dims.pad 2*dims.pad+dims.btnHt ...
      dims.figWd-2*dims.pad dims.figHt-3*dims.pad-dims.btnHt],...
   'BackgroundColor',[1 1 1],...
   'Max',2,'Min',0,...
   list,...
   'HorizontalAlignment','left');

c.x.OkButton=uicontrol(allProps,...
   'Style','pushbutton',...
   'Position',[(dims.figWd-2*dims.btnWd-2*dims.pad),...
      dims.pad dims.btnWd dims.btnHt],...
   'Callback','systembrowse(get(gcbf,''UserData''),''okselect'')',...
   'UserData',logical(0),...   
   'Enable',okEnable,...
   'String','OK'); 

c.x.CancelButton=uicontrol(allProps,...
   'Style','pushbutton',...
   'Position',...
   [(dims.figWd-dims.btnWd-dims.pad),...
      dims.pad dims.btnWd dims.btnHt],...
   'Callback','systembrowse(get(gcbf,''UserData''),''cancelselect'')',...
   'String','Cancel'); 

c.x.HelpButton=uicontrol(allProps,...
   'Style','pushbutton',...
   'Position',...
     [dims.pad dims.pad dims.btnWd dims.btnHt],...
   'Callback','systembrowse(get(gcbf,''UserData''),''helpselect'')',...
   'String','Help'); 

set(c.x.BrowseFigure,'visible','on','UserData',c)
uiwait(c.x.BrowseFigure);

if get(c.x.OkButton,'UserData')
   %clicking OK sets UserData to logical(1);
   listVal=get(c.x.BrowseList,'Value');
   listUD=get(c.x.BrowseList,'UserData');
   
   mStruct.MdlCurrSys=listUD(listVal);
else
   %we are cancelling out
   %do nothing
end

delete(c.x.BrowseFigure);
set(c.x.all.Parent,'Pointer',oldPtr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function listselect(c)

if isempty(get(c.x.BrowseList,'Value'))
   set(c.x.BrowseList,'Value',1);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cancelselect(c)

uiresume(c.x.BrowseFigure);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function okselect(c)

set(c.x.OkButton,'UserData',logical(1));
uiresume(c.x.BrowseFigure);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function helpselect(c)

currSysHelp={'"Current" System'
   ''
   '  For each model listed in the Model Loop component, '
   '  you may decide which systems are reported on.  Certain '
   '  reporting options ("current & below", "current & above", or '
   '  "current") allow the user to designate one or more systems'
   '  as "current".  The resulting reported systems will be the'
   '  union of all selected systems and (depending on the loop '
   '  type) their parents or children.'
   ''
   '  The Current System designation is model-specific so if you'
   '  change the model''s name, all Current System information will'
   '  be lost.'};


helpwin({'Current System' currSysHelp},...
   'Current System');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sOnOff=onoff(lOnOff)

if lOnOff
   sOnOff='on';
else
   sOnOff='off';
end
