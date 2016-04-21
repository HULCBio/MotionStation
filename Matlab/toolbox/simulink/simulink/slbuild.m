function slbuild(mdl, varargin)
%SLBUILD Invoke the build procedure on a model
%
%   slbuild invokes the Real-Time Workshop build procedure to create either 
%   a standalone executable or a model reference target for a model.
%   The build procedure uses the model's configuration settings.
%
%   slbuild('model') builds a standalone executable for the model.
%
%   slbuild('model','ModelReferenceSimTarget') builds a model reference
%   simulation target for the model.
%
%   slbuild('model','ModelReferenceRTWTarget') builds a model reference
%   RTW target for the model.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $

persistent slBuildIsInUse;

OkayToThrowError         = true;
CalledFromInsideSimulink = false;
errMsg                   = '';

%Initialize buildArgs with default because it is used in the catch below
buildArgs = loc_get_default_build_args;

try

  if nargin < 1
    error('usage: slbuild(''model'', ...)');
  end
  nargs = nargin-1; % length of varargin
  
  %% Detect and report a warning if slbuild called recursively
  if ~isempty(slBuildIsInUse) && slBuildIsInUse
    warning(['Recursive call to slbuild is detected. ', ...
            'This is invalid but may be caused by using dbquit ', ...
             'while in the MATLAB debugger.']);
  end
  slBuildIsInUse = true;
  rtwprivate('rtwinfomatman','','ResetRtwMatInfoFileStructs');

  if nargs > 0
    % second argument has to be target, i.e., top level rtw or model reference
    target = varargin{1};
    if isequal(target, 'StandaloneRTWTarget')
      % Do nothing buildArgs has been initialized to default value
      buildArgsAreKnown = false; %% read other args
    elseif isequal(target, 'ModelReferenceTarget')
      if nargs > 1 && isstruct(varargin{2})
        % if the third argument is a struct, overwrite the initial buildArgs
        % buildArgs
        buildArgs         = varargin{2};
        buildArgsAreKnown = true;
        % ModelrefCleanup: Make sure the structure has all the fields
        if(nargs > 2)
          error('slBuild: Invalid input arguments specified');
        end

      else
        buildArgs.ModelReferenceTargetType      = 'SIM';
        buildArgs.UpdateTopModelReferenceTarget = false;
        buildArgsAreKnown = false; %% read other args
      end
    elseif isequal(target, 'ModelReferenceSimTarget')
      buildArgs.OkayToPushNags                = false;
      buildArgs.ModelReferenceTargetType      = 'SIM';
      buildArgs.UpdateTopModelReferenceTarget = true;
      buildArgsAreKnown = true;
      if(nargs > 1)
        error('slBuild: Invalid input arguments specified');
      end

    elseif isequal(target, 'ModelReferenceRTWTarget')
      buildArgs.OkayToPushNags                = false;
      buildArgs.ModelReferenceTargetType      = 'RTW';
      buildArgs.UpdateTopModelReferenceTarget = true;
      buildArgsAreKnown = true;
      if(nargs > 1)
        error('slBuild: Invalid input arguments specified');
      end
    else
      error(['Invalid second argument to slbuild. Expected one of: ',...
             '''StandaloneRTWTarget'', ''ModelReferenceTarget'', ',...
             '''ModelReferenceSimTarget'', or ''ModelReferenceRTWTarget''',...
             ' but received ''',target,'''']);
    end
  else
    %Use the default build arg
    buildArgsAreKnown = true;
  end

  % cache the default value
  OkayToPushNags = buildArgs.OkayToPushNags;
  
  if ~buildArgsAreKnown
    pvPairsStartIdx = 2;

    % parse parameter name, value pairs
    if nargs > pvPairsStartIdx

      nPairs = nargs - pvPairsStartIdx + 1;
      if (2*floor(nPairs/2) ~= nPairs)
        error(['Invalid usage of slbuild. Property names and values must ',...
               'come in pairs']);
      end
      nPairs = nPairs/2;
      for i=0:(nPairs-1),
        pIdx = pvPairsStartIdx + 2*i;
        nam = varargin{pIdx};
        val = varargin{pIdx+1};

        if isequal(nam, 'StoredChecksum')
          buildArgs.StoredChecksum = val;
          buildArgs.UseChecksum = true;
        end

        if isequal(nam, 'OkayToPushNags')
          OkayToPushNags = val;
          continue;
        end

        if isequal(nam, 'CalledFromInsideSimulink')
          CalledFromInsideSimulink = val;
          continue;
        end

        if isequal(nam, 'OkayToThrowError')
          OkayToThrowError = val;
          continue;
        end

        if ~isequal(buildArgs.ModelReferenceTargetType, 'NONE')
          if isequal(nam, 'ModelReferenceTargetType') && ...
                (isequal(val,'SIM') || isequal(val, 'RTW'))
            buildArgs.ModelReferenceTargetType = val;
            continue;
          end
          if isequal(nam, 'UpdateTopModelReferenceTarget')
            buildArgs.UpdateTopModelReferenceTarget = val;
            continue;
          end
        end

        % invalid parameter name
        error(['Invalid parameter ''', nam, ''' specified']);

      end
    end
  end

  %% ADD CODE HERE AFTER ALL ARGUMENTS HAVE BEEN PARSED
  
  mdlsToClose = {}; % assume

  if ~ischar(mdl),
    % must be a handle to an open model
    if ~ishandle(mdl),
      error('usage: slbuild(''model'')');
    end
    mdl = get_param(mdl,'Name');
  else
    % load the model if it is not loaded
    mdlsToClose = load_model(mdl);
  end

  % check that mdl is a block diagram model
  if ~strcmpi(get_param(mdl,'Type'),'block_diagram')

       error(['The first argument is invalid.  It must be ', ...
              'the name of (or handle to) a block diagram model.']);

  elseif ~strcmpi(get_param(mdl,'BlockDiagramType'),'model')

     error(['The first argument is invalid. ''', mdl, ''' is a ', ...
            'block diagram library. slbuild does not handle block ', ...
            'diagram libraries.']);
  end

  % Once we get the OkayToPushNags value, we need to ClearSimulation if needed
  % so that nags can be pushed in correctly
  buildArgs.OkayToPushNags = OkayToPushNags;
  if buildArgs.OkayToPushNags && ~CalledFromInsideSimulink
    slsfnagctlr('ClearSimulation', get_param(mdl,'Name'));
  end

  % Check if we are in an illegal directory before the build is
  % started.  Otherwise the slprj directory will get created before
  % we error out.
  rtw_checkdir;
  
  % Check slprj version, report an error if an old slprj dir exists
  rtwprivate('modelrefutil','','rtw_checkslprjdir', pwd);

  % Now we know the target type and we can do a license check before proceeding
  loc_check_license(buildArgs.ModelReferenceTargetType,mdl)

  % check that if the simprm dialog has unapplied changes
  commitBuild = slprivate('checkSimPrm', mdl);

  if commitBuild
    % identify the top level model currently being built
    Simulink.BuildInProgress(mdl);
    
    % get the verbosity from the RTW settings
    configset = getActiveConfigSet(mdl);
    if isequal(buildArgs.ModelReferenceTargetType,'SIM')
      buildArgs.Verbose = get_param(configset,'ModelReferenceSimTargetVerbose');
    else
      buildArgs.Verbose = get_param(configset,'RTWVerbose');
    end
    buildArgs.Verbose = isequal(buildArgs.Verbose,'on');

    if isequal(buildArgs.ModelReferenceTargetType,'NONE')
      % build stand alone RTW target for model
      [hadErr, errMsg] = build_standalone_rtw_target(mdl, buildArgs);
    else
      % build model reference target
      [hadErr, errMsg] = update_model_reference_targets(mdl, buildArgs);
    end
    if hadErr && isempty(errMsg)
      error('Fatal error in slbuild');
    end
  end

  close_models(mdlsToClose);

catch
  errMsg = lasterr;
  if buildArgs.OkayToPushNags
    nag = create_nag('Simulink', 'Error', 'Build', errMsg, mdl);
    slsfnagctlr('Naglog', 'push', nag);
  end
end

%% Note: slBuildIsInUse must be reset before any hard error
%% (see the hard error below)
slBuildIsInUse = false;

if ~isempty(errMsg)
  if buildArgs.OkayToPushNags
    if ~CalledFromInsideSimulink
      % assign to a dummy right hand side value to get around an 
      % interpreter issue
      tmpout = slsfnagctlr('ViewSimulation'); 
    end
    % if called from insided simulink, Simulink will
    % deal with bringing up and displaying the nags.
  end
  if OkayToThrowError
    error(errMsg);
  end
else
  % If we did not have any errors clear any info/warning messages that may have
  % been pushed into the nag controller. if we do not clear these here, they
  % will stick around and come up at a later point when any errors are displayed
  % in the nag controller.
  if buildArgs.OkayToPushNags, slsfnagctlr('ClearSimulation'); end
end

%endfunction slbuild


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function buildArgs = loc_get_default_build_args
  buildArgs.OkayToPushNags                = false;
  buildArgs.UpdateTopModelReferenceTarget = false;
  buildArgs.ModelReferenceTargetType      = 'NONE';
  buildArgs.UseChecksum                   = false;
  buildArgs.StoredChecksum                = [];
%endfunction


function  loc_check_license(ModelReferenceTargetType,mdl)

  % This check is not strictly needed because checks are performed in the
  % engine in rtwgen (which is ultimately called by slbuild to generate code)
  % and in sleUpdateModelReferenceTargets (to avoid calling this at all).
  % However, it is nice to error out here because we avoid displaying messages
  % indicating that we're generating code and we do not attempt the out-of-date
  % checking that is done here (which may not work since we're not guaranteed
  % to have the needed files, e.g. the mat file corresponding to the model
  % being referenced)
  %
  % Also the check is nice to have here for calling slbuild directly from
  % the command line
  %
  if ~isequal(ModelReferenceTargetType, 'SIM')
    if(strcmp(get_param(mdl,'SimulationMode'),'accelerator'))
      if(~slproductinstalled('Simulink_Accelerator'))
        error('Unable to check out the Simulink Accelerator license');
      end
    elseif ~slproductinstalled('Real-Time_Workshop')
      % Building model reference RTW target or a vanilla RTW build,
      % check out RTW license
      error(['Unable to check out the Real-Time Workshop license ',...
             'which is required to generate code']);
    end
  end
%endfunction

% eof
