function varargout = sviewer(varargin)
%SVIEWER Signal viewer/Simulink communication interface.
%   SVIEWER(varargin) provides the functionality for information exchange
%   between Java-based Signal Viewer and Simulink.

%   Nikita Visnevski
%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.22.2.4 $

LookUnderMasks_str  = 'off';
FollowLinks_str     = 'off';
Warning_str         = 'Wrong argument # %d pased to <sviewer.m> - Ignored';
Dialog_name         = 'Signal Viewer';
ShowModelRefs       =  false;

%
% Extracting find_system flags 'LookUnderMasks' and
% 'FollowLinks' from input arguments.
%
if nargin > 2,
  if strcmp(varargin{3},'off') | strcmp(varargin{3},'all'), 
    LookUnderMasks_str = varargin{3};
  else,
    warndlg(sprintf(Warning_str,3),[Dialog_name ' Warning'],'modal');
  end,
end,
if nargin > 3,
  if strcmp(varargin{4},'off') | strcmp(varargin{4},'on'), 
    FollowLinks_str = varargin{4};
  else,
    warndlg(sprintf(Warning_str,4),[Dialog_name ' Warning'],'modal');
  end,
end,        

Action = varargin{1};
switch Action,
  
case 'GetModel',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Returns the handle and the name of the current 
  % or specified in varargin{2} block diagram
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (~strcmp(varargin{2}, '')),
    varargout{2} = varargin{2};
  else,
    varargout{2} = bdroot;
  end,
  
  varargout{1} = LocalGetModel(varargout{2});
  
  filter_active = varargin{5}{1};
  % Getting isEmpty flag
  if (filter_active)
    varargout{3} = LocalIsEmpty(varargout{1}, LookUnderMasks_str, FollowLinks_str, varargin{6});
  else,
    varargout{3} = LocalIsEmpty(varargout{1}, LookUnderMasks_str, FollowLinks_str);
  end,
  
  % Getting hasSubsystems flag
  ShowModelRefs = boolean(varargin{5}{2});
  varargout{4} = LocalHasSubsystems(varargout{1}, LookUnderMasks_str, FollowLinks_str, ShowModelRefs);
  % Initialize the block handles to -1
  varargout{5} = -1 * ones(1,length( varargout{1}));
case 'GetAllBlockDiagrams',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Returns arrays of handles and names of all loaded
  % or opened block diagrams.  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %f = figure;
  %h = uicontrol(f, ...
  %  'Style','text',...
  %  'string',[num2str(nargin) sprintf('\n') varargin{1} sprintf('\n') varargin{2} sprintf('\n') varargin{3} sprintf('\n') varargin{4} sprintf('\n') num2str(varargin{5}) sprintf('\n') varargin{6}],...
  %  'position',[0 0 400 400]);
  
  varargout{1} = find_system(0,'Type','block_diagram');
  if nargout > 1,
    varargout{2} = get_param(varargout{1},'Name');
    
    filter_active = varargin{5}{1};
    % Getting isEmpty flag
    if (filter_active)
      varargout{3} = LocalIsEmpty(varargout{1}, LookUnderMasks_str, FollowLinks_str, varargin{6});
    else,
      varargout{3} = LocalIsEmpty(varargout{1}, LookUnderMasks_str, FollowLinks_str);
    end,
    
    % Getting hasSubsystems flag
    ShowModelRefs = boolean(varargin{5}{2});
    varargout{4} = LocalHasSubsystems(varargout{1}, LookUnderMasks_str, FollowLinks_str, ShowModelRefs);
    varargout{5} = -1 * ones(1,length( varargout{1}));
  end,
  
case 'GetSignalName',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Returns the name of the signal varargin{2} prepended by its
  % full path in the block diagram.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [varargout{1},varargout{2}] = LocalGetSignalName(varargin{2});
  
case 'GetSubsystemLayer',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Returns arrays of handles and names of all subsystems
  % in the block diagram, specified by varargin{2}
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  ShowModelRefs             =  varargin{5};
  parentModelRefBlockHandle =  varargin{6}{1};
  rest                      = char(varargin{6}{2});
  rootH                     =  varargin{6}{3};
  [varargout{1},varargout{2},varargout{3},varargout{4}, varargout{5},  varargout{6}] = ...
      LocalGetSubsystemLayer(varargin{2}, LookUnderMasks_str, FollowLinks_str, ...
                             ShowModelRefs, parentModelRefBlockHandle, rest, rootH);

case 'GetBlockLayer',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Returns arrays of handles and names of all blocks
  % in the block diagram, specified by varargin{2}
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (~varargin{5}),
    varargout{1} = LocalGetBlockLayer(varargin{2}, LookUnderMasks_str, FollowLinks_str);
  else,
    varargout{1} = LocalGetBlockLayer(varargin{2}, LookUnderMasks_str, FollowLinks_str, varargin{6});
  end,
  if nargout > 1,
    varargout{2} = get_param(varargout{1},'Name');
    
    % Getting isEmpty flag
    if (varargin{5}),
      varargout{3} = LocalIsEmpty(varargout{1}, LookUnderMasks_str, FollowLinks_str, varargin{6});
    else,
      varargout{3} = LocalIsEmpty(varargout{1}, LookUnderMasks_str, FollowLinks_str);
    end,
    
    % Getting isASubsystem flag
    varargout{4} = LocalIsASubsystem(varargout{1});
    varargout{5} = -1 * ones(1,length( varargout{1}));
  end, 
  
case 'GetSignalLayer',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Returns following information for subsystem varargin{2}:
  %   varargout{1}  - double array of line handles;
  %   varargout{2}  - cell array of strings - signal names;
  %   varargout{3}  - cell array of strings - src block handles;
  %   varargout{4}  - cell array of strings - src port numbers;
  %   varargout{5}  - cell array of strings - Test Point property 
  %                                           values.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [varargout{1},varargout{2},varargout{3},varargout{4},varargout{5}] = LocalGetSignalLayer(varargin{2});
  
case 'GetBlockDialogParameters',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Returns block dialog parameters: 
  %   'dialogparameters', 'masknames' and 'maskstyles'
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  varargout{1} = LocalGetBlockDialogParameters(varargin{2});
  
case 'Has_Subsystems',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Returns an array of strings 'true'/'false' for aech element of
  % the array of block handles specified by varargin{2}, if this 
  % block includes subsystems.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  varargout{1} = LocalHasSubsystems(varargin{2},LookUnderMasks_str,FollowLinks_str, ShowModelRefs);
  
case 'Is_A_Subsystem',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Returns an array of strings 'true'/'false' for aech element of
  % the array of block handles specified by varargin{2}, if this 
  % block is a subsystem.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  varargout{1} = LocalIsASubsystem(varargin{2});
    
case 'Is_Empty',
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Returns an array of strings 'true'/'false' for aech element of
  % the array of block handles specified by varargin{2}, if this 
  % block is an empty block.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nargin < 4,
    varargout{1} = LocalIsEmpty(varargin{2},LookUnderMasks_str,FollowLinks_str);
  else,
    varargout{1} = LocalIsEmpty(varargin{2:end});
  end,
  
otherwise,
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Default case - Invalid action command.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  errordlg(['Invalid action command: ' Action],[Dialog_name ' Error'],'modal'); 
  
end

% [end] sviewer


%******************************************************************
%                  Start Local Functions
%******************************************************************


%= FUNCTION == LocalGetModel ======================================
%   - returns the handle of the block diagram with the name 
%     ModelName.  If this block diagram has not been loaded or 
%     is not open, it loads the block diagram without displaying it.
%==================================================================
function ModelHandle = LocalGetModel(ModelName)
  ModelHandle = find_system(0,'SearchDepth',1,'Name',ModelName);
  if isempty(ModelHandle),
    load_system(ModelName);
    ModelHandle = get_param(ModelName,'Handle');
  end,
  
% [end] LocalGetModel  


%= FUNCTION == LocalGetSignalName =================================
%   - returns the name of the signal prepended with its full path.
%==================================================================
function [SignalString,TestPointFlag] = LocalGetSignalName(SignalHandle)
  SignalSrcPort   = get_param(SignalHandle,'SrcPortHandle');
  SignalName      = get_param(SignalSrcPort,'Name');
  SignalSrcBlock  = get_param(SignalSrcPort,'Parent');
  
  if (isempty(SignalName)),
    SignalName = strcat(get_param(SignalSrcBlock,'Name'),'_Port',...
      num2str(get_param(SignalSrcPort,'PortNumber')));
  end,
  SignalString  = strcat(SignalSrcBlock,'/',SignalName);
  TestPointFlag = get_param(SignalSrcPort,'TestPoint');
  
% [end] LocalGetSignalName
  
%= FUNCTION == LocalGetSubsystemLayer =================================
%  returns the subsystem layer with ModelRef blocks if necessary
function varargout = LocalGetSubsystemLayer(sysHandle, LookUnderMasks_str, FollowLinks_str,...
                                            ShowModelRefs, pMRBlkHandle, rest, rootH)

 parentBlockModel = -1;  
 if(sysHandle == rootH)
   isSysHandleModelBlock = 0;
 else
   isSysHandleModelBlock = 1;
 end
 
 if(strcmp(get_param(sysHandle,'Type'),'block'))
   if(strcmp(get_param(sysHandle,'BlockType'),'ModelReference'))
     mdlName =get_param(sysHandle,'ModelName');
     try
       load_system(mdlName)
       subMdlHandle = get_param(mdlName,'Handle');
       parentBlockModel = sysHandle;
       sysHandle = subMdlHandle;
     end
   end
 end
 varargout{1} = find_system(sysHandle,...
                            'SearchDepth',      1,...
                            'LookUnderMasks',   LookUnderMasks_str,...
                            'FollowLinks',      FollowLinks_str,...
                            'BlockType',        'SubSystem',...
                            'Parent',           getfullname(sysHandle));
 
  v = {'false','true'};
  isModelRefBlk = zeros(1,length( varargout{1}));
  ModelRefFlag = v(isModelRefBlk+1);

  if(ShowModelRefs)
    mRefBlocks = find_system(sysHandle,...
                           'SearchDepth',      1,...
                           'LookUnderMasks',   LookUnderMasks_str,...
                           'FollowLinks',      FollowLinks_str,...
                           'BlockType',        'ModelReference',...
                           'Parent',           getfullname(sysHandle));
    if(~isempty(mRefBlocks))
      for(k = 1:length(mRefBlocks))
        varargout{1}(end + 1) = mRefBlocks(k);
        ModelRefFlag{end +1}  = 'true';
      end
    end
  end
  
  if nargout > 1,
    varargout{2} = get_param(varargout{1},'Name');    
    % Append model name to the modelReference block
    appendFlag = strcmp(get_param(varargout{1},'BlockType'),'ModelReference')
    blkNames = varargout{2};    
    if(~iscell(blkNames))
      blkNames = {blkNames}
    end

    encodedBlockFullPath = getfullname(varargout{1});   
    [encodedBlockFullPath] = LocalGetEncodedBlockFullPath(encodedBlockFullPath,... 
                                                      rest, isSysHandleModelBlock);

    for(k=1:length(appendFlag))
      if(appendFlag(k))
        blkNames{k} = [blkNames{k} '(' get_param(varargout{1}(k),'ModelName') ')']
      end
    end
    
    varargout{2} = blkNames;
    
    % Getting hasSubsystems flag
    varargout{3} = LocalHasSubsystems(varargout{1}, LookUnderMasks_str, FollowLinks_str, ShowModelRefs);

    varargout{4} = ModelRefFlag;
    parentBlockModelArray = -1 * ones(1,length( varargout{1}));
    
    if(pMRBlkHandle < 0)
      % Set the new parent block
      parentBlockModelArray(1:end) = parentBlockModel;
    else
      % Mantain the current parent block
      parentBlockModelArray(1:end) = pMRBlkHandle;
    end    
    varargout{5} = parentBlockModelArray;
    varargout{6} = encodedBlockFullPath;

  end,

%= FUNCTION == LocalGetEncodedBlockFullPath =================================
%   - returns the encoded path for SubSytem nodes or Modelreference nodes
%==================================================================  
function [encodedBlockFullPath] = LocalGetEncodedBlockFullPath(encodedBlockFullPath,rest, isSysHandleModelBlock);


    if(~iscell(encodedBlockFullPath))
      encodedBlockFullPath = {encodedBlockFullPath};      
    end

    lenRest = length(rest);
    okTogo = true;

    if(lenRest < length(encodedBlockFullPath{1}))
      if(~strcmp(rest,encodedBlockFullPath{1}(1:length(rest))))
        okTogo = true;
      else
        % This is a root node. We don't need to endode
        okTogo = false;
      end
    end

    if(okTogo)
      for(k=1:length(encodedBlockFullPath))      
        appendModelName = 0;
        if(strcmp(get_param(encodedBlockFullPath{k},'BlockType'),'ModelReference'))          
          appendModelName = 1;
          encPathModelName =  [get_param(encodedBlockFullPath{k} ,'ModelName')];
        end
        
        if(isSysHandleModelBlock)
          % Idealy we should use private_sl_decpath to get the rest
          % as follows:
          %   rest = 'mtop/MR|msub/MR|msub1'
          %   rest = private_sl_decpath(rest) 
          %   the new rest should be:
          %   rest = 'mtop/MR|msub/MR' instead of 'mtop/MR'
          idx = regexp(rest,'\|');
          if~(isempty(idx))
            rest = rest(1:idx(end)-1);
          end
          encodedBlockFullPath{k} =  [rest '|' encodedBlockFullPath{k}];
        else          
          rest = private_sl_decpath(rest);        
          encodedBlockFullPath{k} =  private_sl_encpath(rest, encodedBlockFullPath{k},'','modelref');
        end
          
        if(appendModelName)
          encodedBlockFullPath{k} =  [encodedBlockFullPath{k} '|' encPathModelName];
        end
      end
    else
      for(k=1:length(encodedBlockFullPath))
       if(strcmp(get_param(encodedBlockFullPath{k},'BlockType'),'ModelReference'))
         encodedBlockFullPath{k} = private_sl_encpath(encodedBlockFullPath{k},...
                                                      get_param(encodedBlockFullPath{k} ,'ModelName'),...
                                                      '','modelref');
       end
      end
    end
   
%= FUNCTION == LocalGetBlockLayer =================================
%   - returns an array of block handles in the subsystem 
%     varargin{1}.
%==================================================================
function BlockHandles = LocalGetBlockLayer(ParentHandle,LookUnderMasksStr,FollowLinksStr,FilterStr)
 
  %msgbox( 'LocalGetBlockLayer' ) % debug

  fsArgs = { ParentHandle,...
      'SearchDepth',      1,...
      'LookUnderMasks',   LookUnderMasksStr,...
      'FollowLinks',      FollowLinksStr,...
      'Type',             'block',...
      'Parent',           getfullname(ParentHandle)};
  %
  % If we want to add some filters to find_system, we do it in the fourth argument
  %
  if nargin > 3,
    additionalArgs = eval(['{' FilterStr '}']);
    fsArgs = { fsArgs{:} additionalArgs{:} };
  end
  
  BlockHandles = find_system(fsArgs{:});
  
  % If filters used, check for subsystems that contain filtered blocks
  if nargin > 3,
    s = find_system( ParentHandle, 'SearchDepth', 1, 'blocktype', 'SubSystem' );
    if( ~isempty( s) ),
      for i = 1:length(s),
        if( isempty( find_system( s(i), additionalArgs{:} ) ) ),
            % None in this subsystem. Kill it.
            s(i) = 0;
        end;
      end;
      BlockHandles = sort( [ BlockHandles; s( s > 0 ) ] );
      % Kill dups
      if( ~isempty( BlockHandles ) )
          BlockHandles = [ BlockHandles( diff(BlockHandles) ~= 0 ); BlockHandles(end) ];
      end;
    end;
  end
  
% [end] LocalGetBlockLayer


%= FUNCTION == LocalGetSignalLayer =================================
%   - returns signal handles and names along with src block names,
%     src port numbers, and test point flags.
%==================================================================
function [SignalHandles,SignalNames,SrcBlockNames,SrcPortNumbers,TestPointFlags] = ...
                                                              LocalGetSignalLayer(ParentObjectHandle),
                                                            
  OutPortHandles = find_system(ParentObjectHandle,...
    'FindAll',            'on',...
    'SearchDepth',        1,...
    'LookUnderMasks',     'all',...
    'Type',               'port',...
    'PortType',           'outport');
  %
  % If the subsystem is empty, we need to exit
  %
  if isempty(OutPortHandles),
    SignalHandles   = [];
    SignalNames     = cell(0);
    SrcBlockNames   = cell(0);
    SrcPortNumbers  = cell(0);
    TestPointFlags  = cell(0);
    return;
  end,
  %
  % First elements of the find_system outport list can be a top level
  % subsystem outports. In this case we need to eliminate them from our list.
  %
  if ~strcmp(get_param(ParentObjectHandle,'type'),'block_diagram'),
    parent_port_numbers   = get_param(ParentObjectHandle,'Ports');
    parent_outport_number = parent_port_numbers(2);
    OutPortHandles = OutPortHandles(parent_outport_number+1:length(OutPortHandles));
  end,
  %
  % Getting the list of line handles - signals
  %
  SignalHandles = get_param(OutPortHandles,'Line');
  % Converting from the cell array to double array
  if length(SignalHandles) > 1,
    SignalHandles = [SignalHandles{:}]';
  end,
  %
  % Getting the list of signal names
  %
  SignalNames = get_param(OutPortHandles,'Name');
  %
  % Getting src block names
  %
  SrcBlockNames = get_param(get_param(OutPortHandles,'Parent'),'Name');
  %
  % Getting src port numbers
  %
  SrcPortNumbers = get_param(OutPortHandles,'PortNumber');
  % Converting from the cell array to double array
  if length(SrcPortNumbers) > 1,
    SrcPortNumbers = [SrcPortNumbers{:}]';
  end,
  SrcPortNumbers = cellstr(strjust(int2str(SrcPortNumbers),'left'));
  %
  % Getting test point flags
  %
  TestPointFlags = get_param(OutPortHandles,'TestPoint');
  
% [end] LocalGetSignalLayer


%= FUNCTION == LocalGetBlockDialogParameters ======================
%   - returns an array of strings with block dialog parameters.
%     If the block is a masked subsystem, this is an array of 
%     mask dialog parameters.
%==================================================================
function BlockDialogParams = LocalGetBlockDialogParameters(BlockHandle),

  if isequal(get_param(BlockHandle,'Type'),'block_diagram'),
    BlockDialogParams = {};
    return;
  end,
  
  BlockParamStruct = get_param(BlockHandle,'MaskPrompts');
  if isempty(BlockParamStruct),
    BlockParamStruct      = get_param(BlockHandle,'DialogParameters');
    if isempty(BlockParamStruct),
      % returning an empty numerical array
      BlockDialogParams = [];
      return;
    else,
      BlockParamFieldNames  = fieldnames(BlockParamStruct);
      BlockEditParamNum     = [];
      j = 1;
      for i=1:length(BlockParamFieldNames),
        ParamFieldData = getfield(BlockParamStruct,BlockParamFieldNames{i});
        paramType = ParamFieldData.Type;
        if strcmp(paramType,'string'),
          BlockEditParamNum(j) = i;
          j=j+1;
        end,
      end,
    end,
  else,
    BlockParamNameStruct  = get_param(BlockHandle,'MaskNames');
    BlockParamFieldNames  = strcat(BlockParamStruct,' (',BlockParamNameStruct,')');
    BlockEditParamNum     = find(strcmp(get_param(BlockHandle,'MaskStyles'),'edit'));
  end,  
  
  BlockDialogParams = BlockParamFieldNames(BlockEditParamNum);
  
% [end] LocalGetBlockDialogParameters


%= FUNCTION == LocalHasSubsystems =================================
%   - returns an array of strings 'true'/'false' for aech element 
%     of ReferenceHandles, if this element is a handle of a block
%     which contains subsystems.
%==================================================================
function FlagStrings = LocalHasSubsystems(ReferenceHandles,LookUnderMasksStr,FollowLinksStr, ShowModelRefs);
  FlagStrings = cell(size(ReferenceHandles));

  %msgbox( 'LocalHasSubsystems' ) % debug
  tf = { 'false', 'true' };  
  modelRefName = {}
  for i=1:length(ReferenceHandles),    
    has_subsystems(i) = ~isempty(find_system(ReferenceHandles(i),...
                          'LookUnderMasks',     LookUnderMasksStr,...
                          'FollowLinks',        FollowLinksStr,...
                          'BlockType',          'SubSystem',...
                          'Parent',             getfullname(ReferenceHandles(i))));
  end

  if(ShowModelRefs)
    for i=1:length(ReferenceHandles),
      has_modelreferences(i) = ~isempty(find_system(ReferenceHandles(i),...
                                 'LookUnderMasks',     LookUnderMasksStr,...
                                 'FollowLinks',        FollowLinksStr,...
                                 'BlockType',          'ModelReference',...
                                  'Parent',             getfullname(ReferenceHandles(i))));
      
      sub_modelHasSubSys(i) = 0;
      sub_modelHasModelRef(i) = 0;
      modelRefName{i} = '';
      if(strcmp(get_param(ReferenceHandles(i),'Type'),'block'))
        if(strcmp(get_param(ReferenceHandles(i),'BlockType'),'ModelReference'))
          modelRefName{i} = get_param(ReferenceHandles(i),'ModelName');
          try
            load_system(modelRefName{i})
            sub_modelHasSubSys(i) =   ~isempty(find_system(modelRefName{i},...
                                                         'LookUnderMasks',     LookUnderMasksStr,...
                                                         'FollowLinks',        FollowLinksStr,...
                                                         'BlockType',          'SubSystem',...
                                                         'Parent',             getfullname(modelRefName{i})));
          
            sub_modelHasModelRef(i) =   ~isempty(find_system(modelRefName{i},...
                                                         'LookUnderMasks',     LookUnderMasksStr,...
                                                         'FollowLinks',        FollowLinksStr,...
                                                         'BlockType',          'ModelReference',...
                                                         'Parent',             getfullname(modelRefName{i})));
          
          end
        end
      end
    end

    % ModelRef becomes a node if the model has a subsystem or a model ref inside       
    sub_modelHasSubSys = or(sub_modelHasModelRef,sub_modelHasSubSys);
    has_subsystems = or(sub_modelHasSubSys,has_subsystems);
    lenSub  =  length(has_subsystems);
    lenMRef =  length(has_modelreferences);
    
    if(lenSub > lenMRef)
      has_modelreferences(lenSub) = 1; 
    elseif(lenSub < lenMRef)
      has_subsystems(lenMRef) = 1;
    end
    
    has_subsys_and_modelref =  or(has_subsystems,has_modelreferences);
    FlagStrings = tf( has_subsys_and_modelref+1);
  else    
    FlagStrings = tf(has_subsystems+1);
  end
  
% [end] LocalHasSubsystems
  
  
%= FUNCTION == LocalIsASubsystem ==================================
%   - returns an array of strings 'true'/'false' for aech element
%     of ReferenceHandles, if this element is a handle of a 
%     subsystem.
%==================================================================
function FlagStrings  = LocalIsASubsystem(ReferenceHandles),
  FlagStrings = cell(size(ReferenceHandles));
  
  %
  % Top level block diagrams do not have 'BlockType' parameter.
  % We need to do try - catch to be able to handle this case.
  %

  %msgbox( 'LocalIsASubsystem' ) % debug
  try,
    fsRet = get_param(ReferenceHandles,'BlockType');
    if ~iscell(fsRet), fsRet = { fsRet }; end;
    is_a_subsystem = strcmp(fsRet, 'SubSystem');
  catch,
    is_a_subsystem = zeros(size(ReferenceHandles));
  end,
  
  tf = { 'false', 'true' };
  FlagStrings = tf(is_a_subsystem+1);
  
% [end] LocalIsASubsystem
  
  
%= FUNCTION == LocalIsEmpty========================================
%   - returns an array of strings 'true'/'false' for aech element 
%     of ReferenceHandles, if this element is a handle of a block
%     which is empty.
%==================================================================
function FlagStrings  = LocalIsEmpty(ReferenceHandles,LookUnderMasksStr,FollowLinksStr,FilterStr),
  FlagStrings         = cell(size(ReferenceHandles));
  is_empty            = zeros(size(ReferenceHandles));

  %msgbox( { 'LocalIsEmpty: ', num2str((ReferenceHandles(:)))} ) % debug
   fsArgs = { ...
      'LookUnderMasks',   LookUnderMasksStr,...
      'FollowLinks',      FollowLinksStr,...
      'Type',             'block' };
     
  %
  % If we want to add some filters to find_system, we do it in the fourth argument
  %
  if nargin > 3,
    additionalArgs = eval(['{' FilterStr '}']);
  else,
    additionalArgs = {};
  end,
  
  % See if there are any blocks in each system that match the given
  % property value pairs. 
  % Note: Don't count reference handles
  for i=1:length(ReferenceHandles),
    is_empty(i) = ~any( find_system( ReferenceHandles(i), fsArgs{:}, additionalArgs{:} ) ~= ReferenceHandles(i) );% ...
%                    & bdroot( ReferenceHandles(i) ) ~= ReferenceHandles(i);
%   *** This line caused errors, but was put in for a reson that I can't recall ***
%   *** Check here if model systems show up as empty when they are not! ***
  end,
  
  
  tf = { 'false', 'true' };
  FlagStrings = tf(is_empty+1);
  %msgbox( {'localIsEmpty', FlagStrings{:} } ) % debug

% [end] LocalIsEmpty
  
% [EOF] sviewer.m


