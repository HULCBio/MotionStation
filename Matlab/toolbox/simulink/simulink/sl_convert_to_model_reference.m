function [conversionSuccess,...
          newTopModelNameOut,...
          createdModelsNameList,...
          candidateListNameOnly] = sl_convert_to_model_reference(topModelIn,...
                                                  saveLocation,...
                                                  varargin)
% sl_convert_to_model_reference: Partitions a model into several models using Model blocks
%
% Basic Usage:
%    sl_convert_to_model_reference(topModelIn,saveLocation);
%
% Full Usage Example:
%  [conversionSuccess,newTopModelNameOut,createdModels,candidateListNameOnly] = 
%    sl_convert_to_model_reference('myModel','.',
%                                  {'modelRefTargetToBuild','Sim',...
%                                   'candidateListIn','myModel/someSubsystem',...
%                                   'lookInsideThisSystem',true,...
%                                   'newTopModelName','myModel_revised',...
%                                   'busSaveFormat','mat',...
%                                   'busFileName','myBuses',...
%                                   'maxModelNameLength',30,...
%                                   'mdlNameKeepEndWhenTooLong',false,...
%                                   'useLibNameForModelName',true})
%
% Inputs:
%
%   topModelIn: the model to be converted (either its name or handle)
%
%   saveLocation: the directory into which everything created will be saved
%      This includes the newly created models, the converted
%      top model, any modified libraries, and a mat file containing
%      the definitions of bus objects created.
%
%  The third input is a cell array of parameter-value pairs. The pairs may 
%  appear in any order.  A description of each parameter follows the summary
%  of default values.
%
%  Default values:
%     modelRefTargetToBuild      'Sim'
%     candidateListIn            computed using find_system
%     lookInsideThisSystem       false
%     newTopModelName            [original name,'_converted'];
%     busSaveFormat              'mat'
%     busFileName                [newTopModelName,'_buses.m(at)']
%     maxModelNameLength         20
%     mdlNameKeepEndWhenTooLong  true
%     useLibNameForModelName     false
%
%  Parameter Descriptions:
%
%   modelRefTargetToBuild: An argument indicating what model reference
%      target to build. The corresponding value must be one of: 
%         'Sim' - Build the model reference simulation target only
%         'RTW' - Build the model reference RTW target (which also builds sim)
%         'Neither' - Do not build the model reference target
%      If not specified, the default is 'Sim'.
%
%   candidateListIn: An argument containing a list of atomic 
%      subsystems to convert to models. If not specified, the initial list 
%      will be created using:
%         candidateListIn = find_system(topModelIn,...
%                                       'FollowLinks','on',...  
%                                       'LookUnderMasks','graphical',...
%                                       'BlockType','SubSystem',...
%                                       'TreatAsAtomicUnit','on');
%      Note this list (either passed in or the default) will be pruned of the 
%      subsystems that do not meet all of the following criteria:
%         (1) Plain atomic subsystem (i.e. it has no enable, trigger, or 
%             action ports, or for, or while blocks)
%         (2) Is not masked other than a purely graphical mask
%         (3) If the system contains a Stateflow chart, the machine cannot have 
%             any machine parented data, machine parented events, or any 
%             exported graphical functions
%         (4) Does not have function-call outputs
%         (5) If the system is a link, all other instances of that link must
%             not be under a mask other than a purely graphical one
%         (6) If the system is a link, all other instances of that link must
%             have the same structural checksum
%      Additional systems will be eliminated during the conversion process due
%      to the following reasons:
%         (1) While defining bus objects, a bus creator block is 
%             encountered which is a link and not all instances of that
%             reference block have the same bus definition
%
%   lookInsideThisSystem: A flag (true or false) indicating that searching for
%      candidate subsystems should be only inside the system passed in as the 
%      candidateListIn argument and not in the model as a whole.  If 
%      the lookInsideThisSubsystem flag is true, then the length of 
%      candidateListIn must be one.
%
%   newTopModelName: A name to use for the model passed in after conversion. 
%      By default  the model name will have '_converted' appended to it.
%
%   busSaveFormat: A string either 'm' or 'mat' indicating which format any
%      bus objects created during conversion should be saved in
% 
%   busFileName: A name to use for the file in which the bus objects are 
%      to be saved. If not specified, the file name will be the new model
%       name appended with '_buses'
%
%   maxModelNameLength: An integer indicating the maximum length allowed for 
%      the names of models being created. The default is 20.
%
%   mdlNameKeepEndWhenTooLong: A flag (true or false) indicating how to 
%      truncate model names that will be too long based on maxModelNameLength.
%      If this flag is true (the default) then characters will be removed 
%      from the beginning, otherwise characters will be removed from the end.
%
%   useLibNameForModelName: A flag (true or false) indicating that for 
%      subsystems that are library links where the subsystem is the only
%      block in the library, the library name should be used for the 
%      created model name. This means that the library will no longer
%      be needed after conversion
%
% Outputs: 
%
%   conversionSuccess: Whether the conversion successfully completed or not
%   newTopModelName: The name of the top model after conversion
%   createdModelsNameList: A list of the names of all of the models created during 
%      the conversion process
%   candidateListNameOnly: A list of all of the candidates after pruning. The
%      names (including the full path) are returned instead of the handles 
%      since the top model will be closed and so handles will be invalid.
%      Note that this list will be sorted so that the most deeply nested 
%      candidates are first
%
%
% The conversion is accomplished by the following steps:
% 
%   (1) The find_model_reference_candidates routine is used to determine 
%       which subsystems should be converted to models and replaced with 
%       Model blocks
%   (2) The subsystem_to_model_reference function is called for each 
%       subsystem to create a model from the subsystem and the new
%       model is saved in the saveLocation passed in
%   (4) The original model passed in is saved with a new name 
%       and the subsystems that have been converted are changed to Model
%       blocks. Also, any bus creators that needed bus objects for model 
%       referencing have bus objects specified on them
%   (5) Any libraries in need of modification are modified (by having 
%       bus objects set, or by having subsystems turned into model blocks)
%       and saved in the saveLocation passed in
%   (6) Each newly created model is opened, the model reference target is
%       built as requested by the third input, and then the model is closed
%
% Note that any libraries that require modification will now have two
% copies saved and on the MATLAB path: the original one, and the version
% modified by this tool and saved in the location specified. This means
% that care needs to be taken when loading a model to ensure that the 
% correct library is being used.
%
%
% Known Limitations
% Here is a list of some things that sl_convert_to_model_reference does not do:
%
%   (1) Preserve directory structure when saving converted models
%   (2) Copy the PreLoad, PostLoad, etc. functions
%   (3) Consider multiple models at once when converting
%   (4) Handle the conversion of subsystems with masks by creating 
%       parameter arguments
%   (5) Detect systems with the following characteristics that preclude 
%       the system from being converted to a referenced model:
%       (5a) Subsystems that are only virtual blocks
%       (5b) Systems that are MathWorks Library blocks (other than the 
%            Simulink library)
%       (5c) Systems with a Mux block feeding the output
%       (5d) Systems with Rate transistion blocks directly connected to 
%            the outport (the block cannot determine its output port sample
%            time)
%       (5e) Systems whose input ports are constant
%       (5f) Systems whose Inport feeds a merge block
%
%   $Revision: 1.1.6.11 $

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Startup stuff, validating inputs etc. %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  if nargin < 2 || nargin >5
    error('ModelRefConv:NumInputs',...
          'Wrong number of inputs. Two required. Five permitted.');
  end
  
  % Validate the first input: must be a simulink model
  isModel = false;
  if exist(topModelIn) == 4
    load_system(topModelIn);
    isModel = strcmp(get_param(topModelIn,'BlockDiagramType'),'model');
  end
  if ~isModel
    error('ModelRefConv:InvalidFirstInput',...
          'First argument must be a Simulink model');
  end
  
  % First input validated, now make sure we have name and handle
  topModel.Name   = get_param(topModelIn,'Name');
  topModel.Handle = get_param(topModelIn,'Handle');
  
  % Verify that saveLocation is a directory
  % Note no check is done for write permission
  if strcmp(saveLocation,'.')
     saveLocationInfo = what(pwd);
  else
    saveLocationInfo = what(saveLocation);
    if isempty(saveLocationInfo)
      % There is no such directory on the path. Create one.
      if ~isvarname(saveLocation)
        error('ModelRefConv:saveLocationNotVarName',...
              'The second argument must be a valid MATLAB variable name');
      end
      disp(['The directory ''',saveLocation,...
            ''' does not exist. Creating it in ''',pwd,'''']);
      if ~(mkdir(saveLocation))
        error('ModelRefConv:InvalidSecondInput',...
              ['The directory ',saveLocation,' did not exist and',...
               'could not be created.']);
      end
      saveLocationInfo = what(saveLocation);
    elseif (length(saveLocationInfo) > 1)
      % There are multiple directories that fit this. Make the user specify 
      % which one is wanted
      error('ModelRefConv:ambiguousSaveLocation',...
            'The specified location for saving files, ''',saveLocation,...
            ' is ambiguous. Please specify the full path.');
    else
      % One pre-existing directory. If it contains any mdl files issue an error
      if ~isempty(saveLocationInfo.mdl)
        warning(['The directory: ',saveLocationInfo.path,' contains mdl files. ',...
                 'You may see unexpected results if you are re-running ',...
                 'the conversion of a model or overwriting the original ',...
                 'model or libraries']);
      end
    end
  end
  fullSaveLocation = saveLocationInfo.path;

  
  % Set the defaults
  modelRefTargetToBuild = 'Sim';
  candidateListIn       = [];
  lookInsideThisSystem  = false;
  newTopModelName       = [topModel.Name,'_converted'];
  busSaveFormat         = 'mat';
  busFileName           = '';
  maxModelNameLength    = 20;
  mdlNameKeepEndWhenTooLong      = true;
  useLibNameForModelName         = false;
  
  if nargin >= 3
    if iscell(varargin{1}) 
      dataCell = varargin{1};
      if (mod(length(dataCell),2)~=0)
        error('ModelRefConv:InvalidThirdInput',...
              ['Third argument must be a cell array with an even ',...
               'number of elements.']);
      end
      % extract the values from the cell array
      for m = 1:2:length(dataCell)
        name = dataCell{m};
        val  = dataCell{m+1};        
        switch name
         case 'modelRefTargetToBuild'       
          modelRefTargetToBuild = val;
         case 'candidateListIn'
          candidateListIn = val;
         case 'lookInsideThisSystem'
          lookInsideThisSystem = val;
         case 'newTopModelName'  
          newTopModelName = val;          
         case 'busSaveFormat'
          busSaveFormat = val;          
         case 'busFileName'
          busFileName = val;          
         case 'maxModelNameLength'
          maxModelNameLength = val;          
         case 'mdlNameKeepEndWhenTooLong'
          mdlNameKeepEndWhenTooLong = val;
         case 'useLibNameForModelName'
          useLibNameForModelName = val;          
         otherwise
          error(['unrecognized variable name ''',name, ...
                 ''' passed to ''',mfilename,'''']);
        end %switch
      end
      if nargin >3
        error('ModelRefConv:NumInputsWithCell',...
              ['Wrong number of inputs. When the third input is a cell ',...
               'array only three inputs are permitted']);
      end
    else
      % The R14LCS style input arguments
      modelRefTargetToBuild = varargin{1};
      if nargin > 3
        candidateListIn = varargin{2};
      end
      if nargin > 4
        lookInsideThisSystem  = varargin{3};
      end  
    end
  end
      
  % Validate the modelRefTargetToBuild argument: must be one of three strings
  if ( ~ischar(modelRefTargetToBuild) || ...
       (~strcmpi(modelRefTargetToBuild,'Sim') && ...
        ~strcmpi(modelRefTargetToBuild,'RTW') && ...
        ~strcmpi(modelRefTargetToBuild,'Neither') ) )
    error('ModelRefConv:modelRefTargetToBuild',...
          ['modelRefTargetToBuild argument must be one of: ',...
           '''Sim'',''RTW'',''Neither''.']);
  end
  
  % Now set two flags to check what to build
  % and not do the strcmp for each subsystem
  buildSim = strcmpi(modelRefTargetToBuild,'Sim');
  buildRTW = strcmpi(modelRefTargetToBuild,'RTW');
  
  % Validate the candidateListIn (optional) argument: must be a list of 
  % atomic subsystems
  if ~isempty(candidateListIn)
    % First check that it is a vector
    sizeCands = size(candidateListIn);
    if (ndims(candidateListIn)>2) || (sizeCands(1)~=1 && sizeCands(2)~=1)
      error('ModelRefConv:FourthInputNotVector',...
            'Fourth argument must be a vector');
    end
    % next load all of the libraries by using the side effect of find_system
    disp('Forcing the loading of all libraries associated with this model');
    find_system(topModelIn,...
                'FollowLinks','on',...
                'LookUnderMasks','all');
    disp('done loading libraries')
    
    % check that each candidate is an atomic subsystem block
    if ~iscell(candidateListIn) && ...
          (length(candidateListIn) ~= 1) && ...
          ~ischar(candidateListIn)
      error('ModelRefConv:FourthInputNotExpectedType',...
            ['Fourth argument must be a single string, a handle, ',...
             'a cell array of strings or handles ']);
    end
    if ~iscell(candidateListIn)
      candidateListIn = {candidateListIn};
    end
    for i=1:length(candidateListIn)
      if ishandle(candidateListIn(i))
        candidateListIn2(i) = candidateListIn(i);
      else
        candidateListIn2(i) = get_param(candidateListIn{i},'Handle');
      end
    end
    blkType = get_param(candidateListIn2(i),'BlockType');
    if ~strcmp(blkType,'SubSystem')
      error('ModelRefConv:FourthInputNotSubsystem',...
            ['Fourth argument must be a list of simulink ',...
             'subsystem blocks. Element ',num2str(i),' is not ',...
             'a subsystem']);
    end
    atomicSS = get_param(candidateListIn2(i),'TreatAsAtomicUnit');
    if ~strcmp(atomicSS,'on')
      error('ModelRefConv:FourthInputNotAtomic',...
            ['Fourth argument must be a list of simulink ',...
             'atomic subsystem blocks. Element ',num2str(i),...
             ' is not atomic']);
    end
  else
    candidateListIn2 = [];
  end

  % Validate the lookInsideThisSystem argument: must be true or false
  % and there must be only candidate subsystem if it is true
  if ~islogical(lookInsideThisSystem) || ~isscalar(lookInsideThisSystem)
    error('ModelRefConv:lookInsideThisSystemNotBoolean',...
          'lookInsideThisSystem argument must be a logical scalar');
  end
  if ( length(candidateListIn2) ~= 1 && lookInsideThisSystem)
    error('ModelRefConv:FifthFourthInputIncomp',...
          ['Cannot look inside this system for candidates ',...
           'if multiple systems given or no systems given']);
  end
  
  if ~isvarname(newTopModelName)
    error('ModelRefConv:newTopModelName',...
          'newTopModelName argument must be a valid variable name');
  end
  
  if (~ischar(busSaveFormat) || ...
      (~strcmpi(busSaveFormat,'m') && ~strcmpi(busSaveFormat,'mat')))
    error('ModelRefConv:busSaveFormatInvalid',...
          'busSaveFormat must be either ''m'' or ''mat''');
  end
  
  if isempty(busFileName)
    busFileName = [fullSaveLocation,filesep,newTopModelName,'_buses.',...
                   lower(busSaveFormat)];
  elseif ~isvarname(busFileName)
    error('ModelRefConv:busFileNameInvalid',...
          'busFileName must be a valid variable name');
  else
    busFileName = [fullSaveLocation,filesep,busFileName,'.',...
                   lower(busSaveFormat)];
  end
  
  if (~islogical(useLibNameForModelName) || ...
      ~isscalar(useLibNameForModelName))
    error('ModelRefConv:useLibNameForModelNameNotBoolean',...
          'useLibNameForModelName argument must be a scalar logical');
  end
  
  if (~isnumeric(maxModelNameLength) || ...
      ~isscalar(maxModelNameLength))
    error('ModelRefConv:maxModelNameLengthNotNumeric',...
          'maxModelNameLength argument must be a scalar numeric value');
  end

  if (~islogical(mdlNameKeepEndWhenTooLong) || ...
      ~isscalar(mdlNameKeepEndWhenTooLong))
    error('ModelRefConv:mdlNameKeepEndWhenTooLongNotBoolean',...
          'mdlNameKeepEndWhenTooLong argument must be a scalar logical');
  end
  
  % Initialize the output variables
  conversionSuccess = false;
  createdModelsNameList = [];
  candidateListNameOnly = [];
  newTopModelNameOut = [];

  % Error if incorrect number of outputs
  if nargout > 4
    error('ModelRefConv:InvalidNumOutputs',...
          'only four outputs supported');
  end
  
  % remember where we started and what the original path was
  startDir = pwd;
  origPath = path;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % From here on out we will not error out. We will always return,      %
  % passing back the outputs. This is to enable refining a candidate    %
  % list If certain candidates cause errors, the list will be returned  %
  % and the problem candidates can be removed from the list and another %
  % conversion attempt can be made                                      %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  try
    % Make sure the model is configured properly, for now just warn if 
    % it is not
    modelref_conversion_utilities('config_set_checks',topModel.Handle,false);
    
    % We need access to compiled information during the conversion process, 
    % so put the model into compiled mode now
    if ~strcmp(get_param(topModel.Name,'SimulationStatus'),'stopped')
      error('ModelRefConv:BadSimulationStatus',...
            'The model is being run. Please stop it and re-run this function.');
    end
    disp(['Putting the model into a compiled state. ',...
          'If something goes wrong this can be undone with the command: ',...
          sprintf('\n'),'feval(''',topModel.Name,''',[],[],[],''term'')']);
    evalc('feval(topModel.Name,[],[],[],''compile'');');
    disp(' ');
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find the list of subsystems to convert %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % candidateList is a cell array of structures whose elements are:
    %   Handle   - the handle to the subsystem block
    %   Name     - the name of the subsystem block (i.e. get_param(handle,
    %              'Name')
    %   FullName - the full path name of the subsystem block (i.e. getfullname)
    %   RefBlock - The ReferenceBlock for the subsystem. This is empty if
    %              the subsystem is not a link
    %   Checksum - The StructuralChecksum for the subsystem
    %
    disp('Looking for subsystems to convert to models....');
    [candidateList,candidateListNameOnly] = ...
        find_model_reference_candidates(topModel,candidateListIn2,...
                                        lookInsideThisSystem);
    
    if isempty(candidateList)
      conversionSuccess =true;
      disp('No candidates to convert');
      cleanup(topModel.Name,startDir,origPath);
      return;
    end
    
    listLengthStr = sprintf('%d',length(candidateList));
    listLength    = length(candidateList);
    
    % Add fullSaveLocation to the path, if needed

    if (isempty(strfind(path,fullSaveLocation)) && ...
        ~strcmp(pwd,fullSaveLocation))
      disp('Adding save location to the path');
      eval(['addpath ',fullSaveLocation]);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Convert the subsystems to models %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Initialize a few things:
    % (1) As we convert systems and find ones that cannot be converted 
    %     (and so should be removed from the candidate list we will return)
    %     they will be added to the two below variables
    createdModels = [];
    candsToRemove = [];    
    % (2) Initialize the structure for tracking the bus objects created. 
    %     This is a cell array where each element is a structure with 
    %     four fields:
    %        a) BlockFullName: the path to the bus creator in the original model
    %        b) BusName: the name of the bus object created
    %        c) SetOnBlk: a flag indicating whether the bus object has been set
    %           on the bus creator block yet. (The object will 
    %           be set when a new model is created containing that block,
    %           or when we are updating the libraries, the original model 
    %           and libraries will not be modified.)
    %        d) RefBlk: the ReferenceBlock for the bus creator. Empty if 
    %           the block is not a link
    busCreatorObjects=[];
    
    % If none of the systems are actually converted to models, report
    % success if the models were all eliminated for known reasons, but 
    % report failure if any of the systems were eliminated for an
    % unknown reason
    reportSuccessIfNoNewModels = true;
    
    % Loop over the subsystems and convert them one at a time
    for i=1:listLength
      
      disp(['====================>Converting (',...
            sprintf('%d',i),' of ',listLengthStr,'): ',...
            strrep(candidateList(i).FullName, sprintf('\n'), ' ')]);
      
      % Determine if a system that is identical to this one has already been 
      % converted by using the checksum and reference block
      alreadyDone = is_identical_to_processed_system(candidateList(i),...
                                                     createdModels);
      
      if (~alreadyDone)

        % Convert the subsystem to a model for referencing
        [modelCreationSuccess,...
         newModel,...
         busCreatorObjects,...
         createdModels] = subsystem_to_model_reference(...
             candidateList(i),...
             topModel,...
             fullSaveLocation,...
             createdModels,...
             busCreatorObjects,...
             useLibNameForModelName,...
             maxModelNameLength,...
             mdlNameKeepEndWhenTooLong);

        if ~strcmp(modelCreationSuccess,'success')
          % The  subsystem_to_model_reference function displays a message 
          % that this system failed to be converted
          candsToRemove = [candsToRemove,i];
          if strcmp(modelCreationSuccess,'failedDueToError')
            reportSuccessIfNoNewModels = false;
          elseif ~strcmp(modelCreationSuccess,'failedDueToLimitation')
            error('ModelRefConv:UnknownModelCreationStatus',...
                  'Fatal Error: Unknown model creation status');
          end
          continue;
        end
        
        % Add all the information about this newly created model to the
        % book keeping data structure createdModels
        createdModels = add_to_created_models_list(createdModels,...
                                                   candidateList(i),...
                                                   newModel,...
                                                   topModel.Handle);
        
        % Close the new system so it is not taking up space in memory
        close_system(newModel.Handle,0);
      
      end
    end
    
    % Remove the candidates that were not successfully turned into models
    if ~isempty(candsToRemove) && (length(candidateList) == 1)
      % If there was only one candidate the command below will remove the first
      % character of the candidate instead of the first candidate
      candidateListNameOnly = [];
    else
      candidateListNameOnly(candsToRemove) =[];
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Convert the Top model %
    %%%%%%%%%%%%%%%%%%%%%%%%%

    % Get the original model out of its compiled state
    disp([sprintf('\n'),'Getting the model out of the compiled state']);
    feval(topModel.Name,[],[],[],'term');
    
    if length(createdModels) == 0
      disp('No candidates to convert');
      conversionSuccess = reportSuccessIfNoNewModels;
      cleanup(topModel.Name,startDir,origPath);
      return;
    end
    
    % Save the original model with a new name so we can modify it
    disp('Converting the top level model');
    
    % Change the config set as needed for model reference
    modelref_conversion_utilities('config_set_checks',topModel.Handle,true);
    
    % Convert the main model so that:
    % (1) the subsystems converted to models become Model blocks 
    createdModels = modelref_conversion_utilities(...
        'replace_subsystems_with_model_blks',...
        topModel.Name,...
        topModel.Name,...
        createdModels,...
        newTopModelName);
    % and (2) bus creators have bus objects specified on them, as needed
    topModel.FullName = topModel.Name;
    busCreatorObjects = modelref_conversion_utilities(...
        'add_bus_objects_to_creators',...
        topModel,...
        topModel,...
        busCreatorObjects);
    
    % Save top with its new name
    newTopModel.Name =  newTopModelName;
    save_system(topModel.Handle,[fullSaveLocation,filesep,newTopModel.Name]);
    newTopModelNameOut = newTopModelName;
    newTopModel.Handle = get_param(newTopModel.Name,'Handle');
    
    % close the new top level. This needs to be done because we're about
    % to modify the libraries and the changes to the libraries will not 
    % be seen if we do not close and re-open the model.
    disp(['Closing new top-level model ',newTopModel.Name]);
    close_system(newTopModel.Handle,1);
    newTopModel.Handle = []; % no longer valid

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Save the bus objects to a mat or m file %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(busCreatorObjects)
      if strcmpi(busSaveFormat,'mat')
        disp(['Saving bus objects to ',busFileName]);        
        modelref_conversion_bus_utils('save_bus_in_mat',...
                                      busFileName,busCreatorObjects);
      else
        [mfid, message] = fopen(busFileName,'wt');
        if mfid == -1
          error('ModelRefConv:FileOpenError',...
                ['Could not open file ''',busFileName,...
                 ''' for saving bus objects as M-code. ',...
                 'Reason given by system is: ''',message,'''']);
        end
        disp(['Saving bus objects as M code in ',busFileName]);
        modelref_conversion_bus_utils('print_bus_m_header',mfid,...
                                      topModel.Name,newTopModel.Name,...
                                      busFileName);
        
        modelref_conversion_bus_utils('save_nonbus_data_types_in_m',...
                                      mfid,busCreatorObjects);
        for i=1:length(busCreatorObjects)
          modelref_conversion_bus_utils('save_bus_in_m',...
                                        mfid,busCreatorObjects{i});
        end
        fclose(mfid);
      end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Modify any libraries in need of modification %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp(sprintf('\n'));
    disp('=========== Modifying Libraries ==========');
    % Set the bus objects on the creators
    for i= 1:length(busCreatorObjects)
      % Use SetOnBlk rather than checking for RefBlk empty because
      % a block that had a reference block in the original top model
      % may have had the link broken when its parent system was turned
      % into a model, in which case the SetOnBlk flag will be true because
      % the bus object will have been set on the bus creator in the newly 
      % created model
      if (~busCreatorObjects{i}.SetOnBlk)

        blkToMod = busCreatorObjects{i}.RefBlk;
        libToMod = bdroot(blkToMod);
        lock_status = get_param(libToMod,'lock');
        set_param(libToMod,'lock','off');
        
        disp(['Setting bus object on ''',...
              strrep(getfullname(blkToMod),sprintf('\n'),''),...
              ''' in library ''',...
              get_param(libToMod,'Name'),'''']);
        set_param(blkToMod,'UseBusObject','on');
        set_param(blkToMod,'BusObject',busCreatorObjects{i}.BusName);
        busCreatorObjects{i}.SetOnBlk = true;
        save_system(libToMod,[fullSaveLocation,filesep,...
                            get_param(libToMod,'Name')]);
        set_param(libToMod,'lock',lock_status);
        
      end
    end    

    for i=1:length(createdModels)
      % Two things to do here:
      
      % (1) Modify any instances that are in libraries
      %
      % In this step we are replacing the subsystem blocks with model 
      % blocks in this case
      %
      % +--------------------------+
      % |  Original Model          |
      % |                          |
      % |   +--------------------+ |
      % |   | subsysLink         | |
      % |   |                    | |
      % |   |   +-------------+  | |
      % |   |   | subToMdlRef |  | |
      % |   |   +-------------+  | |
      % |   |                    | |
      % |   +--------------------+ |
      % +--------------------------+
      %
      %  subssysLink is a subsystem that is NOT becoming a model but it IS
      %  a library link block (Its library is subsysLinkLib)
      %  e.g. bdroot(get_param(subsysLink,'ReferenceBlock')) is subsysLinkLib
      %
      %  subToMdlRef is a subsystem which is becoming a model 
      %
      theList = createdModels(i).Instances;

      for idx=1:length(theList)
        if ~(theList(idx).SubsysReplacedByModelBlk)
          theBlock = theList(idx).postConversionLocation.FullPathInLibrary;
          theLibrary = theList(idx).postConversionLocation.LibraryName;
          
          % assert that ModelToModIsLib
          if (isempty(theLibrary))
            error('ModelRefConv:Fatal',...
                  'Fatal Error: assertion failed ==> ~isempty(theLibrary)');
          end
          
          % Replace subsystems with Model Blocks
          refToReplace.Handle = get_param(theBlock,'Handle');
          refToReplace.Name = get_param(theBlock,'Name');

          %unlock the library
          lock_status = get_param(theLibrary,'lock');
          set_param(theLibrary,'lock','off');
          
          disp(['Replacing subsystem ''',theBlock,...
                ''' with Model block in ''',theLibrary,'''']);
          
          % do the switch
          modelref_conversion_utilities(...
              'replace_block_with_model_block',...
              refToReplace,...
              createdModels(i).ModelName,...
              createdModels(i).LabelOuts);
          
          save_system(theLibrary,[saveLocation,filesep,...
                              get_param(theLibrary,'Name')]);
          set_param(theLibrary,'lock',lock_status);
          theList(idx).SubsysReplacedByModelBlk = true;          
        end
      end
      % retain the mods to theList (setting SubsysReplacedByModelBlk = true)
      createdModels(i).Instances = theList;
      
      % (2) modify the library containing the definition of the subsystem
      %     i.e. if you choose "Go to link" from the link options on the block
      %     make that found link a model block. All instances have the same 
      %     reference block. This is done for completeness so that the post
      %     conversion library will accurately reflect the current state of
      %     the model (all instances of the link have been replaced by model
      %     blocks in step 1)
      if ( createdModels(i).ModifyRefBlockLibrary )
        
        % assert that if we are to modify a library there is a library to modify
        if (isempty(createdModels(i).RefBlock))
          error('ModelRefConv:Fatal',...
                ['Fatal Error: assertion failed ==> '...
                 'convertedSys(i).ModifyRefBlockLibrary && '...
                 '~isempty(convertedSys(i).RefBlock)']);
        end

        % Replace subsystems with Model Blocks
        refToReplace.Handle = get_param(createdModels(i).RefBlock,...
                                        'Handle');
        refToReplace.Name = get_param(createdModels(i).RefBlock,...
                                      'Name');
        libToMod =bdroot(createdModels(i).RefBlock);
        %unlock the library
        lock_status = get_param(libToMod,'lock');
        set_param(libToMod,'lock','off');
        
        disp(['Replacing subsystem ''',...
              refToReplace.Name,...
              ''' with Model block in library ''',...
              get_param(libToMod,'Name'),'''']);
        
        modelref_conversion_utilities('replace_block_with_model_block',...
                                      refToReplace,...
                                      createdModels(i).ModelName,...
                                      createdModels(i).LabelOuts);
        
        save_system(libToMod,[fullSaveLocation,filesep,...
                            get_param(libToMod,'Name')]);
        set_param(libToMod,'lock',lock_status);
        
      end
    end
    
    bdclose('all')
    
    disp(['Adding ''',startDir,''' to path.']);
    addpath(startDir);
    disp(['Changing to directory ''',fullSaveLocation,'''']);
    cd(fullSaveLocation);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now we need to perform a few steps to correct all of the model names %
    % for the systems for which we want to use the library name            %
    %   (1) Re-save the model with the new name                            %
    %   (2) Change all of the ModelName Parameters on the Model blocks     %
    %   (3) Delete the models with the temp names                          %
    %   (4) Change the name in the createdModels list                      %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % (1) Save all the special models with the new names
    if (useLibNameForModelName)
      disp(' ');
      disp('Re-naming models');
      for idx = 1:length(createdModels)
        if ~strcmp(createdModels(idx).ModelName,...
                   createdModels(idx).FinalModelName)
          disp(['Saving model ''',createdModels(idx).ModelName,...
                ''' with new name ''',createdModels(idx).FinalModelName,'''']);
          load_system(createdModels(idx).ModelName);
          save_system(createdModels(idx).ModelName,...
                      createdModels(idx).FinalModelName);
          close_system(createdModels(idx).FinalModelName);
        end
      end
      
      % (2) change all the names in the model blocks
      disp(' ');
      disp('Changing ModelName parameter in model blocks');
      for mdlIdx = 1:length(createdModels)
        if ~strcmp(createdModels(mdlIdx).ModelName,...
                   createdModels(mdlIdx).FinalModelName)
          
          theList = createdModels(mdlIdx).Instances;
          for instIdx=1:length(theList)
            if(~theList(instIdx).SubsysReplacedByModelBlk)
              error('ModelRefConv:Fatal',...
                    ['Fatal Error: assertion failed ==> '...
                     'theList(',num2str(instIdx),').SubsysReplacedByModelBlk']);
            end
            
            modelToModify = theList(instIdx).postConversionLocation.ParentModelName;
            modelToModifyIsLibrary = false;
            convertedBlkFullName = ...
                theList(instIdx).postConversionLocation.FullPathInModel;
            
            if ~isempty(theList(instIdx).postConversionLocation.LibraryName)
              modelToModify = theList(instIdx).postConversionLocation.LibraryName;
              modelToModifyIsLibrary = true;
              convertedBlkFullName = ...
                  theList(instIdx).postConversionLocation.FullPathInLibrary;
            end
            
            load_system(modelToModify);
            if modelToModifyIsLibrary
              set_param(modelToModify,'lock','off');
            end
            disp(['Changing ModelName parameter in ''',...
                  convertedBlkFullName,...
                  ''' to ''',createdModels(mdlIdx).FinalModelName,...
                  '''']);
            set_param(convertedBlkFullName,...
                      'ModelName',...
                      createdModels(mdlIdx).FinalModelName);
            save_system(modelToModify);         
            close_system(modelToModify);
          end
          
          % (3) delete the tempName version
          disp(['Deleting the temporary model ''',...
                createdModels(mdlIdx).ModelName,''''])
          delete([createdModels(mdlIdx).ModelName,'.mdl']);
        end
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build the model reference target code %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    allModelsBuilt = true;
    if (buildSim || buildRTW)
      disp(sprintf('\n'));
      disp('========= Building the Model Reference Targets =========');
      for mdlIdx=1:length(createdModels)
        load_system(createdModels(mdlIdx).FinalModelName);
        modelH = get_param(createdModels(mdlIdx).FinalModelName,'Handle');

        targetBuilt =  buildTarget(modelH,mdlIdx,...
                                   length(createdModels),...
                                   buildRTW);
        
        if ~targetBuilt
          allModelsBuilt = false;
        end
        close_system(createdModels(mdlIdx).FinalModelName);
      end
    end

    conversionSuccess = allModelsBuilt;
    
    createdModelsNameList = cell(size(createdModels));
    for mdlIdx = 1:length(createdModels)
      createdModelsNameList{mdlIdx} = createdModels(mdlIdx).FinalModelName;
    end
    
  catch
    err = lasterror;
    disp(['Conversion failed. Error message(s):',sprintf('\n')]);
    for errIdx = 1:length(err)
      disp(err(errIdx).message);
    end
  end
  
  cleanup(topModel.Name,startDir,origPath);


function cleanup(topName,startDir,origPath)
  try
    % Put this in a try because we may have already closed the model
    if  ~strcmp(get_param(topName,'SimulationStatus'),'stopped')
      evalc([topName,'([],[],[],''term'');']);    
    end
  end
  disp(['Changing back to original directory ''',startDir,'''']);
  cd(startDir);
  disp(['Reverting path to the original. This means that created ',...
        'models and libraries may not be on the path'])
  path(origPath);
  

function targetBuilt =  buildTarget(modelH,thisIdx,numModels,buildRTW)
  
  targetBuilt = false;  
  hadErr = false;
              
  if buildRTW
    msgStr = ['Building the model reference RTW target for ',...
          get_param(modelH,'Name'),...
          ' (',sprintf('%d',thisIdx),' of ',...
          sprintf('%d',numModels),')'];
    bldCmd = 'slbuild(modelH,K''ModelReferenceRTWTarget'');';
  else
    msgStr = ['Building the model reference simulation target for ',...
              get_param(modelH,'Name'),...
              ' (',sprintf('%d',thisIdx),' of ',...
              sprintf('%d',numModels),')'];
    bldCmd = 'slbuild(modelH,''ModelReferenceSimTarget'');';
  end
  
  disp(msgStr);
  buildOutput = evalc(bldCmd,'hadErr=true;');
  
  if hadErr
    % Was the error a multi-instance error? If so change to only allowing
    % one instance and try again
    if ~isempty(sllasterror)
      errs = sllasterror;
      multiInstanceError = false;
      for errIdx=1:length(errs)
        if (strfind(errs(errIdx).MessageID,'SL_MdlrefMultiInstance') == 1)
          multiInstanceError = true;
          break;
        end
      end
      
      if (multiInstanceError)
        % clear lasterror
        lasterr('');
        sllasterror('');
        disp(['Failed to build. Setting the model to allow only ',...
              'one instance and will try again']);
        cs = getActiveConfigSet(modelH);
        modelReferenceComponent = cs.getComponent('Model Referencing');
        modelReferenceComponent.ModelReferenceNumInstancesAllowed = 1;
        save_system(modelH);
        hadErr = false;
        buildOutput = evalc(bldCmd,'hadErr=true;');
      end
    end
  end
  
  if hadErr
    disp(['Build failed.',sprintf('\n')]);
    disp('********** START BUILD LOG **********');
    disp(buildOutput);
    disp('********** END BUILD LOG **********');
    err = lasterror;
    disp(['Error message(s):',sprintf('\n')]);
    for errIdx = 1:length(err)
      disp(err(errIdx).message);
    end
  else 
    targetBuilt = true;
  end

%% add_to_created_models_list
function createdModels = add_to_created_models_list(createdModels,...
                                                    candidateSys,...
                                                    newModel,...
                                                    topModelH)

  % cache information about the model being created including how to find
  % all instances of it before and after conversion
  numModels = length(createdModels) + 1;
  createdModels(numModels).RefBlock  = candidateSys.RefBlock;
  createdModels(numModels).RefBlockLibrary = bdroot(candidateSys.RefBlock);
  createdModels(numModels).ModifyRefBlockLibrary = newModel.ModifyLib;
  createdModels(numModels).Checksum  = candidateSys.Checksum;
  
  createdModels(numModels).ModelName = newModel.Name;
  createdModels(numModels).FinalModelName = newModel.FinalName;
  createdModels(numModels).BusOuts   = newModel.BusOuts;
  createdModels(numModels).LabelOuts = newModel.LabelOuts;
  
  if ~isempty(candidateSys.RefBlock)
    allReferences = find_system(topModelH,...
                                'FollowLinks','on',...  
                                'LookUnderMasks','all',...
                                'ReferenceBlock',candidateSys.RefBlock);
    numInstances = length(allReferences);
    
    % pre-allocate the Instances array

    for instIdx = 1:numInstances
      
      % First figure out the pre-conversion location
      % There are three pieces to it:
      %    (1) FullPathInModel
      %    (2) FullPathInLibrary
      %    (3) LibraryName
      preConversionLoc.FullPathInModel = getfullname(allReferences(instIdx));
      
      % If the parent is a library link keep track of where this instance
      % really lives (i.e. where we'd have to switch the subsystem to a 
      % model block)
      instanceParent = get_param(allReferences(instIdx),'Parent');
      if ~strcmp(get_param(instanceParent,'Type'),'block_diagram')
        instanceParentRefBlk = get_param(instanceParent,'ReferenceBlock');
      else
        instanceParentRefBlk = '';
      end
      if isempty(instanceParentRefBlk)
        preConversionLoc.FullPathInLibrary = '';
        preConversionLoc.LibraryName = '';
      else
        parentFullName = getfullname(instanceParent);
        parentRefFullName = getfullname(instanceParent);
        preConversionLoc.FullPathInLibrary = ...
            strrep(preConversionLoc.FullPathInModel,...
                   parentFullName,...
                   parentRefFullName);
        preConversionLoc.LibraryName = bdroot(preConversionLoc.FullPathInLibrary);
      end
      
      theInstances(instIdx).preConversionLocation = preConversionLoc;
      
      % Now initialize the post-conversion location. We will fill these fields in
      % when we know where this system will end up after conversion
      % There are four pieces to it:
      %    (1) FullPathInModel
      %    (2) ParentModelName
      %    (2) FullPathInLibrary
      %    (3) LibraryName
      postConversionLoc.FullPathInModel = '';
      postConversionLoc.ParentModelName = '';
      postConversionLoc.FullPathInLibrary = '';
      postConversionLoc.LibraryName = '';
      theInstances(instIdx).postConversionLocation = postConversionLoc;
      
      % Initialize the SubsysReplacedByModelBlk field to false
      % This will track whether we've actually replaced the subsystem
      % block with a model block yet
      theInstances(instIdx).SubsysReplacedByModelBlk = false;

    end
  else
    
    % First figure out the pre-conversion location
    % There are three pieces to it:
    %    (1) FullPathInModel
    %    (2) FullPathInLibrary
    %    (3) LibraryName
    preConversionLoc.FullPathInModel = candidateSys.FullName;
    preConversionLoc.FullPathInLibrary = '';
    preConversionLoc.LibraryName = '';
      
    theInstances.preConversionLocation = preConversionLoc;
      
    % Now initialize the post-conversion location. We will fill these fields in
    % when we know where this system will end up after conversion
    % There are four pieces to it:
    %    (1) FullPathInModel
    %    (2) ParentModelName
    %    (2) FullPathInLibrary
    %    (3) LibraryName
    postConversionLoc.FullPathInModel = '';
    postConversionLoc.ParentModelName = '';
    postConversionLoc.FullPathInLibrary = '';
    postConversionLoc.LibraryName = '';
    theInstances.postConversionLocation = postConversionLoc;
      
    % Initialize the SubsysReplacedByModelBlk field to false
    % This will track whether we've actually replaced the subsystem
    % block with a model block yet
    theInstances.SubsysReplacedByModelBlk = false;
  end
  createdModels(numModels).Instances = theInstances;
    

  
  
  
  
  
  
function alreadyDone = is_identical_to_processed_system(candidateSys,...
                                                    createdModels)
  
  % Note we use the createdModels list instead of the candidateList
  % because there may be systems in the candidateList that failed to 
  % convert. Ideally we should probably detect if this system is the
  % same as one of the ones that failed to convert and not try to 
  % convert it.
  alreadyDone = false;
  for j=1:length(createdModels)
    sameChecksum = false;
    
    if(~isempty(candidateSys.Checksum) && ...
       ~isempty(createdModels(j).Checksum)) 
      sameChecksum = (candidateSys.Checksum == ...
                      createdModels(j).Checksum );
    end
    
    if sameChecksum
      % If they happen to have the same checksum even though the 
      % ref blocks are different (or empty) do not make them the 
      % same model (allowing them to be the same model can potentially
      % cause problems with the automatic bus handling)
      if strcmp(createdModels(j).RefBlock,candidateSys.RefBlock)...
            && ~isempty(candidateSys.RefBlock)
        alreadyDone = true;
        disp([sprintf('\n'),...
              'Current Candidate will reference the model ''',...
              createdModels(j).ModelName,...
              ''' which has already been created.']);
        
        % assert that this system is in the instance list of the createdModels
        foundThisSys = false;
        theInstances = createdModels(j).Instances;
        for instIdx = 1:length(theInstances)
          if strcmp(...
              theInstances(instIdx).preConversionLocation.FullPathInModel,...
              candidateSys.FullName)
            foundThisSys = true;

            break;
          end
        end
        if ~foundThisSys
          error('ModelRefConv:Fatal',...
                ['Fatal Error: assertion failed ==> identical ',...
                 'reference not on list']);
        end
        break;
      end
    end
  end
  
