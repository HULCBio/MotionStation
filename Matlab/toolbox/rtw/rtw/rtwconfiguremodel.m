function rtwconfiguremodel(varargin)
% RTWCONFIGUREMODEL - Configure a model for a Real-Time Workshop
% application.  
% 
% args{1}   - Name or handle of the model
% args{2}   - Operating mode
% args{3:N} - optional argument/value list: acceptable arguments
%  
% fxpMode   - 'fixed'   : configure for fixed-point
%             'floating': configure for floating-point
%             'noop'    : don't change relevant fixed/float settings
% forGRT    - true/false: Configure for GRT
% optimized - true/false: optimized or debug
% forDSP    - true/false: requires DSP support (i.e., complex)
%
% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:14:46 $

  % Sanity check
  if nargin < 2
    error(['Require at least two input arguments']);
  end

  model = varargin{1};
  % the first argument must be a valid model
  errmsg1 = 'The first input argument of rtwconfiguremodel must be a valid model';
  if ishandle(model)
    if ~isequal(get_param(model, 'Type'), 'block_diagram') || ...
          ~isequal(get_param(model, 'BlockDiagramType', 'model'))      
      error(errmsg1);
    end
  elseif ischar(model) 
    if isempty(find_system(model, 'type', 'block_diagram')) || ...
          ~isequal(get_param(model, 'BlockDiagramType'), 'model')
      error(errmsg1);
    end
  else
    error(errmsg1);    
  end
  
  % default values for other settings
  fxpMode   = 'noop';
  forGRT    = true;
  optimized = true;
  isDSP     = true;
  nonFiniteOption = false;

  mode = varargin{2};
  switch mode
   case 'ERT (optimized for fixed-point)'
    fxpMode = 'fixed';
    forGRT = false;
    optimized = true;
    
   case 'ERT (optimized for floating-point)'
    fxpMode = 'floating';
    forGRT = false;
    optimized = true;
    
   case 'GRT (optimized for fixed/floating-point)'
    fxpMode = 'noop';
    forGRT = true;
    optimized = true;
    
   case 'GRT (debug for fixed/floating-point)'
    fxpMode = 'noop';
    forGRT = true;
    optimized = false;

   case 'Specified'
    i = 3;
    while i < nargin
      var = varargin{i};
      setting = varargin{i+1};
      if isequal(var, 'fxpMode')
        fxpMode = setting;
      elseif isequal(var, 'forGRT')
        forGRT = setting;
      elseif isequal(var, 'optimized')
        optimized = setting;
      elseif isequal(var, 'forDSP')
        isDSP = setting;
      elseif isequal(var, 'nonFinites')
        nonFiniteOption = true;
        nonFinites = setting;
      end
      i = i + 2;
    end
    
   otherwise
    error(['Internal error: unrecognized configuration mode']);
  end

  % Obtain the active configuration set
  
  cs = getActiveConfigSet(model);
  
  % Select appropriate RTW sysetm target file
  
  if forGRT
    stf = 'grt.tlc';
    tmf = 'grt_default_tmf';
    mc  = 'make_rtw';
  else
    stf = 'ert.tlc';
    tmf = 'ert_default_tmf';
    mc  = 'make_rtw';
  end
      
  % Switch to the appropriate target
  
  switchTarget(cs,stf,[]);
  set_param(cs,'TemplateMakefile',tmf);
  set_param(cs,'MakeCommand',mc);

  isERT = strcmp(get_param(cs,'IsERTTarget'),'on');
  
  % TLC command line options
  
  %set_param(cs,'TLCOptions','-p0');
  
  % Solver options
  
  %set_param(cs,'SolverType','Fixed-step');    % Type
  %set_param(cs,'Solver','FixedStepDiscrete'); % Solver
  %set_param(cs,'SolverMode','Auto');          % Tasking mode for periodic sample times
  %set_param(cs,'AutoInsertRateTranBlk','on'); % Automatically handle data transfers
                                               % between tasks (on Solver page)

  % Optimizations

  if optimized
    set_param(cs,'BlockReduction','on');               % Block reduction optimization
    set_param(cs,'ConditionallyExecuteInputs','on');   % Conditional input branch execution
    set_param(cs,'InlineParams','on');                 % Inline parameters
    set_param(cs,'BooleanDataType','on');              % Implement logic signals a boolean data
    set_param(cs,'OptimizeBlockIOStorage','on');       % Signal storage reuse
    set_param(cs,'LocalBlockOutputs','on');            % Enable local block outputs
    set_param(cs,'BufferReuse','on');                  % Reuse block outputs
    set_param(cs,'ExpressionFolding','on');            % Eliminate superfluous temporary variables
    set_param(cs,'EnforceIntegerDowncast','off');      % Ignore integer downcast in folded
                                                       % expressions (NOTE: inverted logic from UI)
    set_param(cs,'RollThreshold',5);                   % Loop unrolling threshold
    set_param(cs,'InlineInvariantSignals','on');       % Inline invariant signals
                                                       % to 0.0 (NOTE: inverted logic from UI)
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
  else
    set_param(cs,'BlockReduction','off');               % Block reduction optimization
    set_param(cs,'ConditionallyExecuteInputs','off');   % Conditional input branch execution
    set_param(cs,'InlineParams','off');                 % Inline parameters
    set_param(cs,'OptimizeBlockIOStorage','off');       % Signal storage reuse
    set_param(cs,'EnforceIntegerDowncast','on');        % Ignore integer downcast in folded
                                                        % expressions (NOTE: inverted logic from UI)
    set_param(cs,'InlineInvariantSignals','off');       % Inline invariant signals
                                                        % to 0.0 (NOTE: inverted logic from UI)
    set_param(cs,'StateBitsets','off');                 % Use bitsets for storing state configuration
                                                        % (Stateflow)
    set_param(cs,'DataBitsets','off');                  % Use bitsets for storing boolean data
                                                        % (Stateflow)
    set_param(cs,'UseTempVars','off');                  % Minimize array reads using temporary
                                                        % variables (Stateflow)
    set_param(cs,'FoldNonRolledExpr','off');            % Non-UI
    set_param(cs,'ParameterPooling','off');             % Non-UI
  
    if isERT
      set_param(cs,'ZeroExternalMemoryAtStartup','on'); % Remove root level I/O zero initialization
                                                        % (NOTE: inverted logic from UI)
      set_param(cs,'ZeroInternalMemoryAtStartup','on'); % Remove internal state zero initialization
                                                        % (NOTE: inverted logic from UI)
      set_param(cs,'InitFltsAndDblsToZero','on');       % Use memset to initialize floats and double
      set_param(cs,'InlinedParameterPlacement',...      % Parameter structure
                   'Hierarchical');                   
      set_param(cs,'NoFixptDivByZeroProtection','off')
    end
  end

  % Hadware Implementation
  
  %set_param(cs,'ProdHWDeviceType','Specified'); % Device type
  %set_param(cs,'ProdBitPerChar', 8);            % char number of bits
  %set_param(cs,'ProdBitPerShort', 16);          % short number of bits
  %set_param(cs,'ProdBitPerInt', 32);            % int number of bits
  %set_param(cs,'ProdBitPerLong', 32);           % long number of bits
  %set_param(cs,'ProdWordSize', 32);             % Native word size
  %set_param(cs,'ProdIntDivRoundTo', 'Floor');   % Integer division with negative operand
  %                                              % quotient rounds to
  %set_param(cs,'ProdShiftRightIntArith','on');  % Shift right on a signed integer as
  %                                              % arithmetic shift right
  %set_param(cs,'ProdEndianess','LittleEndian'); % Byte ordering
  %set_param(cs,'ProdEqTarget','on');            % None (literally 'None')
  
  % HTML Report
  
  set_param(cs,'GenerateReport','on');             % Generate HTML report
  set_param(cs,'LaunchReport','on');               % Launch report
  if isERT
    set_param(cs,'IncludeHyperlinkInReport','on'); % Include hyperlinks to model
  end
  
  % Comments
  
  set_param(cs,'GenerateComments','on');         % Include comments
  set_param(cs,'SimulinkBlockComments','on');    % Simulink block comments
  set_param(cs,'ShowEliminatedStatement','off'); % Show eliminated statements
  set_param(cs,'ForceParamTrailComments','on');  % Verbose comments for SimulinkGlobal
                                                 % storage class
  if isERT
    set_param(cs,'InsertBlockDesc','on');        % Simulink block descriptions
    set_param(cs,'SimulinkDataObjDesc','on');    % Simulink data object descriptions
    %set_param(cs,'EnableCustomComments','off'); % Custom comments (MPT objects only)
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
  
  %set_param(cs,'GenFloatMathFcnCalls','ISO_C');   % Target floating point math
                                                   % environment (ANSI_C, ISO_C,
                                                   % GNU)
  if isERT
    if strcmp(fxpMode,'fixed')
      set_param(cs,'PurelyIntegerCode','on');      % Floating point numbers (Note: inverted
                                                   % logic from UI)
    elseif strcmp(fxpMode,'floating')
      set_param(cs,'PurelyIntegerCode','off');     % Floating point numbers (Note: inverted
                                                   % logic from UI)
    end
    if nonFiniteOption
      if nonFinites
        set_param(cs,'SupportNonFinite','on');     % Non-finite numbers
      else
        set_param(cs,'SupportNonFinite','off');
      end
    end
    if isDSP
      set_param(cs,'SupportComplex','on');         % Complex numbers
    else
      set_param(cs,'SupportComplex','off');
    end
    %set_param(cs,'SupportAbsoluteTime','off');    % Absolute time
    %set_param(cs,'SupportContinuousTime','off');  % Continuous time
    %set_param(cs,'SupportNonInlinedSFcns','off'); % Non-inlined S-Functions
    %set_param(cs,'LifeSpan','1');                 % Application lifespan (days)
  end

  % Code interface
  
  if isERT
    set_param(cs,'IncludeMdlTerminateFcn','off');        % Terminate function required
    %set_param(cs,'MultiInstanceERTCode','off');         % Generate reusable code
    %set_param(cs,'MultiInstanceErrorCode','Error');     % Reusable code error diagnostic
    %set_param(cs,'RootIOFormat','Structure Reference'); % Pass root-level I/O as
    %set_param(cs,'SuppressErrorStatus','on');           % Supress error status in real-time model
                                                         % data structure
    set_param(cs,'GRTInterface','off');                  % GRT compatible call interface
    set_param(cs,'CombineOutputUpdateFcns','on');        % Single output update
  end
  %set_param(cs,'UtilityFuncGeneration','Auto')          % Utility function generation
  
  % Data exchange
  
  %set_param(cs,'RTWCAPIParams','off');    % Generate C-API for signals
  %set_param(cs,'RTWCAPISignals','off');   % Generate C-API for parameters
  %set_param(cs,'GenerateASAP2','off');    % Generate ASPA2 file
  %set_param(cs,'ExtMode','off');          % Generate External Mode interface

  % Templates

  if isERT
    set_param(cs,'ERTCustomFileTemplate',...
                 'example_file_process.tlc');   % File customization template
    set_param(cs,'GenerateSampleERTMain',...    
                 'on');                         % Generate an example main program
    %set_param(cs,'TargetOS',...                 
    %             'BareBoardExample');          % Target operating system
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

  %if isERT
    %set_param(cs,'GenerateErtSFunction','off');  % Create Simulink (S-Function) block
  %end
  set_param(cs,'MatFileLogging','off');  % MAT-file logging
  set_param(cs,'SaveTime','off');        %   o Time
  set_param(cs,'SaveOutput','off');      %   o States
  set_param(cs,'SaveState','off');       %   o Output
  set_param(cs,'SaveFinalState','off');  %   o File states

  % Build environment
  
  if optimized
    set_param(cs,'RTWVerbose','off');      % Verbose build 
    set_param(cs,'RetainRTWFile','off');   % Delete the .rtw file
    %set_param(cs,'GenCodeOnly','on');     % Generate code only
  else
    set_param(cs,'RTWVerbose','on');       % Verbose build 
    set_param(cs,'RetainRTWFile','on');    % Delete the .rtw file
    %set_param(cs,'GenCodeOnly','on');     % Generate code only
  end
  