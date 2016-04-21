function varargout=simbrowse(varargin)
%SIMBROWSE Tree diagram.
%   SIMBROWSE(Sys) will display in a GUI the systems that are contained in
%   the model Sys. SIMBROWSE is meant to be called from the Simulink File
%   menu but the command line interface also exists.

%   Loren Dean
%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.38.2.2 $

SimBrowseFig=[];
switch nargin,
  %%%%%%%%%%%%%%%%%%%%%%%%%
  %%% Callbacks from SL %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%
  case 4,
    Action=varargin{1};
    SimBrowseFig=varargin{2};
    BlockHandles=varargin{3};
    SystemHandle=varargin{4};

    set(SimBrowseFig,'pointer','watch');
    Data=get(SimBrowseFig,'UserData');

    SysBlockHandles=find_system(BlockHandles,'flat','BlockType','SubSystem');

    IsSystem=~isempty(SysBlockHandles);
    IsShown=any(Data.SysHandles(Data.Mapping)==SystemHandle);
    InSelectedSystem=isequal(SystemHandle,Data.CurrentSys);

    switch Action,
      %%%%%%%%%%%
      %%% Add %%%
      %%%%%%%%%%%
      case 'Add',
        if IsSystem,
          Data=LocalCreateInfo(Data,SystemHandle);
          if IsShown,
            Data=LocalCreateSysString(Data);
          end
        end % if IsSystem

        if InSelectedSystem,
          Data=LocalSysSelectionUpdate(Data,false);
        end % if InSelectedSystem


      %%%%%%%%%%%%%%%%%%
      %%% LinkChange %%%
      %%%%%%%%%%%%%%%%%%
      case 'LinkChange',
        if IsSystem,
          Loc=find(ismember(Data.SysHandles,SysBlockHandles));
          Data.HasLibLink(Loc)= ...
            strcmp(get_param(Data.SysHandles(Loc),'LinkStatus'),'resolved');
          Data.MaskTypeString(Loc)=cellstr(...
            LocalGetMaskString(Data.HasMask(Loc),Data.HasLibLink(Loc), ...
                               Data.HasOpenFcn(Loc),Data.IsStateChart(Loc)));

          Data=LocalGetMapping(Data);
          if IsShown,
            Data=LocalCreateSysString(Data);
          end % if IsShown
        end % if IsSystem

        if InSelectedSystem,
          Loc=find(ismember(Data.Children,BlockHandles));
          Data.ChildHasLibLink(Loc)= ...
            strcmp(get_param(Data.Children(Loc),'LinkStatus'),'resolved');
          Data.ChildMaskString(Loc)=cellstr(...
            LocalGetMaskString(Data.ChildHasMask(Loc), ...
                               Data.ChildHasLibLink(Loc), ...
                               Data.ChildHasOpenFcn(Loc), ...
                               Data.ChildIsStateChart(Loc)));
          Data=LocalUpdateBlockString(Data);
        end % if InSelectedSystem


      %%%%%%%%%%%%
      %%% Mask %%%
      %%%%%%%%%%%%
      case 'Mask',
        if IsSystem,
          Loc=find(ismember(Data.SysHandles,SysBlockHandles));
          Data.HasMask(Loc)=LocalHasMask(Data.SysHandles(Loc));
          Data.MaskTypeString(Loc)=cellstr(...
            LocalGetMaskString(Data.HasMask(Loc),Data.HasLibLink(Loc), ...
                               Data.HasOpenFcn(Loc),Data.IsStateChart(Loc)));

          Data=LocalGetMapping(Data);

          if IsShown,
            Data=LocalCreateSysString(Data);
          end % if IsShown
        end % if IsSystem

        if InSelectedSystem,
          Loc=find(ismember(Data.Children,BlockHandles));
          Data.ChildHasMask(Loc)=LocalHasMask(Data.Children(Loc));
          Data.ChildMaskString(Loc)=cellstr(...
            LocalGetMaskString(Data.ChildHasMask(Loc), ...
                               Data.ChildHasLibLink(Loc), ...
                               Data.ChildHasOpenFcn(Loc), ...
                               Data.ChildIsStateChart(Loc)));
          Data=LocalUpdateBlockString(Data);
        end % if InSelectedSystem


      %%%%%%%%%%%%%%%%%%
      %%% NameChange %%%
      %%%%%%%%%%%%%%%%%%
      case 'NameChange',

        Loc=find(ismember(Data.SysHandles,SysBlockHandles));
        for lp=1:length(Loc),
          Data.NameString{Loc(lp)}=LocalGetName(Data.SysHandles(Loc(lp),1));
        end % for

        if IsSystem && IsShown,
          Data=LocalCreateSysString(Data);
        end % if IsSystem

        if InSelectedSystem,
          Loc=find(ismember(Data.Children,BlockHandles));
          for lp=1:length(Loc),
            Data.ChildNameString{Loc(lp)}= ...
              LocalGetName(Data.Children(Loc(lp),1));
          end % for
          Data=LocalUpdateBlockString(Data);
        end % if InSelectedSystem

      %%%%%%%%%%%%%%%
      %%% OpenFcn %%%
      %%%%%%%%%%%%%%%
      case 'OpenFcn',
        if IsSystem,
          Loc=find(ismember(Data.SysHandles,SysBlockHandles));
          Data.HasOpenFcn(Loc)= ...
            ~strcmp(get_param(Data.SysHandles(Loc),'OpenFcn'),'');
          Data.MaskTypeString(Loc)=cellstr(...
            LocalGetMaskString(Data.HasMask(Loc),Data.HasLibLink(Loc), ...
                               Data.HasOpenFcn(Loc),Data.IsStateChart(Loc)));

          if IsShown,
            Data=LocalCreateSysString(Data);
          end % if IsShown
        end % if IsSystem

        if InSelectedSystem,
          Loc=find(ismember(Data.Children,BlockHandles));
          Data.ChildHasOpenFcn(Loc)= ...
            ~strcmp(get_param(Data.Children(Loc),'OpenFcn'),'');
          Data.ChildMaskString(Loc)=cellstr(...
            LocalGetMaskString(Data.ChildHasMask(Loc), ...
                               Data.ChildHasLibLink(Loc), ...
                               Data.ChildHasOpenFcn(Loc), ...
                               Data.ChildIsStateChart(Loc)));
          Data=LocalUpdateBlockString(Data);
        end % if InSelectedSystem

      %%%%%%%%%%%%%%
      %%% Remove %%%
      %%%%%%%%%%%%%%
      case 'Remove',
        OldCurrentSys=Data.CurrentSys;
        if IsSystem,
          Data=LocalCreateInfo(Data,SystemHandle);
          if IsShown,
            Data=LocalCreateSysString(Data);
          end
        end % if IsSystem

        % If a parent to the current system was deleted then
        % The old current system can no longer be the new currentsys
        if isempty(find(Data.SysHandles==OldCurrentSys)),
          Data.CurrentSys=SystemHandle;
          Data=LocalSysSelectionUpdate(Data,true);

        else
          if InSelectedSystem,
            Loc=find(ismember(Data.Children,BlockHandles));
            Data.Children(Loc)=[];
            Data.ChildHasMask(Loc)=[];
            Data.ChildHasOpenFcn(Loc)=[];
            Data.ChildHasLibLink(Loc)=[];
            Data.ChildIsStateChart(Loc)=[];
            Data.ChildNameString(Loc)=[];
            Data.ChildMaskString(Loc)=[];
            Data=LocalUpdateBlockString(Data);
            Data=LocalBlockButtonDown(Data,get(Data.Browser(2),'Parent'));
          end % if InSelectedSystem
        end % if isempty


    end % switch Action

  %%%%%%%%%%%%%%%%%%%%%%%%
  %%% Peform an action %%%
  %%%%%%%%%%%%%%%%%%%%%%%%
  case 2,
    Action=varargin{1};
    SimBrowseFig=varargin{2};

    set(SimBrowseFig,'pointer','watch');
    Data=get(SimBrowseFig,'UserData');
    switch Action,
      %%%%%%%%%%%%%%%%%%%%%%%
      %%% BlockButtonDown %%%
      %%%%%%%%%%%%%%%%%%%%%%%
      case 'BlockButtonDown',
        Data=LocalBlockButtonDown(Data,SimBrowseFig);

      %%%%%%%%%%%%%
      %%% Close %%%
      %%%%%%%%%%%%%
      case 'Close',
        % Take care of close being called from command line
        if isempty(SimBrowseFig),
          SimBrowseFig=gcf;
          Data=get(SimBrowseFig,'UserData');
        end
        set(SimBrowseFig,'Visible','off');

      %%%%%%%%%%%%%%%%%%
      %%% CloseModel %%%
      %%%%%%%%%%%%%%%%%%
      case 'CloseModel',
        % The GUI is closed by the call to close the model
        set_param(Data.ModelHandle,'SimulationCommand','stop')
        close_system(Data.ModelHandle)

      %%%%%%%%%%%%%%
      %%% Delete %%%
      %%%%%%%%%%%%%%
      case 'Delete',
        % Take care of delete being called from command line
        if isempty(SimBrowseFig),
          SimBrowseFig=gcf;
          Data=get(SimBrowseFig,'UserData');
        end
        delete(SimBrowseFig)
        if ~isempty(Data),
          % Check to see if the model is still open
          if ~isempty(find_system('Handle',Data.ModelHandle)),
            LocalSafeSet_param(Data.ModelHandle,'BrowserHandle',-1);
          end
        end

      %%%%%%%%%%%%%%%%%%%%
      %%% DisplayStyle %%%
      %%%%%%%%%%%%%%%%%%%%
      case 'DisplayStyle',
        DisplayHandle=gcbo;
        Loc=get(Data.Browser(1),'Value');
        Handle=Data.SysHandles(Data.Mapping(Loc));
        if strcmp(Data.DisplayType,'Alphabetical'),
          Data.DisplayType='Hierarchy';
          set(DisplayHandle,'Label','Display Alphabetical List');
          Loc=find(Data.SysHandles==Handle);

          % LocalExpandTree expands the current system
          % This will disallow that from happening here.
          TempExpand=Data.IsExpanded(Loc);
          Data=LocalExpandTree(Data,true);
          Data.IsExpand(Loc)=TempExpand;
          set(Data.ExpandAll,'Enable','on');

        else
          Data.DisplayType='Alphabetical';
          set(DisplayHandle,'Label','Display Hierarchical List');
          set(Data.ExpandAll,'Enable','off');
        end
        Data=LocalGetMapping(Data);
        Data=LocalCreateSysString(Data);


      %%%%%%%%%%%%%%%%%
      %%% ExpandAll %%%
      %%%%%%%%%%%%%%%%%
      case 'ExpandAll',
        ShowDlg=get(Data.LookUnder(1),'Value');
        ShowLinks=get(Data.ExpandLib(1),'Value');
        ChildFlag=(Data.HasChildren(:,1) + ...
              (Data.HasChildren(:,2)*ShowDlg) + ...
              (Data.HasChildren(:,3)*ShowLinks) + ...
              (Data.HasChildren(:,4)*(ShowLinks&ShowDlg)) )>0;
        Data.IsExpanded(:)=true;
        Data=LocalGetMapping(Data);
        Data=LocalCreateSysString(Data);

      %%%%%%%%%%%%
      %%% Help %%%
      %%%%%%%%%%%%
      case 'Help',
          set(SimBrowseFig,'Pointer','watch');

          HelpCell={ ...
            'The Browser is used to view the list of systems in a'
            'block diagram.  This list may be viewed either hierarchically'
            'or alphabetically.  The list on the left side of the Browser'
            'displays the systems in the block diagram and the list on the'
            'right side of the browser displays the blocks in the'
            'currently selected system on the left.'
            ''
            'For a system, the letters inside of the brackets ([ ])'
            'indicate if the particular system has an OpenFcn ([O ]),'
            'a mask dialog ([ M ]), a library link ([  L]) or is a '
            'Stateflow chart ([S]).'
            'A checkbox is placed under the left list allows control'
            'over whether subsystems with a mask dialog are to be'
            'displayed. The other checkbox allows control over'
            'displaying the contents of linked systems.'
            ''
            'Double clicking in the listbox on the right opens the'
            'selected system.'
            ''
            'Pressing the "Look Into System" button will look'
            'under the mask of the given system and not execute'
            'the OpenFcn for that system.'
            };
          helpwin(HelpCell,'SIMBROWSE Help');

      %%%%%%%%%%%%%%%%%%%%%%
      %%% LookIntoSystem %%%
      %%%%%%%%%%%%%%%%%%%%%%
      case 'LookIntoSystem',
        LocalSafeOpen(Data,'force');

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %%% LookUnder / ExpandLinks %%%
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      case {'LookUnder','ExpandLinks'},
        LocalSetMenusAndCheckboxes(Data.LookUnder,gcbo);
        LocalSetMenusAndCheckboxes(Data.ExpandLib,gcbo);
        Data=LocalGetMapping(Data);
        NewSysFlag=false;
        while isempty(find(Data.SysHandles(Data.Mapping)==Data.CurrentSys)),
          Data.CurrentSys= ...
            get_param(get_param(Data.CurrentSys,'Parent'),'Handle');
          NewSysFlag=true;
        end
        Data=LocalCreateSysString(Data);
        if NewSysFlag,
          Data=LocalSysSelectionUpdate(Data,true);
        else
          Data=LocalUpdateBlockString(Data);
        end

      %%%%%%%%%%%%%%%%%%
      %%% OpenSystem %%%
      %%%%%%%%%%%%%%%%%%
      case 'OpenSystem',
        LocalSafeOpen(Data);

      %%%%%%%%%%%%%
      %%% Print %%%
      %%%%%%%%%%%%%
      case 'Print',
        Loc=get(Data.Browser(1),'Value');
        Handle=Data.SysHandles(Data.Mapping(Loc));
        simprintdlg(Handle);

      %%%%%%%%%%%%%%
      %%% Resize %%%
      %%%%%%%%%%%%%%
      case 'Resize',
        LocalResize(Data,SimBrowseFig);

      %%%%%%%%%%%%%%%%%%%%%
      %%% SysButtonDown %%%
      %%%%%%%%%%%%%%%%%%%%%
      case 'SysButtonDown',
        Data=LocalSysButtonDown(Data,SimBrowseFig);

      %%%%%%%%%%%%%%
      %%% Update %%%
      %%%%%%%%%%%%%%
      case 'Update',
        Data=LocalCreateInfo(Data,Data.ModelHandle);
        Data=LocalCreateSysString(Data);
        Loc=get(Data.Browser(1),'Value');
        Data.CurrentSys=Data.SysHandles(Data.Mapping(Loc));

        Data.ChildHasMask=[];
        Data.ChildHasOpenFcn=[];
        Data.ChildHasLibLink=[];
        Data.ChildIsStateChart=[];
        Data.ChildNameString={};
        Data.ChildMaskString={};
        Data=LocalSysSelectionUpdate(Data,true);

    end % switch Action

  %%%%%%%%%%%%%%%%%%
  %%% Initialize %%%
  %%%%%%%%%%%%%%%%%%
  case 1,
    if ischar(varargin{1}),
      ModelName=varargin{1};
      eval(['ErrorFlag=0;' ModelName],'ErrorFlag=1;');
      if ErrorFlag,
        eval(['ErrorFlag1=0;get_param(ModelName,''name'');'],'ErrorFlag1=1;');
        if ErrorFlag1,
          error('Invalid model name given to SIMBROWSE.');
        end
      end
      Handle=get_param(ModelName,'Handle');

    else
      if ishandle(varargin{1}),
        Handle=varargin{1};
      else
        error('Invalid handle given to SIMBROWSE.');
      end % if ishandle
    end % if ischar

    Data=LocalInitFig(Handle);

  %%%%%%%%%%%%%%%%%%
  %%% Initialize %%%
  %%%%%%%%%%%%%%%%%%
  case 0,
    if ~isempty(gcs),
      System=bdroot(gcs);
    else
      simulink3
      System='simulink3';
    end
    Handle=get_param(System,'Handle');
    Data=LocalInitFig(Handle);

  %%%%%%%%%%%%%
  %%% Error %%%
  %%%%%%%%%%%%%
  otherwise,
    error('Wrong number of input arguments for SIMBROWSE');

end % switch nargin

if ~isempty(SimBrowseFig) && ishandle(SimBrowseFig),
  set(SimBrowseFig,'UserData',Data,'Pointer','arrow');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalBlockButtonDown %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalBlockButtonDown(Data,SimBrowseFig)

Value=get(Data.Browser(2),'Value');

if isempty(Value) || isempty(Data.Children),
  set([Data.LookIntoSystem;Data.OpenSystem],'Enable','off');
  set(Data.BlockType,{'String'},{'BlockType:';''},'Enable','off');
  Data.CurrentChild=[];
  return
end
Data.CurrentChild=Data.Children(Value);

%%% The block listbox has been double clicked on
if strcmp(get(SimBrowseFig,'SelectionType'),'open') && ...
   isequal(gcbo,Data.Browser(2)),
  simbrowse('OpenSystem',SimBrowseFig);
else
  if Data.ChildHasMask(Value) || Data.ChildHasOpenFcn(Value),
    Enable='on';
  else
    Enable='off';
  end
  set(Data.LookIntoSystem,'Enable',Enable);
  set(Data.OpenSystem,'Enable','on');

  if Data.ChildHasMask(Value),
    MaskBlockType='MaskType:';
    MaskBlockTypeString=get_param(Data.Children(Value),'MaskType');
  else
    MaskBlockType='BlockType:';
    if Data.ChildIsStateChart(Value),
      MaskBlockTypeString=get_param(Data.Children(Value),'MaskType');
    else
      MaskBlockTypeString=get_param(Data.Children(Value),'BlockType');
    end
  end
  set(Data.BlockType,{'String'},{MaskBlockType;MaskBlockTypeString}, ...
                     'Enable'  ,'on');

  Blocks=find_system(Data.CurrentSys, ...
                    'FollowLinks'   ,'on'   , ...
                    'LookUnderMasks','all'   , ...
                    'SearchDepth'   ,1      , ...
                    'Type'          ,'block', ...
                    'Selected'      ,'on'     ...
                    );
  if ~isempty(Blocks),
    LocalSafeSet_param(Blocks,'Selected','off');
  end
  if ~isempty(Data.CurrentChild),
    LocalSafeSet_param(Data.CurrentChild,'Selected','on');
  end

end % switch

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalChildren %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function [HasChildren,ChildList]=LocalChildren(SysHandles)

NumHandles=length(SysHandles);

ChildList=cell(NumHandles,3);
% 1st column - handles of non-masked children
% 2nd column - handles of children with Dialog
% 3rd column - handles of children with Library link
% 4th column - handles of children with Library link and Mask

HasChildren=zeros(NumHandles,3);
% 1st column - has non-masked children
% 2nd column - has children with Dialog
% 3rd column - has children with library link
% 4th column - has children with library link and dialog

for lp=1:NumHandles,
  % Find all subsystems that are children of the current system
  TempChildren=find_system(SysHandles(lp) , ...
                          'LookUnderMasks','all'       , ...
                          'FollowLinks'   ,'on'       , ...
                          'SearchDepth'   ,1          , ...
                          'BlockType'     ,'SubSystem'  ...
                          );
  TempChildren(find(TempChildren==SysHandles(lp)))=[];

  if ~isempty(TempChildren),

    DlgLoc=LocalHasMask(TempChildren);
    % Unresolved links are blocktype reference and thus won't show
    % up in this list
    LinkChildren=find_system(TempChildren,'flat','LinkStatus','resolved');
    TempLinkLoc=find(ismember(TempChildren,LinkChildren));
    LinkLoc=false(length(TempChildren),1);
    LinkLoc(TempLinkLoc)=true;

    ChildList{lp,1}=TempChildren(~DlgLoc & ~LinkLoc);
    ChildList{lp,2}=TempChildren( DlgLoc & ~LinkLoc);
    ChildList{lp,3}=TempChildren(~DlgLoc &  LinkLoc);
    ChildList{lp,4}=TempChildren( DlgLoc &  LinkLoc);

    HasChildren(lp,1)=~isempty(ChildList{lp,1});
    HasChildren(lp,2)=~isempty(ChildList{lp,2}) | HasChildren(lp,1);
    HasChildren(lp,3)=~isempty(ChildList{lp,3}) | HasChildren(lp,1);
    HasChildren(lp,4)=~isempty(ChildList{lp,4}) | HasChildren(lp,2) | ...
                       HasChildren(lp,3);

  end % if ~isempty
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCollapseTree %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalCollapseTree(Data)
% Collapse the Tree
Value=find(Data.SysHandles==Data.CurrentSys);
Data.IsExpanded(Value)=false;
Data=LocalGetMapping(Data);
Data=LocalCreateSysString(Data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCreateBlockString %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Data,SysString]=LocalCreateBlockString(Data)

if isempty(Data.Children),
  ChildMaskString='';
  ChildNameString='';

else
  NameString=char(Data.ChildNameString);
  [BlockString,Index]=sortrows(NameString);

  % The logicals are temporary workarounds to a language bug
  Data.Children=Data.Children(Index);
  Data.ChildHasMask=logical(Data.ChildHasMask(Index));
  Data.ChildHasOpenFcn=logical(Data.ChildHasOpenFcn(Index));
  Data.ChildHasLibLink=logical(Data.ChildHasLibLink(Index));
  Data.ChildIsStateChart=logical(Data.ChildIsStateChart(Index));
  Data.ChildNameString=Data.ChildNameString(Index);
  Data.ChildMaskString=Data.ChildMaskString(Index);

  % Place Subsystems at the top of the list
  SubSystems=strcmp(get_param(Data.Children,'BlockType'),'SubSystem')& ...
                    ~Data.ChildIsStateChart;

  ShowDlg=get(Data.LookUnder(1),'Value');
  ShowLinks=get(Data.ExpandLib(1),'Value');

  if ~ShowDlg,SubSystems=SubSystems & ~Data.ChildHasMask;end
  if ~ShowLinks,SubSystems=SubSystems & ~Data.ChildHasLibLink;end

  FinalIndex=[find(SubSystems)
              find(Data.ChildIsStateChart)
              find(~SubSystems & ~Data.ChildIsStateChart)
             ];
  % The logicals are temporary workarounds to a language bug
  Data.Children=Data.Children(FinalIndex);
  Data.ChildHasMask=logical(Data.ChildHasMask(FinalIndex));
  Data.ChildHasOpenFcn=logical(Data.ChildHasOpenFcn(FinalIndex));
  Data.ChildHasLibLink=logical(Data.ChildHasLibLink(FinalIndex));
  Data.ChildIsStateChart=logical(Data.ChildIsStateChart(FinalIndex));
  Data.ChildNameString=Data.ChildNameString(FinalIndex);
  Data.ChildMaskString=Data.ChildMaskString(FinalIndex);

  ChildMaskString=char(Data.ChildMaskString);
end % if isempty

if ~isempty(ChildMaskString),
  space=' ';
  space=space(ones(length(Data.Children),1));
else
  space=[];
end

SysString=cellstr([ChildMaskString,space,char(Data.ChildNameString)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCreateInfo %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalCreateInfo(Data,StartHandle)

% This function:
% 1) Determine new handle info.
% 2) Get Indices old syshandles beneath StartHandle
% 3) Remove stale info
% 4) Insert new info
% 5) Restore expand setting


SysHandles=find_system(StartHandle    , ...
                       'LookUnderMasks','all', ...
                       'FollowLinks'   ,'on', ...
                       'BlockType'     ,'SubSystem');

if (StartHandle==Data.ModelHandle),
  SysHandles=[StartHandle;SysHandles];
  Indices=(2:length(SysHandles))';

  % The following 4 settings cover the case where there are
  % no systems in the model
  if isempty(Indices),
    HasMask=false;
    HasLibLink=HasMask;
    HasOpenFcn=HasMask;
    IsStateChart=HasMask;
  end
else
  Indices=(1:length(SysHandles))';
end

NumSysHandles=length(SysHandles);

Level=ones(NumSysHandles,1);
IsExpanded=zeros(NumSysHandles,1);
[HasChildren,ChildList]=LocalChildren(SysHandles);

HasMask(Indices,1)=LocalHasMask(SysHandles(Indices));

HasLibLink(Indices,1)= ...
  strcmp(get_param(SysHandles(Indices),'LinkStatus'),'resolved');

HasOpenFcn(Indices,1)=~strcmp(get_param(SysHandles(Indices),'OpenFcn'),'');

for HLp=NumSysHandles:-1:1,
  Level(HLp)=getlevel(SysHandles(HLp));
end % for HLp

[IsStateChart,HasMask,HasOpenFcn,HasChildren]= ...
  LocalDealWithStateflow(SysHandles,HasMask,HasOpenFcn,HasChildren);

EmptyFlag=false;

for LLp =1:NumSysHandles,
  NameString{LLp,1}=LocalGetName(SysHandles(LLp));
end % for LLp

MaskTypeString= ...
  cellstr(LocalGetMaskString(HasMask,HasLibLink,HasOpenFcn,IsStateChart));

if isempty(Data.SysHandles),
  EmptyFlag=true;
  OldData.SysHandles=[];
  OldData.IsExpanded=[];
else
  StartLoc=find(Data.SysHandles==StartHandle);
  CurLevel=Data.Level(StartLoc);
  FindLevel=find(Data.Level((StartLoc+1):end)<=CurLevel);
  if isempty(FindLevel),
    FindLevel=length(Data.SysHandles);
  else
    FindLevel=StartLoc+FindLevel(1)-1;
  end
  RemoveIndices=StartLoc:FindLevel;

  OldData.SysHandles=Data.SysHandles(RemoveIndices);
  OldData.IsExpanded=Data.IsExpanded(RemoveIndices);

  NewSysHandles    = Data.SysHandles   ; NewSysHandles(RemoveIndices)    = [];
  NewLevel         = Data.Level        ; NewLevel(RemoveIndices)         = [];
  NewHasMask       = Data.HasMask      ; NewHasMask(RemoveIndices)       = [];
  NewHasLibLink    = Data.HasLibLink   ; NewHasLibLink(RemoveIndices)    = [];
  NewIsExpanded    = Data.IsExpanded   ; NewIsExpanded(RemoveIndices)    = [];
  NewHasChildren   = Data.HasChildren  ; NewHasChildren(RemoveIndices,:) = [];
  NewIsStateChart  = Data.IsStateChart ; NewIsStateChart(RemoveIndices)  = [];
  NewHasOpenFcn    = Data.HasOpenFcn   ; NewHasOpenFcn(RemoveIndices)    = [];
  NewNameString    = Data.NameString   ; NewNameString(RemoveIndices)    = [];
  NewMaskTypeString=Data.MaskTypeString;NewMaskTypeString(RemoveIndices) = [];

  if ~isempty(NewSysHandles),
    InsertPoint=StartLoc-1;
    NewSysHandles=[NewSysHandles(1:InsertPoint)
                   SysHandles
                   NewSysHandles(InsertPoint+1:end)
                  ];
    NewLevel=[NewLevel(1:InsertPoint)
              Level
              NewLevel(InsertPoint+1:end)
             ];
    NewHasMask=[NewHasMask(1:InsertPoint)
                HasMask
                NewHasMask(InsertPoint+1:end)
               ];
    NewHasLibLink=[NewHasLibLink(1:InsertPoint)
                   HasLibLink
                   NewHasLibLink(InsertPoint+1:end)
                  ];
    NewIsExpanded=[NewIsExpanded(1:InsertPoint)
                   IsExpanded
                   NewIsExpanded(InsertPoint+1:end)
                  ];
    NewHasChildren=[NewHasChildren(1:InsertPoint,:)
                    HasChildren
                    NewHasChildren(InsertPoint+1:end,:)
                   ];
    NewIsStateChart=[NewIsStateChart(1:InsertPoint)
                     IsStateChart
                     NewIsStateChart(InsertPoint+1:end)
                    ];
    NewHasOpenFcn=[NewHasOpenFcn(1:InsertPoint)
                   HasOpenFcn
                   NewHasOpenFcn(InsertPoint+1:end)
                  ];
    NewNameString=[NewNameString(1:InsertPoint)
                   NameString
                   NewNameString(InsertPoint+1:end)
                  ];
    NewMaskTypeString=[NewMaskTypeString(1:InsertPoint)
                       MaskTypeString
                       NewMaskTypeString(InsertPoint+1:end)
                      ];
  else
    EmptyFlag=true;
  end % if ~isempty

end % if ~isempty

if EmptyFlag,
    NewSysHandles=SysHandles;
    NewLevel=Level;
    NewHasMask=HasMask;
    NewHasLibLink=HasLibLink;
    NewIsExpanded=IsExpanded;
    NewHasChildren=HasChildren;
    NewIsStateChart=IsStateChart;
    NewHasOpenFcn=HasOpenFcn;
    NewNameString=NameString;
    NewMaskTypeString=MaskTypeString;
end

Data.SysHandles=NewSysHandles;
Data.Level=NewLevel;
Data.HasMask=NewHasMask;
Data.HasLibLink=NewHasLibLink;
Data.IsExpanded=NewIsExpanded;
Data.HasChildren=NewHasChildren;
Data.IsStateChart=NewIsStateChart;
Data.HasOpenFcn=NewHasOpenFcn;
Data.NameString=NewNameString;
Data.MaskTypeString=NewMaskTypeString;

[IntHandles,IDLoc,IODLoc]=intersect(Data.SysHandles,OldData.SysHandles);
if ~isempty(IntHandles),
  Data.IsExpanded(IDLoc)=OldData.IsExpanded(IODLoc);
end

Data=LocalGetMapping(Data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCreateSysString %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalCreateSysString(Data)
% Create the string for the System Browser
if ~isempty(Data.SysHandles),
  ShowDlg=get(Data.LookUnder(1),'Value');
  ShowLinks=get(Data.ExpandLib(1),'Value');
  LevelInfo=Data.Level(Data.Mapping);
  NumVal=length(LevelInfo);

  space=' ';
  %%% Create the String %%%
  if strcmp(Data.DisplayType,'Hierarchy'),
    if     ~ShowDlg && ~ShowLinks,
      ChildFlag=Data.HasChildren(Data.Mapping,1);

    elseif  ShowDlg && ~ShowLinks,
      ChildFlag=Data.HasChildren(Data.Mapping,2);

    elseif ~ShowDlg &&  ShowLinks,
      ChildFlag=Data.HasChildren(Data.Mapping,3);

    else
      ChildFlag=Data.HasChildren(Data.Mapping,4);

    end

    % Does it have children and is it expanded or collapsed
    %43='+',45='-'
    ExpandCollapse=char(32+ChildFlag.*((Data.IsExpanded(Data.Mapping)*2)+11));
    ExpandCollapse=num2cell(ExpandCollapse,2);
    String=Data.NameString(Data.Mapping);

    for LLp =1:NumVal,
      String{LLp,1}=[...
                     space(ones(1,LevelInfo(LLp)*2)) ...
                     ExpandCollapse{LLp,1}           ...
                     space                           ...
                     String{LLp,1}
                    ];
    end % for LLp

    String=[char(Data.MaskTypeString(Data.Mapping)) char(String)];

  % Alphabetical
  else
    NameString=char(Data.NameString(Data.Mapping));
    MaskTypeString=Data.MaskTypeString(Data.Mapping);
    [NameString,Index]=sortrows(NameString);
    MaskTypeString=char(MaskTypeString(Index));
    String=[MaskTypeString NameString];
    Data.Mapping=Data.Mapping(Index);
  end % strcmp(DisplayType

else
  String='';
  Data.Mapping=[];
end % if ~isempty

% List was changed
TopDispValue=get(Data.Browser(1),{'Value','ListboxTop'});
HandleLoc=find(ismember(Data.SysHandles(Data.Mapping),Data.CurrentSys));
if isempty(HandleLoc),
  TopDispValue={1 1};
else
  TopDispValue{1}=HandleLoc;
  TopDispValue{2}=min(TopDispValue{2},HandleLoc);
end

set(Data.Browser(1), ...
   'String'                  ,cellstr(String), ...
   {'Value','ListboxTop'}    ,TopDispValue     ...
   );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalDealWithStateflow %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout=LocalDealWithStateflow(Handles,HasMask,HasOpenFcn,varargin)
%[IsStateChart,HasMask,HasOpenFcn, (HasChildren) ]= ...
%  LocalDealWithStateflow(Handles,HasMask,HasOpenFcn, (HasChildren) );

IsStateChart=logical(HasMask*0);
Loc=(HasMask&HasOpenFcn);
SFLoc=strcmp(get_param(Handles(Loc),'MaskType'),'Stateflow');
IsStateChart(Loc)=SFLoc;
HasMask(IsStateChart)=false;
HasOpenFcn(IsStateChart)=false;
varargout(1:3)={IsStateChart HasMask HasOpenFcn};

if nargin==4,
  HasChildren=varargin{1};
  HasChildren(IsStateChart,:)=false;
  varargout{4}=HasChildren;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalExpandTree %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalExpandTree(Data,StringFlag)
% Expand the Tree

Value=find(Data.SysHandles==Data.CurrentSys);
Data.IsExpanded(Value)=1;

%%% Expand all the way up the tree in case something beneath a
%%% collapsed branch has been expanded.
Level=Data.Level(Value);
while Level>=0,
  Levels=find(Data.Level(1:Value)==(Level-1));
  if ~isempty(Levels),
    Data.IsExpanded(Levels(end))=1;
    Level=Level-1;
  else
    break;
  end
end

if ~StringFlag,
  Data=LocalGetMapping(Data);
  Data=LocalCreateSysString(Data);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetFigPos %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Horiz,Vert]=LocalGetFigPos(Height,SysHandle)
% Get Initial Figure Position
Temp=get(0,'Units');
set(0,'Units','pixels');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',Temp);

SysPos=get_param(SysHandle,'Location');

Horiz=SysPos(1);
Vert=ScreenSize(4)-SysPos(2)-Height;

if Horiz>ScreenSize(3),Horiz=10;end
if Vert<0,Vert=ScreenSize(4)-Height-30;end

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetName %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function String=LocalGetName(Handle)

String=get_param(Handle,'Name');
ReturnChar=sprintf('\n');
String(String==ReturnChar)=' ';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetMaskString %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function MaskType= ...
  LocalGetMaskString(MaskVector,LibVector,OpenVector,IsStateChart)

Loc=find(MaskVector|LibVector|OpenVector|IsStateChart);

if isempty(Loc),
  MaskType=char(ones(length(MaskVector),0));
else
  space=' ';
  MaskType=space(ones(length(MaskVector),7));

  MaskType(OpenVector  ,2)='O';
  MaskType(MaskVector  ,3)='M';
  MaskType(LibVector   ,4)='L';
  MaskType(IsStateChart,5)='S';

  if ~any(IsStateChart) ,MaskType(:,5)=[];end
  if ~any(LibVector)    ,MaskType(:,4)=[];end
  if ~any(MaskVector)   ,MaskType(:,3)=[];end
  if ~any(OpenVector)   ,MaskType(:,2)=[];end

  MaskType(Loc,1)='[';
  MaskType(Loc,end-1)=']';
end % if isempty

if isempty(MaskType),MaskType=blanks(length(MaskVector))';end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetMapping %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalGetMapping(Data)

%%% Set up The String Data %%%
ShowDlg=get(Data.LookUnder(1),'Value');
ShowLink=get(Data.ExpandLib(1),'Value');

NumObjs=length(Data.SysHandles);
Data.Mapping=(1:NumObjs)';
MLoc=[];
% Dlg Button is out
if ~ShowDlg,
  MLoc=find(Data.HasMask==1);
end
if ~ShowLink,
  MLoc=unique([MLoc;find(Data.HasLibLink==1)]);
end

% Need to remove children of systems that are masked or linked if
% appropriate
IndicesRemoved=[];
while ~isempty(MLoc),
  CurLevel=Data.Level(MLoc(1));
  FindLevel=find(Data.Level((MLoc(1)+1):end)<=CurLevel);
  if ~isempty(FindLevel),
    Loc=MLoc(1)+FindLevel(1)-1;
  else
    Loc=length(Data.SysHandles);
  end % if ~isempty
  IndicesRemoved=[IndicesRemoved;(MLoc(1):Loc)'];
  MLoc(MLoc<=max(IndicesRemoved))=[];
end % while MLp

Data.Mapping(IndicesRemoved)=[];
% A hierarchical list is being used
% Need to remove children of systems that are not viewed
if strcmp(Data.DisplayType,'Hierarchy'),
  % Now to set up the hierarchy
  NumObjs=length(Data.SysHandles(Data.Mapping));
  Loc=1;
  Val=[];
  while Loc<=NumObjs,
    Val=[Val;Loc];
    if Data.IsExpanded(Data.Mapping(Loc)),
      Loc=Loc+1;
    else
      ValLevel=Data.Level(Data.Mapping(Loc));
      FindLevel=find(Data.Level(Data.Mapping((Loc+1):end))<=ValLevel);
      if ~isempty(FindLevel),
        Loc=Loc+FindLevel(1);
      else
        Loc=NumObjs+1;
      end % if ~isempty
    end % if ~
  end % while
  Data.Mapping=Data.Mapping(Val);
end % if strcmp

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalHasMask %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function MaskFlag=LocalHasMask(Systems)

MaskOn=find(strcmp(get_param(Systems,'Mask'),'on'));
DlgParams  =~strcmp(get_param(Systems(MaskOn),'MaskPromptString')  ,'');
InitString =~strcmp(get_param(Systems(MaskOn),'MaskInitialization'),'');
HelpText   =~strcmp(get_param(Systems(MaskOn),'MaskHelp')          ,'');
Description=~strcmp(get_param(Systems(MaskOn),'MaskDescription')   ,'');
DlgOrWk= DlgParams | InitString | HelpText | Description;
MaskIndices=MaskOn(DlgOrWk);
MaskFlag=zeros(length(Systems),1);
MaskFlag(MaskIndices)=1;
MaskFlag=logical(MaskFlag);

%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalResize %%%%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalResize(Data,SimBrowseFig)

set([Data.ButtonHandles Data.Browser ...
     SimBrowseFig Data.FrameHandles],'Units','pixels');

FigPos=get(SimBrowseFig,'Position');

ButtonPos=get(Data.ButtonHandles,{'Position'});
ButtonPos=cat(1,ButtonPos{:});

FramePos=get(Data.FrameHandles,{'Position'});
FramePos=cat(1,FramePos{:});

BrowserPos=get(Data.Browser,{'Position'});
BrowserPos=cat(1,BrowserPos{:});

Offset=ButtonPos(1,2);
ListWidth=BrowserPos(1,3);

NewButtonWidth=min(Data.ButtonWidth,(FramePos(1,3)-4*Offset)/3);
ButtonPos(3,1)=sum(FramePos(1,[1 3]))-NewButtonWidth-Offset;
ButtonPos(2,1)=sum(ButtonPos([1 3],1))/2;
ButtonPos(1:3,3)=NewButtonWidth;
ButtonPos(4:5,3)=min(Data.IconButtonWidth,FramePos(3,3)-2*Offset);
ButtonPos(4:5,1)=FramePos(3,1)+(FramePos(3,3)-ButtonPos(4,3))/2;

ButtonPos(:,4)=Data.ButtonHeight;

ButtonPos(6:7,3)=min(Data.BlockButtonWidth,ListWidth-2*Offset);
ButtonPos(6:7,1)=BrowserPos(2,1)+(ListWidth-ButtonPos(6,3))/2;

FigPos=get(SimBrowseFig,'Position');
FramePos(1,4)=sum(ButtonPos(1,[2 4]))+Offset;
FramePos(2,2)=sum(FramePos(1,[2 4]));
FramePos(2,4)=FigPos(4)-FramePos(2,2);
FramePos(3:4,2)=FramePos(2,2)+Offset;
ButtonPos([4 6],2)=FramePos(3,2)+Offset;
ButtonPos([5 7],2)=sum(ButtonPos(4,[2 4]));
ButtonPos(8:9,2)=sum(ButtonPos(7,[2 4]));
FramePos(3:4,4)=sum(FramePos(2,[2 4]))-FramePos(3,2)-Offset;

Vert1=sum(ButtonPos(5,[2 4]))+Offset;
Vert2=sum(ButtonPos(9,[2 4]))+Offset;
Height1=sum(FramePos(3,[2 4]))-Vert1-Offset-Data.ButtonHeight;
Height2=sum(FramePos(3,[2 4]))-Vert2-Offset-Data.ButtonHeight;

if Height1<50,Height1=50;end
if Height2<50,Height2=50;end

BrowserPos(1,[2 4])=[Vert1 Height1];
BrowserPos(2,[2 4])=[Vert2 Height2];

ButtonPos(10,2)=sum(BrowserPos(1,[2 4]));
ButtonPos(11,2)=sum(BrowserPos(2,[2 4]));

FramePos(3:4,4)=sum(ButtonPos(11,[2 4]))-FramePos(3,2)+Offset;
FramePos(2,4)=FramePos(3,4)+2*Offset;

ButtonPos=num2cell(ButtonPos,2);
BrowserPos=num2cell(BrowserPos,2);
FramePos=num2cell(FramePos,2);

set(Data.ButtonHandles,{'Position'},ButtonPos);
set(Data.FrameHandles,{'Position'},FramePos);
set(Data.Browser,{'Position'},BrowserPos);
set([Data.ButtonHandles Data.Browser ...
SimBrowseFig Data.FrameHandles],'Units','normalized');

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSafeOpen %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSafeOpen(Data,ForceOption)

Vals=get(Data.Browser(2),'Value');
for lp=1:length(Vals),
  Handle=Data.Children(Vals(lp));
  Parent=get_param(get_param(Handle,'Parent'),'Handle');

  Blocks=find_system(Parent, ...
                    'FollowLinks'   ,'on'   , ...
                    'LookUnderMasks','all'   , ...
                    'SearchDepth'   , 1     , ...
                    'Type'          ,'block', ...
                    'Selected'      ,'on'     ...
                    );
  ModelHandle=bdroot(Handle);

  LockFlag=get_param(ModelHandle,'Lock');
  set_param(ModelHandle,'Lock','off');

  if strcmp(get_param(Handle,'BlockType'),'SubSystem'),

    % The block has a mask but we're not looking under it
    if nargin==1 && strcmp(get(Data.LookIntoSystem,'Enable'),'on'),
      open_system(Parent,'force');
      LocalSafeSet_param(Blocks,'Selected','off');
      open_system(Handle);
      LocalSafeSet_param(Handle,'Selected','on');

    % Look into the system
    elseif nargin==2,
      open_system(Handle,'force');

    % Open the system or statechart
    else
      open_system(Handle);
    end % if

  else
    open_system(Parent,'force');
    LocalSafeSet_param(Blocks,'Selected','off');
    if nargin==1,
      open_system(Handle);
    else
      open_system(Handle,'force');
    end
    LocalSafeSet_param(Handle,'Selected','on');

  end % if strcmp

  set_param(ModelHandle,'Lock',LockFlag);

end % if for

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSafeSet_param %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSafeSet_param(SysHandle,Parameter,Value)
  if ~isempty(SysHandle),
    Handle=bdroot(SysHandle(1));
    LockSetting=get_param(Handle,'Lock');
    set_param(Handle,'Lock','off');
    for lp=1:length(SysHandle),
      set_param(SysHandle(lp),Parameter,Value);
    end
    set_param(Handle,'Lock',LockSetting);
  end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetMenusAndCheckboxes %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetMenusAndCheckboxes(Handles,CBHandle)
% Handles of 1 is a checkbox
% Handles of 2 is a uimenu
if isequal(CBHandle,Handles(1)),
  if isequal(get(Handles(1),'Value'),1),
    set(Handles(2),'Checked','on');
  else
    set(Handles(2),'Checked','off');
  end
elseif isequal(CBHandle,Handles(2)),
  if isequal(get(Handles(2),'Checked'),'on'),
    set(Handles(1),'Value',0);
    set(Handles(2),'Checked','off');
  else
    set(Handles(1),'Value',1);
    set(Handles(2),'Checked','on');
  end
end % if isequal

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSysButtonDown %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalSysButtonDown(Data,SimBrowseFig)

String=get(Data.Browser(1),'String');
Value=Data.Mapping(get(Data.Browser(1),'Value'));
Data.CurrentSys=Data.SysHandles(Value);

if ~isempty(Data.CurrentSys) & Value==1 & strcmp(String{1},''),return,end


switch get(SimBrowseFig,'SelectionType'),
  case 'open',
    set(SimBrowseFig,'Pointer','watch');
    if Data.IsExpanded(Value), % it's expanded or childless
      %it's got children,collapse it
      if Data.IsExpanded(Value),
        Data=LocalCollapseTree(Data);

      % It's root and has no children
      elseif (Value==1)&(~Data.IsExpanded(Value)),
        Data=LocalExpandTree(Data,false);

      end % if
    else % it's collapsed and has children
      Data=LocalExpandTree(Data,false);

    end % if

  otherwise, % Normal Selection
    Data=LocalSysSelectionUpdate(Data,true);

end % switch

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSysSelectionUpdate %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalSysSelectionUpdate(Data,UpdateAll)

if ~Data.IsStateChart(find(Data.SysHandles==Data.CurrentSys)),
  Children=find_system(Data.CurrentSys, ...
                      'FollowLinks'   ,'on', ...
                      'LookUnderMasks','all', ...
                      'SearchDepth'   ,1     ...
                      );
  % Remove SysHandle from Child list
  Children(1)=[];

  % If we're not supposed to update all children, then weed out
  % the children for which we already have information.
  if ~UpdateAll,
    Children=setdiff(Children,Data.Children);
    Children=Children(:);
    EmptyChildFlag=isempty(Children) & isempty(Data.Children);

  else
    EmptyChildFlag=isempty(Children);

  end

else
  Children=[];
  EmptyChildFlag=true;
end


if EmptyChildFlag,

  SysString={};
  Data.Children=[];
  Data.ChildHasMask=[];
  Data.ChildHasOpenFcn=[];
  Data.ChildHasLibLink=[];
  Data.ChildIsStateChart=[];
  Data.ChildNameString={};
  Data.ChildMaskString={};

else

  %%% Create the block strings %%%
  NumVal=length(Children);
  for LLp =NumVal:-1:1,
    NameString{LLp,1}=LocalGetName(Children(LLp));
  end % for LLp

  HasOpenFcn=~strcmp(get_param(Children,'OpenFcn'),'');
  HasMask=LocalHasMask(Children);
  HasLibLink=strcmp(get_param(Children,'LinkStatus'),'resolved');

  [IsStateChart,HasMask,HasOpenFcn]= ...
      LocalDealWithStateflow(Children,HasMask,HasOpenFcn);

  if UpdateAll,
    Data.Children=Children;
    Data.ChildHasMask=HasMask;
    Data.ChildHasOpenFcn=HasOpenFcn;
    Data.ChildHasLibLink=HasLibLink;
    Data.ChildIsStateChart=IsStateChart;
    Data.ChildNameString=NameString;
    Data.ChildMaskString= ...
      cellstr(LocalGetMaskString(HasMask,HasLibLink,HasOpenFcn,IsStateChart));

  else
    Data.Children=[Data.Children;Children];
    Data.ChildHasMask=[Data.ChildHasMask;HasMask];
    Data.ChildHasOpenFcn=[Data.ChildHasOpenFcn;HasOpenFcn];
    Data.ChildHasLibLink=[Data.ChildHasLibLink;HasLibLink];
    Data.ChildIsStateChart=[Data.ChildIsStateChart;IsStateChart];
    Data.ChildNameString=[Data.ChildNameString;NameString];
    Data.ChildMaskString=[Data.ChildMaskString;
      cellstr(LocalGetMaskString(HasMask,HasLibLink,HasOpenFcn,IsStateChart))];

  end % if UpdateAll

  [Data,SysString]=LocalCreateBlockString(Data);

end

if ~UpdateAll,
  Value=[];
  if ~isempty(Data.CurrentChild),
    Value=find(Data.Children==Data.CurrentChild);
  end
  if isempty(Value),Value=1;end
  ListboxTop=get(Data.Browser(2),'ListboxTop');
  StrVal={SysString Value ListboxTop};
else
  StrVal={SysString 1 1};
end

set(Data.Browser(2),{'String','Value','ListboxTop'},StrVal);
Data=LocalBlockButtonDown(Data,get(Data.Browser(2),'Parent'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalUpdateBlockString %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalUpdateBlockString(Data)

StrVal=get(Data.Browser(2),{'String','Value','ListboxTop'});
[Data,StrVal{1}]=LocalCreateBlockString(Data);

HandleLoc=find(ismember(Data.Children,Data.CurrentChild));
if isempty(HandleLoc),
  StrVal(2:3)={1 1};
else
  StrVal{2}=HandleLoc;
  StrVal{3}=min(StrVal{3},HandleLoc);
end


set(Data.Browser(2),{'String','Value','ListboxTop'},StrVal);

%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalInitFig %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function Data=LocalInitFig(Handle)
ModelName=get_param(bdroot(Handle),'name');
SimBrowseFig=findobj(allchild(0),'flat','Name',['"' ModelName '"' ' Browser']);
if ~isempty(SimBrowseFig),
  % This will make it visible and bring it to the front.
  figure(SimBrowseFig)
  Data=get(SimBrowseFig,'UserData');
  Data.CurrentSys=Handle;
  set(SimBrowseFig,'UserData',Data);
  simbrowse('Update',SimBrowseFig);
  Data=get(SimBrowseFig,'UserData');
  return
end

% Set up colors
Black=[0 0 0];

%%% Set up positions
Offset=5;

FigWidth=420;  FigHeight=340;
[FigHoriz,FigVert]=LocalGetFigPos(FigHeight,Handle);
FigPos=[FigHoriz FigVert-30 FigWidth FigHeight]; % -30 for menu

ButtonWidth=100;ButtonHeight=25;

FramePos=zeros(4,4);
FramePos(1,:)=[1 1 FigWidth-1 2*Offset+ButtonHeight-1];
FramePos(2,:)=[FramePos(1,1) sum(FramePos(1,[2 4])) ...
               FigWidth-1      FigHeight-sum(FramePos(1,[2 4]))];

ButtonPos=zeros(11,4);
ButtonPos(1,:)=[FramePos(1,1)+Offset FramePos(1,2)+Offset ...
                ButtonWidth          ButtonHeight];
ButtonPos(3,:)=[sum(FramePos(1,[1 3]))-ButtonWidth-Offset  ButtonPos(1,2) ...
                ButtonWidth                                ButtonHeight];
ButtonPos(2,:)=[sum(ButtonPos([1 3],1))/2 ButtonPos(1,2:4)];

FramePos(3,:)=[FramePos(2,1)+Offset sum(FramePos(1,[2 4]))+Offset ...
               (FramePos(1,3)-2*Offset)/2 0];
IconButtonWidth=FramePos(3,3)-2*Offset;

ButtonPos(4,:)=[FramePos(3,1)+Offset FramePos(3,2)+Offset ...
                IconButtonWidth ButtonHeight];

ButtonPos(5,:)=ButtonPos(4,:);
ButtonPos(5,2)=sum(ButtonPos(4,[2 4]));

FramePos(3,4)=sum(FramePos(2,[2 4]))-FramePos(3,2)-Offset;

FramePos(4,:)=FramePos(3,:);
FramePos(4,1)=sum(FramePos(3,[1 3]));

BlockButtonWidth=150;
ButtonPos(6,3)=BlockButtonWidth;
ButtonPos(6,:)=[FramePos(4,1)+(FramePos(4,3)-ButtonPos(6,3))/2 ...
                FramePos(4,2)+Offset BlockButtonWidth ButtonPos(1,4)];
ButtonPos(7,:)=ButtonPos(6,:)+[0 ButtonPos(6,4) 0 0];
ButtonPos(8:9,:)=ButtonPos([7 7],:);
ButtonPos(8:9,2)=sum(ButtonPos(7,[2 4]));
ButtonPos(8,1)=FramePos(4,1)+Offset;ButtonPos(8,3)=(FramePos(4,3)-2*Offset)/3;
ButtonPos(9,1)=sum(ButtonPos(8,[1 3]));ButtonPos(9,3)=ButtonPos(8,3)*2;

ListWidth=FramePos(3,3)-2*Offset;
ListPos=zeros(2,4);
ListPos(1,:)=[FramePos(3,1)+Offset sum(ButtonPos(5,[2 4]))+Offset ...
               ListWidth FramePos(3,4)-3*Offset-3*ButtonHeight];
ListPos(2,:)=[FramePos(4,1)+Offset sum(ButtonPos(9,[2 4]))+Offset ...
              ListWidth  ...
              sum(FramePos(4,[2 4]))-2*Offset- ...
                sum(ButtonPos(9,[2 4]))-ButtonHeight
             ];

TitlePos=zeros(2,4);
ButtonPos(10,:)=[ListPos(1,1) sum(ListPos(1,[2 4])) ListWidth ButtonHeight];
ButtonPos(11,:)=[ListPos(2,1) sum(ListPos(2,[2 4])) ListWidth ButtonHeight];


%%% Other Info

ButtonColor=get(0,'DefaultUicontrolBackgroundColor');
ButtonStrings={'Help';'Print...';'Close'
               'Expand [L]ibrary Links'
               'Look Under [M]ask Dialog'
               'Look Into System'
               'Open System'
               'BlockType:';'BlockTypeString'
               'Systems:';'Contents of current system:'
              };

ButtonTags={'ButtonHelp';'ButtonPrint';'ButtonClose'
            'ButtonExpandLibraryLinks'
            'ButtonLookUnderMask'
            'ButtonLookIntoSystem'
            'ButtonOpenSystem'
            'ButtonBlockType';'ButtonBlockTypeString'
            'ButtonSystem';'ButtonContents'
           };

ButtonInfo.BackGroundColor=ButtonColor;
ButtonInfo.Units='pixels';
ButtonInfo.HandleVisibility='off';
ButtonInfo.ForeGroundColor=Black;
ButtonInfo.Interruptible='off';
ButtonInfo.BusyAction='queue';

ButtonAlign={'center';'center';'center'
             'left'
             'left'
             'center'
             'center'
             'left';'left'
             'left';'left'
            };
ButtonStyle={'pushbutton' ;'pushbutton';'pushbutton'
             'checkbox'
             'checkbox'
             'pushbutton'
             'pushbutton'
             'text';'text'
             'text';'text'
            };
ButtonCall={ ...
            'simbrowse(''Help'',gcbf)'
            'simbrowse(''Print'',gcbf)'
            'simbrowse(''Close'',gcbf)'
            'simbrowse(''ExpandLinks'',gcbf)'
            'simbrowse(''LookUnder'',gcbf)'
            'simbrowse(''LookIntoSystem'',gcbf)'
            'simbrowse(''OpenSystem'',gcbf)'
            '';''
            '';''
           };

ListTags={'Systems';'Blocks'};
ListCalls={'simbrowse(''SysButtonDown'',gcbf)'
           'simbrowse(''BlockButtonDown'',gcbf)'};
ListInfo=ButtonInfo;
ListInfo.Style='listbox';
if ~isunix 
   ListInfo.BackgroundColor='white';
end

ListInfo.Max=1;
ListInfo.Value=1;
ListInfo.FontName='FixedWidth';
ListInfo.HorizontalAlignment='left';

%% Create uimenus
MenuLabels={'File'                      ;'>Print...'
            '>--'                       ;'>Close Model'
            '>Close Browser'            ;'Options'
            '>Open System';'>Look Into System';'>--'
            '>Display Alphabetical List'
            '>Expand All'               ;'>--'
            '>Look Under Mask Dialog'
            '>Expand Library Links'
           };
MenuCalls={''                                ;'simbrowse(''Print'',gcbf)'
           ''                                ;'simbrowse(''CloseModel'',gcbf)'
           'simbrowse(''Close'',gcbf)';''
           'simbrowse(''OpenSystem'',gcbf)'
           'simbrowse(''LookIntoSystem'',gcbf)'   ;''
           'simbrowse(''DisplayStyle'',gcbf)'
           'simbrowse(''ExpandAll'',gcbf)'    ;''
           'simbrowse(''LookUnder'',gcbf)'
           'simbrowse(''ExpandLinks'',gcbf)'
          };
MenuTags={'MenuFile'             ;'MenuFilePrint'
          ''                     ;'MenuFileCloseModel'
          'MenuFileCloseBrowser' ;'MenuOptions'
          'MenuOptionsOpenSystem'
          'MenuOptionsLookIntoSystem';''
          'MenuOptionsListType'
          'MenuOptionsExpandAll' ;''
          'MenuOptionsLookUnderMask'
          'MenuOptionsExpandLibraryLinks'
         };

MenuLabels = str2mat(MenuLabels{:});
MenuCalls =str2mat(MenuCalls{:});
MenuTags=str2mat(MenuTags{:});

% set up tool
SimBrowseFig=figure(                     ...
              'Color'              ,ButtonColor                   , ...
              'IntegerHandle'      ,'off'                         , ...
              'CloseRequestFcn'    ,'simbrowse(''Close'',gcbf)'   , ...
              'DeleteFcn'          ,'simbrowse(''Delete'',gcbf)'  , ...
              'HandleVisibility'   ,'off'                         , ...
              'MenuBar'            ,'none'                        , ...
              'Name'               ,['"' ModelName '"' ' Browser'], ...
              'Tag'                ,'Simulink Browser'            , ...
              'NumberTitle'        ,'off'                         , ...
              'Units'              ,'pixels'                      , ...
              'Position'           ,FigPos                        , ...
              'Resize'             ,'on'                          , ...
              'ResizeFcn'          ,'simbrowse(''Resize'',gcbf)'  , ...
              'UserData'           ,[]                            , ...
              'Colormap'           ,[]                            , ...
              'Pointer'            ,'arrow'                       , ...
              'Visible'            ,'off'                           ...
              );

MenuHandles=makemenu(SimBrowseFig,MenuLabels,MenuCalls,MenuTags);
set(MenuHandles,'HandleVisibility','off');
%set(MenuHandles(end-3),'Checked','on'); % Hierarchy

for FLp=1:size(FramePos,1),
  FrameHandles(FLp)=uicontrol(ButtonInfo   , ...
                             'Parent'      ,SimBrowseFig          , ...
                             'Style'       ,'frame'               , ...
                             'Position'    ,FramePos(FLp,:)       , ...
                             'Tag'         ,['Frame' num2str(FLp)]  ...
                             );
end

for LLp=1:length(ListTags),
  BrowserListHandles(LLp)=uicontrol(ListInfo      , ...
                                    'Parent'      ,SimBrowseFig  , ...
                                    'Position'    ,ListPos(LLp,:), ...
                                    'Tag'         ,ListTags{LLp} , ...
                                    'Callback'    ,ListCalls{LLp}, ...
                                    'String'      ,{''}            ...
                                   );
end % LLp

for BLp=1:size(ButtonTags,1),
  ButtonHandles(BLp)=uicontrol(ButtonInfo          , ...
                              'Style'              ,ButtonStyle{BLp,1}  , ...
                              'Parent'             ,SimBrowseFig        , ...
                              'Position'           ,ButtonPos(BLp,:)    , ...
                              'Tag'                ,ButtonTags{BLp,1}   , ...
                              'Callback'           ,ButtonCall{BLp,1}   , ...
                              'HorizontalAlignment',ButtonAlign{BLp,1}  , ...
                              'String'             ,ButtonStrings{BLp,1}  ...
                              );
end % BLp

set([SimBrowseFig BrowserListHandles ButtonHandles FrameHandles], ...
    'Units','normalized');

Data.BlockType=ButtonHandles(8:9);
Data.BlockButtonWidth=BlockButtonWidth;
Data.Browser=BrowserListHandles;
Data.ButtonHandles=ButtonHandles;
Data.ButtonHeight=ButtonHeight;
Data.ButtonWidth=ButtonWidth;
Data.Children=[];
Data.DisplayType='Hierarchy';
Data.ExpandAll=MenuHandles(end-2);
Data.FrameHandles=FrameHandles;
Data.ExpandLib=[ButtonHandles(4);MenuHandles(end)];
Data.LookUnder=[ButtonHandles(5);MenuHandles(end-1)];
Data.IconButtonWidth=IconButtonWidth;
Data.LookIntoSystem=[ButtonHandles(6);MenuHandles(7)];
Data.Mapping=1;
Data.ModelName=ModelName;
Data.ModelHandle=get_param(Data.ModelName,'Handle');
Data.OpenSystem=[ButtonHandles(7);MenuHandles(6)];

Data.CurrentSys=Handle;
Data.CurrentChild=[];
Data.SysHandles=[];
Data.Level=[];
Data.HasMask=[];
Data.HasLibLink=[];
Data.IsExpanded=[];
Data.HasChildren=[];
Data.IsStateChart=[];
Data.HasOpenFcn=[];
Data.NameString={};
Data.MaskString={};
Data.ChildHasMask=[];
Data.ChildHasOpenFcn=[];
Data.ChildHasLibLink=[];
Data.ChildIsStateChart=[];
Data.ChildNameString={};
Data.ChildMaskString={};

Data=LocalCreateInfo(Data,Data.ModelHandle);
Data.IsExpanded(1)=1;
Data=LocalGetMapping(Data);
Data=LocalCreateSysString(Data);
SysLoc=find(Data.SysHandles==Handle);
Loc=find(Data.Mapping==SysLoc);
set(Data.Browser(1),'Value',Loc);
Data=LocalSysSelectionUpdate(Data,true);

set(SimBrowseFig,'Visible','on','UserData',Data);

LocalSafeSet_param(Data.ModelHandle,'BrowserHandle',SimBrowseFig);
