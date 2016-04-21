function varargout = modelrefsiglog(varargin)
% MODELREFSIGLOG creates and manages the Model Reference Signal Logging Dialog

%   Copyright 2003 The MathWorks, Inc.
%   $Revision $
%   Ricardo Monteiro

 try
   persistent USERDATA;    
   mlock
   
   %%%%%%%%%%%%%%%%%%%%%%%%%
   %% Determine arguments %%
   %%%%%%%%%%%%%%%%%%%%%%%%%
   Action = varargin{1};
   args   = varargin(2:end);
   
   %%%%%%%%%%%%%%%%%%%%
   %% Process Action %%
   %%%%%%%%%%%%%%%%%%%%
   switch (Action)
    case 'Create'
     % Test for existence of java
     if ~usejava('MWT')
       error(' Model Reference Signal Logging requires Java support');
     end


      ModelRefBlockHandle = args{1};
      if(~ishandle(ModelRefBlockHandle))
        error('Invalid block handle')
        return;
      end

      isSfBlk = isStateflowBlock(ModelRefBlockHandle);
      isMrBlk = isModelrefBlock(ModelRefBlockHandle);

      if ~isSfBlk && ~isMrBlk
        error('Block must be Model Reference or Stateflow');
        return;
      end

      if isSfBlk
        ModelHandle  = bdroot(ModelRefBlockHandle);
      else
        ModelRefName =  get_param(ModelRefBlockHandle,'ModelName');    
        %% For now we will load the submodel %%
        load_system(ModelRefName);
        ModelHandle  = get_param(ModelRefName,'Handle');
      end
   
      % Check if dialog already created
      dialog_exists = 0;
      idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);
      if ~isempty(idx)
        PanelHandle   = USERDATA(idx).PanelHandle;
        dialog_exists = 1;
      end

      % Create dialog for Signal Selector block and store it
      if (dialog_exists == 0)
        PanelHandle                  = ModelRefSigLogCreate(ModelHandle, ...
                                                          ModelRefBlockHandle);
        USERDATA(end+1).ModelHandle  = ModelHandle;
        USERDATA(end).PanelHandle    = PanelHandle;
        USERDATA(end).ModelRefBlockHandle = ModelRefBlockHandle;
      end
      
      % Now make it visible
      frame = PanelHandle.getFrame;
      frame.show;
      if(nargin > 2 )
        blkHandleToShow = args{2};
        signalToShow    = args{3};
        if(ishandle(blkHandleToShow) && ischar(signalToShow))
          if(strcmp(get_param(blkHandleToShow,'BlockType') , 'ModelReferenceBlock'))
            PanelHandle.selectTreeItemFromBlockHandle(blkHandleToShow, signalToShow);
          end
        end
      end
    case 'Close'
     ModelRefBlockHandle    = args{1};              
     idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);
     if ~isempty(idx)
       PanelHandle = USERDATA(idx).PanelHandle;
       frame        = PanelHandle.getFrame;
       frame.dispose;
       USERDATA(idx) = [];
     end
    case 'Populate'    
     ModelHandle         = args{1};
     CurrentBlockHandle  = args{2};
     ModelRefBlockHandle = args{3};                                                
     idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);     
     if ~isempty(idx) 
       [varargout{1}, varargout{2}, varargout{3}, varargout{4} ,...
        varargout{5}, varargout{6},varargout{7}, varargout{8}] = DeterminePopulationData(USERDATA(idx) , args);
     end
    
    case 'Apply'
     doApply(args);   
    case 'ApplyAll'
     doApplyAll(args, USERDATA);       
    case 'GetCurrentSignals'
     varargout{1} = GetCurrentSignals(args, USERDATA);     
    case 'GetPanelHandle'
      varargout{1} =  GetPanelHandle(args, USERDATA); 
    case 'UpdateSignal'
     UpdateSignal(args, USERDATA);     
   end
 catch 
   warning(lasterr);
 end
 
%%%%%%%%%%%%%%%%%%%% 
% Helper Functions %
%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function idx = FindModelRefSigLog(UD, H)
% 
idx = [];
if ~isempty(UD)
  idx = find([UD.ModelRefBlockHandle] == H);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function panel = ModelRefSigLogCreate(modelHandle, mdlRefBlkHandle)

modelName          = get_param(modelHandle,'Name');
DialogTitle        = '';
defaultDataLogging = '';
hideModelHierPane  = false;

if isModelrefBlock(mdlRefBlkHandle)
  DialogTitle = sprintf('Model Reference Signal Logging: %s (%s)', getfullname(mdlRefBlkHandle), modelName);
  defaultDataLogging = get_param(mdlRefBlkHandle,'DefaultDataLogging');
  hideModelHierPane  = false;
else
  % Stateflow block
  DialogTitle = sprintf('Stateflow Signal Logging: %s', getfullname(mdlRefBlkHandle));
  defaultDataLogging = 'always_off';
  hideModelHierPane  = true;
end

panel = com.mathworks.toolbox.simulink.mdlrefsignallog...
        .ModelReferenceSignalLog.CreateModelReferenceSignal(modelName, ...
                                                  modelHandle, ...
                                                  mdlRefBlkHandle,...
                                                  DialogTitle,...
                                                  defaultDataLogging,...
                                                  hideModelHierPane);
                                               

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [names, logSignal, LogName, MaxPoints, ...
          Decimation, LogFramesIndv, BlockPath, DefaultDataLogging] = DeterminePopulationData(UD, args)

names      = {''};
logSignal  = [];
LogName    = {''};
MaxPoints  = [];
Decimation = [];
LogFramesIndv = [];
BlockPath  = {''};
DefaultDataLogging = '';

ModelHandle         = args{1};
SelectedObj         = args{2};
specifiedByModelRef = args{4}{1};
diveIntoRefMdls     = args{4}{2};
modelBlockRefHandle = UD.ModelRefBlockHandle;

if isModelrefBlock(modelBlockRefHandle)
  DefaultDataLogging = get_param(modelBlockRefHandle,'DefaultDataLogging');
  if(diveIntoRefMdls)
    % Refresh Signals from the Model file
    SigPropNode = get_param(modelBlockRefHandle,'UpdateSigLoggingInfo');
  end
else
  % Stateflow block
  DefaultDataLogging = 'always_off';
end

if(specifiedByModelRef)
  SigPropNode = get_param(modelBlockRefHandle,'AvailSigsDefaultProps');
else
  SigPropNode = get_param(modelBlockRefHandle,'AvailSigsInstanceProps');
end

if(isempty(SigPropNode))
  return;
end


objectType = get_param(SelectedObj,'Type');

switch objectType   
  case 'block_diagram'
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Root object was selected, show TP in root level %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    availSigs =  SigPropNode.Signals;
    numOfSigs = length(availSigs);
    for n = 1:numOfSigs
        names{n} = availSigs(n).SigName;
        logSignal(n)  =  availSigs(n).LogSignal;
        LogName{n}    =  availSigs(n).LogName;
        MaxPoints(n)  =  availSigs(n).MaxPoints;
        Decimation(n) =  availSigs(n).Decimation;
        LogFramesIndv(n) = 0;
        BlockPath{n}     = availSigs(n).BlockPath;   
    end
   
   case 'block'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Subsystem or ModelRefBlock was selected %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    thisBlockPath = getfullname(SelectedObj);

    if( feature('MultilevelModelReferenceSignalLogging'))
      PanelHandle = UD.PanelHandle;
      encPath = PanelHandle.getEncodedPathFromSelectedNode;
      encPath = char(encPath);

      [found , SigPropNode] = multi_level_signal_node_lookup(SigPropNode,...
                                                        encPath);
    
    else
      [found , SigPropNode] = single_level_signal_node_lookup(SigPropNode,...
                                                     thisBlockPath, 0);
    end
  
   
    if(found)
      numOfSigs = length(SigPropNode.Signals);
      for k = 1:numOfSigs         
        names{k}      =  SigPropNode.Signals(k).SigName;
        logSignal(k)  =  SigPropNode.Signals(k).LogSignal;
        LogName{k}    =  SigPropNode.Signals(k).LogName;
        MaxPoints(k)  =  SigPropNode.Signals(k).MaxPoints;
        Decimation(k) =  SigPropNode.Signals(k).Decimation;
        LogFramesIndv(k) = 0;
        BlockPath{k}     = SigPropNode.Signals(k).BlockPath;   
      end
    end
end
% sort all the signanmes
if isempty(MaxPoints) return, end
[names, LogName] = convertSignalNames(SigPropNode, names, LogName);
[names idx] = sort(names);
logSignal   = double(logSignal(idx));
LogName     = LogName(idx);
MaxPoints   = MaxPoints(idx);
Decimation  = Decimation(idx);
LogFramesIndv =  LogFramesIndv(idx);
BlockPath     =  BlockPath(idx);
return;   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [names, LogName] = convertSignalNames(SigPropNode, names, LogName)

for(k=1:length(SigPropNode.Signals))
  if(isempty(SigPropNode.Signals(k).SigName))
    indx = findstr(SigPropNode.Signals(k).BlockPath,'/');
    r = SigPropNode.Signals(k).BlockPath(indx(end)+1 : end);
    names{k} = [r ' : ' num2str(SigPropNode.Signals(k).PortIndex)];
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doApply(args)

ModelHandle         = args{1};
ModelRefBlockHandle = args{2};      
SigIndex = 0;
SigPropNode = get_param(ModelRefBlockHandle,'AvailSigsInstanceProps')
for i = 1:length(SigPropNode.Signals)
  if(strcmp(SigPropNode.Signals(i).BlockPath,args{10}))
    SigIndex = i;
  end
end
if(SigIndex > 0)
  SigPropNode.Signals(SigIndex).LogSignal = args{5};
  SigPropNode.Signals(SigIndex).LogName = args{6};
  SigPropNode.Signals(SigIndex).MaxPoints = str2num( args{7} );
  SigPropNode.Signals(SigIndex).Decimation =  str2num( args{8});
  set_param(ModelRefBlockHandle,'AvailSigsInstanceProps', SigPropNode);
else
  warning('Unable to update signal data');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function doApplyAll(args, USERDATA)

 if( feature('MultilevelModelReferenceSignalLogging') && ...
     ~isStateflowBlock(args{2}))
   % We are dealing with ModelRef blocks
   doMultiLevelApplyAll(args, USERDATA)
   return;
 else
   doSingleLevelApplyAll(args,USERDATA)
 end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  doSingleLevelApplyAll(args, USERDATA)

ModelHandle         = args{1};
ModelRefBlockHandle = args{2};      
sigProps            = args{3};     
changedSignals      = args{4};

SigPropNode = get_param(ModelRefBlockHandle,'AvailSigsInstanceProps')
found = 0;
   
for m=1:length(changedSignals)
  sigIdx = changedSignals{m};
  
  
  [found , referenceSigPropNode, ...
   SigPropNode] = single_level_signal_node_lookup(SigPropNode,...
                                         sigProps{sigIdx}{2}, 1);
  if(found )
    for k =1:length(referenceSigPropNode.Signals)
      if(strcmp(sigProps{sigIdx}{2}, referenceSigPropNode.Signals(k).BlockPath))
        % Log Signal
        referenceSigPropNode.Signals(k).LogSignal  = sigProps{sigIdx}{3};  
        % Log Name          
        if(isValidLogName(sigProps{sigIdx}{4}, referenceSigPropNode.Signals(k).SigName))
          errordlg('Logging name must be specified',...
                     'Signal Logging Interface');
          return;
        end
        referenceSigPropNode.Signals(k).LogName    = sigProps{sigIdx}{4};
        % Max Points
        referenceSigPropNode.Signals(k).MaxPoints  = sigProps{sigIdx}{5};
        % Decimation
        referenceSigPropNode.Signals(k).Decimation = sigProps{sigIdx}{6};
        break
      end
    end
  end    
end

set_param(ModelRefBlockHandle,'AvailSigsInstanceProps', SigPropNode);

return;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val = isValidLogName(LogName, SignaName)
% Return 1 If the signal name is empty and the logging name 
% was name was not specified
val = 0;
if(isempty(LogName) && isempty(SignaName))
 val = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  PanelHandle = GetPanelHandle(args, USERDATA)
PanelHandle = [];

ModelRefBlockHandle = args{1}; 
idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);

if ~isempty(idx) 
  PanelHandle = USERDATA(idx).PanelHandle;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sigProps = GetCurrentSignals(args, USERDATA)

sigProps = [];

ModelRefBlockHandle = args{1}; 
idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);     
if ~isempty(idx) 
   PanelHandle = USERDATA(idx).PanelHandle;
   drawnow;
   pause(2);
   sigPropsObject = PanelHandle.getCurrentSignals;
   
   for i=1:length(sigPropsObject)
     sigProps.SigName{i}   = sigPropsObject(i,1);
     sigProps.BlockPath{i} = sigPropsObject(i,2);
     sigProps.LogSignal{i} = sigPropsObject(i,3); 
     sigProps.LogName{i}   = sigPropsObject(i,4); 
     sigProps.MaxPoints{i} = sigPropsObject(i,5); 
     sigProps.Decimation{i}= sigPropsObject(i,6); 
     sigProps.LogFramesIndv{i}= sigPropsObject(i,7); 
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateSignal(args, USERDATA)


ModelRefBlockHandle = args{1}; 
sigProps =  args{2};
sigIndex =  args{3};
idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);     
if ~isempty(idx) 
 PanelHandle = USERDATA(idx).PanelHandle;
 PanelHandle.updateSignal(sigProps.SigName{sigIndex},...
                          sigProps.BlockPath{sigIndex},...
                          sigProps.LogSignal{sigIndex},...
                          sigProps.LogName{sigIndex},...
                          sigProps.MaxPoints{sigIndex},...
                          sigProps.Decimation{sigIndex},...
                          sigProps.LogFramesIndv{sigIndex});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [found , nsigNode, sigNode] = single_level_signal_node_lookup(sigNode,...
                                                                      blockPath,...
                                                                      exactPath)
% Search for a signal node given the block path
found = 0;
flatSigPropNode = sigNode.find;
nsigNode = [];

for k=1:length(flatSigPropNode)
  if(exactPath)
    for m = 1: length(flatSigPropNode(k).Signals)
      if( strcmp( flatSigPropNode(k).signals(m).BlockPath , blockPath) )
        found = 1;
        nsigNode = flatSigPropNode(k);
        return
      end 
    end
  else
    if( strcmp(flatSigPropNode(k).Path, blockPath))
      found = 1;
      nsigNode = flatSigPropNode(k);
      return
    end 
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [found, SigProp] =  multi_level_signal_node_lookup(sigPropNodeVector,... 
                                                            encPath)

found = 0;
SigProp = [];

flatSigPropNodeVector = sigPropNodeVector.find;

for i=1:length(flatSigPropNodeVector)
  [found  SigProp, signalIndex ] = findSigPropFromEncodedPath(flatSigPropNodeVector(i).Signals,...
                                                    encPath,...
                                                    found);
  if(found == 1)
    SigProp =  flatSigPropNodeVector(i);
    break
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [found , SigProp, signalIndex] = findSigPropFromEncodedPath(SigProp,...
                                                  encPath,...
                                                  found)

signalIndex = -1;
len = length(encPath);
relEncPath = [encPath '/'];
for i=1:length(SigProp)
 if(strncmp(SigProp(i).BlockPath, relEncPath, len + 1))
   found = 1;
   signalIndex = i;
   break
 end 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  doMultiLevelApplyAll(args, USERDATA)
ModelHandle         = args{1};
ModelRefBlockHandle = args{2};      
sigProps            = args{3};     
changedSignals      = args{4};
encPath             = char(args{5});
SigPropList = get_param(ModelRefBlockHandle,'AvailSigsInstanceProps')

idx = FindModelRefSigLog(USERDATA, ModelRefBlockHandle);     
if ~isempty(idx) 
   PanelHandle = USERDATA(idx).PanelHandle;   
else
  return
end

len = length(encPath);
relEncPath = [encPath '/'];
flatSigPropNodeVector = SigPropList.find;

for m=1:length(changedSignals)
  sigIdx = changedSignals{m};
  % Loop over the flat signal list
  for n=1:length(flatSigPropNodeVector)
    % Loop over the Signal nodes
    for i=1:length(flatSigPropNodeVector(n).Signals)
      
      if(strncmp(flatSigPropNodeVector(n).Signals(i).BlockPath, relEncPath, len + 1))
        % Foud the Signal Node 
        
        % Check if the stored block path is the same as the Signal Node block path
        %  sigProps{sigIdx}{2} is the stored block path in Java   
        if(strcmp(sigProps{sigIdx}{2}, flatSigPropNodeVector(n).Signals(i).BlockPath))
          % Found the signal in the Signal Node that needs to be updated     

          % Update Log Signal
          flatSigPropNodeVector(n).Signals(i).LogSignal   = sigProps{sigIdx}{3};  
          % Update Log Name
           flatSigPropNodeVector(n).Signals(i).LogName    = sigProps{sigIdx}{4};
          % Update Max Points
          flatSigPropNodeVector(n).Signals(i).MaxPoints   = sigProps{sigIdx}{5};
          % Update Decimation
          flatSigPropNodeVector(n).Signals(i).Decimation  = sigProps{sigIdx}{6};
          break        
        end             
      end     
    end
  end
end

set_param(ModelRefBlockHandle,'AvailSigsInstanceProps', SigPropList);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isSfBlk = isStateflowBlock(blkHandle)

isSfBlk = strcmp( determineBlockType(blkHandle), 'Stateflow' );
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function isMrBlk = isModelrefBlock(blkHandle)

isMrBlk = strcmp( determineBlockType(blkHandle), 'ModelReference' );
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blkType = determineBlockType(blkHandle)

blkType  = get_param(blkHandle,'BlockType');
maskType = get_param(blkHandle,'MaskType');

if(strcmp(blkType,'SubSystem') && strcmp(maskType,'Stateflow'))
  blkType = maskType;
end

%eof modelrefsiglog.m
