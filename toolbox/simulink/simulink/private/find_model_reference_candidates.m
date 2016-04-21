function [sortedCandidateList,...
          candidateListNameOnly] = find_model_reference_candidates(topModel,...
                                                  candidateListIn,...
                                                  lookInsideThisSystem)
% find_model_reference_candidates: Find subsystems that can be converted to Models
%
% Return a list of subsystems in the model passed in that are good
% candidates for conversion to model reference
%
% This function performs the following steps:
%    (1) If no initial list is passed in, use a find_system command to 
%        find an initial list of candidates. 
%    (2) Pruned the list of the subsystems that do not meet all of the 
%        following criteria:
%         (a) Not a simulink library block
%         (a) Plain atomic subsystem (i.e. it has no enable, trigger, or 
%             action ports or for, or while blocks)
%         (b) Is not masked other than a purely graphical mask
%         (c) If the system contains a Stateflow chart, the machine cannot have 
%             any machine parented data, machine parented events, or any 
%             exported graphical functions
%         (d) Does not have function-call outputs
%         (e) Does not have a constant input port
%         (f) If the system is a link, all other instances of that link must
%             not be under a mask other than a purely graphical one
%         (g) If the system is a link, all other instances of that link must
%             have the same structural checksum (a.k.a. the code reuse checksum)
%    (3) Sort the subsystems so that the most deeply nested are processed
%        first. This ensures that when a subsystem is converted to a model
%        it will be known if any of the subsystems it contains should be
%        changed to model blocks
%
%   $Revision: 1.1.6.9 $
 
  % Initialize the output
  sortedCandidateList = [];
  candidateListNameOnly = [];
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% STEP 1: Find the initial list of subsystems %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ( (length(candidateListIn) >1) || ...
       ( (length(candidateListIn)==1) && ...
         (lookInsideThisSystem == false) ) )
    % We know the candidate list because either:
    % (1) we have more than one candidate in the list, or
    % (2) we are not looking in the candidate passed in for further candidates
    candidateList = candidateListIn;
  else
    % Either no candidate was specified, or one was and we were instructed to 
    % look inside it for other potential systems to convert,
    % either way we'll do a find system to find the list of candidate subsystems
    if lookInsideThisSystem
      systemToSearchIn = get_param(candidateListIn,'Handle');
    else
      systemToSearchIn = topModel.Handle;
    end
    
    % Atomic subsystems only, following links, and looking under 
    % graphical masks
    if (slfeature('ModelReferenceConversionTesting') == 0)
      candidateList = find_system(systemToSearchIn,...
                                  'FollowLinks','on',...  
                                  'LookUnderMasks','graphical',...
                                  'BlockType','SubSystem',...
                                  'TreatAsAtomicUnit','on');
    else
      candidateList = find_system(systemToSearchIn,...
                                  'FollowLinks','on',...  
                                  'LookUnderMasks','graphical',...
                                  'BlockType','SubSystem'); 
    end

    if lookInsideThisSystem
      % Add the handle for the system passed in to the list
      candidateList(end+1) = systemToSearchIn;
    end      
    
    if ~isempty(candidateList)
      % Remove empty subsystems
      blks = get_param(candidateList,'Blocks');
      
      newList = [];
      if ~isempty(blks)
        j = 1; 
        for iCheck = 1 : length(candidateList)
          if ~isempty(blks{iCheck})
            newList(j) = candidateList(iCheck);
            j = j + 1;
          end
        end
      end
      candidateList = newList;
    end
  end

  disp(['Original number of systems to convert is ',...
        sprintf('%d',length(candidateList))]);
  if isempty(candidateList)
    return;
  end
   
  if ~ishandle(candidateList)
    %assertion check
    error('ModelRefConv:Fatal',...
          ['Fatal Error: find_model_reference_candidates: ',...
           'candidateList is not handles']);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% STEP 2:  Remove anything in the simulink library %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  toremove = [];
  for i=1:length(candidateList)
    if (strfind(get_param(candidateList(i),'ReferenceBlock'),'simulink/') == 1)
      toremove=[toremove,i];
    end
  end
  candidateList(toremove) = [];
  disp([sprintf('\n'),...
        sprintf('%d',length(candidateList)),...
        ' remain after removing simulink library blocks']);
  if isempty(candidateList)
    return;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% STEP 3: Remove any systems with enable, trigger, for, etc. %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  toremove = [];
  for i=1:length(candidateList)
    if ~(isplainatomicss(candidateList(i)))
      toremove=[toremove,i];
    end
  end
  candidateList(toremove) = [];
  disp([sprintf('\n'),...
        sprintf('%d',length(candidateList)),...
        ' remain after removing systems with enable, trigger, for, etc.']);
  if isempty(candidateList)
    return;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% STEP 4: Remove masked systems with variables because we do not %%
  %%         handle parameters                                      %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  toremove = [];
  for i=1:length(candidateList)
    if ~(isempty(get_param(candidateList(i), 'MaskNames')) && ...
       isempty(deblank(get_param(candidateList(i),'MaskInitialization'))))
      toremove=[toremove,i];
    end
  end
  candidateList(toremove) = [];
  disp([sprintf('\n'),...
        sprintf('%d',length(candidateList)),...
        ' remain after removing systems with masks that are ',...
        'not purely graphical']);
  if isempty(candidateList)
    return;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% STEP 5: Remove any systems that contain assignment blocks that are %%
  %%         not in an iterator subsystem                               %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  toremove = [];
  for i=1:length(candidateList)
   if has_assign_iterator_issue(candidateList(i))
     toremove=[toremove,i];
   end
  end
  candidateList(toremove) = [];
  disp([sprintf('\n'),...
        sprintf('%d',length(candidateList)),...
        ' remain after removing systems with assignment blocks that are not in iterator subsystems']);
  if isempty(candidateList)
    return;
  end

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% STEP 6:  Remove anything with stateflow issues                   %%
  %%          Stateflow issues:                                       %%
  %%            - machine parented data or events for non-link charts %%
  %%            - exported graphical functions for any charts         %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  hasDataOrEvents = machine_has_data_or_events(topModel.Handle);
  hasFuncs = model_has_exported_funcs(topModel.Name);
  toremove = [];
  for i=1:length(candidateList)
    if ~stateflowAllowsPartioning(candidateList(i), hasFuncs, hasDataOrEvents)
      toremove=[toremove,i];
    end
  end
  candidateList(toremove) = [];
  disp([sprintf('\n'),...
        sprintf('%d',length(candidateList)),...
        ' remain after removing systems with Stateflow when the machine ',...
        'has machine parented data or events, or there are exported ',...
        'graphical functions']);
  if isempty(candidateList)
    return;
  end
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% STEP 7: Remove any systems with function-call outputs %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  toremove = [];
  for i=1:length(candidateList)
    portDataTypes = get_param(candidateList(i),'CompiledPortDataTypes');
    outDataTypes = portDataTypes.Outport;
    for j=1:length(outDataTypes)
      if strcmp(outDataTypes(j),'fcn_call')
        toremove=[toremove,i];
      end
    end
  end
  candidateList(toremove) = [];
  disp([sprintf('\n'),...
        sprintf('%d',length(candidateList)),...
        ' remain after removing systems with function call outputs']);
  if isempty(candidateList)
    return;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% STEP 8: Remove any systems with constant inputs %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  toremove = [];
  for i=1:length(candidateList)
    if has_const_input(candidateList(i))
      toremove=[toremove,i];
    end
  end
  candidateList(toremove) = [];
  disp([sprintf('\n'),...
        sprintf('%d',length(candidateList)),...
        ' remain after removing systems with constant inputs']);
  if isempty(candidateList)
    return;
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% STEP 9: Remove any systems with with data stores        %%
  %%         crossing system boundaries or assignment blocks %% 
  %%         checking the iteration number of an iterator    %%
  %%         block                                           %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  toremove = [];
  for i=1:length(candidateList)
    compiledInfo = get_param(candidateList(i),'CompiledRTWSystemInfo');
    if (compiledInfo(5) > 0)
      toremove=[toremove,i];
    end
  end
  candidateList(toremove) = [];
  disp([sprintf('\n'),...
        sprintf('%d',length(candidateList)),...
        ' remain after removing systems with Data Store Read/Write/Memory',... 
        ' or Assignment/Iterator block sets crossing the system boundary']);
  if isempty(candidateList)
    return;
  end
   
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  %% Step 10: Remove any systems that are Reference Blocks if any  %%
  %%          other instances of the ReferenceBlock have different %% 
  %%          checksums or are under masks                         %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  refBlk = get_param(candidateList,'ReferenceBlock');
  [sortRefBlk,idx] = sort(refBlk);
  numCands = length(candidateList);
  toremove = [];
  i = 1;
  while i<numCands
    if isempty(sortRefBlk{i})
      % Not a link - nothing to do - go on to the next block
      i=i+1;
    else
      j = i+1;
      thisGroup =idx(i);
      while strcmp(sortRefBlk(i),sortRefBlk(j))
        thisGroup = [thisGroup,idx(j)];
        j = j+1;
        if j>numCands
          break
        end
      end
      allReferences = find_system(topModel.Handle,...
                                  'FollowLinks','on',...  
                                  'LookUnderMasks','all',...
                                  'ReferenceBlock',sortRefBlk{i});
      nonMaskedReferences = find_system(topModel.Handle,...
                                        'FollowLinks','on',...  
                                        'LookUnderMasks','graphical',...
                                        'ReferenceBlock',sortRefBlk{i});

      if ( (length(allReferences) ~= length(nonMaskedReferences)) || ...
           (length(allReferences) ~= length(thisGroup)) )
        % There are instances of this reference under a mask so remove it
        toremove = [toremove, thisGroup];
      else
        % Check the checksums
        if length(allReferences) > 1
          checksums = get_param(allReferences,'StructuralChecksum');
          for k=1:length(allReferences)
            if checksums{k} ~= checksums{1}
              toremove = [toremove, thisGroup];
              break;
            end
          end
        end
      end
      i = j;
    end
  end
  candidateList(toremove) = [];
  disp([sprintf('\n'),...
        sprintf('%d',length(candidateList)),...
        ' remain after removing systems where different instances ',...
        'of the link have different structural checksums or some ',...
        'instances of the link are under masks (other than purely ',...
        'graphical masks)']);
  if isempty(candidateList)
    return;
  end
    
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% STEP 10: Sort so deepest are first %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  depth = zeros(length(candidateList),1);
  for i=1:length(candidateList)
    depth(i) = calcNestingLevel(candidateList(i),topModel.Handle);
  end
  [notNeeded,idx]=sort(depth,1,'descend');

  candidateListNameOnly = getfullname(candidateList(idx));

  for i=1:length(idx)
    sortedCandidateList(i).Handle   = candidateList(idx(i));
    sortedCandidateList(i).Name     = get_param(candidateList(idx(i)),'name');
    sortedCandidateList(i).FullName = getfullname(candidateList(idx(i)));
    sortedCandidateList(i).RefBlock = get_param(candidateList(idx(i)),...
                                                'ReferenceBlock');
    sortedCandidateList(i).Checksum = get_param(candidateList(idx(i)),...
                                                    'StructuralChecksum');
  end

  return  
  
%%%%%%%%%%%%%%%%%%%%% 
%% LOCAL FUNCTIONS %%
%%%%%%%%%%%%%%%%%%%%% 
  
%%%%%%%%%%%%%%%%%%%%
% calcNestingLevel %
%%%%%%%%%%%%%%%%%%%%
function depth = calcNestingLevel(blkH,mdlH)
  
  depth = 0;
  parentH = get_param(get_param(blkH,'Parent'),'Handle');
  while (parentH ~= mdlH)
    depth = depth+1;
    parentH = get_param(get_param(parentH,'Parent'),'Handle');
  end
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% machine_has_data_or_events %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hasDataOrEvents = machine_has_data_or_events(modelHandle)
  modelH = get_param(modelHandle, 'uddobject');

  dataH = modelH.find('-depth', 1, '-isa', 'Stateflow.Data');
  eventH = modelH.find('-depth', 1, '-isa', 'Stateflow.Event');

  hasDataOrEvents = ~isempty(dataH) | ~isempty(eventH);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% model_has_exported_funcs %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hasFuncs = model_has_exported_funcs(modelName)

  hasFuncs = 0;

  sf('Private', 'machine_bind_sflinks', modelName);
  machines = sf('Private', 'get_link_machine_list', modelName, 'sfun');

  if has_exported_funcs(modelName)
    hasFuncs = 1;
    return;
  end

  for i = 1:length(machines)
    if has_exported_funcs(machines{i})
      hasFuncs = 1;
      return;
    end
  end

%  model_has_exported_funcs helper function
function hasFuncs = has_exported_funcs(modelName)
  hasFuncs = 0;
  modelH = get_param(modelName, 'uddobject');
  charts = modelH.find('-isa', 'Stateflow.Chart');
  charts = find(charts, 'ExportChartFunctions', 1);

  for i = 1:length(charts)
    chart = charts(i);
    functions = chart.find('-depth', 1, '-isa', 'Stateflow.Function');
    if ~isempty(functions)
      hasFuncs = 1;
      return;
    end
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stateflowAllowsPartioning %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function disallows partitioning if there are any charts that
% could possibly use exported graphical functions, machine parented data,
% or machine parented events. It would be nice to determine if the chart
% actually uses such things. This determination requires an enhancement to
% Stateflow and has been gecked as 174207
function isPartionable = stateflowAllowsPartioning(subsysH, ...
                                                modelHasExportedFcns,...
                                                machineHasDataOrEvents)
  % The second and third arguments are determined by the model and so
  % are computed once (by the functions above) and passed into this
  % function along with the subsystem we are currently considering as
  % a candidate

  if modelHasExportedFcns
    % exported functions can be used by any chart (link chart or otherwise)
    % so we need to follow links in looking for charts
    sfBlcks = find_system(subsysH, 'FollowLinks','on',...
                          'LookUnderMasks','on',...
                          'MaskType','Stateflow');
  elseif machineHasDataOrEvents
    % Link charts cannot use machine parented data or events so we 
    % do not need to follow links when looking for the existence of charts
    sfBlcks = find_system(subsysH, 'LookUnderMasks','on',...
                          'MaskType','Stateflow', ...
                          'ReferenceBlock', '');
  else
    % If there are no exported functions, and no machine parented data
    % then we do not care if there are any charts (they won't preclude
    % the partitioning so don't bother doing the find_system
    sfBlcks = [];
  end

  isPartionable = isempty(sfBlcks);
  

%%%%%%%%%%%%%%%%%%%  
% isplainatomicss %
%%%%%%%%%%%%%%%%%%%
function [result,message] = isplainatomicss(blockH)
% Check that the subsystem is a simple subsystem (no triggers, fors, etc.)

  ssPorts = get_param(blockH,'PortHandles');
  
  % enable, trigger/function, action ports
  if (~isempty(ssPorts.Enable) || ...
      ~isempty(ssPorts.Trigger) || ...
      ~isempty(ssPorts.Ifaction) )
    if nargout == 2
      message = 'Model reference does not support control ports on the model';
    end
    result = false;
    return;
  end
  
  %State ports
  if(~isempty(ssPorts.State))
    if nargout == 2
      message = 'Model reference does not support state ports';
    end
    result = false;
    return;
  end
  
  %Physmod 
  if(~isempty(ssPorts.LConn) || ...
     ~isempty(ssPorts.RConn) )
    if nargout == 2
      message = ['The selected system expresses connection ports. ', ...
                 'Model reference is not supported for portions of ',...
                 'physical models. The physical model must exist ',...
                 'entirely within a subsystem.'];
    end
    result = false;
    return;
  end

  % For/while
  if (~isempty(find_system(blockH,'SearchDepth',1,...
                           'FollowLinks','on',...
                           'BlockType','WhileIterator')) || ...
      ~isempty(find_system(blockH,'SearchDepth',1,...
                           'FollowLinks','on',...
                           'BlockType','ForIterator')))
    if nargout == 2
      message = ['Model reference does not support for or while blocks',...
                 'at the top level of the model'];
    end
    result = false;
    return
  end
  
  % Stateflow
  if strcmp(get_param(blockH,'MaskType'),'Stateflow')
    result = false;
    if nargout == 2
      message = ['Model reference does not support Stateflow',...
                 'at the top level of the model'];
    end
    return
  end

  result = true;
  message = [];

function hasAssignIteratorIssue =  has_assign_iterator_issue(sysH)
  
  hasAssignIteratorIssue = false;
  
  assignBlks = find_system(sysH,...
                           'LookUnderMasks','all',...
                           'FollowLinks','on',...
                           'BlockType','Assignment');
  
  for assignIdx = 1: length(assignBlks)
    foundIterBlk = false;
    par  = get_param(assignBlks(assignIdx),'Parent');
    parSysH = get_param(par,'Handle');
  
    while(parSysH ~= sysH)

      if (~isempty(find_system(parSysH,'SearchDepth',1,...
                               'FollowLinks','on',...
                               'BlockType','WhileIterator')) || ...
          ~isempty(find_system(parSysH,'SearchDepth',1,...
                               'FollowLinks','on',...
                               'BlockType','ForIterator')))
        foundIterBlk = true;
        return
      end
      par = get_param(parSysH,'Parent');
      parSysH = get_param(par,'Handle');
    end
    if ~foundIterBlk
      hasAssignIteratorIssue = true;
      return
    end
  end
  
%endfunction

function   hasConstInput = has_const_input(candidateSys)
  hasConstInput = false;
  inBlkHs = find_system(candidateSys,...
                       'FollowLinks','on',...
                       'LookUnderMasks','all',...
                       'SearchDepth',1,...
                       'BlockType','Inport');
  for inIdx=1:length(inBlkHs)
    compTs = get_param(inBlkHs(inIdx),'CompiledSampleTime');
    if isinf(compTs(1))
      hasConstInput = true;
      break
    end
  end
