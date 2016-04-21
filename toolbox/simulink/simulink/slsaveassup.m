function slsaveassup(modelName, saveAsName, saveAsVersion, breakLinks) 
%SLSAVEASSUP Support file used by save_system to convert models to a 
%   previous version.
%   This function is used internally by Simulink and is not meant to
%   be invoked directly on the command line.
%
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $

% Check number of arguments
  if (nargin ~= 4)
    error('Wrong number of input arguments to slsaveas.');
  end
        
  % Check for valid versions
  validVersions = {'SAVEAS_R13SP1', 'SAVEAS_R13', 'SAVEAS_R12', 'SAVEAS_R12P1'};
  if ~any(strcmp(saveAsVersion, validVersions))
    error(['Invalid version in slsaveas.m', saveAsVersion]);
  end
  
  UpdateModel(modelName, saveAsName, saveAsVersion, breakLinks);
  
% Function: UpdateModel ========================================================
% Abstract: 
%      Convert a model into R13/R12x. This preprocessing code is common to all
% versions. 
%
function UpdateModel(modelName, saveAsName, saveAsVersion, breakLinks)

  validVersions = {'SAVEAS_R13SP1', 'SAVEAS_R13', 'SAVEAS_R12', 'SAVEAS_R12P1'};
  
  % Create the Simulink translator object
  obj = Simulink.Translator(saveAsVersion);
  if isempty(obj)
    error('Could not create the Simulink Translator object');
  end

  % Get the full path versions of the model name.
  modelNameFullPath = which(modelName);
  
  % Get the full path version of the saveas name.
  fpos = findstr(saveAsName, filesep);
  if isempty(fpos)
    % If there is no path, use the current working directory.
    saveAsNameFullPath = addPath(saveAsName, pwd);
    saveAsNameFullPath = addExtension(saveAsNameFullPath);
  else
    saveAsNameFullPath = addExtension(saveAsName);
  end
  
  if (exist(modelNameFullPath) ~= 4) && (exist(modelNameFullPath) ~= 2)
    error(['Unable to find the model file named ' modelName])
    return;
  end
  
  % Create a temp. file
  tempFileFullPath = [tempname, '.mdl'];
  
  % Copy over the current model into the temp model
  copyfile(modelNameFullPath, tempFileFullPath, 'writable'); 
  fileattrib(tempFileFullPath,'+w');
    
  % turn off the following features
  mdlInterface = slfeature('AlwaysSaveModelInterface');
  configSet = slfeature('SaveConfigSet');
  slTargets = slfeature('SimulinkTargets');

  slfeature('AlwaysSaveModelInterface', 0);
  slfeature('SaveConfigSet', 0);
   
  if any(strcmp(saveAsVersion, {validVersions{3}, validVersions{4}}))
    slfeature('SimulinkTargets', 0);
  end

  % Preprocess the model for R12x and/or R13x.
  if any(strcmp(saveAsVersion, {validVersions{3}, validVersions{4}}))
    PreProcessModelForR12(saveAsVersion, tempFileFullPath, saveAsNameFullPath, breakLinks, obj);
  else
    PreProcessModelForR13(saveAsVersion, tempFileFullPath, saveAsNameFullPath, breakLinks, obj);
  end
  
  % Retore features.
  slfeature('AlwaysSaveModelInterface', mdlInterface);
  slfeature('SaveConfigSet', configSet);
 
  if any(strcmp(saveAsVersion, {validVersions{3}, validVersions{4}}))
    slfeature('SimulinkTargets', slTargets);
  end
    
  verInfo = '';
  switch saveAsVersion
   case 'SAVEAS_R13SP1'
    verInfo = 'R13 (SP1)';
   case 'SAVEAS_R13'
    verInfo = 'R13';
   case 'SAVEAS_R12P1'
    verInfo = 'R12.1';
   case 'SAVEAS_R12'
    verInfo = 'R12';
  end

  % Create a list of new blocks that will be removed to display to the users.
  newBlocks = obj.getNewBlocks;
  newBlockStr = ['- ', newBlocks{1}{1}];
  for k=2:length(newBlocks{1})
    newBlockStr = [newBlockStr, 10, '- ', newBlocks{1}{k}];
  end
  disp(['The following new blocks will be replaced during saveas: ', 10, newBlockStr]);
 
  
  % Start the waitbar
  RepModelR14 = strrep(modelName,'_','\_');
  waitbarh = waitbar(0,['Converting ' RepModelR14 ' to ', verInfo, ' format...']);
  
  waitbar(.15,waitbarh);

  % For all versions, we will update the model to R13SP1 or R13.
  [status, msg] = UpdateModel_R13(saveAsVersion, tempFileFullPath, saveAsNameFullPath, waitbarh, obj);
  delete(tempFileFullPath);
  
  % If we want R12/R12P1 versions, run the perl script on the R13 model file. 
  if (~status) && any(strcmp(saveAsVersion, {validVersions{3}, validVersions{4}}))
    % Create a temp. file
    tempFileFullPath = [tempname, '.mdl'];
    copyfile(saveAsNameFullPath, tempFileFullPath,  'writable'); 
    fileattrib(tempFileFullPath,'+w');
    
    [status, msg] = UpdateModel_R12(tempFileFullPath, saveAsNameFullPath, saveAsVersion, waitbarh);
    
    delete(tempFileFullPath);
    
    %temporay workaround for arrow glass
    for i= 65:100
      waitbar(i/100,waitbarh)
    end
  else
    %temporay workaround for arrow glass
    for i= 35:100
      waitbar(i/100,waitbarh)
    end
  end

  % cleanup
  if ishandle(waitbarh)
    close(waitbarh)
  end
  
  % Delete the translator object
  delete(obj);
  
  if(~status)
    cr = sprintf('\n');
    str = ['    Model: ' modelName ' was converted successfully', cr ,...
           '    Created: ' saveAsName ' model to be used in Simulink ' verInfo];
    h = msgbox(str, ['Save as ', verInfo]);
  else
    disp(msg);
  end
  
% Function: UpdateModel_R13 =====================================================
% Abstract: 
%      Converts a model into a R13SP1 or R13 model.
%
function [status, msg] = UpdateModel_R13(saveAsVersion, modelR14FullPath, modelR13FullPath, waitbarh, obj)
  
  % Get the location of the perl files
  if ispc
    FileComm = fullfile(strrep(lower(which(mfilename)), [mfilename '.m'],''), 'slsaveasR13.pl');
  else
    FileComm = fullfile(strrep(which(mfilename), [mfilename '.m'],''), 'slsaveasR13.pl');
  end
  
  % Get the list of new block diagram level parameters
  newBDParams = obj.getNewBDParams;
  newBDStr = '';
  for i=1:length(newBDParams)      
    if i ~= 1
      newBDStr = [newBDStr, '|', newBDParams{i}];
    else
      newBDStr = newBDParams{i};
    end
  end

  % Get a list of new blocks
  newBlocks = obj.getNewBlocks;
  newBlockStr = '';
  for i=1:length(newBlocks{1})
    blockType = strrep(newBlocks{1}{i}, sprintf('\n'), '\n');
    if i ~= 1
      newBlockStr = [newBlockStr, '||', blockType, ...
            '|', num2str(newBlocks{2}{i}), '|', num2str(newBlocks{3}{i})];
    else
      newBlockStr = [blockType, '|', num2str(newBlocks{2}{i}), '|', ...
                    num2str(newBlocks{3}{i})];
    end
  end

  % Get a list of new port parameters
  newPortParams = obj.getNewPortParams;
  newPortParamsStr = '';
  for i=1:length(newPortParams)
    if i ~= 1
      newPortParamsStr = [newPortParamsStr, '|', newPortParams{i}];
    else
      newPortParamsStr = newPortParams{i};
    end
  end

  % Get a list of new block parameters
  newBlockParams = obj.getNewBlockParams;
  newBlockParamsStr = '';
  for i=1:2:length(newBlockParams)
    blockType = strrep(newBlockParams{i}, sprintf('\n'), '\n');
    if i~= 1
      newBlockParamsStr = [newBlockParamsStr, '||', blockType];
    else
      newBlockParamsStr = blockType;
    end
    params = newBlockParams{i+1};
    for j=1:length(params)
      newBlockParamsStr = [newBlockParamsStr, '|', params{j}];
    end
  end
  
  % Get a list of new block parameters that are common
  newCommonBlockParams = obj.getNewCommonBlockParams;
  newCommonBlockParamsStr = '';
  for i=1:length(newCommonBlockParams)
    if i ~= 1
      newCommonBlockParamsStr = [newCommonBlockParamsStr, '|', newCommonBlockParams{i}];
    else
      newCommonBlockParamsStr = newCommonBlockParams{i};
    end
  end
  
  % Get a list of reference changes
  refMap = obj.getReferenceMappings;
  reMapStr = '';
  for i=1:length(refMap)
    entry1 = strrep(refMap{i}{1}, sprintf('\n'), '\n');
    entry2 = strrep(refMap{i}{2}, sprintf('\n'), '\n');
    if i ~= 1
      refMapStr = [refMapStr, '||', entry1, '|', entry2];
    else
      refMapStr = [entry1, '|', entry2];  
    end
  end
    
  % Strip out the path and .mdl extension
  modelR13NoPath = getModelNameNoPath(modelR13FullPath);
  modelR13NoPath = getModelNameNoExt(modelR13NoPath);

  % Determine the version string to print out in the .mdl file
  verStr = '';
  if strcmp(saveAsVersion, 'SAVEAS_R13SP1')
    verStr = '5.1';
  else
    verStr = '5.0';
  end
  
  s = []; w = [];  
  % Execute the perl file
  if ispc
    perlLocation = fullfile(matlabroot, 'sys\perl\win32\bin\perl');
  else
    perlLocation = 'perl ';
  end
  
  waitbar(.35,waitbarh);
  
  % The command can be too long for certain systems to execute. Write it to a file and the 
  % perl file will read it in.
  dataFile = [tempname, '.txt'];
  fid = fopen(dataFile, 'w');
  fprintf(fid, '%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n', verStr, modelR14FullPath, modelR13FullPath, ...
          modelR13NoPath, newBDStr, newBlockStr, newBlockParamsStr, refMapStr, newPortParamsStr, ...
          newCommonBlockParamsStr);
  fclose(fid);
  
  cmd = [perlLocation, ' ', FileComm, ' "', dataFile, '"'];
  [status,msg] = system(cmd);
  delete(dataFile);
  
% Function: UpdateModel_R12 =====================================================
% Abstract: 
%      Runs a perl conversion program to create an R12/R12P1 model from the R13
% model file. Called from Simulink.
%
function [status, msg] = UpdateModel_R12(modelR13FullPath, modelR12FullPath, saveAsVersion, waitbarh)

  if ispc
    FileComm = fullfile(strrep(lower(which(mfilename)), [mfilename '.m'],''), 'slsaveasR12.pl');
  else
    FileComm = fullfile(strrep(which(mfilename), [mfilename '.m'],''), 'slsaveasR12.pl');
  end
  
  % Strip out the .mdl extension
  modelR12NoPath =  getModelNameNoPath(modelR12FullPath);
  modelR12NoPath =  getModelNameNoExt(modelR12NoPath);
   
  % Execute the perl file
  waitbar(.65,waitbarh);
  if ispc
    perlLocation = fullfile(matlabroot, 'sys\perl\win32\bin\perl');
    if any(isspace(modelR12FullPath))
      modelR12FullPath = ['"' modelR12FullPath '"'];
    end
    [status,msg] = dos([perlLocation, ' ', FileComm, ' ', modelR13FullPath, ' ', modelR12FullPath, ' ', ...
                        modelR12NoPath, ' ', saveAsVersion]);
  else
    [status,msg] = unix(['perl ', FileComm, ' ', modelR13FullPath, ' ', modelR12FullPath, ' ', ...
                        modelR12NoPath, ' ', saveAsVersion]);
  end
  
% Function: getModelNameNoPath =================================================
% Abstract: 
%      Returns the model without the path. It will still have the .mdl extension.       
%
function mdl = getModelNameNoPath(name)
  
  hasfilesep = findstr(name,filesep);
  if(~isempty(hasfilesep))
    fns = findstr(name,filesep);
    mdl= name(fns(end)+1:end);
  else
    mdl = name;
  end
 
% Function: getModelNameNoExt =================================================
% Abstract: 
%      Returns the model without the extension. It may still have the path.
%
function mdl = getModelNameNoExt(name)
  
  hasExt = findstr(name, '.mdl');
  if(~isempty(hasExt))
    mdl= name(1:hasExt-1);
  else
    mdl = name;
  end
  
% Function: addExtension =======================================================
% Abstract: 
%      Adds the .mdl extension to the model if needed.
%
function mdl = addExtension(name)
  
  hasExt = findstr(name,'.');
  if(isempty(hasExt))
    mdl = [name '.mdl'];
  else
    mdl = name;
  end
  
% Function: getFilePath ========================================================
% Abstract: 
%      Gets the file path from a model.
%
function path = getFilePath(name)
  
  hasPath = findstr(name, filesep);
  if ~isempty(hasPath)
    path = name(1:hasPath(end));
  else
    path = '';
  end
  
% Function: addPath ============================================================
% Abstract: 
%      Adds a path to the model if needed
%
function mdl = addPath(name, path)
  
  hasPath = findstr(name, filesep);
  if(isempty(hasPath))
    if ~isempty(path)
      if strcmp(path(end), filesep)
        mdl = [path, name];
      else
        mdl = [path, filesep, name];
      end
    else
      mdl = name;
    end
  else
    mdl = name;
  end
  
% Function: getMatFileName =====================================================
% Abstract: 
%      Gets a fullpath to a unique mat file.
%
function filepath = getMatFileName(name)
 
  if isempty(name)
    filepath = [tempname, '.mat'];
  else
    modelNameNoExt = getModelNameNoExt(name);
    filepath = [modelNameNoExt, '_saveas', '.mat'];
    if exist(filepath) == 2
      count = 1;
      filepath = [modelNameNoExt, '_saveas', num2str(count), '.mat'];
      while exist(filepath) == 2
        count = count + 1;
        filepath = [modelNameNoExt, '_saveas', num2str(count), '.mat'];
      end
    end
  end

% Function: PreProcessModelForR13 ==============================================
% Abstract: 
%      Pre processing work to convert an R14 model to R13/R13SP1.
%    
function PreProcessModelForR13(saveAsVersion, modelNameFullPath, saveAsNameFullPath, breakLinks, obj)

  currentDir = pwd;
  
  % Save path information
  if findstr(path, currentDir)
    isCurrentDirInThePath = 1;
  else
    path(path,currentDir);
    isCurrentDirInThePath = 0;
  end
  
  % cd to the temp directory to do our work.
  cd(tempdir);
  
  % strip out the extension and the path
  modelNameNoPath = getModelNameNoPath(modelNameFullPath);
  modelNameNoPath = getModelNameNoExt(modelNameNoPath);
  
  try
    % load the model
    load_system(modelNameNoPath);
    
    bdType = get_param(modelNameNoPath, 'BlockDiagramType');
    lock = get_param(modelNameNoPath, 'Lock');
    if (strcmp(bdType, 'library') || strcmp(lock ,'on'))
      set_param(modelNameNoPath, 'Lock', 'off');
    end
      
    % Save the workspace data to a MAT file.
    ws = get_param(modelNameNoPath, 'ModelWorkspace');
    if ~isempty(ws)
      matfileName = getMatFileName(saveAsNameFullPath);
      ws.save(matfileName); % Save out the model workspace data
      ws.DataSource = 'MAT-File'; % Switch to MAT file logging mode
      ws.FileName = ''; % Don't save the filepath in the .mdl file.
      disp(['Note: Any model workspace data will be stored in ', matfileName]);
    end
    
    % Remove new blocks
    processBlocks(modelNameNoPath, obj);
    
    if (strcmp(bdType, 'library') || strcmp(lock ,'on'))
      set_param(modelNameNoPath, 'Lock', 'on');
    end
    
    % Save and close the system
    if (breakLinks) 
      save_system(modelNameNoPath, modelNameNoPath, 'BreakLinks');
    else
      save_system(modelNameNoPath);
    end
    
    close_system(modelNameNoPath);
  catch
    warnMsg = sprintf(['Warning: Unable to fully convert model.']);
    warnState = warning;  
    warning on;  
    disp(warnMsg);
    warning(warnState)
  end
  
  % Restore path information
  cd(currentDir);
  if ~isCurrentDirInThePath
    rmpath(currentDir);
  end
   
% Function: PreProcessModelForR12 ==============================================
% Abstract: 
%      Pre processing work to convert an R14 model to R12/R12.1. In particular, some
% features are turned off and the model is compiled to get information about 
% fixed point settings. Some blocks are updated with special save-as tags that
% are processed by the perl code in slsaveasR12.pl.
%
function PreProcessModelForR12(saveAsVersion, modelNameFullPath, saveAsNameFullPath, breakLinks, obj)
  
  fileattrib(modelNameFullPath,'+w');
  modelNameNoPath = getModelNameNoPath(modelNameFullPath);
  modelNameNoPath = getModelNameNoExt(modelNameNoPath);
    
  currentDir = pwd;
  
  % Add the current dir to the path so that we can compile the model in case
  % there is an M-file or S-function that is needed a compile time.
  
  if findstr(path,currentDir)
    isCurrentDirInThePath = 1;
  else
    path(path,currentDir);
    isCurrentDirInThePath = 0;
  end
  
  cd(tempdir)
  failed = 1;
  try
    load_system(modelNameNoPath);
    
    if strcmp(get_param(modelNameNoPath,'BlockDiagramType'), 'library')
      set_param(modelNameNoPath,'lock','off')
    end
    
    % Save the workspace data to a MAT file.
    ws = get_param(modelNameNoPath, 'ModelWorkspace');
    if ~isempty(ws)
      matfileName = getMatFileName(saveAsNameFullPath);
      ws.save(matfileName); % Save out the model workspace data
      ws.DataSource = 'MAT-File'; % Switch to MAT file logging mode
      ws.FileName = ''; % Don't save the filepath in the .mdl file.
      disp(['Note: Any model workspace data will be stored in ', matfileName]);
    end
    
    % Remove new blocks
    processBlocks(modelNameNoPath, obj);
      
    set_param(modelNameNoPath,'SaveDefaultBlockParams','off');
    if (breakLinks) 
      save_system(modelNameNoPath, modelNameNoPath, 'BreakLinks');
    else
      save_system(modelNameNoPath);
    end
     
    if ~strcmp(get_param(modelNameNoPath,'BlockDiagramType'), 'library')
      lasterr('');
      feval(modelNameNoPath,[],[],[],'compile');
      tableBlocks = getTableBlocks;
      for k=1:length(tableBlocks) 
        h = find_system(modelNameNoPath,'LookUnderMasks','on','BlockType',tableBlocks{k,1});
        for i = 1: length(h)
          pdt = get_param(h{i},'CompiledPortDataTypes');
          if ( strmatch('sfix',pdt.Inport) | strmatch('ufix',pdt.Inport))
            set_param(h{i},'Tag',tableBlocks{k,2})
          elseif (strmatch('sfix',pdt.Outport) | strmatch('ufix',pdt.Outport))
            set_param(h{i},'Tag',tableBlocks{k,2})
          end
        end
      end  
      
      feval(modelNameNoPath,[],[],[],'term');
      % Constant 
      hConstant = find_system(modelNameNoPath,'LookUnderMasks','on','BlockType','Constant');
      k = 1;
      for i = 1: length(hConstant)
        outDTScalingMode = get_param(hConstant{i},'OutputDataTypeScalingMode');
        value = get_param(hConstant{i},'Value');
        switch outDTScalingMode
         case {'single','int8','int16',...
               'int32',...
               'uint8',...
               'uint16',...
               'uint32',...
               'booloean'}
          
          set_param(hConstant{k},'Value',[outDTScalingMode '(' value ')']);
          
         case {'Specify via dialog', 'Inherit via back propagation'}    
          feval(modelNameNoPath,[],[],[],'compile');  
          pdt = get_param(hConstant{i},'CompiledPortDataTypes');
          if (strmatch('sfix',pdt.Outport) | strmatch('ufix',pdt.Outport))
            set_param(hConstant{i},'Tag','FixPtConstantSaveAsR12');
          end
          feval(modelNameNoPath,[],[],[],'term');
         otherwise
          % do nothing
        end      
        k = k+1;
      end
    end
    if (breakLinks) 
      save_system(modelNameNoPath, modelNameNoPath, 'BreakLinks');
    else
      save_system(modelNameNoPath);
    end
    close_system(modelNameNoPath);
    failed = 0;
  catch
    cd(currentDir);
    if ~isCurrentDirInThePath
      rmpath(currentDir);
      isCurrentDirInThePath = 1;
    end
    warnMsg = sprintf(['Warning: Unable to fully update/compile the model.']);
    warnState = warning;  
    warning on;  
    disp(warnMsg);
    warning(warnState)
  end
  
  cd(currentDir)
  if ~isCurrentDirInThePath
    rmpath(currentDir);
  end
  if failed
    try
      if (breakLinks) 
        save_system(modelNameNoPath, modelNameNoPath, 'BreakLinks');
      else
        save_system(modelNameNoPath);
      end
    catch
      disp(lasterr)
    end
  end
  
% Function: processBlocks ======================================================
% Abstract:
%      Replace new R14 blocks with an empty subsystem
%
function processBlocks(sys, obj)
  
  % Make a temp. model to create empty subsystems
  tempModel = createTempMdl;
  mdlH = new_system(tempModel);
  load_system(tempModel);
  
  % Get a list of new blocks
  newBlocks = obj.getNewBlocks;

  for i=1:length(newBlocks{1})
    
    % Get the block type and port information
    blockType = newBlocks{1}{i};
    numInputs = newBlocks{2}{i};
    numOutputs = newBlocks{3}{i};
    
    if isempty(blockType)
      continue;
    end
    
    % Check if we should look for reference blocks
    hasPath = findstr(blockType, '/');
    
    try
      if ~isempty(hasPath)
        %
        % Handle reference blocks
        %
        if numInputs == -1 || numOutputs == -1
          % Variable number of inputs and outputs. Each block will have to be replaced individually
          findAndReplaceBlocks(sys, tempModel, 'Reference', blockType);
        else
          % Same number of inputs and outputs. Batch replace is enough 
          replacementBlock = createEmptySubsystem(tempModel, numInputs, numOutputs); 
          replace_block(sys, 'ReferenceBlock', blockType, replacementBlock, 'noprompt');
        end
        
      else
        %
        % Handle built-in blocks
        %
        if (numInputs == -1) || (numOutputs == -1)
          % Variable number of inputs and outputs. Each block will have to be replaced individually
          findAndReplaceBlocks(sys, tempModel, blockType, '');
        else
          % Same number of inputs and outputs. Batch replace is enough 
          replacementBlock = createEmptySubsystem(tempModel, numInputs, numOutputs);
          replace_block(sys, 'BlockType', blockType, replacementBlock, 'noprompt');
        end
      end
      
    catch
      disp(lasterr);
      break;
    end
  end
  
  close_system(tempModel, 0);
  
% Function: findAndReplaceBlocks ===============================================
% Abstract:
%      Finds all instances of the specified block in the model.
%
function blks = findAndReplaceBlocks(sys, tempSys, blockType, refBlock)
  
  try 
    if strcmp(blockType, 'Reference')
      blks = find_system(sys, 'LookUnderMasks', 'on', 'FollowLinks', 'off', ...
                         'ReferenceBlock', refBlock);
    else
      blks = find_system(sys, 'LookUnderMasks', 'on', 'FollowLinks', 'off', ...
                         'BlockType', blockType);
    end
  catch
    blks = {};
  end

  for j=1:length(blks)
    ports = get_param(blks{j}, 'Ports');
    pos = get_param(blks{j}, 'Position');
    name = get_param(blks{j}, 'Name');
    parent = get_param(blks{j}, 'Parent');
    destBlock = [parent, '/', name];
    replacementBlock = createEmptySubsystem(tempSys, ports(1), ports(2));
    delete_block(blks{j});
    add_block(replacementBlock, destBlock);
    set_param(destBlock, 'Position', pos);
    set_param(destBlock, 'Name', name);
  end
   
% Function: createEmptySubsystem ===============================================
% Abstract:
%      Creates an empty subsystem in the specified model.
%
function newBlock = createEmptySubsystem(sys, numInputs, numOutputs)
  
  newBlock = [sys, '/tmp'];
  
  % Get rid of the old block if it exists
  try
    delete_block(newBlock);
  catch
  end
  add_block('built-in/SubSystem', newBlock);
  
  offset = 0;
  for i=1:numInputs
    yI = 23 + offset;
    hI = 37 + offset;
    yT = 20 + offset;
    hT = 40 + offset;
    str_i = num2str(i);
    
    inport = [newBlock, '/In', str_i];
    term = [newBlock, '/Terminator', str_i];
    
    add_block('built-in/Inport', inport);
    add_block('built-in/Terminator', term);
    set_param(inport, 'Position', [35, yI, 65, hI]);
    set_param(term, 'Position', [100, yT, 120, hT]);
    add_line(newBlock, ['In', str_i, '/1'], ['Terminator', str_i, '/1']);

    offset = offset + 60;
  end
  
  offset = 0;
  for i=1:numOutputs
    yO = 23 + offset;
    hO = 37 + offset;
    yG = 20 + offset;
    hG = 40 + offset;
    str_i = num2str(i);
    
    outport = [newBlock, '/Out', str_i];
    ground = [newBlock, '/Ground', str_i];
    
    add_block('built-in/Outport', outport);
    add_block('built-in/Ground', ground);
    set_param(outport, 'Position', [250, yO, 280, hO]);
    set_param(ground, 'Position', [165, yG, 185, hG]);
    add_line(newBlock, ['Ground', str_i, '/1'], ['Out', str_i, '/1']);
        
    offset = offset + 60;
  end

  try
    set_param(newBlock, ...
              'Description', 'Replaced Block', ...
              'ShowPortLabels', 'on', ...
              'BackgroundColor', 'yellow', ...
              'Mask', 'on', ...
              'MaskType', 'Replaced Block', ...
              'MaskDescription', 'This is an R14 block which was replaced with an empty Subsystem.', ...
              'MaskDisplay', 'disp(''Replaced\nBlock'')', ...
              'MaskIconFrame', 'on', ...
              'MaskIconOpaque', 'on', ...
              'MaskIconRotate', 'none', ...
              'MaskIconUnits', 'Autoscale'); 
  catch
    disp(lasterr);
  end
      
  
% Function: getTableBlocks =====================================================
% Abstract: 
%      Returns the Blocks and Tag information. These table represents a partial 
% list of blocks to be updated. Used only for save-as to R12/R12p1. 
%
function tableBlocks = getTableBlocks

  tableBlocks = {'Sum','FixPtSumSaveAsR12';,...
                 'Gain','FixPtGainSaveAsR12';,...
                 'Product','FixPtProductSaveAsR12';,...
                 'UnitDelay','FixPtUnitDelaySaveAsR12';,...
                 'Abs','FixPtAbsSaveAsR12';,...
                 'Signum','FixPtSignumSaveAsR12';,...
                 'Logic','FixPtLogicSaveAsR12';,...
                 'Switch','FixPtSwitchSaveAsR12';,...
                 'MultiPortSwitch','FixPtMultiPortSwitchSaveAsR12';,...
                 'RelationalOperator','FixPtRelationalOperatorSaveAsR12';,...
                 'Relay','FixPtRelaySaveAsR12';,...
                 'Lookup','FixPtLookupSaveAsR12';,...
                 'Lookup2D','FixPtLookup2DSaveAsR12';,...
                };

% Function: createTempMdl ======================================================
% Abstract:
%      Returns the name of a nonexistent model.  The
%   model name is neither an MDL file nor is it a block diagram
%   in memory created by NEW_SYSTEM.
%
function [mdl, mdlFullPath] = createTempMdl 
  lastSlDiagCache = get_param(0,'LastDiagnostic');
  lastErrCache    = lasterr;
  [lastWarnCache, lastWarnIdCache]   = lastwarn;
  
  while 1
    [ mdlpath, mdlfile, mdlext, mdlver ] = fileparts(tempname);
    mdl=mdlfile;
    if ~exist(mdl) 
      try
        find_system(mdl,'SearchDepth',0);
      catch
        mdlFullPath = [fullfile(mdlpath, mdlfile) '.mdl'];
        break;
      end
    end
  end
  
  set_param(0,'LastDiagnostic',lastSlDiagCache);
  lasterr(lastErrCache);
  lastwarn(lastWarnCache, lastWarnIdCache);