function rtwsampleconfig(cs)
% RTWSAMPLECONFIG - Configure a model for a Real-Time Workshop
% application.  This is an example file.  You should modify
% the file to suit your need.
%
% The input value is the handle to the configuration set object
% of a model.  Use get_param, set_param to query and change
% individual parameter.
%  
% Use getModel(cs) to get the handle of the host model of the 
% configuration set object.
% 
% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2004/03/21 22:53:45 $

  % Select appropriate RTW sysetm target file
  
  stf = 'ert.tlc';
  tmf = 'ert_default_tmf';
  mc  = 'make_rtw';
      
  % Switch to the appropriate target
  
  switchTarget(cs,stf,[]);
  set_param(cs,'TemplateMakefile',tmf);
  set_param(cs,'MakeCommand',mc);

  isERT = strcmp(get_param(cs,'IsERTTarget'),'on');
  
  % TLC command line options
  
  set_param(cs,'TLCOptions','-p0');
  
  % Solver options
  
  set_param(cs,'SolverType','Fixed-step');      % Type
  set_param(cs,'Solver','FixedStepDiscrete');   % Solver
  if strcmp(get_param(cs, 'SolverType'), 'Fixed-step')
    set_param(cs,'SolverMode','Auto');          % Tasking mode for periodic sample times
    set_param(cs,'AutoInsertRateTranBlk','on'); % Automatically handle data transfers
                                                % between tasks (on Solver page)
  end
  
  % Optimizations
  
  set_param(cs,'BlockReduction','on');               % Block reduction optimization
  set_param(cs,'ConditionallyExecuteInputs','on');   % Conditional input branch execution
  set_param(cs,'InlineParams','on');                 % Inline parameters
  if strcmp(get_param(cs, 'InlineParams'), 'on')
    set_param(cs,'InlineInvariantSignals','on');     % Inline invariant signals
                                                     % to 0.0 (NOTE: inverted logic from UI)
  end
  set_param(cs,'BooleanDataType','on');              % Implement logic signals a boolean data
  set_param(cs,'OptimizeBlockIOStorage','on');       % Signal storage reuse
  if strcmp(get_param(cs, 'OptimizeBlockIOStorage'), 'on')
    set_param(cs,'LocalBlockOutputs','on');          % Enable local block outputs
    set_param(cs,'BufferReuse','on');                % Reuse block outputs
    set_param(cs,'ExpressionFolding','on');          % Eliminate superfluous temporary variables
  end
  set_param(cs,'EnforceIntegerDowncast','off');      % Ignore integer downcast in folded
                                                     % expressions (NOTE: inverted logic from UI)
  set_param(cs,'RollThreshold',5);                   % Loop unrolling threshold
  set_param(cs,'StateBitsets','on');                 % Use bitsets for storing state configuration
                                                     % (Stateflow)
  set_param(cs,'DataBitsets','on');                  % Use bitsets for storing boolean data
                                                     % (Stateflow)
  set_param(cs,'UseTempVars','on');                  % Minimize array reads using temporary
                                                     % variables (Stateflow)
  set_param(cs,'FoldNonRolledExpr','on');            % Non-UI
  set_param(cs,'ParameterPooling','on');             % Non-UI
  
  if isERT
    set_param(cs,'ZeroExternalMemoryAtStartup','off'); % Remove root level I/O zero initialization
                                                       % (NOTE: inverted logic from UI)
    set_param(cs,'ZeroInternalMemoryAtStartup','off'); % Remove internal state zero initialization
                                                       % (NOTE: inverted logic from UI)
    set_param(cs,'InitFltsAndDblsToZero','off');       % Use memset to initialize floats and double
    set_param(cs,'InlinedParameterPlacement',...       % Parameter structure
                 'NonHierarchical');                   
    set_param(cs,'NoFixptDivByZeroProtection','on')
  end

  % Hadware Implementation
  
  set_param(cs,'ProdHWDeviceType','Specified'); % Device type
  set_param(cs,'ProdBitPerChar', 8);            % char number of bits
  set_param(cs,'ProdBitPerShort', 16);          % short number of bits
  set_param(cs,'ProdBitPerInt', 32);            % int number of bits
  set_param(cs,'ProdBitPerLong', 32);           % long number of bits
  set_param(cs,'ProdWordSize', 32);             % Native word size
  set_param(cs,'ProdIntDivRoundTo', 'Floor');   % Integer division with negative operand
                                                % quotient rounds to
  set_param(cs,'ProdShiftRightIntArith','on');  % Shift right on a signed integer as
                                                % arithmetic shift right
  set_param(cs,'ProdEndianess','LittleEndian'); % Byte ordering
  
  % HTML Report
  
  set_param(cs,'GenerateReport','on');               % Generate HTML report
  if strcmp(get_param(cs, 'GenerateReport'), 'on')
    set_param(cs,'LaunchReport','on');               % Launch report
    if isERT
      set_param(cs,'IncludeHyperlinkInReport','on'); % Include hyperlinks to model
    end
  end
  
  % Comments
  
  set_param(cs,'GenerateComments','on');         % Include comments
  if strcmp(get_param(cs, 'GenerateComments'), 'on')
    set_param(cs,'SimulinkBlockComments','on');    % Simulink block comments
    set_param(cs,'ShowEliminatedStatement','off'); % Show eliminated statements
    set_param(cs,'ForceParamTrailComments','on');  % Verbose comments for SimulinkGlobal
                                                   % storage class
    if isERT
      set_param(cs,'InsertBlockDesc','on');        % Simulink block descriptions
      set_param(cs,'SimulinkDataObjDesc','on');    % Simulink data object descriptions
      %set_param(cs,'EnableCustomComments','off'); % Custom comments (MPT objects only)
    end
  end
  
  % Symbols
  
  %set_param(cs,'MaxIdLength',31);                     % Maximum identifier length
  if isERT
    set_param(cs,'MangleLength',1);                    % Minimum mangling length for ids
    set_param(cs,'CustomSymbolStr','$N$M');            % Symbol format
    set_param(cs,'InlinedPrmAccess','Literals');       % Generate scalar inlined paramters as
    set_param(cs,'IgnoreCustomStorageClasses','off');  % Ignore custom storage classes
    %set_param(cs,'DefineNamingRule','None');          % #define naming
    %set_param(cs,'ParamNamingRule','None');           % Parameter naming
    %set_param(cs,'SignalNamingRule','None');          % Signal naming
  end
  
  % Software Environment
  
  set_param(cs,'GenFloatMathFcnCalls','ISO_C');   % Target floating point math
                                                  % environment (ANSI_C, ISO_C,
                                                  % GNU)
  if isERT
    set_param(cs,'PurelyIntegerCode','on');       % Floating point numbers (Note: inverted
                                                  % logic from UI)
    set_param(cs,'SupportAbsoluteTime','off');    % Absolute time
    set_param(cs,'SupportComplex','off');         % Complex numbers
    set_param(cs,'SupportContinuousTime','off');  % Continuous time
    set_param(cs,'SupportNonFinite','off');       % Non-finite numbers
    set_param(cs,'SupportNonInlinedSFcns','off'); % Non-inlined S-Functions
    set_param(cs,'LifeSpan','1');                 % Application lifespan (days)
  end

  % Code interface
  
  if isERT
    set_param(cs,'IncludeMdlTerminateFcn','off');       % Terminate function required
    set_param(cs,'MultiInstanceERTCode','off');         % Generate reusable code
    set_param(cs,'MultiInstanceErrorCode','Error');     % Reusable code error diagnostic
    set_param(cs,'RootIOFormat','Structure Reference'); % Pass root-level I/O as
    set_param(cs,'SuppressErrorStatus','on');           % Supress error status in real-time model
                                                        % data structure
    set_param(cs,'GRTInterface','off');                 % GRT compatible call interface
    set_param(cs,'CombineOutputUpdateFcns','on');       % Single output update
  end

  % Data exchange
  
  set_param(cs,'RTWCAPIParams','off');    % Generate C-API for signals
  set_param(cs,'RTWCAPISignals','off');   % Generate C-API for parameters
  set_param(cs,'GenerateASAP2','off');    % Generate ASPA2 file
  set_param(cs,'ExtMode','off');          % Generate External Mode interface

  % Templates

  if isERT
    set_param(cs,'ERTCustomFileTemplate',...
                 'example_file_process.tlc');   % File customization template
    set_param(cs,'GenerateSampleERTMain',...    
                 'on');                         % Generate an example main program
    set_param(cs,'TargetOS',...                 
                 'BareBoardExample');           % Target operating system
    set_param(cs,'ERTSrcFileBannerTemplate',... 
                 'ert_code_template.cgt');      % Source file (*.c) template (code)
    set_param(cs,'ERTHdrFileBannerTemplate',...
                 'ert_code_template.cgt');      % Source file (*.h) template (code)
    set_param(cs,'ERTDataSrcFileTemplate',...
                 'ert_code_template.cgt');      % Source file (*.c) template (data)
    set_param(cs,'ERTDataHdrFileTemplate',...
                 'ert_code_template.cgt');      % Source file (*.h) template (data)
  end
  
  % Validation

  if isERT
    set_param(cs,'GenerateErtSFunction','off');  % Create Simulink (S-Function) block
  end
  set_param(cs,'MatFileLogging','off');  % MAT-file logging
  set_param(cs,'SaveTime','off');        %   o Time
  set_param(cs,'SaveOutput','off');      %   o States
  set_param(cs,'SaveState','off');       %   o Output
  set_param(cs,'SaveFinalState','off');  %   o File states

  % Build environment
  
  set_param(cs,'RTWVerbose','off');      % Verbose build 
  set_param(cs,'RetainRTWFile','off');   % Delete the .rtw file
  set_param(cs,'GenCodeOnly','on');     % Generate code only
  
  