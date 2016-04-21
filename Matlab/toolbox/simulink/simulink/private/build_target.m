function varargout = build_target(iSubFcn, varargin)

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.9 $

  [varargout{1:nargout}] = feval(iSubFcn, varargin{1:end});

%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oState = Setup(iMdl)

  oState.mModel = iMdl;
  oState.mMdlsToClose = load_model(iMdl);

  % Ensure that bdroot is set to model
  % (This is needed in case parts of build process use bdroot).
  oState.mCurrentSystem = saveAndSetPrm(0, 'CurrentSystem', iMdl);

  % do not disp backtraces when we get rtwgen errors
  oState.mWarning = [warning; warning('query','backtrace')];
  warning off backtrace;
  warning on;
  
%endfunction


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Cleanup(iState)

  warning(iState.mWarning);
  restorePrm(iState.mCurrentSystem);
  close_models(iState.mMdlsToClose);
  
%endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function RunBuildCmd(iMdl, iBuildArgs)

  if isequal(iBuildArgs.ModelReferenceTargetType,'SIM')
    buildCmdFcn = 'make_rtw';
    buildCmdArgs = '';
  else
      % Resolve any discrepency between system target file and
      % target object itself.
      activeCS = getActiveConfigSet(iMdl);
      csCopy   = copy(activeCS);
      targetComponent = getComponent(csCopy, 'any', 'Target');
      csCopy.switchTarget(get_param(csCopy, 'SystemTargetFile'), []);
      csCopy.assignFrom(activeCS, true);
      targetComponent2 = getComponent(csCopy, 'any', 'Target');
      
      % For class based target, content may be different since not all 
      % properties are exposed through RTWOptions string.  For STFCustomTargetCC, 
      % we have to check the content since this is the only way to verify
      % two targets are of the same type. 
      if ~isequal(class(targetComponent), class(targetComponent2)) | ...
            (isa(targetComponent, 'Simulink.STFCustomTargetCC') & ...
             ~isContentEqual(targetComponent, targetComponent2))
        % switch target and apply the old settings to the new one.
        % xxx (Xiaocang) do we want to issue a warning?
        activeCS.switchTarget(get_param(activeCS, 'SystemTargetFile'), []);
        activeCS.assignFrom(csCopy, true);
        
        % After this step, try to reassign value pairs in the extra options to see
        % if they can be absorbed this time
        activeCS.setRTWOptions(activeCS.ExtraOptions);
      end

    [buildCmdFcn buildCmdArgs] = strtok(get_param(iMdl, 'RTWMakeCommand'));
  end

  % strip leading and trailing white space
  buildCmdArgs = strtrim(buildCmdArgs);

  % Verify build cmd function exists
  if ~any(exist(buildCmdFcn) == [6,2]) %% p,m-function
    beep;
    error(['Unable to locate make command "', ...
           buildCmdFcn, '" on MATLAB path']);
  end

  % Add mdl:name after command if the command starts with 'make_'
  if strncmp(buildCmdFcn,'make_',5)
    buildCmdArgs = ['mdl:' iMdl, ' ', buildCmdArgs];
  end

  Simulink.BuildInProgress(iMdl);
  
  iBuildArgs.mDispHook = {@disp}; % ??? Why do we need this ???
  feval(buildCmdFcn, iBuildArgs, buildCmdArgs);
  
%endfunction
