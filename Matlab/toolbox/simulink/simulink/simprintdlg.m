function varargout = simprintdlg(varargin)
%SIMPRINTDLG  Print dialog box.
%   SIMPRINTDLG(sys) creates a modal dialog box from which the system,
%   sys, can be printed. SIMPRINTDLG by itself prints the current
%   system.  sys may be a handle or a string name.
%
%   SIMPRINTDLG('-crossplatform',sys) will force the standard cross-platform
%   MATLAB printing dialog to appear rather than the built-in printing
%   dialog for PC and Macintosh. This option gets inserted just before
%   any of the other options.
%
%
%   The following options are intended for command line use.  They do
%   not open the printing dialog.
%
%   [Systems,PrintLog]=SIMPRINTDLG(Sys,SysOpt,LookUnderMask,ExpandLibLinks)
%   Systems     - list of System handles to print and the order to be printed
%                 Also includes Stateflow handles.  The Stateflow handles
%                 need to be deleted once they are printed.
%   PrintLog    - Text version of the print log.
%
%   Sys is the system from which the printing dialog was spawned.
%
%   SysOpt is 'CurrentSystem'        , 'CurrentSystemAndAbove',
%             'CurrentSystemAndBelow', 'AllSystems'.
%
%   LookUnderMask is 0 to not look under masks and 1 to see all systems.
%
%   ExpandLibLinks is 0 to stop at the first library link and 1 is to descend
%                  into the link.
%
%
%   SIMPRINTDLG(Sys,SysOpt,LookUnderMask,ExpandLibLinks,PrintInfo) where
%   PrintInfo is a data structure with the following fields:
%   PrintLog, PrintFrame, FileName, PrintOptions, PaperType, PaperOrientation.
%
%   If PrintLog is 'on' then the log file will also be printed.  If
%   PrintLog is 'off' or '', then the log file will not be printed.
%
%   If PrintFrame is '' then no print frames will be included in the 
%   print job.  Otherwise, if PrintFrame is not empty and is a valid 
%   printframe file then printframes will be included in the output.
%
%   If FileName is empty then output will be printed.  If FileName is
%   not empty, then output will be saved to files with the FileName 
%   and the apprpriate extension (i.e. txt, ps, eps).  
%
%   PaperType and PaperOrientation may be any of the valid settings
%   for these properties.
%
%   PrintOptions will add the specified print options to the print command.
%
%   An example PrintData structure which does not include a print log
%   but does output to a file with printframes using encapsulated
%   postscript is:
%       PrintData.PrintLog='off';
%       PrintData.PrintFrame='sldefaultframe.fig';
%       PrintData.FileName='myprintoutput';
%       PrintData.PrintOptions='-deps';
%       PrintData.PaperOrientation='landscape';
%       PrintData.PaperType='usletter';
%
%   See also SIMPRINTLOG, FRAMEEDIT, PRINT.

%   Loren Dean
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.65.4.2 $ $Date: 2004/04/15 00:49:12 $

%   If the PrintData structure contains the fields PaperPosition and
%   PaperUnits, the system will print with the specified size and origin.
%   PrintData.PrintFrame must be empty to use this option.
%       PrintData.PaperPosition = [1 1 6 6];
%       PrintData.PaperUnits    = 'inches';


ForceBuiltIn=~isunix;
Action='Initialize';
Dlg=[];

switch nargin,
  % called as simprintdlg
  case 0,
    [Data.Sys,ErrorString]=LocalGetSysName(gcs);
    if ~isempty(ErrorString),error(ErrorString);end
    if isempty(Data.Sys),
      simulink
      [Data.Sys,ErrorString]=LocalGetSysName(gcs);
      if ~isempty(ErrorString),error(ErrorString);end
    end  % if isempty


  % called as simprintdlg sys or simprintdlg(syshandle) or
  % simprintdlg -crossplatform
  case 1,

    if ischar(varargin{1}),
      if strcmp(varargin{1},'-crossplatform'),
        ForceBuiltIn=logical(0);
        [Data.Sys,ErrorString]=LocalGetSysName(gcs);
        if ~isempty(ErrorString),error(ErrorString);end
        if isempty(Data.Sys),
          simulink
          [Data.Sys,ErrorString]=LocalGetSysName(gcs);
        end % if isempty

      else
        [Data.Sys,ErrorString]=LocalGetSysName(varargin{1});
        if ~isempty(ErrorString),error(ErrorString);end

      end % if strcmp

    else
      [Data.Sys,ErrorString]=LocalGetSysName(varargin{1});
      if ~isempty(ErrorString),error(ErrorString);end

    end % if ischar

  % called as simprintdlg('-crossplatform',sys)
  case 2,
    ForceBuiltIn=logical(0);
    ErrorFlag=logical(0);
    if ~ischar(varargin{1}) || ~strcmp(varargin{1},'-crossplatform'),
      ErrorFlag=logical(1);
    end % if

    if ErrorFlag,
      error(['The first input argument must be ''-crossplatform''' ...
             ' when using 2 inputs.']);
    end

    [Data.Sys,ErrorString]=LocalGetSysName(varargin{2});
    if ~isempty(ErrorString),error(ErrorString);end

  % Callback from Dialog
  % Might also be a call from the PC and MAC dialogs to return the
  % "correct" handle
  case 3,
    ForceBuiltIn=logical(0);
    Action=varargin{1}; % varargin{2:3} are dummy input args
    Dlg=gcbf;

    % if this handle is invalid, lose it!
    if ~isempty(Dlg) && ishandle(Dlg) && ~strcmp(get(Dlg, 'Tag'), 'TMWsimprintdlg'), Dlg = []; end;

	% This is the case where the PC or MAC calls simprintdlg
    if strcmp(Action,'GetCorrectHandle'),

      [Data.Sys,ErrorString]=LocalGetSysName(varargin{3});
      if ~isempty(ErrorString),error(ErrorString);end

    % the only way that Dlg could be empty is by executing a close all hidden
    % or close all force from the command line.  I deal correctly with this
    % below. It might also be the case that the user passed 3 input
    % arguments but that case isn't advertised in the help and I'm not
    % going to worry about it.
	elseif ~isempty(Dlg),
		Tag = get(Dlg, 'Tag');
		if (strcmp(Tag, 'TMWsimprintdlg')),
			Data=get(Dlg,'UserData');
			[Data.Sys,ErrorString]=LocalGetSysName(Data.Sys);
			if ~isempty(ErrorString),
				delete(Dlg)
				return
			end % if ~ishandle
		end
    end  % if strcmp(Action...

  % PC or cmdline calling for info. about what to print
  case 4,
    Action='GetInfoForBuiltIn';
    [Data.Sys,ErrorString]=LocalGetSysName(varargin{1});
    if ~isempty(ErrorString),error(ErrorString);end
    ForceBuiltIn=logical(0);
    Dlg=[];
    
    % PC, MAC,  or cmdline calling for info. about what to print
  case 5,
    if isstruct(varargin{5}),
      Action='PrintFromCmdLine';
      %Fields=sort(fieldnames(varargin{5}));
      RequiredFields={'FileName'
                      'PaperOrientation'
                      'PaperType'
                      'PrintFrame'
                      'PrintLog'
                      'PrintOptions'};
      if ~isempty(setdiff(RequiredFields,fieldnames(varargin{5})))
        error(['The fifth input argument to SIMPRINTDLG must have ' ...
              'the following fields: FileName, PrintFrame, ' ...
              'PrintLog, PrintOptions.']);
      end

    else
      Action='GetInfoForMac';
    end
    
    [Data.Sys,ErrorString]=LocalGetSysName(varargin{1});
    if ~isempty(ErrorString),error(ErrorString);end
    ForceBuiltIn=logical(0);
    Dlg=[];
    
  otherwise,
    error('Too many input arguments to SIMPRINTDLG.')

end % switch nargin


% By this point, the variables Action, Sys and ForceBuiltIn should all exist

% Bring up the print dialog for PC and MAC
if ForceBuiltIn,
  print('-v',['-s' Data.Sys]);
  return
end

if ishandle(Dlg) set(Dlg,'Pointer','watch'); end
%% Deal with callbacks and initialization of the crossplatform dialog
switch Action,
  case 'Cancel',
    RootSysHandle=eval('get_param(Data.RootSys,''Handle'')','[]');
    if ~isempty(RootSysHandle),
      LockedFlag=get_param(Data.RootSys,'Lock');
      set_param(Data.RootSys,'Lock','off');
      set_param(Data.Sys,'PaperType',Data.OrigData{1});
      set_param(Data.Sys,'PaperOrientation',Data.OrigData{2});
      set_param(Data.Sys,'PaperUnits',Data.OrigData{3});
      set_param(Data.Sys,'PaperPosition',Data.OrigData{4});
      set_param(Data.Sys,'PaperPositionMode',Data.OrigData{6});
      set_param(Data.RootSys,'Dirty',Data.OrigData{5});
      set_param(Data.RootSys,'Lock',LockedFlag);
    end
    delete(Dlg)

  % This is called by the PC and MAC (pre-5.2)
  % This converts Stateflow handles correctly.  The reason for this
  % call is to minimize the number of open figures since the MAC
  % has a limit that is usually smaller than what is required for
  % models with a large number of Stateflow charts.
  case 'GetCorrectHandle',
      % Convert Handle to Name
      for lp=1:length(varargin{2}),
        Systems{lp,1}=getfullname(varargin{2}(lp));
        Systems{lp,1}=LocalDealWithStateflow(Systems{lp,1},Data.Sys);
        if ischar(Systems{lp}),Systems{lp}=get_param(Systems{lp},'Handle');end
      end % for lp

      Systems=cat(1,Systems{:});
      varargout{1}=Systems;

  case {'GetInfoForBuiltIn','GetInfoForMac'},
    SystemData=LocalGetPrintSystemList(Data.Sys,varargin{2:4});
    Systems=[SystemData.Systems;SystemData.Resolved];
    Log=simprintlog(SystemData.Systems   , ...
                    SystemData.Resolved  , ...
                    SystemData.Unresolved  ...
                   );

    for lp=1:length(Systems),
      % Convert Names to Handles
      if strcmp(Action,'GetInfoForBuiltIn'),
        Systems{lp}=LocalDealWithStateflow(Systems{lp},Data.Sys);
      end
      if ischar(Systems{lp}),Systems{lp}=get_param(Systems{lp},'Handle');end
    end
    Systems=cat(1,Systems{:});
    varargout{1}=Systems;
    varargout{2}=Log;
    % Debugging purposes
    if nargout==3,
      varargout{3}=SystemData;
    end % if nargout

  case 'Help',
    LocalHelp

  case 'Initialize',
    [Dlg,Data]=LocalInitFig(Data.Sys);

  case 'Orientation',
    Caller=get(gcbo,'String');    
    if strcmp(Caller,'Portrait'),
      NewOrientation={1;0;0};
    elseif strcmp(Caller,'Landscape'),
      NewOrientation={0;1;0};
    else
      NewOrientation={0;0;1};
    end
    set(Data.Orientation,{'Value'},NewOrientation);
    LockedFlag=get_param(Data.RootSys,'Lock');
    set_param(Data.RootSys,'Lock','off');
    set_param(Data.Sys,'PaperOrientation',Caller);

    if ~isequal(NewOrientation,Data.CurrentOrientation),
      PaperPosition=get_param(Data.Sys,'PaperPosition');
      PaperPosition=PaperPosition([2 1 4 3]);
      PaperPositionMode=get_param(Data.Sys,'PaperPositionMode');
      set_param(Data.Sys,'PaperPosition',PaperPosition)
      set_param(Data.Sys,'PaperPositionMode',PaperPositionMode)
    end
    Data.CurrentOrientation=NewOrientation;
    set_param(Data.RootSys,'Lock',LockedFlag);

  case 'PaperType',
    TypeInfo=get(Data.PaperType,{'String','Value'});
    LockedFlag=get_param(Data.RootSys,'Lock');
    set_param(Data.RootSys,'Lock','off');
    set_param(Data.Sys,'PaperType',TypeInfo{1}{TypeInfo{2}});
    set_param(Data.RootSys,'Lock',LockedFlag);

  case 'Print'
    CloseDlg=LocalPrintFromDlg(Data,varargin{:});
    % reset the current system for subsequent calls 
    set_param(0, 'CurrentSystem', Data.Sys); 
    if CloseDlg,
      delete(Dlg);
    end
    
  case 'PrintFromCmdLine',
    CloseDlg=LocalPrintFromCmdLine(Data,varargin{:});
    % reset the current system for subsequent calls 
    set_param(0, 'CurrentSystem', Data.Sys); 
    
  case 'SelectSystems',
    NewHandles=gcbo;
    set(Data.OldHandles,'Value',0);
    set(NewHandles,'Value',1);
    Data.OldHandles=NewHandles;
    Data.CurrentOpt=get(gcbo,'Tag');
    if any(any(Data.ImBtnHandles(3:4)==gcbo)),
      set([Data.LookUnder Data.LibraryLinks],'Enable','on');
    else
      set([Data.LookUnder Data.LibraryLinks],'Enable','off');
    end

  case 'ToFile',
    Caller=get(gcbo,'String');
    if strcmp(Caller,'Printer'),
      set(Data.ToFile,{'Value'},{1;0});
      set(Data.PrintHandle,'String','Print');
    else
      set(Data.ToFile,{'Value'},{0;1});
      set(Data.PrintHandle,'String','Save...');
    end


  case 'TbSelect'
    if isequal(get(Data.TbSelect,'Value'),1),
       set([Data.TbEdit Data.TbBrowse],'Enable','on');
    else
       set([Data.TbEdit Data.TbBrowse],'Enable','off');
    end

  case 'TbBrowse'
    [tbFileName, tbPathName] = uigetfile('*.fig','Select Print Frame');
    if tbFileName ~= 0
       % verify that this is a valid frame file then...
       set(Data.TbEdit,'String',[tbPathName tbFileName]);
    end
    
    %case 'Driver'
    %Turn the "Print with Frame" option OFF if the selected
    %driver is not usable with printframes
     %badFormatName=LocalPrintframeInvalidFormat(get(Data.Device,'String'));
     %if it is currently bad
     %nowBad=(length(badFormatName)>0);
     %if it was previously bad
     %wasBad=strcmp(get(Data.TbSelect,'Enable'),'off');
     
     %if nowBad & ~wasBad
        %if previously OK but now bad
        
        
     %elseif ~nowBad & wasBad
        %if now OK but previously bad
        
     %end
     
  end % switch

if ishandle(Dlg),set(Dlg,'UserData',Data,'Pointer','arrow');end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalDealWithSFAndMasks %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function NewSystems=LocalDealWithSFAndMasks(Systems)

MaskIndices=LocalHasMask(Systems);
NewSystems=Systems;
NewSystems(MaskIndices)=[];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalDealWithStateflow %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function System=LocalDealWithStateflow(System,BaseSys)

BD=logical(0);
if ~isempty(System),
  if strcmp(get_param(System,'Type'),'block_diagram'),
    BD=logical(1);
  end
end

if ~BD && ...
    strcmp(get_param(System,'Mask'),'on') && ...
    strcmp(get_param(System,'MaskType'),'Stateflow'),
  
  if exist('sfprint'),
    
    ParentSys=get_param(System,'Parent');
    RootSys=bdroot(ParentSys);
    
    % Need to set the Paper properties of the system that the chart
    % lives on so that the chart knows what to do. Wouldn't it be nice
    % if SL used vectorized get/set instead of unvectorized
    % get_param/set_param?
    PrintPaperType=get_param(BaseSys,'PaperType');
    PrintPaperOrientation=get_param(BaseSys,'PaperOrientation');
    PrintPaperUnits=get_param(BaseSys,'PaperUnits');
    PrintPaperPosition=get_param(BaseSys,'PaperPosition');
    PrintPaperPositionMode=get_param(BaseSys,'PaperPositionMode');
    
    OrigDirty=get_param(RootSys,'Dirty');
    OrigLock=get_param(RootSys,'Lock');
    OrigOpen=get_param(RootSys,'Open');
    OrigPaperType=get_param(ParentSys,'PaperType');
    OrigPaperOrientation=get_param(ParentSys,'PaperOrientation');
    OrigPaperUnits=get_param(ParentSys,'PaperUnits');
    OrigPaperPosition=get_param(ParentSys,'PaperPosition');
    OrigPaperPositionMode=get_param(ParentSys,'PaperPositionMode');
    
    % Don't have to do open_system here because the one below will force
    % the root model to open
    set_param(RootSys,'Lock','off');
    set_param(ParentSys,'PaperType',PrintPaperType);
    set_param(ParentSys,'PaperOrientation',PrintPaperOrientation);
    set_param(ParentSys,'PaperUnits',PrintPaperUnits);
    set_param(ParentSys,'PaperPosition',PrintPaperPosition);
    set_param(ParentSys,'PaperPositionMode',PrintPaperPositionMode);
    
    
    InstanceID=get_param(System,'UserData');
    ChartID=sf('get',InstanceID,'.chart');
    System=sfprint(ChartID,'default','silent');
    
    % Set everything back the way it was originally.
    set_param(ParentSys,'PaperType',OrigPaperType);
    set_param(ParentSys,'PaperOrientation',OrigPaperOrientation);
    set_param(ParentSys,'PaperUnits',OrigPaperUnits);
    set_param(ParentSys,'PaperPosition',OrigPaperPosition);
    set_param(ParentSys,'PaperPositionMode',OrigPaperPositionMode);
    set_param(RootSys,'Open',OrigOpen);
    set_param(RootSys,'Dirty',OrigDirty);
    set_param(RootSys,'Lock',OrigLock);
    
  else
    warning(['Stateflow not installed, ignoring system ''' System ''''])
  end
  
end % if ~BD

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetPrintSystemList %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function SystemData=LocalGetPrintSystemList( ...
                      Sys,SysOption,LookUnderMask,ExpandLibLinks);

sfPrintJob = 0;

switch SysOption,
  case {'CurrentSystem','CurrentSystemAndAbove'},
        
    if strcmp(SysOption,'CurrentSystemAndAbove'),
      TempSys=Sys;
      Sys={Sys};
      while ~isempty(get_param(TempSys,'Parent')),
        TempSys=get_param(TempSys,'Parent');
        Sys=[{TempSys};Sys];
      end % while
      RootSys=Sys{1};

    else
      RootSys=bdroot(Sys);
      Sys={Sys};

    end % if strcmp

    if stateflow_inside_l(Sys), 
        portal = sf('Private', 'acquire_print_portal');
        sfPrintJob = sf('get', portal, '.sfBasedPrintJob');
     
        if sfPrintJob,
            switch SysOption,
                case 'CurrentSystemAndAbove', directive = 'Up';
                case 'CurrentSystem',         directive = 'This';
                otherwise, error('bad args');
            end;  
        end;
    end;

    try,   if sfPrintJob, Sys = sf('Private', 'sf_hier_print', Sys, 'getSystems', directive); end;
    catch, lasterr
    end;

    % Check to see if the block diagram type is a model
      SystemData.Systems=Sys;
      SystemData.Resolved={};
      SystemData.Unresolved={};

    % It's a library
    %if strcmp(get_param(RootSys,'BlockDiagramType'),'model'),
    %else
    %  SystemData.Systems={};
    %  SystemData.Resolved=Sys;
    %  SystemData.Unresolved={};
    %
    %end % switch

  case {'CurrentSystemAndBelow','AllSystems'},
    OrigSys={Sys};
    if strcmp(SysOption,'AllSystems'),
      Sys=get_param(bdroot(Sys),'Name');
    end

   

    MaskSetting='graphical';
    if LookUnderMask,
      MaskSetting='all';
    end % if

    Systems=find_system(Sys, ...
                       'FollowLinks'   ,'off'      , ...
                       'LookUnderMasks',MaskSetting, ...
                       'BlockType'     ,'SubSystem', ...
                       'TemplateBlock' ,''         , ...
                       'LinkStatus'    ,'none'       ...
                       );

    if ~iscell(Systems),Systems={Systems};end

    if ~LookUnderMask,
      % If the current block is masked and we're not looking under masks
      % we need to look 1 level under the mask and do the appropriate thing
      SpecialCase=logical(0);
      if strcmp(SysOption,'CurrentSystemAndBelow') && LocalHasMask(OrigSys),
        SpecialCase=logical(1);
      end

      if SpecialCase,
        UnderSystems=find_system(OrigSys, ...
                                'FollowLinks'   ,'off'      , ...
                                'LookUnderMasks','all'      , ...
                                'SearchDepth'   ,1          , ...
                                'BlockType'     ,'SubSystem', ...
                                'TemplateBlock' ,''         , ...
                                'LinkStatus'    ,'none'       ...
                                );
        Systems=find_system(UnderSystems   , ...
                           'FollowLinks'   ,'off'      , ...
                           'LookUnderMasks',MaskSetting, ...
                           'BlockType'     ,'SubSystem', ...
                           'TemplateBlock' ,''         , ...
                           'LinkStatus'    ,'none'       ...
                           );
      end % if SpecialCase

      Systems=LocalDealWithSFAndMasks(Systems);

      if SpecialCase,
        Systems=[OrigSys;Systems];
      end

    end

    if isequal(Sys,bdroot(Sys)),
      Systems=[{Sys};Systems];
    end % if

    if stateflow_inside_l(Systems), 
        portal = sf('Private', 'acquire_print_portal');
        sfPrintJob = sf('get', portal, '.sfBasedPrintJob');

        if sfPrintJob && isequal(SysOption, 'CurrentSystemAndBelow'),
            Systems = sf('Private', 'sf_hier_print', Systems, 'getSystems', 'Down');
        else
            Systems = expand_out_charts_with_subcharts_l(Systems);
        end; 
    end; 

    SystemData.Systems=Systems;

    if ExpandLibLinks,
      LibData=libinfo(Sys            , ...
                     'FollowLinks'   ,'on'       , ...
                     'LookUnderMasks',MaskSetting  ...
                     );
      LinkStatus={LibData.LinkStatus};
      ResolvedLinks=strcmp(LinkStatus,'resolved');
      UnresolvedLinks=strcmp(LinkStatus,'unresolved');

      if any(ResolvedLinks),
        ResolvedLinkNames={LibData(ResolvedLinks).ReferenceBlock};
        Resolved         = unique(ResolvedLinkNames);

        % Need to search for subsystems in resolved links
        SystemData.Resolved={};
        for Rslv=1:length(Resolved),
          NewResolved=find_system(Resolved{Rslv}   , ...
                       'FollowLinks'   ,'off'      , ...
                       'LookUnderMasks',MaskSetting, ...
                       'BlockType'     ,'SubSystem', ...
                       'TemplateBlock' ,''         , ...
                       'LinkStatus'    ,'none'       ...
                       );

          SystemData.Resolved=[SystemData.Resolved
                               NewResolved
                              ];
        end % for
        if ~LookUnderMask,
          SystemData.Resolved=LocalDealWithSFAndMasks(SystemData.Resolved);
        end

      else
        SystemData.Resolved={};
      end

      if any(UnresolvedLinks),
        Unresolved={LibData(UnresolvedLinks).Block};
        UnresolvedLinkNames={LibData(UnresolvedLinks).ReferenceBlock};
        [UniqueSys,Index]=unique(UnresolvedLinkNames);
        Unresolved=Unresolved(Index);
        SystemData.Unresolved=UniqueSys(:);

        if ~LookUnderMask,
          NewUnresolved=LocalDealWithSFAndMasks(Unresolved);
          SystemData.Unresolved=get_param(NewUnresolved,'SourceBlock');
          if ~iscell(SystemData.Unresolved),
            SystemData.Unresolved={SystemData.Unresolved};
          end
        end

      else
        SystemData.Unresolved={};
      end


    else
      SystemData.Resolved={};
      SystemData.Unresolved={};

    end % if

  otherwise,
    error('Invalid print option in simprintdlg.');
    SystemData=[];

end % switch

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetSysName %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [StringSys,ErrorString]=LocalGetSysName(Sys)
% Do a lot of error checking on sys to make sure it's valid and
% to return a string system name.

ErrorString='';
StringSys='';

% eval try / catch, ValidHandle defaults to empty if sys is not found 
ValidHandle=eval('find_system(Sys)','[]'); 
  
switch class(Sys),
  case 'char',
    % Check to see if a full system name was passed in
    if isempty(ValidHandle),
      % Check to see if only the window name was passed in
      ValidHandle=find_system(0              , ...
                             'LookUnderMasks','all'      , ...
                             'FollowLinks'   ,'on'       , ...
                             'Name'          ,Sys        , ...
                             'Open'          ,'on'       , ...
                             'BlockType'     ,'SubSystem', ...
                             'TemplateBlock' ,''           ...
                             );
      if isempty(ValidHandle),
        ErrorString='The supplied handle is not a valid system handle.';
        return
      else
        % find_system(0) returns a handle
        Sys=getfullname(ValidHandle(1));
        %Sys=ValidHandle(1);
      end
    end

  case 'double',
    if ~isempty(ValidHandle),
      if length(Sys)>1,
        ErrorString=['Multiple system handles passed to this function.' ...
                     sprintf('\n') ...
                     'This function only accepts one system at a time'];
        return
      else
        Sys=getfullname(Sys);
      end

    else
      ErrorString='The supplied handle is not a valid system handle.';
      return

    end % if ishandle

  otherwise,
    ErrorString='System name or handle must be a string or a double.';
    return

end % switch class

Type=get_param(Sys,'Type');
if ~strcmp(Type,'block_diagram') && ...
   ~strcmp(get_param(Sys,'BlockType'),'SubSystem'),
  warning(['The system passed in is not a block diagram or subsystem.' ...
          sprintf('\n') ...
          'Using the parent of the system passed in.']);
  Sys=get_param(Sys,'Parent');
  %Sys=get_param(get_param(Sys,'Parent'),'Handle');
end
StringSys=Sys;
%HandleSys=Sys;

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalHasMask %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function MaskFlag=LocalHasMask(Systems)

BD=logical(0);
if ~isempty(Systems) && strcmp(get_param(Systems{1},'Type'),'block_diagram'),
  BD=logical(1);
end

if BD,BDSys=Systems(1);Systems(1)=[];end

MaskOn=find(strcmp(get_param(Systems,'Mask'),'on'));
SFSys=strcmp(get_param(Systems(MaskOn),'MaskType'),'Stateflow');
DlgParams  =~strcmp(get_param(Systems(MaskOn),'MaskPromptString')  ,'');
InitString =~strcmp(get_param(Systems(MaskOn),'MaskInitialization'),'');
HelpText   =~strcmp(get_param(Systems(MaskOn),'MaskHelp')          ,'');
Description=~strcmp(get_param(Systems(MaskOn),'MaskDescription')   ,'');
DlgOrWk= DlgParams | InitString | HelpText | Description;
MaskIndices=MaskOn(DlgOrWk & ~SFSys);
MaskFlag=zeros(length(Systems),1);
MaskFlag(MaskIndices)=1;
MaskFlag=logical(MaskFlag);

if BD,MaskFlag=[logical(0);MaskFlag];end

%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalHelp %%%%%
%%%%%%%%%%%%%%%%%%%%%
function LocalHelp
ttlStr = 'Print Dialog';


hlpStr1= ...
        ['                                                     '
         '   To send the designated system window to           '
         '   the default printer, select "Printer" from the    '
         '   "Send To:" popup menu.                            '
         '                                                     '
         '   To send the system to a file, select "File"       '
         '   from the "Send To:" popup menu and then press     '
         '   the "Save..." pushbutton.  A dialog box           '
         '   will appear in which you can enter a              '
         '   filename for the file.                            '
         '                                                     '
         '   If you select more than one system to print       '
         '   to a file, the files will be numbered.  For       '
         '   example, if you select the filename "mysystem.ps" '
         '   your output will be saved as "mysystem1.ps",      '
         '   "mysystem2.ps", "mysystem3.ps",...                '
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
         '    PORTRAIT prints the system window        '
         '    occupying a rectangle with aspect ratio  '
         '    4/3 in the middle of the page.           '
         '                                             '
         '    This popup sets the PaperOrientation and '
         '    PaperPosition properties of the printed  '
         '    system window.                           '
         '                                             '];

helpwin({'Print Dialog'      hlpStr1 ; ...
         'Devices'           hlpStr2 ; ...
         'Paper Orientation' hlpStr3},'Print Dialog',ttlStr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetFileInfo %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FileName,FileNameExt]=LocalGetFileInfo(FileName);
if isempty(FileName),
  FileName='';
  FileNameExt='';
  return
end

iDot = find(FileName=='.');
if ~isempty(iDot)
  iDot = iDot(end);
  FileNameExt = FileName(iDot:end);  % includes .
  if iDot>1
    FileName = FileName(1:iDot-1);
  else
    FileName = '';
  end
else
  FileNameExt = '';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalPrintFromCmdLine %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CloseDlg=LocalPrintFromCmdLine(Data,varargin)

SystemData=LocalGetPrintSystemList(Data.Sys,varargin{2:4});
IncludePrintLog=strcmp(varargin{5}.PrintLog,'on');
IncludePrintFrame=~isempty(varargin{5}.PrintFrame);
ToFileFlag=~isempty(varargin{5}.FileName);
[FileName,FileNameExt]=LocalGetFileInfo(varargin{5}.FileName);

StructInfo={ ...
            'Sys'              ,Data.Sys
            'Systems'          ,SystemData.Systems
            'Resolved'         ,SystemData.Resolved
            'Unresolved'       ,SystemData.Unresolved
            'UsingDlg'         ,logical(0)
            'IncludePrintLog'  ,IncludePrintLog
            'IncludePrintFrame',IncludePrintFrame
            'PrintFrame'       ,varargin{5}.PrintFrame
            'ToFileFlag'       ,ToFileFlag
            'FileName'         ,FileName
            'FileNameExt'      ,FileNameExt
            'Device'           ,varargin{5}.PrintOptions
            };


PrintData=cell2struct(StructInfo(:,2),StructInfo(:,1));

printSys=LocalGetReferenceSystem(Data.Sys);

RootSys=bdroot(printSys); 

OrigDirty=get_param(RootSys,'Dirty');
OrigLock=get_param(RootSys,'Lock');

origParams = { ...
    'PaperOrientation',get_param(printSys,'PaperOrientation'),...
    'PaperType',get_param(printSys,'PaperType')...
};

newParams = { ...
    'PaperOrientation',varargin{5}.PaperOrientation, ...
    'PaperType'       ,varargin{5}.PaperType        ...
};
    
if isempty(varargin{5}.PrintFrame) && ...
        isfield(varargin{5},'PaperPosition') && ...
        isfield(varargin{5},'PaperUnits')
    
    origParams=[origParams,{ ...
                'PaperUnits',get_param(printSys,'PaperUnits') ...
                'PaperPosition',get_param(printSys,'PaperPosition'),...
                'PaperPositionMode',get_param(printSys,'PaperPositionMode'),...
            }];
    
    newParams = [newParams,{ ...
                'PaperUnits',varargin{5}.PaperUnits, ...
                'PaperPosition',varargin{5}.PaperPosition ...
            }];
end

set_param(RootSys,'Lock','off');
set_param(printSys, newParams{:});
 
%Check to see if the Device is one which allows printframes 
if PrintData.IncludePrintFrame
   badFormatName=LocalPrintframeInvalidFormat(PrintData.Device);
   if length(badFormatName)>0
      %maybe this should error?
      PrintData.IncludePrintFrame=logical(0);
      PrintData.PrintFrame='';
   end
end

CloseDlg=LocalPrint(PrintData);

set_param(printSys, origParams{:});

set_param(RootSys,'Dirty',OrigDirty,'Lock',OrigLock);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalPrintFromDlg %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CloseDlg=LocalPrintFromDlg(Data,varargin)

ExpandLibLinks=get(Data.LibraryLinks,'Value');
LookUnderMask=get(Data.LookUnder,'Value');
SystemData=LocalGetPrintSystemList(Data.Sys,Data.CurrentOpt, ...
    LookUnderMask,ExpandLibLinks);
IncludePrintLog=get(Data.PrintLog,'Value');
IncludePrintFrame = get(Data.TbSelect,'Value');
if IncludePrintFrame,
  PrintFrame=get(Data.TbEdit,'String');
else
  PrintFrame='';
end

ToFileFlag=get(Data.ToFile(2),'Value');
if ToFileFlag,
  [fname, pname] = uiputfile('*.*','Save As');
  if isequal(fname,0),
    CloseDlg=logical(0);
    return
  end
  FileName=[pname fname];

  [FileName,FileNameExt]=LocalGetFileInfo(FileName);
else
  FileName = '';
  FileNameExt = '';
end

PrintOptions=get(Data.Device,'String');

TypeInfo=get(Data.PaperType,{'String','Value'});
PaperType=TypeInfo{1}{TypeInfo{2}};


StructInfo={ ...
            'Sys'              ,Data.Sys
            'Systems'          ,SystemData.Systems
            'Resolved'         ,SystemData.Resolved
            'Unresolved'       ,SystemData.Unresolved
            'UsingDlg'         ,logical(1)
            'IncludePrintLog'  ,IncludePrintLog
            'IncludePrintFrame',IncludePrintFrame
            'PrintFrame'       ,PrintFrame
            'ToFileFlag'       ,ToFileFlag
            'FileName'         ,FileName
            'FileNameExt'      ,FileNameExt
            'Device'           ,PrintOptions
            };

PrintData=cell2struct(StructInfo(:,2),StructInfo(:,1));

%Check to see if the Device is one which allows printframes 
if PrintData.IncludePrintFrame
   badFormatName=LocalPrintframeInvalidFormat(PrintData.Device);
   if length(badFormatName)>0
      errorString={['Driver "' badFormatName '" can not be used with printframes.']
         'Continue printing without frames?'};
      selectedBtn=questdlg(errorString,...
         'simprintdlg warning',...
         'Continue',...
         'Cancel',...
         'Cancel');
      switch selectedBtn
      case 'Continue'
         PrintData.IncludePrintFrame=logical(0);
         PrintData.PrintFrame='';
      case 'Cancel'
         CloseDlg=logical(0);
         return
      end
   end
end




CloseDlg=LocalPrint(PrintData);


%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalFindDevType %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function [devtype, device] = LocalFindDevType(in_device)

% get device type stripped of the '-d' prefix
device = in_device(findstr(in_device, '-d')+2:end);
device(findstr(device, ' '):end) = '';

if ~isempty(device)
  [ options, devices, extensions, classes ] = printtables;
  devIndex = strmatch( device, devices, 'exact' );
  devtype = classes{ devIndex };
else
  devtype = [];
end  


%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalPrint %%%%%
%%%%%%%%%%%%%%%%%%%%%%
function CloseDlg=LocalPrint(PrintData)

CloseDlg=logical(1);

% Check for printer device types that are incompatible with Simulink models
[local_devtype, local_device] = LocalFindDevType(PrintData.Device);
if (ischar(local_devtype) && strcmp(local_devtype, 'IM') )
    msg = sprintf('The %s device option is not supported for Simulink systems.', ...
		upper(local_device));
    msgbox(msg, 'Error', 'error', 'modal')
    CloseDlg=logical(0);
    return;
end

% Put up a message dialog
if PrintData.UsingDlg,
  String='Printing log file          .';
  MsgDlg=msgbox(String,'Print status','modal');
  StrHandle=findall(MsgDlg,'String',{String});
  BtnHandle=findall(MsgDlg,'Style','pushbutton');
  set(BtnHandle,'String','Cancel');
  Extent=get(BtnHandle,'Extent');
  Pos=get(BtnHandle,'Position');
  if Extent(3)>(Pos(3)-10),
    Diff=Extent(3)-(Pos(3)-10);
    Pos=[Pos(1)-Diff/2 Pos(2) Pos(3)+Diff Pos(4)];
    set(BtnHandle,'Position',Pos);
  end
  set(StrHandle,'String','');
  drawnow
else
  MsgDlg=[];
  StrHandle=[];
end


device=PrintData.Device;

% Print the file
printerName='';
Loc=min(findstr(device,'-P'));
if ~isempty(Loc),
  Loc2=find(device==' ');
  Loc2=Loc2(Loc2>Loc);
  if ~isempty(Loc2),
    Loc2=Loc2(1);
  else
    Loc2=length(device);
  end % if ~isempty
  
  printerName=device(Loc:Loc2);
  if PrintData.ToFileFlag,
    device(Loc:Loc2)=[];
  end
end % if ~isempty



% Print the Print Log
if PrintData.IncludePrintLog,
  if PrintData.UsingDlg,
    set(StrHandle,'String','Printing log file.');
    drawnow
  end % if using dlg
  
  % Create the file
  if PrintData.ToFileFlag,
    NewFileName=[PrintData.FileName PrintData.FileNameExt '.log'];
  else
    NewFileName=tempname;
  end
  
  PrintLog=simprintlog(PrintData.Systems   , ...
                       PrintData.Resolved  , ...
                       PrintData.Unresolved  ...
                      );

  FileID=fopen(NewFileName,'wt');
  for lp=1:size(PrintLog,1),
    fprintf(FileID,'%s\n',deblank(PrintLog(lp,:)));
  end
  fclose(FileID);

  
  % Print to a printer if not sending all output to a file
  if isempty(StrHandle) || ishandle(StrHandle),
    if ~PrintData.ToFileFlag,
      if isempty(printerName),
        printtext(NewFileName);
      else
        printtext(printerName,NewFileName);
      end
    end % if
    
  % The printing operation has been cancelled
  else
    CloseDlg=logical(0);
    return
  end % if
end % if nargin

SysToPrint=[PrintData.Systems;PrintData.Resolved];
NumSys=length(SysToPrint);
NewFileName='';

initSys=LocalGetReferenceSystem(PrintData.Sys);

PrintPaperType=get_param(initSys,'PaperType');
PrintPaperOrientation=get_param(initSys,'PaperOrientation');
                      
PrintPaperUnits=get_param(initSys,'PaperUnits');
PrintPaperPosition=get_param(initSys,'PaperPosition');
PrintPaperPositionMode=get_param(initSys,'PaperPositionMode');

if PrintData.IncludePrintFrame,
  printframeH = printframe('Create',PrintData.PrintFrame,NumSys,initSys);

  if ~ishandle(printframeH) || printframeH==0
     ReturnChar=sprintf('\n');
     WarningString=['An error occurred when I tried to print.  ', ...
                ReturnChar ...
                'Error: unable to open the Print Frame' ReturnChar ...
                PrintData.PrintFrame ReturnChar ...
                'Printing will continue without PrintFrames.' ...
                ];
     TbSelectFlag = logical(0);
     warning(WarningString)
  end
end


for SysLp=1:NumSys,

  % Check to see if the dialog is still open
  if ~isempty(StrHandle) && ~ishandle(StrHandle),
    CloseDlg=logical(0);
    return
  else
    set(StrHandle, ...
       'String',['Printing page ' num2str(SysLp) ' of ' num2str(NumSys) '.']);
    drawnow
    
    if PrintData.ToFileFlag,
      if NumSys>1  % number the files only if there is more than one page
         NewFileName=[PrintData.FileName int2str(SysLp) PrintData.FileNameExt];
      else
         NewFileName=[PrintData.FileName PrintData.FileNameExt];
      end
    end % if

    % This converts all cell arrays to handles and deals with Stateflow
    SysToPrint{SysLp}=LocalDealWithStateflow(SysToPrint{SysLp},initSys);
    
    origPrintSys=SysToPrint{SysLp};
    currPrintSys=LocalGetReferenceSystem(origPrintSys);
    
    
    % Deal with printing SL diagams
    if ischar(currPrintSys),
      PrintRootSys=bdroot(currPrintSys);

      OrigDirty=get_param(PrintRootSys,'Dirty');
      OrigLock=get_param(PrintRootSys,'Lock');
      OrigOpen=get_param(PrintRootSys,'Open');
      OrigPaperType=get_param(currPrintSys,'PaperType');
      OrigPaperOrientation=get_param(currPrintSys,'PaperOrientation');
      OrigPaperUnits=get_param(currPrintSys,'PaperUnits');
      OrigPaperPosition=get_param(currPrintSys,'PaperPosition');
      OrigPaperPositionMode=get_param(currPrintSys,'PaperPositionMode');

      % Don't have to do open_system here because the one below will force
      % the root model to open
      set_param(PrintRootSys,'Lock','off');
      set_param(currPrintSys,'PaperType',PrintPaperType);
      set_param(currPrintSys,'PaperOrientation',PrintPaperOrientation);
      set_param(currPrintSys,'PaperUnits',PrintPaperUnits);
      set_param(currPrintSys,'PaperPosition',PrintPaperPosition);
      set_param(currPrintSys,'PaperPositionMode',PrintPaperPositionMode);

      OpenFlag=get_param(currPrintSys,'Open');
      open_system(currPrintSys,'force');

      if PrintData.IncludePrintFrame,
         ErrorFlag = logical(0);
         % get system handle to pass to printframe
         sysH = get_param(currPrintSys,'Handle');
         % Init Printframe for this page
         % pass the simulink system, rather than the constructed sf figure
         ErrorFlag = printframe('NewPage', ...
                 [sysH printframeH], SysLp);
         if ErrorFlag
            ReturnChar=sprintf('\n');
            WarningString=['An error occurred when I tried to print.  ', ...
                  ReturnChar ...
                  'Error: unable to initialize the Print Frame' ReturnChar ...
                  PrintData.PrintFrame ReturnChar ...
            ];
            warning(WarningString)
         end
      end


      device=strrep(deblank(device),' ',''',''');

      if PrintData.IncludePrintFrame,
         pstr = ['print( [sysH printframeH],''' device ''','''  ...
                    NewFileName ''')'];
      else
         pstr = ['print([''-s'' currPrintSys ],''' device ''','''  ...
                    NewFileName ''')'];
      end
      % NOW EVAL THE PRINT STATEMENT:
      ErrorFlag = 0;
      eval(pstr,'ErrorFlag = 1;');

      if PrintData.IncludePrintFrame,
         fErr = printframe('FinishPage', printframeH);
      end

      set_param(currPrintSys,'PaperType',OrigPaperType);
      set_param(currPrintSys,'PaperOrientation',OrigPaperOrientation);
      set_param(currPrintSys,'PaperUnits',OrigPaperUnits);
      set_param(currPrintSys,'PaperPosition',OrigPaperPosition);
      set_param(currPrintSys,'PaperPositionMode',OrigPaperPositionMode);

      set_param(PrintRootSys,'Open',OrigOpen);
      set_param(PrintRootSys,'Dirty',OrigDirty);
      set_param(PrintRootSys,'Lock',OrigLock);

      % don't close the parent system on the first pass
      % this allows diagrams which are loaded but not open to get
      % printed with their children/parents
      if strcmp(OpenFlag,'off' ) && ~ strcmp(currPrintSys, PrintRootSys)	
        lockedState = get_param(bdroot(currPrintSys),'Lock');
        set_param(bdroot(currPrintSys),'Lock','off');
        set_param(currPrintSys,'Open','off');
        set_param(bdroot(currPrintSys),'Lock',lockedState);
      end

    % Stateflow printing
    else
    % currPrintSys IS a portal display figure, print it.
    
      device=strrep(deblank(device),' ',''',''');

      if PrintData.IncludePrintFrame,
         ErrorFlag = printframe('NewPage', ...
                 [currPrintSys printframeH], SysLp);
         pstr = ['print( [currPrintSys printframeH],''' device ''',''' ...
                    NewFileName ''')'];
      else
         pstr = ['print(currPrintSys,''' device ''',''' ...
                    NewFileName ''')'];
      end
      % NOW EVAL THE PRINT STATEMENT:
      ErrorFlag = 0;
      eval(pstr,'ErrorFlag = 1;');
      if PrintData.IncludePrintFrame,
         fErr = printframe('FinishPage', printframeH);
      end

    end % if ischar

    if ErrorFlag
      ReturnChar=sprintf('\n');
      WarningString=['An error occurred when I tried to print.  ', ...
              ReturnChar ...
              'Here was the print command:' ReturnChar ...
              pstr ReturnChar ...
              'and here was the error:' ReturnChar ...
              lasterr
          ];
      warning(WarningString)
    end % if error
  end % if ishandle

end % for SysLp

if ~isempty(MsgDlg) && ishandle(MsgDlg),
  delete(MsgDlg);
end

if PrintData.IncludePrintFrame,
  close(printframeH);
end

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInd2RGB %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function rout = LocalInd2RGB(a,cm)
% Make sure A is in the range from 1 to size(cm,1)
if isa(a, 'uint8')
    a = double(a)+1;    % Switch to one based indexing
end
a = max(1,min(a,size(cm,1)));

% Extract r,g,b components
r = zeros(size(a)); r(:) = cm(a,1);
g = zeros(size(a)); g(:) = cm(a,2);
b = zeros(size(a)); b(:) = cm(a,3);

rout = zeros([size(r),3]);
rout(:,:,1) = r;
rout(:,:,2) = g;
rout(:,:,3) = b;


%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function [Dlg,Data]=LocalInitFig(Sys)

Data.Sys=Sys;

Dlgname = ['Print: ' get_param(Data.Sys,'Name') ];
Dlgname = ['Print: ' getfullname(Data.Sys) ];
ReturnChar=sprintf('\n');
Dlgname(Dlgname==ReturnChar)=' ';
Dlg=findobj(allchild(0),'flat','Name',Dlgname);

if ~isempty(Dlg);
  figure(Dlg)
  return
end % if

% This will load in X and Map
load(fullfile('private','simprintdlg.mat'));

BtnWidth=75;BtnHeight=22;
Offset=3;

FigWidth=4*(size(X(:,:,1),1)+5)+5*(Offset+4);

BtnPos=zeros(3,4);
BtnPos(1,:)=[Offset Offset BtnWidth BtnHeight];
BtnPos(2:3,:)=BtnPos([1 1],:);
BtnPos(2,1)=BtnPos(2,1)+1;
BtnPos(3,1)=FigWidth-Offset-BtnWidth;
BtnPos=align(BtnPos,'Distribute','Bottom');

FramePos=zeros(3,4);
% cancel|help|print button frame
FramePos(1,:)=[0 0 FigWidth sum(BtnPos(3,[2 4]))+Offset];
% printframe option frame
FramePos(3,:)=FramePos(1,:);FramePos(3,2)=sum(FramePos(1,[2 4]))-1;
% popup frame
FramePos(2,:)=FramePos(1,:);FramePos(2,2)=sum(FramePos(3,[2 4]))-1;

Width=(FramePos(1,3)-3*Offset)/3;
Width3=((FramePos(1,3)-4*Offset)/4) - 3*Offset;
Upper=4;
TextPos=zeros(Upper,4);
TextPos(1,:)=[FramePos(2,1)+Offset FramePos(2,2)+Offset Width BtnHeight];
for lp=2:Upper,
  TextPos(lp,:)=TextPos(lp-1,:)+[0 BtnHeight+2 0 0];
end
PopupPos=TextPos;PopupPos(:,1)=sum(TextPos(1,[1 3]))+Offset;
PopupPos=PopupPos([1 1 2 3 3 3 4],:);
PopupPos(2,1)=PopupPos(1,1)+PopupPos(1,3);
%make width of all orientation  buttons smaller, there are 3 now
PopupPos([1 2 4 5 6],3) = ones(5,1) * Width3;
PopupPos([2 5],1)=PopupPos(4,1)+[Width3;Width3];%Landscape and File line up
PopupPos(6,1)=PopupPos(5,1)+Width3;%Rotated
PopupPos([3 ],3)=Width*2;
FramePos(2,4)=sum(PopupPos(end,[2 4]))+Offset-FramePos(2,2);

TbPos=zeros(3,4);
TbPos(:,2) = FramePos(3,2)+Offset;
% checkbox
TbPos(1,1:2) = FramePos(3,1:2)+Offset;
TbPos(1,3:4) = [Width BtnHeight];
% Browse button
TbPos(3,1) = FigWidth-Offset-BtnWidth;
TbPos(3,3:4) = [BtnWidth BtnHeight];
% editbox
TbPos(2,1) = PopupPos(1,1);
TbPos(2,3) = TbPos(3,1)-TbPos(2,1)-Offset;
TbPos(2,4) = BtnHeight;

SimOptPos=[Offset sum(FramePos(2,[2 4]))+Offset+BtnHeight ...
           (FigWidth-3*Offset)/2 BtnHeight];
SimOptPos=SimOptPos([1 1 1],:);
SimOptPos(2:3,1)=sum(SimOptPos(1,[1 3]))+Offset;
SimOptPos(2,2)=SimOptPos(1,2)-SimOptPos(2,4);

ImBtnPos=[Offset+2 sum(SimOptPos(3,[2 4]))+Offset size(X(:,:,1))];
ImBtnPos=ImBtnPos([1 1 1 1],:);
ImBtnPos(4,1)=FigWidth-Offset-ImBtnPos(4,3);
ImBtnPos=align(ImBtnPos,'Distribute','Bottom');

Units=get(0,'Units');
set(0,'Units','pixels');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',Units);
FigHeight=sum(ImBtnPos(1,[2 4]))+Offset;
FigPos=[(ScreenSize(3)-FigWidth)/2 (ScreenSize(4)-FigHeight-40)/2 ...
         FigWidth FigHeight];


%%% Set up the controls

White=[1 1 1];Black=[0 0 0];

Std.Units                = 'pixels'     ;
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

SimOpt=Popup;
SimOpt.Style='checkbox';

FigColor=get(0,'defaultuicontrolbackgroundcolor');

SimOpt.BackgroundColor=FigColor;

ImBtnInfo=Btn;
ImBtnInfo.Style='togglebutton';

BtnString={'Cancel';'Help';'Print'};
BtnTag=BtnString;
BtnCall={'simprintdlg Cancel foo bar'
         'simprintdlg Help foo bar'
         'simprintdlg Print foo bar'
        };

TextString={'Send to:';'Device option:'
            'Paper orientation:';'Paper type:'};
[pcmd,device] = printopt;
Loc=min(findstr('-P',device));
if isempty(Loc) && (isunix),
  Printer=getenv('PRINTER');
  if ~isempty(Printer),
    device=['-P' Printer ' ' device];
  end
end

ObjParams=get_param(0,'ObjectParameters');
PaperType=ObjParams.PaperType.Enum;

PopupString=[{'Printer'}
             {'File'}
             {device}
             {'Portrait'}
             {'Landscape'}
             {'Rotated'}
             {PaperType}
            ];
PopupTag={'ToPrinter';'ToFile'
          'Device'
          'Portrait';'Landscape';'Rotated'
          'PaperType'};
PopupCall={'simprintdlg ToFile foo bar';'simprintdlg ToFile foo bar'
           'simprintdlg Driver foo bar'
           'simprintdlg Orientation foo bar'
           'simprintdlg Orientation foo bar'
           'simprintdlg Orientation foo bar'
           'simprintdlg PaperType foo bar'};
PopupStyle={'radiobutton';'radiobutton'
            'edit'
            'radiobutton';'radiobutton';'radiobutton'
            'popupmenu'};
PopupColor={FigColor;FigColor;White;FigColor;FigColor;FigColor;White};

TbString = {'Print with Frame:'
            'sldefaultframe.fig'
            'Browse...'};
TbStyle =  {'checkbox'; 'edit'; 'pushbutton'};
TbColor = {FigColor; White; FigColor};
TbCall = {'simprintdlg TbSelect foo bar'
          ''
          'simprintdlg TbBrowse foo bar'};
TbTag = {'TbSelect';'TbEdit';'TbBrowse'};
TbEnable = {'on'; 'on'; 'on'};


SimOptTag={'PrintLog';'LibraryLinks';'LookUnderMask'};
SimOptString={'Include print log'
              'Expand unique library links'
              'Look under mask dialogs'};

ImBtnTags={'CurrentSystem';
           'CurrentSystemAndAbove';'CurrentSystemAndBelow'
           'AllSystems'};
ImBtnCall={'simprintdlg SelectSystems foo bar'};
ImBtnCall=ImBtnCall([1 1 1 1],1);

%%% Create Everything
Dlg = figure(Std             , ...
            'Color'          ,FigColor                    , ...
            'Colormap'       ,Map                         , ...
            'Menubar'        ,menubar                     , ...
            'Resize'         ,'off'                       , ...
            'Visible'        ,'off'                       , ...
            'Name'           ,Dlgname                     , ...
            'Tag'            ,'TMWsimprintdlg'            , ...
            'Position'       ,FigPos                      , ...
            'IntegerHandle'  ,'off'                       , ...
            'WindowStyle'    ,'modal'                     , ...
            'CloseRequestFcn','simprintdlg Cancel foo bar', ...
            'Resize'         ,'off'                       , ...
            'NumberTitle'    ,'off'                         ...
            );

Std.Parent=Dlg; Btn.Parent=Dlg;
Txt.Parent=Dlg; Popup.Parent=Dlg;
SimOpt.Parent=Dlg;
ImBtnInfo.Parent=Dlg;

for lp=1:size(FramePos,1),
  FrameHandles(lp)=uicontrol(Std      , ...
                            'Style'   ,'frame'       , ...
                            'Position',FramePos(lp,:)  ...
                            );
end % for lp

for lp=1:length(BtnTag),
  BtnHandles(lp)=uicontrol(Btn      , ...
                          'Position',BtnPos(lp,:) , ...
                          'Tag'     ,BtnTag{lp}   , ...
                          'Callback',BtnCall{lp}  , ...
                          'String'  ,BtnString{lp}  ...
                          );
end % for lp

for lp=1:length(TextString),
  TextHandles(lp)=uicontrol(Txt      , ...
                           'Position',TextPos(lp,:)  , ...
                           'Enable'  ,'inactive'     , ...
                           'String'  ,TextString{lp}   ...
                           );
end % for lp
for lp=1:length(PopupString),
  PopupHandles(lp)=uicontrol(Popup           , ...
                            'Position'       ,PopupPos(lp,:) , ...
                            'Tag'            ,PopupTag{lp}   , ...
                            'Style'          ,PopupStyle{lp} , ...
                            'BackgroundColor',PopupColor{lp} , ...
                            'Callback'       ,PopupCall{lp}  , ...
                            'String'         ,PopupString{lp}  ...
                            );
end % for lp
for lp=1:length(TbString),
  TbHandles(lp)=uicontrol(Popup           , ...
                            'Position'       ,TbPos(lp,:) , ...
                            'Tag'            ,TbTag{lp}   , ...
                            'Style'          ,TbStyle{lp} , ...
                            'BackgroundColor',TbColor{lp} , ...
                            'Callback'       ,TbCall{lp}  , ...
                            'String'         ,TbString{lp}, ...
                            'Enable'         ,TbEnable{lp}  ...
                            );
end % for lp
set(TbHandles(1),'Value',1);

for lp=1:length(SimOptString),
  SimOptHandles(lp)=uicontrol(SimOpt   , ...
                             'Position',SimOptPos(lp,:) , ...
                             'Tag'     ,SimOptTag{lp}   , ...
                             'String'  ,SimOptString{lp}  ...
                             );
end % for lp


for BtnLp=1:size(ImBtnTags,1),
  CData=LocalInd2RGB(X(:,:,BtnLp),Map);
  ImBtnHandles(BtnLp)=uicontrol(ImBtnInfo    , ...
                               'Position'       ,ImBtnPos(BtnLp,:), ...
                               'Tag'            ,ImBtnTags{BtnLp} , ...
                               'CData'          ,CData            , ...
                               'Callback'       ,ImBtnCall{BtnLp}   ...
                               );
end

DefaultButton=1;

Data.RootSys      = bdroot(Data.Sys);
Data.CurrentOpt   = get(ImBtnHandles(DefaultButton),'Tag');
Data.Device       = PopupHandles(3);
Data.ImBtnHandles = ImBtnHandles;
Data.LibraryLinks = SimOptHandles(2);
Data.LookUnder    = SimOptHandles(3);
Data.OldHandles   = ImBtnHandles(DefaultButton);
Data.Orientation  = PopupHandles(4:6);
Data.OrigData{1} = get_param(Data.Sys,'PaperType');
Data.OrigData{2}  = get_param(Data.Sys,'PaperOrientation');
Data.OrigData{3} = get_param(Data.Sys,'PaperUnits');
Data.OrigData{4} = get_param(Data.Sys,'PaperPosition');
Data.OrigData{5} = get_param(Data.RootSys,'Dirty');
Data.OrigData{6} = get_param(Data.Sys,'PaperPositionMode');
Data.PaperType    = PopupHandles(end);
Data.PrintHandle  = BtnHandles(3);
Data.PrintLog     = SimOptHandles(1);
Data.ToFile       = PopupHandles(1:2);
Data.TbSelect     = TbHandles(1);
Data.TbEdit       = TbHandles(2);
Data.TbBrowse     = TbHandles(3);

% Select the printer option
set(Data.ToFile(1),'Value',1);

% Need to make the print button interruptible so that the cancel option
% works during printing.
set(Data.PrintHandle,'Interruptible','on');

if strcmp(get_param(Data.Sys,'PaperOrientation'),'portrait'),
  Data.CurrentOrientation={1;0;0};
elseif strcmp(get_param(Data.Sys,'PaperOrientation'),'landscape'),
  Data.CurrentOrientation={0;1;0};
else
  Data.CurrentOrientation={0;0;1};
end
set(Data.Orientation,{'Value'},Data.CurrentOrientation);

% Press the second button and disable checkboxes
set(Data.OldHandles,'Value',1)
set([Data.LookUnder Data.LibraryLinks],'Enable','off');

set(Dlg,'Visible','on','UserData',Data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
function badFormatName=LocalPrintframeInvalidFormat(driverString)

badList={'dwin'
   'dmeta'
   'dhpgl'
   'dill'
   'dmfile'};

badFormatName='';
i=1;
badListLength=length(badList);
while length(badFormatName)==0 && i<=badListLength
   if length(findstr(driverString,badList{i}))>0
      badFormatName=badList{i};
   else
      i=i+1;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function refSys=LocalGetReferenceSystem(origSys)

try
   if strcmp(get_param(origSys,'type'),'block') & ...
         strcmp(get_param(origSys,'LinkStatus'),'resolved')
      refSys=get_param(origSys,'ReferenceBlock');
   else
      refSys=origSys;
   end
catch
   %If origSys is an HG handle (Stateflow), get_param
   %will error.  Just return the original handle
   refSys=origSys;
end


%-------------------------------------------------------------------------
function Systems = expand_out_charts_with_subcharts_l(Systems, directive),
%
%  i) find all paths to charts in the Systems list
% ii) replicate System entries for all charts with subcharts and
%     setup a printStack inside the Stateflow Print Portal object.
%       (this will be used to spoof the Simulink printing code --a
%        necessary evil since we're releasing Stateflow 3.0 against
%        a static Simulink R11 Image and Simulink printing has been
%        designed as a closed system!).

    if isempty(Systems) return; end;

    portal = sf('Private', 'acquire_print_portal');
    if strcmp(get_param(Systems{1},'Type'),'block_diagram'), 
        theRoot    = Systems(1);
        subSystems = Systems(2:end);
    else           
        theRoot    = {};                                         
        subSystems = Systems;
    end;
    
    chartInd = find(strcmp(get_param(subSystems,'MaskType'), 'Stateflow'));

    if isempty(chartInd), return ;end;
    
    numSys  = length(subSystems);
    pStack  = [];
    repInds = 1;

    % Loop through each chart path, composing a print stack 
    % and building a replicating index vector 
    for i = 1:length(chartInd),           
        ind        = chartInd(i);
        sfSystem   = subSystems{ind};
        instance   = get_param(sfSystem, 'userdata');
        chart      = sf('get', instance, '.chart');
		subCharts = sf('Private','non_empty_subcharts_in',chart);
        subCharts  = subCharts(:);
        num        = length(subCharts);
        pStack     = [pStack; chart; subCharts];
        
        if length(repInds > 1), prev = repInds(1:(end-1)); else prev = []; end;
        
        startInd   = repInds(end);
        repInds    = [prev, startInd:ind];
        if num > 0, repInds = [repInds, ones(1,num)*ind]; end;
     end;    

    sf('set', portal, '.printStack', pStack(:).');
    
    % tack back on any remainig non-chart systems
    last = repInds(end);
    if last < numSys, repInds = [repInds, (last+1):numSys]; end;

    % Use Tony's Trick to quickly expand these suckers.
    x= subSystems(repInds);
    x = x(:);
    Systems = [theRoot; x];
    Systems = Systems(:);

    
%-------------------------------------------------------------------
function x = stateflow_inside_l(systems),
% 
% 
%
    blockDiagrams = strcmp(get_param(systems, 'Type'), 'block_diagram');
    bdInd = find(blockDiagrams);
    systems(bdInd) = [];
    
    x = any(find(strcmp(get_param(systems,'MaskType'), 'Stateflow')));

    % if you don't find any Stateflow blocks in the list, check to
    % see if you're IN a Stateflow sponsored print job ==> stateflowIndide = true;
    isSF = [];
    if ~x, 
   	   [m, mexFcns] = inmem;
       for i=1:length(mexFcns), isSF(i) = isequal(mexFcns{i}, 'sf'); end;
    
       if any(isSF),
          portal = sf('Private', 'acquire_print_portal');
          x = sf('get', portal, '.sfBasedPrintJob');
       end;      
    end;

   
   
   

