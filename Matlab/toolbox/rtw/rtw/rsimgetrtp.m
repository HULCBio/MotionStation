function [rtpStruct] = rsimgetrtp(modelname,varargin)
% RSIMGETRTP   Get the parameter structure from your model.
% rtP = RSIMGETRTP('MODELNAME',OPTIONS)
%
% RSIMGETRTP returns a parameter structure for the current model settings. This
%   structure is designed to be used with the Real-Time Workshop Rapid
%   Simulation Target (Rsim). The process of obtaining the "rtP" structure
%   forces an 'update diagram' action. In additon to the current model tunable
%   block parameter settings, the rtP structure contains a structural
%   checksum. This checksum is used to ensure that the model structure is
%   consistent with that of the model when the Rsim executable was generated.
%
% Options:
%
%    Options are passed as parameter-value pairs.
%
%    'AddTunableParamInfo', this option uses the Real-Time Workshop code
%        generation process to extract tunable parameter information from your
%        model and place it with the return argument (RTP). This information
%        gives you a mapping between the parameter structure and the tunable
%        parameters.
%
%        The AddTunableParamInfo option requires that the Inline Parameters
%        check box is selected in the Simulation Parameters dialog box. This
%        option also creates (and deletes) a temporary file, modelname.rtw in
%        your current working directory.
%
%        Tunable Fixed-Point parameters will show up as their stored value.
%        For example, an sfix(16) parameter value of 1.4 with a scaling of 2^-8
%        will have a value of 358 as an int16.
%
% Example 1: Creating an Rsim executable and passing a different
%            parameter structure.
%    a) Set the Real-Time Workshop target configuration to Rapid Simulation
%       Target
%    b) Create an rsim executable for the model by clicking the build button
%       or type rtwbuild('model').
%    c) Modify parameters in your model and save the rtP structure:
%       >> rtP = rsimgetrtp('model')
%       >> save myrtp.mat rtP
%    d) Run the generate executable with the new parameter set:
%        >> !model -p myrtp.mat
%    e) Load the results in to Matlab
%        >> load model.mat
%
% Example 2: Create an rtP with the tunable parameter mapping information:
%    a) Create rtP with the tunable parameter information
%        >> rtP = rsimgetrtp('model','AddTunableParamInfo','on')
%    b) The rtP structure looks like:
%         modelChecksum:  1x4 vector that encodes the structure of the model
%         parameters:     A structure of the tunable parameters in the model.
%       The parameters structure contains the following fields:
%         dataTypeName: The data type name, e.g., 'double'
%         dataTypeId  : Internal data type identifier for use by Real-Time
%                       Workshop
%         complex     : 0 if real, 1 if complex
%         dtTransIdx  : Internal data type identifier for use by Real-Time
%                       Workshop
%         values      : All values associated with this entry in the
%                       parameters substructure.
%         map         : Mapping structure information that correlates the values
%                       to the models' tunable parameters.
%       The map structure contains the following fields:
%         Identifier   : Tunable parameter name
%          ValueIndices: [startIdx, endIdx] start and end indices into
%                        the values field.
%          Dimensions  : Dimension of this tunable parameter (matrices
%                        are generally stored in column-major).
%

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.12.2.4 $

  %
  % Parse the input arguments
  %
  addTunableParamInfo = -1;

  i = 1;
  while i <= nargin - 1
    arg = varargin{i};

    if ~ischar(arg) 
      error('All input arguments must be strings');
    end

    if strcmp(arg,'AddTunableParamInfo')
      i = i + 1;
      if i > nargin
        error(['Invalid number of inputs. Missing parameter value for ',...
               'AddTunableParamInfo option']);
      end
      opt = varargin{i};
      if (strcmp(opt,'on'))
        addTunableParamInfo = 1;
      elseif (strcmp(opt,'off'))
        addTunableParamInfo = 0;
      else
        error('Invalid parameter value for AddTunableParamInfo option');
      end
    else
      error(['Unknown option ',arg]);
    end
    i = i + 1;
  end

  if addTunableParamInfo == -1
    addTunableParamInfo = 0;
  end

  %
  % Load the block diagram if it is not already loaded.
  %
  openModels = find_system('type','block_diagram');
  modelOpen = 0;
  for i=1:length(openModels)
    mdl = openModels{i};
    if strcmp(mdl,modelname)
      modelOpen = 1;
      break;
    end
  end
  if ~modelOpen
    load_system(modelname);
  end

  %
  % Check state of the model
  %
  if addTunableParamInfo
    if strcmp(get_param(modelname,'RTWInlineParameters'),'off')
      error(['Your model parameters must be inlined in order to '...
             'generate add the tunable parameter mapping info to the '...
             'rtP structure']);
    end
  end

  %
  % Load the rtPStruct return argument:
  %
  dirty=get_param(modelname,'dirty');
  initialState = get_param(modelname,'SimulationMode');
  set_param(modelname,'SimulationMode','external');
  set_param(modelname,'ExtModeParamVectName','rtpStruct');
  try
    set_param(modelname,'SimulationCommand','WriteExtModeParamVect');
  end
  set_param(modelname,'SimulationMode',initialState);
  set_param(modelname,'dirty',dirty);

  %
  % Add the tunable parameter mapping information if requested
  %
  if addTunableParamInfo
    rtwgen(modelname);
    rtwFileName = [modelname '.rtw'];

    %
    % Read the ModelParameters from .rtw file using TLC Server then delete the
    % file
    %
    handle = tlc('new');
    tlc('read',handle,rtwFileName);
    params = tlc('query',handle,'CompiledModel.ModelParameters');
    tlc('close',handle);

    rtw_delete_file(rtwFileName);

    %
    % Build the parameter map info.
    %
    nTrans     = length(rtpStruct.parameters);
    paramIdx   = 1;

    for transIdx = 1:nTrans,
      startIdx   = 1;
      mapIdx     = 1;
      nElements  = length(rtpStruct.parameters(transIdx).values);

      while startIdx <= nElements

        if strcmp(params.Parameter{paramIdx}.Tunable,'yes')

          len          = length(params.Parameter{paramIdx}.Value);
          valueIndices = [startIdx startIdx+len-1];

          mapStruct.Identifier   = params.Parameter{paramIdx}.Identifier;
          mapStruct.ValueIndices = valueIndices;
          mapStruct.Dimensions   = params.Parameter{paramIdx}.Dimensions;

          rtpStruct.parameters(transIdx).map(mapIdx) = mapStruct;

          startIdx  = startIdx + len;
          mapIdx    = mapIdx + 1;

        elseif params.Parameter{paramIdx}.IsSfcnSizePrm == 1
          len = length(params.Parameter{paramIdx}.Value);
          startIdx = startIdx + len;
        end

        paramIdx  = paramIdx + 1;

      end
    end

  end % addTunableParamInfo

%endfunction rsimgetrtp
